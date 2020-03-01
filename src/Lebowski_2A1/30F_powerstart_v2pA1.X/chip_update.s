.include "p30F4011.inc"
.include "defines.inc"
.include "print_macros.mac"

;*****************************************************************
;useful macros
;*****************************************************************
.macro tx_char
1:
	btsc U2STA, #9
    bra 1b
    mov w0, U2TXREG
.endm
	
.macro rx_char
1:
	btss U2STA, #0
    bra 1b
    mov U2RXREG, w0
    and #0xff, w0
.endm	

.macro erase_page	
	mov #0x4041, w0
	mov w0, NVMCON				
	clr NVMADRU
	mov w13, NVMADR
    disi #5					
    mov #0x55, w0
    mov w0, NVMKEY
    mov #0xAA, w0
    mov w0, NVMKEY
    bset NVMCON, #15
    nop
    nop
.endm
	
.macro write_page
	mov #0x4001, w0
	mov w0, NVMCON		
    disi #5					
    mov #0x55, w0
    mov w0, NVMKEY
    mov #0xAA, w0
    mov w0, NVMKEY
    bset NVMCON, #15
    nop
    nop
.endm
	
;*****************************************************************
	
.global pre_update
pre_update:
;------------------------------ print warning	
	print_txt update_warning
									;wait till tx completed
1:
	btss U2STA, #8
	bra 1b
;------------------------------ initialise
									;shut down watchdog timer
	bclr RCON, #5
									;baud rate to 4800
	mov #390, w0
	mov w0, U2BRG
									;erase settings in ROM
	call erase_settings
							
	clr TBLPAG
;------------------------------ check initial characters	
;------------------------------ first wait till we have a '#' character
pu_wait_startchar:
	rx_char
	mov #'#', w1
	cp w0, w1
	bra nz, pu_wait_startchar
;------------------------------ receive first 8 characters, build words for version checking

	mov #str_buf, w13	
	
	do #7, pu_rx_version_lp
	rx_char
pu_rx_version_lp:
	mov.b w0, [w13++]
;------------------------------ check whether one of the versions matches, if not, indicate and freeze.
	mov #tbloffset(chip_version), w7
	tblrdl [w7++], w10
	tblrdl [w7], w11
	
	mov str_buf, w0
	cp w0, w10
	bra nz, pu_check_2nd
	mov str_buf+2, w0
	cp w0, w11
	bra z, pu_version_match
pu_check_2nd:	
	mov str_buf+4, w0
	cp w0, w10
	bra nz, pu_no_match
	mov str_buf+6, w0
	cp w0, w11
	bra z, pu_version_match
pu_no_match:
									;send a 'X' to indicate non-compatible toggle file
	mov #'X', w0
	tx_char
1:
	bra 1b	
;------------------------------ perform update
pu_version_match:	
	
	mov #data_array_sin, w4			;w4: 1st 128 byte array
	mov #data_array_sin+128, w5		;w5: 2nd 128 byte array
	
	goto 0x7E00

update_warning:
.pascii "\n Chip update has been triggered."
.pascii "\n If you do not want to update chip, power down or reset the controller NOW."
.pascii "\n\n For update, switch PC to 4800 baud and upload update file. \n\n\0"		
	
;*****************************************************************
;code in permanent memory
;*****************************************************************	
	
.section *,code,address (0x7E00)
;on call:
;w4 = 1st 128 byte array
;w5 = 2nd 128 byte array
.global update_chip
update_chip:	
	clr TBLPAG
;------------------------------ initialise variables
	mov #0x0000, w13				;w13: memory address of current page
;------------------------------ loop
uc_main_lp:
;------------------------------ read memory page (to 1st 128 byte array)
	mov w13, w11
	mov w4, w10						;w4 = #1st 128 byte array
	do #31, uc_read_rom_lp
	tblrdh [w11], w0
	mov w0, [w10++]
	tblrdl [w11++], w0
uc_read_rom_lp:
	mov w0, [w10++]
;------------------------------ erase memory page w13
	erase_page
;------------------------------ reset 2nd 128 data byte array addressing
	
	mov w5, w11						;w5 = #2nd 128 data byte array
	clr w10							;address offset and bit counter, 1024 bits, 0000 00yy yyyy xxxx with 0000 0000 0yyy yyy0 adress offset)

;------------------------------ receive dummy characters (code <= 57)
	
	mov #58, w1
	rx_char
uc_rx_dummies_lp:
	cpslt w0, w1
	bra uc_rx_charlp
	rx_char
	bra uc_rx_dummies_lp
	
;------------------------------ set or clear toggle bits (data_array_Y+128 array) based on received characters
	
uc_rx_charlp:
									;data (w1) = 122 - rxed
	mov #122, w1
	sub w1, w0, w1
	mov #6, w12						;counter for bits in each rxed character	
uc_rx_lp:
									;determine address offset (w3) and bit (w2)
	mov #0x000F, w3
	and w10, w3, w2
	sub w3, w2, w2
	lsr w10, #3, w3
	bclr w3, #0
									;write toggle bit 
	mov [w11+w3], w0
	rrc w1, w1
	bsw.c w0, w2
	mov w0, [w11+w3]
									;add 7 to data_array_Y+128 addressing, end when 0
	add #7, w10
	mov #0x03FF, w0
	and w10, w0, w10
	bra z, uc_rx_page_end
									;next bit, receive new character if necessary
	dec w12, w12
	bra nz, uc_rx_lp
	rx_char
	bra uc_rx_charlp
	
uc_rx_page_end:	
;------------------------------ receive 3 bytes for extra XOR randomization
	clr w10
									;6 bits from 1st character
	rx_char
	sub #35, w0
	do #5, 1f
	rrc w0, w0
1:
	rlc w10, w10
									;5 bits from 2nd character
	rx_char
	sub #35, w0
	do #4, 1f
	rrc w0, w0
1:
	rlc w10, w10
									;5 bits from 3rd character
	rx_char
	sub #35, w0
	do #4, 1f
	rrc w0, w0
1:
	rlc w10, w10
	
;------------------------------ write XOR (1st, 2nd 128 byte data array) to ROM page
	mov w4, w11						;w4 = #1st 128 byte data array
	mov w5, w12						;w5 = #2nd 128 byte data array

	do #31, uc_xor_lp
	mov [w11++], w0
	xor w0, w10, w0
	xor w0, [w12++], w0
	tblwth w0, [w13]
	mov [w11++], w0
	xor w0, w10, w0
	xor w0, [w12++], w0
uc_xor_lp:
	tblwtl w0, [w13++]
;------------------------------ write memory page (NVMADR still set to old w13, from erase_page)	
	write_page
									;send a '.' to indicate progress
	mov #'.', w0
	tx_char
;------------------------------ loop between w13 = 0x0000 and 0x7E00
	mov #0x7E00, w0
	cp w0, w13
	bra nz, uc_main_lp
;------------------------------ end	
									;send a '*' to indicate update finished
	mov #'*', w0
	tx_char
1:
	bra 1b

.fillupper 0xaa
.fillvalue 0xaa
									;fill to 0x7FFC to prevent other code from landing here
.fill 0x7FFC-0x7EF2
;.fill 0x0010

.end
