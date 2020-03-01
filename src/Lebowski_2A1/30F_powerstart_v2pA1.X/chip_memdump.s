.include "p30F4011.inc"
.include "defines.inc"


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
	
.macro tx_hex
	mov #4, w2
	mov #10, w3
2:
	clr w1
									;rotate top 4 bits into w1
	do #3, 3f
	rlc w0, w0
3:
	rlc w1, w1					
	cpslt w1, w3
	add #('A'-'9'-1), w1
									;add '0'
	add #'0', w1
									;tx character
1:
	btsc U2STA, #9
    bra 1b
    mov w1, U2TXREG	
									;loop through all 4 characters
	dec w2, w2
	bra nz, 2b
.endm
		
	
	
.macro chip_wipe
	clr TBLPAG
	mov #0x0100, w13
9:
;------------------------------ erase page if we're at the beginning of page (W13 = 0bxxxx xxxx xx00 0000)
	mov #0x003F, w0
	and w0, w13, w0
	bra nz, 2f
	erase_page
1:
    btsc NVMCON, #15
    bra 1b
2:
;------------------------------ write 0x37ffff to latch
	mov #0x0037, w0
	tblwth w0,[w13]
	mov #0xffff, w0
	tblwtl w0,[w13]
;------------------------------ write page if we're at the end of page (w13 = 0bxxxx xxxx xx11 1110)
	mov #0xFFC1, w0
	ior w0, w13, w0                         ;all '1' when on boundary
	com w0, w0                              ;flip to all '0' to trigger 'z' flag
	bra nz, 3f
	write_page
1:
    btsc NVMCON, #15
    bra 1b
3:
;------------------------------ update address counter, loop
	inc2 w13, w13
	mov #0x7E00, w0
	cp w0, w13
	bra nz, 9b
;------------------------------ end
.endm	
	
;*****************************************************************
;code in permanent memory
;*****************************************************************	

;on call:
;w4 = 1st 128 byte array
;w5 = 2nd 128 byte array
;w6 = #str_buf	
;w7 = #tbloffset(chip_version)
.section *,code,address (0x7E00)
.global memory_content
memory_content:
	mov w6, w13
									;must have received '! 0x00AA 0x00E4 0x00C5' else wipe
	mov.b [w13+1], w1
	ze w1, w1
	mov #0x00AA, w0
	cp w0, w1
	bra nz, mc_wipe
	
	mov.b [w13+2], w1
	ze w1, w1
	mov #0x00E4, w0
	cp w0, w1
	bra nz, mc_wipe
	
	mov.b [w13+3], w1
	ze w1, w1
	mov #0x00C5, w0
	cp w0, w1
	bra nz, mc_wipe
	
;------------------------------ initialise
mc_cont:
	clr TBLPAG
	mov #0x0100, w13
;------------------------------ loop, print 0x
md_lp:
	mov #'0', w0
	tx_char
	mov #'x', w0
	tx_char
;------------------------------ print data in hex	
									;print bits 23-16
	tblrdh [w13], w0
	tx_hex
									;print bits 15-0
	tblrdl [w13++], w0
	tx_hex
									
;------------------------------ loop end
	mov #'\n',w0
	tx_char
	
	mov #0x7E00, w0
	
	cp w0, w13
	bra nz,md_lp
;------------------------------ end, wipe chip
;------------------------------ All locations: 0x37FFFF, which is
;------------------------------ 1:
;------------------------------	bra 1b
mc_wipe:	
	chip_wipe
	
	mov #'x', w0
	tx_char
	
1:
	bra 1b	
	
.fillupper 0xAA
.fillvalue 0xAA
.fill 0x7FFC-0x7EF2
;.fill 0x0010
		
.end