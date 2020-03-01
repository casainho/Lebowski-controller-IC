.include "p30F4011.inc"
.include "defines.inc"
.include "fp_macros.mac"

.macro ICD_return_main

    mov #6, w0
    add PCL, wreg
    mov w0, imp_collect_address
    return

.endm
	
.macro reg_copy
	mov [w12++], [w13++]
	mov [w12--], [w13--]
.endm

.macro led_on
	bset LATD, #2
.endm
.macro led_off
	bclr LATD, #2
.endm
	
.text

;*****************************************************************	

.global reset_collect_imp_data
reset_collect_imp_data:
	
	mov #tbloffset(imp_collect_data), w0
    mov w0, imp_collect_address
											;clr all 11 (* 3) data words
	mov #data_collected, w13
	repeat #32
	clr [w13++]
	
clr dummy1	
	
	return
	
;*****************************************************************	
	
.global imp_collect_data
imp_collect_data:
;--------------------------------------- check if data valid
	
	ICD_return_main	
	
	btss flags1, #valid_data_imp_meas
	bra imp_collect_data
	
;--------------------------------------- capture data and convert to fp
											;1/inv_vbat to reg1
	lsr filter_inv_vbat, wreg
	mov w0, reg1+2
	mov #1, w0
	mov w0, reg1
	
	mov #reg1, w13
	call fp_oneover 
											;V_real to Va, * 1/invvbat
	signed_to_fp ampli_real Va
	mov #Va, w13
	mov #reg1, w12
	call fp_mult
											;V_imag to Vb, * 1/invvbat
	signed_to_fp ampli_imag Vb
	mov #Vb, w13
	mov #reg1, w12
	call fp_mult
											;I_real to Ia
	signed_to_fp filter_I+4 Ia
											;I_imag to Ib
	signed_to_fp filter_Q+4 Ib
											;phi_int to w
	signed32_to_fp phi_int w

	ICD_return_main					
;--------------------------------------- process Ia^2 + Ib^2	
											;reg1 = Ia^2 + Ib^2
	mov #Ia, w12
	mov #reg1, w13
	reg_copy
	call fp_mult
	
	mov #Ib, w12
	mov #reg2, w13
	reg_copy
	call fp_mult

	mov #reg1, w13
	mov #reg2, w12
	call fp_add
	
	ICD_return_main					
											;only use samples with enough current
											;limit for Ia^2+Ib^2 : 1e6
mov #5, w0
mov w0, reg2
mov #-31250, w0
mov w0, reg2+2
mov #reg2, w13
mov #reg1, w12
call fp_add
btsc reg2+2, #15
bra imp_collect_data	
ICD_return_main		
	
											;and filter
	mov #reg1, w12
	mov #data_collected+3*iatiapibtib, w13
	call filter_collected
	
	ICD_return_main		

;--------------------------------------- process w^2
											;reg2 = w^2
	mov #w, w12
	mov #reg2, w13
	reg_copy
	call fp_mult

	mov #reg2, w12
	mov #data_collected+3*wtw, w13
	call filter_collected

	ICD_return_main		
;--------------------------------------- process w^2 * (Ia^2 + Ib^2)
											;reg1 = w^2 * (Ia^2 + Ib^2)
	mov #reg1, w13
	mov #reg2, w12
	call fp_mult
	
	mov #reg1, w12
	mov #data_collected+3*wtwtiatiapibtib, w13
	call filter_collected
	
	ICD_return_main		
;--------------------------------------- process -w^2 * Ib

	mov #reg2, w13
	neg [++w13], [w13--]
	mov #Ib, w12
	call fp_mult
	
	mov #reg2, w12
	mov #data_collected+3*mwtwtib, w13
	call filter_collected

	ICD_return_main			
;--------------------------------------- process w * Ia
											;reg1 = w * Ia
	mov #reg1, w13
	mov #w, w12
	reg_copy
	mov #Ia, w12
	call fp_mult
	
	mov #reg1, w12
	mov #data_collected+3*wtia, w13
	call filter_collected

	ICD_return_main	
;--------------------------------------- process w * Ia * Ib
											;reg1 = w * Ia
	mov #reg2, w13
	mov #Ib, w12
	reg_copy
	mov #reg1, w12
	call fp_mult
	
	mov #reg2, w12
	mov #data_collected+3*wtiatib, w13
	call filter_collected

	ICD_return_main		
;--------------------------------------- process w * Ia * Vb
											;reg1 = w * Ia
	mov #reg2, w13
	mov #Vb, w12
	reg_copy
	mov #reg1, w12
	call fp_mult
	
	mov #reg2, w12
	mov #data_collected+3*wtiatvb, w13
	call filter_collected

	ICD_return_main	
