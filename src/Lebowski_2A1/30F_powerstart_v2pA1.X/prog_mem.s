.include "p30F4011.inc"
.include "defines.inc"
.include "print_macros.mac"

.text

;*****************************************************************

.global restore_from_progmem
restore_from_progmem:
                                            ;initialise read address to start
    mov #tblpage(setup_rom), w0
    mov w0, TBLPAG
    mov #tbloffset(setup_rom), w13
                                            ;read all variables
    mov #tbloffset(read_array_progmem), w14  	
    goto process_all_variables

;*****************************************************************

.global store_in_progmem
store_in_progmem:
                                            ;initialise write address to start
    mov #tblpage(setup_rom), w0
    mov w0, TBLPAG
    mov #tbloffset(setup_rom), w13
                                            ;write all variables
    mov #tbloffset(write_array_progmem), w14
	goto process_all_variables

;*****************************************************************

.global restore_from_ascii
restore_from_ascii:
                                            ;initialise read address to start
    mov #tblpage(setup_rom), w0
    mov w0, TBLPAG
    mov #tbloffset(setup_rom), w13
                                            ;read all variables
    mov #tbloffset(read_array_ascii), w14
    call process_all_variables
                                            ;wait for endchar
    call rx_endchar_232

    return
;*****************************************************************

.global store_in_ascii
store_in_ascii:
											;print version information
	mov #tblpage(version_txt), w0
    mov #tbloffset(version_txt), w1
    call tx_str_232
		
	mov #tbloffset(chip_version), w13
	tblrdl [w13], w0
	ze w0, w0
	call tx_char_232
	tblrdl [w13++], w0
	lsr w0, #8, w0
	call tx_char_232
	tblrdl [w13], w0
	ze w0, w0
	call tx_char_232
	tblrdl [w13], w0
	lsr w0, #8, w0
	call tx_char_232
    mov #'\n', w0
    call tx_char_232	
                                            ;initialise counter for colomn output
    mov #8, w0
    mov w0, counter
                                            ;initialise write address to start
    mov #tblpage(setup_rom), w0
    mov w0, TBLPAG
    mov #tbloffset(setup_rom), w13
                                            ;write all variables
    mov #tbloffset(write_array_ascii), w14
	call process_all_variables
                                            ;write '*' termination character
    mov #'*', w0
    call tx_char_232
    mov #'\n', w0
    call tx_char_232
    mov #'\n', w0
    call tx_char_232

    return
	
version_txt:
	.pascii "version:\0" 

;*****************************************************************

;w0: number of words to be read
;w1: ram address of data to be read
;w13: automatically updated eeprom address counter 

read_array_progmem:

    dec w0, w2
    do w2, rap_do_end
                                            ;read data
    tblrdl [w13++], w0
rap_do_end:                                 ;write to ram
    mov w0, [w1++]

    return
		

;*****************************************************************

;w0: number of words to be written
;w1: ram address of data to be written
;w13: automatically updated eeprom address counter 

write_array_progmem:

    dec w0, w2
    do w2, wap_do_end

;--------------------------------------- erase page if we're at the beginning of page (W13 = 0bxxxx xxxx xx00 0000)

	mov #0x003F, w0
	and w0, w13, w0
	bra nz, wap_after_erase
                                            ;erase page, cannot be sure address is known so NVMADR(U) must be initialised
	mov #0x4041, w0
	mov w0, NVMCON				
	mov #tblpage (setup_rom), w0			
	mov w0, NVMADRU
	mov w13, NVMADR
    disi #5					
    mov #0x55, w0
    mov w0, NVMKEY
    mov #0xAA, w0
    mov w0, NVMKEY
    bset NVMCON, #15
    nop
    nop
wap_erase_wait:
    btsc NVMCON, #15
    bra wap_erase_wait
	
;--------------------------------------- write data to latch
wap_after_erase:

    mov [w1++], w0
    tblwtl w0, [w13]

;--------------------------------------- write page if we're at the end of page (w13 = 0bxxxx xxxx xx11 1110)

	mov #0xFFC1, w0
	ior w0, w13, w0                         ;all '1' when on boundary
	com w0, w0                              ;flip to all '0' to trigger 'z' flag
	bra nz, wap_after_write
                                            ;write page, address already in NVMADR(U) due to preceeding tblwtl operation
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
wap_write_wait:
    btsc NVMCON, #15
    bra wap_write_wait

