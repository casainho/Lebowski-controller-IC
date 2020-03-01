.include "p30F4011.inc"
.include "defines.inc"
.include "fp_macros.mac"
.include "print_macros.mac"

.macro IPD_return_main

    mov #6, w0
    add PCL, wreg
    mov w0, imp_process_address
    return

.endm
	
;.macro led_on
;	bset LATD, #2
;.endm
;.macro led_off
;	bclr LATD, #2
;.endm
	
.text

;*****************************************************************	

.global reset_process_imp_data
reset_process_imp_data:
	
	mov #tbloffset(imp_process_data), w0
    mov w0, imp_process_address

	bclr flags1, #new_matrix_data_KR
	bclr flags1, #new_matrix_data_L
	
	return
	
;*****************************************************************	
	
.global imp_process_data
imp_process_data:
;--------------------------------------- check if data valid
		
	bclr flags1, #new_matrix_data_KR
	bclr flags1, #new_matrix_data_L
	
	IPD_return_main	
	
	btsc flags1, #new_matrix_data_L
	bra process_L
	
	btss flags1, #new_matrix_data_KR
	bra imp_process_data
	
;--------------------------------------- calculate regdet = 1/( Ia^2 * w^2 - (w*Ia)^2 )
	
	mov #data_for_imp+2*wtia, w12
	mov #regdet, w13
	reg_copy
	call fp_mult
	neg [++w13], [w13--]
	btsc SR, #OV
	com [++w13], [w13--]
	
	mov #data_for_imp+2*wtw, w12
	mov #regu, w13
	reg_copy
	mov #data_for_imp+2*iatia, w12
	call fp_mult
	
	mov #regu, w12
	mov #regdet, w13
	call fp_add
	
	cp0 regdet+2
	bra z, imp_process_data
	
	IPD_return_main	
	
	mov #regdet, w13	
	call fp_oneover
	
;--------------------------------------- calculate R = ( w^2 * IaY - w*Ia * wY) * regdet
	
	mov #data_for_imp+2*wtia, w12
	mov #regu, w13
	reg_copy
	mov  #data_for_imp+2*ytw, w12
	call fp_mult
	neg [++w13], [w13--]
	btsc SR, #OV
	com [++w13], [w13--]
	
	IPD_return_main	
	
	mov #data_for_imp+2*wtw, w12
	mov #regv, w13
	reg_copy
	mov  #data_for_imp+2*ytia, w12
	call fp_mult
	
	mov #regu, w12
	call fp_add
	
	mov #regdet, w12
	call fp_mult
	
	mov #regv, w12
	mov #real_impedance, w13
	reg_copy
	
	IPD_return_main		
;--------------------------------------- calculate K = ( -w*Ia * IaY + Ia^2 * wY) * regdet
	
	mov #data_for_imp+2*wtia, w12
	mov #regu, w13
	reg_copy
	mov  #data_for_imp+2*ytia, w12
	call fp_mult
	neg [++w13], [w13--]
	btsc SR, #OV
	com [++w13], [w13--]
	
	mov #data_for_imp+2*iatia, w12
	mov #regv, w13
	reg_copy
	mov  #data_for_imp+2*ytw, w12
	call fp_mult
	
	mov #regu, w12
	call fp_add
	
	mov #regdet, w12
	call fp_mult
	
	mov #regv, w12
	mov #Kv, w13
	reg_copy
	
	IPD_return_main		
	
	bra new_impedances
	
	
;--------------------------------------- calculate L
process_L:
	
	cp0 data_for_imp+2*wtwtibtib+2
	bra z, imp_process_data
	
	mov #data_for_imp+2*wtwtibtib, w12
	mov #regu, w13
	reg_copy
	
	call fp_oneover
	
	IPD_return_main
	
	mov #regu, w13
	mov #data_for_imp+2*bty, w12
	call fp_mult
	
	mov #regu, w12
	mov #imag_impedance, w13
	reg_copy
	
	IPD_return_main		
	