;--------------------------------------- process (w * Ia)^2
											;reg1 = w * Ia
	mov #reg2, w13
	mov #reg1, w12
	reg_copy
	call fp_mult
	
	mov #reg2, w12
	mov #data_collected+3*wtiatwtia, w13
	call filter_collected

	ICD_return_main	
;--------------------------------------- process w * Va
											;reg1 = w * Va
	mov #reg1, w13
	mov #w, w12
	reg_copy
	mov #Va, w12
	call fp_mult
	
	mov #reg1, w12
	mov #data_collected+3*wtva, w13
	call filter_collected

	ICD_return_main	
;--------------------------------------- process -w * Ib * Va
											;reg1 = w * Va
	mov #reg1, w13
	neg [++w13], [w13--]
	mov #Ib, w12
	call fp_mult
	
	mov #reg1, w12
	mov #data_collected+3*mwtibtva, w13
	call filter_collected

	ICD_return_main	
;--------------------------------------- process Ia*Va + Ib*Vb

	mov #reg1, w13
	mov #Ia, w12
	reg_copy
	mov #Va, w12
	call fp_mult
	
	mov #reg2, w13
	mov #Ib, w12
	reg_copy
	mov #Vb, w12
	call fp_mult
	
	mov #reg1, w13
	mov #reg2, w12
	call fp_add

	ICD_return_main	
	
	mov #reg1, w12
	mov #data_collected+3*iatvapibtvb, w13
	call filter_collected

	ICD_return_main	
;--------------------------------------- write a copy of output data

	mov #data_collected, w12
	mov #data_for_matrix, w13
	
	do #10, 1f
	mov [w12++], [w13++]
	mov [w12++], [w13++]
1:
	inc2 w12, w12
	
	mov #data_for_matrix+2*wtiatvb, w12
	mov #data_for_matrix+2*mwtibtva, w13
	call fp_add
	
	bset flags1, #new_matrix_data
inc dummy1
;--------------------------------------- loop
	bra imp_collect_data
	
;*****************************************************************
filter_collected:
;--------------------------------------- determine difference
											;difference to reg2
	mov #reg_filt, w11
	mov [w13++], [w11++]
	neg [w13--], [w11--]
	exch w11, w13
	call fp_add
	exch w11, w13
;--------------------------------------- mult with filter coefficient (exponent only)   
	mov #12, w0
	subr w0, [w11], [w11]
;--------------------------------------- add to integrator			
											;which exponent is bigger ?
	mov [w13], w10
    sub w10, [w11], w0
    bra ge, 1f
											;w11_e > w13_e
											;build the two 32 bit words
	mov [w11], w10
	sub w10, [w13], w0
	
	mov [w13+2], w1
	mov [w13+4], w2
	
	asr w1, w0, w3
	lsr w2, w0, w2
	subr w0, #16, w0
	sl w1, w0, w1
	ior w2, w1, w2

	add w3, [++w11], w3
	bra fc_cont
1:	
											;w13_e >= w11_e
											;build the two 32 bit words
	mov [w11+2], w2
											;w13_e >= w11_e, if larger by more than 31, skip alltogether, 
	cp w0, #31
	bra ge, fc_end
	cp w0, #16
	bra lt, fc_small_shift
fc_big_shift:								;shift of 16 bits or more
	asr w2, #15, w3
	sub w0, #16, w0
	asr w2, w0, w2
	bra fc_add
	
fc_small_shift:							;shift of less than 16 bits
	asr w2, w0, w3
	subr w0, #16, w0
	sl w2, w0, w2
	
fc_add:
	mov [w13+2], w1
	mov [w13+4], w0
											;add
	add w0, w2, w2
	addc w1, w3, w3
fc_cont:
											;deal with possible overflow
	bra nov, 1f
	rrc w3, w3
	rrc w2, w2
	inc w10, w10
1:	
											;calculate exponent, shift mantissa
	fbcl w3, w0
    neg w0, w0
	sub w10, w0, w10
	
	sl w3, w0, w3
	sl w2, w0, w1
	subr w0, #16, w0
	lsr w2, w0, w2
	ior w3, w2, w3
											;store
	mov w1, [w13+4]
	mov w3, [w13+2]
	mov w10, [w13]
;--------------------------------------- end
fc_end:
	
nop
nop
nop
	
	return
;*****************************************************************
	
.bss
	
w:		.space 4
Va:		.space 4
Vb:		.space 4
Ia:		.space 4
Ib:		.space 4
			
reg1:	.space 4
reg2:	.space 4
reg_filt:	.space 4
	


.end

	