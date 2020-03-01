.include "p30F4011.inc"
.include "defines.inc"
.include "print_macros.mac"

.text

;*****************************************************************

.global fp_main
fp_main:

	nop
	nop
	nop
	
	mov #-8, w0
	mov w0, regA
	mov #20529, w0
	mov w0, regA+2
	
	mov #-10, w0
	mov w0, regB
	mov #-22008, w0
	mov w0, regB+2
	
	mov #regA, w12
	mov #regB, w13
	call fp_add
	
	print_txt eq
	print_fp regB
	
	mov #-8, w0
	mov w0, regA
	mov #20529, w0
	mov w0, regA+2
	
	mov #-10, w0
	mov w0, regB
	mov #-22008, w0
	mov w0, regB+2
	
	mov #regB, w12
	mov #regA, w13
	call fp_add
	
	print_tab
	print_fp regA
	
	nop
	nop
	nop
	
hangloop:
	bra hangloop
	
	
eq:	
.pascii "A = 80.1914\n" 
.pascii "B = -21.4922\n" 
.pascii "A+B, B+A= \0"
	
.bss
regA:	.space 2*fp_N
regB:	.space 2*fp_N
	
	