;--------------------------------------- determine new impedance based variables
new_impedances:

											;Z_ratio = real_impedance / imag_impedance
	cp0 imag_impedance+2
	bra z, imp_process_data
	mov #imag_impedance, w12
	mov #regu, w13
	reg_copy
	call fp_oneover
	mov #real_impedance, w12
	call fp_mult
											
	neg regu, wreg
	mov regu+2, w1
	asr w1, w0, w0
	mov w0, Z_ratio		

	IPD_return_main												
											;motor_filt_coeff = 2*pi * real_impedance / imag_impedance	
	mov #-12, w0
	mov w0, regA
	mov #25736, w0
	mov w0, regA+2
	
	mov #regu, w12
	mov #regA, w13
	call fp_mult
	
	neg regA, wreg
	mov regA+2, w1
	asr w1, w0, w0
	mov w0, motor_filt_coeff	
											;phase_comp_coeff = 2^14 * imag_impedance / real_impedance	
	mov #regu, w13
	cp0 regu+2
	bra z, imp_process_data
	call fp_oneover
	
	mov #-14, w0
	sub w0, [w13], w0
	mov [w13+2], w1
	asr w1, w0, w0
	
	mov w0, phase_comp_coeff
							
	IPD_return_main												
								
;--------------------------------------- show new impedances

											;imag_impedance
	mov #regA, w13
	mov #regB, w12
	
	lsr inv_vbat0, wreg
	mov w0, [w13+2]
	mov #1, w0
	mov w0, [w13]
	
	lsr vbat0, wreg
	fbcl w0, w3
	inc w3, [w12++]
	neg w3, w3
	sl w0, w3, w0
	mov w0, [w12--]
									;regA = Vbat0[12.4] * inv_vbat0
	call fp_mult
	
	lsr main_loop_count, wreg
	fbcl w0, w3
	inc w3, [w12++]
	neg w3, w3
	sl w0, w3, w0
	mov w0, [w12--]
									;regA = mlc * Vbat0[12.4] * inv_vbat0
	call fp_mult

	lsr transimpedance, wreg
	fbcl w0, w3
	inc w3, [w12++]
	neg w3, w3
	sl w0, w3, w0
	mov w0, [w12--]
									;regA = R_sens[8.8] * mlc * Vbat0[12.4] * inv_vbat0
	call fp_mult
									;10 * (1e6 / (256000 * 16 * 33349)) = 73.2u = 19652^-28
	mov #-28, w0
	mov w0, [w12]
	mov #19652, w0
	mov w0, [w12+2]
									;regA = (1e6 / (256000 * 16 * 33349)) * R_sens[8.8] * mlc * Vbat0[12.4] * inv_vbat0
	call fp_mult
	
	mov #imag_impedance, w12
									;regA = (1e6 / (256000 * 16 * 33349)) * imag_impedance * R_sens[8.8] * mlc * Vbat0[12.4] * inv_vbat0
	call fp_mult

	neg regA, wreg
	mov regA+2, w1
	asr w1, w0, w0
	mov w0, meas_L
	
	IPD_return_main
											;real_impedance
	mov #regA, w13
	mov #regB, w12
	
	lsr inv_vbat0, wreg
	mov w0, [w13+2]
	mov #1, w0
	mov w0, [w13]
	
	lsr vbat0, wreg
	fbcl w0, w3
	inc w3, [w12++]
	neg w3, w3
	sl w0, w3, w0
	mov w0, [w12--]
									;regA = Vbat0[12.4] * inv_vbat0
	call fp_mult
	
	lsr transimpedance, wreg
	fbcl w0, w3
	inc w3, [w12++]
	neg w3, w3
	sl w0, w3, w0
	mov w0, [w12--]
									;regA = R_sens[8.8] * Vbat0[12.4] * inv_vbat0
	call fp_mult
									;10*(1000*1.15*4915)/(16*256000*65536) = 21e-5 = 28261 2^-27
	mov #-27, w0
	mov w0, [w12]
	mov #28261, w0
	mov w0, [w12+2]
									;regA = (1000*1.15*4915)/(16*256000*65536) * R_sens[8.8] * Vbat0[12.4] * inv_vbat0
	call fp_mult
	
	mov #real_impedance, w12
									;regA = (1000*1.15*4915)/(16*256000*65536) * real_impedance * R_sens[8.8] * Vbat0[12.4] * inv_vbat0
	call fp_mult

	neg regA, wreg
	mov regA+2, w1
	asr w1, w0, w0
	mov w0, meas_R
	
;--------------------------------------- loop
	
	bra imp_process_data
;*****************************************************************
	
.bss	

regu:	.space 4
regv:	.space 4
regdet:	.space 4


.end

	