;--------------------------------------- increment write address to next word location
wap_after_write:

	inc2 w13, w13

;--------------------------------------- next word
    nop
wap_do_end:				
    nop

    return

;*****************************************************************

;w0: number of words to be written
;w13: automatically updated eeprom address counter

write_array_ascii:

    mov w0, w12
    mov w1, w13
waa_lp:
                                            ;write '0x'
    mov #'0', w0
    call tx_char_232
    mov #'x', w0
    call tx_char_232
                                            ;write 4 characters
    mov [w13++], w0
    mov #str_buf, w1
    call word_to_hex_str
    mov #str_buf, w0
    call tx_ram_str_232
                                            ;write tab or EOL based on counter
    dec counter
    bra nz, write_tab
write_EOL:
                                            ;restore counter, write EOL
    mov #8, w0
    mov w0, counter
                                            ;write '\n'
    mov #'\n', w0
    call tx_char_232

    dec w12, w12
    bra nz, waa_lp

    return

write_tab:
                                            ;write '\t'
    mov #'\t', w0
    call tx_char_232

    dec w12, w12
    bra nz, waa_lp

    return

;*****************************************************************
;w0: number of words to be read
;w1: ram address of data to be read

read_array_ascii:
    dec w0, w2
    do w2, raa_do_end
                                            ;read data
    call rx_hex_232
                                            ;write to ram
    mov w0, [w1++]
                                            ;print a '.'
    mov #'.', w0
    call tx_char_232
    nop
raa_do_end:
    nop

    return

;*****************************************************************
;*****************************************************************

.global online_store_in_progmem
online_store_in_progmem:
                                            ;pwm off
    bclr PTCON, #15
											;watchdog timer off
	bclr RCON, #5
											;store chip status
	call store_status
                                            ;all interrupts off just to be sure
    call init_interrupts
;--------------------------------------- calculate rom variables
	call calc_rom_variables_online
;--------------------------------------- write to ROM
    call store_in_progmem
;--------------------------------------- flash LEDs
                                            ;LED's on
    bset LATC, #15
    bset LATC, #13
    bset LATC, #14
    bset LATE, #8
                                            ;wait a bit
    mov #32768, w0
    mov w0, counter
osip:
    btss IFS0, #3
    bra osip
    bclr IFS0, #3

    dec counter
    bra nz, osip
;--------------------------------------- end
                                            ;and reset
    reset

;*****************************************************************
	
.global erase_settings
erase_settings:

;------------------------------ initialise
	clr TBLPAG
	mov #tbloffset(setup_rom), w13
;------------------------------ loop
es_lp:
;------------------------------ erase page if we're at the beginning of page (W13 = 0bxxxx xxxx xx00 0000)
	mov #0x003F, w0
	and w0, w13, w0
	bra nz, es_after_erase
    
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

es_erase_wait:
    btsc NVMCON, #15
    bra es_erase_wait
es_after_erase:
;------------------------------ write 0xffffff to latch
	setm w0
	tblwth w0,[w13]
	tblwtl w0,[w13]
;------------------------------ write page if we're at the end of page (w13 = 0bxxxx xxxx xx11 1110)
	mov #0xFFC1, w0
	ior w0, w13, w0                         ;all '1' when on boundary
	com w0, w0                              ;flip to all '0' to trigger 'z' flag
	bra nz, es_after_write
     
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
	
es_write_wait:
    btsc NVMCON, #15
    bra es_write_wait
es_after_write:
;------------------------------ update address counter, loop
	inc2 w13, w13
	mov #tbloffset(setup_rom)+1024, w0
	cp w0, w13
	bra nz, es_lp
;------------------------------ end
	return

	
;*****************************************************************

 .align 1024								;make sure we stay on the same table page
                                            ;reserve 512 words (we need between 290 / 320 words plus 32 dummies)
											;pre-load with 0xffffff
.global setup_rom
setup_rom:
	.fillupper 0xff
	.fillvalue 0xff
	.space 1024



.end


