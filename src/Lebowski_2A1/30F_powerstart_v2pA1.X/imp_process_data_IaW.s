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

	bclr flags1, #new_matrix_data
	
	return
	
;*****************************************************************	
	
.global imp_process_data
imp_process_data:
;--------------------------------------- check if data valid
		
	IPD_return_main	
	
	btss flags1, #new_matrix_data
	bra imp_process_data
	
	bclr flags1, #new_matrix_data
	
;--------------------------------------- build matrix
	mov #matrix, w13
											;1st row
	mov #data_for_matrix+2*iatiapibtib, w12
	mov [w12++], [w13++]
	mov [w12++], [w13++]	
;	mov #0xC000, w0
;	mov w0, [w13++]
;	clr [w13++]	
	add #4, w13
	mov #data_for_matrix+2*wtia, w12
	mov [w12++], [w13++]
	mov [w12++], [w13++]	
	mov #data_for_matrix+2*wtiatib, w12
	mov [w12++], [w13++]
	mov [w12++], [w13++]	
	mov #data_for_matrix+2*iatvapibtvb, w12
	mov [w12++], [w13++]
	mov [w12++], [w13++]
											;2nd row
;	mov #0xC000, w0
;	mov w0, [w13++]
;	clr [w13++]								
	add #4, w13										
	mov #data_for_matrix+2*wtwtiatiapibtib, w12
	mov [w12++], [w13++]
	mov [w12++], [w13++]
	mov #data_for_matrix+2*mwtwtib, w12
	mov [w12++], [w13++]
	mov [w12++], [w13++]
	mov #data_for_matrix+2*wtiatwtia, w12
	mov [w12++], [w13++]
	mov [w12++], [w13++]
	mov #data_for_matrix+2*wtiatvbmwtibtva, w12
	mov [w12++], [w13++]
	mov [w12++], [w13++]
											;3rd row
	mov #data_for_matrix+2*wtia, w12
	mov [w12++], [w13++]
	mov [w12++], [w13++]
	mov #data_for_matrix+2*mwtwtib, w12
	mov [w12++], [w13++]
	mov [w12++], [w13++]
	mov #data_for_matrix+2*wtw, w12
	mov [w12++], [w13++]
	mov [w12++], [w13++]
;	mov #0xC000, w0
;	mov w0, [w13++]
;	clr [w13++]			
	add #4, w13
	mov #data_for_matrix+2*wtva, w12
	mov [w12++], [w13++]
	mov [w12++], [w13++]
											;4th row
	mov #data_for_matrix+2*wtiatib, w12
	mov [w12++], [w13++]
	mov [w12++], [w13++]
	mov #data_for_matrix+2*wtiatwtia, w12
	mov [w12++], [w13++]
	mov [w12++], [w13++]
;	mov #0xC000, w0
;	mov w0, [w13++]
;	clr [w13++]								
	add #4, w13
	mov #data_for_matrix+2*wtiatwtia, w12
	mov [w12++], [w13++]
	mov [w12++], [w13++]
	mov #data_for_matrix+2*wtiatvb, w12
	mov [w12++], [w13++]
	mov [w12++], [w13++]
	
	IPD_return_main	
											;keep copies of w^2Ia^2 and wIaIb, for cancellation of kl later
	mov #matrix+M44, w12
	mov #copy_wwiaia, w13
	reg_copy
	mov #matrix+M14, w12
	mov #copy_wiaib, w13
	reg_copy

;--------------------------------------- eliminate first column
											;determine mult for 3rd row ( - M11/M31 )
	cp0 matrix+M31+2
	bra z, 1f
	mov #matrix+M31, w12
	mov #reg_mult, w13
	reg_copy
	call fp_oneover
	mov #matrix+M11, w12
	call fp_mult
	neg [++w13], [w13--]
	btsc SR, #OV
	com [++w13], [w13--]	 
	
	IPD_return_main		
											;mult all of 3rd row
	mov #reg_mult, w12
	mov #matrix+M32, w13
	call fp_mult
	mov #matrix+M33, w13
	call fp_mult
	mov #matrix+M35, w13
	call fp_mult
											;perform addition
;clr matrix+M31
;clr matrix+M31+2
	mov #matrix+M13, w12									
	mov #matrix+M33, w13
	call fp_add
	
	IPD_return_main	
	
	mov #matrix+M14, w12
	mov #matrix+M34, w13
	reg_copy
	mov #matrix+M15, w12									
	mov #matrix+M35, w13
	call fp_add						
1:											;determine mult for 4th row ( - M11/M41 )
	cp0 matrix+M41+2
	bra z, 1f
	mov #matrix+M41, w12
	mov #reg_mult, w13
	reg_copy
	call fp_oneover
	mov #matrix+M11, w12
	call fp_mult
	neg [++w13], [w13--]
	btsc SR, #OV
	com [++w13], [w13--]	 
	
	IPD_return_main	
											;mult all 
	mov #reg_mult, w12
	mov #matrix+M42, w13
	call fp_mult
	mov #matrix+M44, w13
	call fp_mult
	mov #matrix+M45, w13
	call fp_mult
											;perform addition
;clr matrix+M41
;clr matrix+M41+2
	mov #matrix+M13, w12									
	mov #matrix+M43, w13
	reg_copy
	mov #matrix+M14, w12
	mov #matrix+M44, w13
	call fp_add
	
	IPD_return_main	

	mov #matrix+M15, w12									
	mov #matrix+M45, w13
	call fp_add						
1:
;--------------------------------------- eliminate second column
											;determine mult for 3rd row ( - M22/M32 )
	cp0 matrix+M32+2
	bra z, 1f
	mov #matrix+M32, w12
	mov #reg_mult, w13
	reg_copy
	call fp_oneover
	mov #matrix+M22, w12
	call fp_mult
	neg [++w13], [w13--]		
	btsc SR, #OV
	com [++w13], [w13--]	 
	
	IPD_return_main	
											;mult all of 3rd row
	mov #reg_mult, w12
	mov #matrix+M33, w13
	call fp_mult
	mov #matrix+M34, w13
	call fp_mult
	mov #matrix+M35, w13
	call fp_mult
											;perform addition
;clr matrix+M32
;clr matrix+M32+2
	mov #matrix+M23, w12									
	mov #matrix+M33, w13
	call fp_add	
	
	IPD_return_main	
	
	mov #matrix+M24, w12									
	mov #matrix+M34, w13
	call fp_add			
	mov #matrix+M25, w12									
	mov #matrix+M35, w13
	call fp_add			
1:
											;determine mult for 4th row ( - M22/M42 )
	cp0 matrix+M42+2
	bra z, 1f
	mov #matrix+M42, w12
	mov #reg_mult, w13
	reg_copy
	call fp_oneover
	
	IPD_return_main	

	mov #reg_mult, w13
	mov #matrix+M22, w12
	call fp_mult
	neg [++w13], [w13--]
	btsc SR, #OV
	com [++w13], [w13--]	 
											;mult all of 4th row
	mov #reg_mult, w12
	mov #matrix+M43, w13
	call fp_mult
	mov #matrix+M44, w13
	call fp_mult
	mov #matrix+M45, w13
	call fp_mult
	
	IPD_return_main		
											;perform addition
;clr matrix+M42
;clr matrix+M42+2
	mov #matrix+M23, w12									
	mov #matrix+M43, w13
	call fp_add			
	mov #matrix+M24, w12									
	mov #matrix+M44, w13
	call fp_add			
	mov #matrix+M25, w12									
	mov #matrix+M45, w13
	call fp_add			
1:	
	IPD_return_main															
;--------------------------------------- eliminate third column
											;determine mult for 1st row ( - M33/M13 )
	cp0 matrix+M13+2
	bra z, 1f
	mov #matrix+M13, w12
	mov #reg_mult, w13
	reg_copy
	call fp_oneover
	mov #matrix+M33, w12
	call fp_mult
	neg [++w13], [w13--]	
	btsc SR, #OV
	com [++w13], [w13--]	 
											;mult all of 1st row
	mov #reg_mult, w12
	mov #matrix+M11, w13
	call fp_mult
	
	IPD_return_main	
															
	mov #reg_mult, w12
	mov #matrix+M14, w13
	call fp_mult
	mov #matrix+M15, w13
	call fp_mult	
											;perform addition
;clr matrix+M13
;clr matrix+M13+2
	mov #matrix+M34, w12									
	mov #matrix+M14, w13
	call fp_add			
	mov #matrix+M35, w12									
	mov #matrix+M15, w13
	call fp_add			
1:						
	IPD_return_main																			
											;determine mult for 2nd row ( - M33/M23 )
	cp0 matrix+M23+2
	bra z, 1f
	mov #matrix+M23, w12
	mov #reg_mult, w13
	reg_copy
	call fp_oneover
	mov #matrix+M33, w12
	call fp_mult
	neg [++w13], [w13--]		
	btsc SR, #OV
	com [++w13], [w13--]	 
											;mult all of 2nd row
	mov #reg_mult, w12
	mov #matrix+M22, w13
	call fp_mult
	
	IPD_return_main	
																		
	mov #reg_mult, w12
	mov #matrix+M24, w13
	call fp_mult
	mov #matrix+M25, w13
	call fp_mult							
											;perform addition
;clr matrix+M23
;clr matrix+M23+2
	mov #matrix+M34, w12									
	mov #matrix+M24, w13
	call fp_add			
	mov #matrix+M35, w12									
	mov #matrix+M25, w13
	call fp_add							
1:	
	IPD_return_main																
											;determine mult for 4th row ( - M33/M43 )	
	cp0 matrix+M43+2
	bra z, 1f
	mov #matrix+M43, w12
	mov #reg_mult, w13
	reg_copy
	call fp_oneover
	mov #matrix+M33, w12
	call fp_mult
	neg [++w13], [w13--]										
	btsc SR, #OV
	com [++w13], [w13--]	 
											;mult all of 4th row
	mov #reg_mult, w12
	mov #matrix+M44, w13
	call fp_mult
	
	IPD_return_main	

	mov #reg_mult, w12	
	mov #matrix+M45, w13
	call fp_mult				
											;perform addition
;clr matrix+M43
;clr matrix+M43+2
	mov #matrix+M34, w12									
	mov #matrix+M44, w13
	call fp_add			
	mov #matrix+M35, w12									
	mov #matrix+M45, w13
	call fp_add			
1:
;--------------------------------------- eliminate fourth column
											;determine mult for 1st row ( - M44/M14 )	
	cp0 matrix+M14+2
	bra z, 1f
	
	IPD_return_main		

	mov #matrix+M14, w12
	mov #reg_mult, w13
	reg_copy
	call fp_oneover
	mov #matrix+M44, w12
	call fp_mult
	neg [++w13], [w13--]	
	btsc SR, #OV
	com [++w13], [w13--]	 
											;mult all of 1st row
	mov #reg_mult, w12
	mov #matrix+M11, w13
	call fp_mult
	
	IPD_return_main		

	mov #reg_mult, w12
	mov #matrix+M15, w13
	call fp_mult												
											;perform addition
;clr matrix+M14
;clr matrix+M14+2
	mov #matrix+M45, w12									
	mov #matrix+M15, w13
	call fp_add	
1:	
											;determine mult for 2nd row ( - M44/M24 )	
	cp0 matrix+M24+2
	bra z, 1f
	mov #matrix+M24, w12
	mov #reg_mult, w13
	reg_copy
	call fp_oneover
	
	IPD_return_main		
		
	mov #reg_mult, w13	
	mov #matrix+M44, w12
	call fp_mult
	neg [++w13], [w13--]										
	btsc SR, #OV
	com [++w13], [w13--]	 
											;mult all of 2nd row
	mov #reg_mult, w12
	mov #matrix+M22, w13
	call fp_mult
	mov #matrix+M25, w13
	call fp_mult												
											;perform addition
;clr matrix+M24
;clr matrix+M24+2
	mov #matrix+M45, w12									
	mov #matrix+M25, w13
	call fp_add	
1:
	IPD_return_main				
											;determine mult for 3rd row ( - M44/M34 )	
	cp0 matrix+M34+2
	bra z, 1f
	mov #matrix+M34, w12
	mov #reg_mult, w13
	reg_copy
	call fp_oneover
	mov #matrix+M44, w12
	call fp_mult
	neg [++w13], [w13--]												
	btsc SR, #OV
	com [++w13], [w13--]	 
											;mult all of 3rd row
	mov #reg_mult, w12
	mov #matrix+M33, w13
	call fp_mult
	
	IPD_return_main		
		
	mov #reg_mult, w12
	mov #matrix+M35, w13
	call fp_mult
											;perform addition
;clr matrix+M34
;clr matrix+M34+2
	mov #matrix+M45, w12									
	mov #matrix+M35, w13
	call fp_add	
1:
;--------------------------------------- make unit matrix
											;but ignore all data if div0 !
	cp0 matrix+M11+2
	bra z, imp_process_data		
	mov #matrix+M11, w13
	call fp_oneover
	
	IPD_return_main		
	
	mov #matrix+M15, w13
	mov #matrix+M11, w12
	call fp_mult
	
	cp0 matrix+M22+2
	bra z, imp_process_data		
	mov #matrix+M22, w13
	call fp_oneover
	mov #matrix+M25, w13
	mov #matrix+M22, w12
	call fp_mult
	
	IPD_return_main		
	
	cp0 matrix+M33+2
	bra z, imp_process_data		
	mov #matrix+M33, w13
	call fp_oneover
	mov #matrix+M35, w13
	mov #matrix+M33, w12
	call fp_mult
	
	IPD_return_main		
	
	cp0 matrix+M44+2
	bra z, imp_process_data		
	mov #matrix+M44, w13
	call fp_oneover
	mov #matrix+M45, w13
	mov #matrix+M44, w12
	call fp_mult

	IPD_return_main		
/*
;--------------------------------------- make Kl (or kb) zero in collected data, as we are changing impedance
											;negate Kl, div by 8
	mov #matrix+M45, w12
	neg [++w12], [w12--]
	btsc SR, #OV
	com [++w12], [w12--]
	mov #-3, w0
	add matrix+M45
											;times w^2*Ia^2
	mov #copy_wwiaia, w13
	call fp_mult
											;times wIaIb
	mov #copy_wiaib, w13
	call fp_mult										
											;add -kl*wIaIb to IaVa+IbVb
	mov #copy_wiaib, w12
	mov #data_collected+3*iatvapibtvb, w13
	call fp_add 
	
	IPD_return_main		
											;add -kl*w^2ia^2 to wIaVb and WIaVb-wIbVa
	mov #copy_wwiaia, w12
	mov #data_collected+3*wtiatvbmwtibtva, w13
	call fp_add 
	mov #data_collected+3*wtiatvb, w13
	call fp_add 	
											;reset new data flag as making kl zero must be accounted for before new matrix inversion
;	bclr flags1, #new_matrix_data
	
	IPD_return_main		
*/
;--------------------------------------- determine new impedance based variables

	mov #matrix+M25, w12
	mov #imag_impedance, w13
	reg_copy
	mov #matrix+M15, w12
	mov #real_impedance, w13
	reg_copy
											;Z_ratio = real_impedance / imag_impedance
	mov #imag_impedance, w12
	cp0 imag_impedance+2
	bra z, imp_process_data
	mov #reg_mult, w13
	reg_copy
	call fp_oneover
	mov #real_impedance, w12
	call fp_mult
											
	neg reg_mult, wreg
	mov reg_mult+2, w1
	asr w1, w0, w0
	mov w0, Z_ratio		

	IPD_return_main												
											;motor_filt_coeff = 2*pi * real_impedance / imag_impedance	
	mov #-12, w0
	mov w0, regA
	mov #25736, w0
	mov w0, regA+2
	
	mov #reg_mult, w12
	mov #regA, w13
	call fp_mult
	
	neg regA, wreg
	mov regA+2, w1
	asr w1, w0, w0
	mov w0, motor_filt_coeff	
											;phase_comp_coeff = 2^14 * imag_impedance / real_impedance	
	mov #reg_mult, w13
	cp0 reg_mult+2
	bra z, imp_process_data
	call fp_oneover
	
	mov #-14, w0
	sub w0, [w13], w0
	mov [w13+2], w1
	asr w1, w0, w0
	
	mov w0, phase_comp_coeff
							
	IPD_return_main												
											
;--------------------------------------- show new impedances
											;Kl
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
									;100 * (1e6 / (256000 * 16 * 33349)) = 732u = 24562^-25
	mov #-25, w0
	mov w0, [w12]
	mov #24562, w0
	mov w0, [w12+2]
									;regA = (1e6 / (256000 * 16 * 33349)) * R_sens[8.8] * mlc * Vbat0[12.4] * inv_vbat0
	call fp_mult
	
	mov #matrix+M45, w12
									;regA = (1e6 / (256000 * 16 * 33349)) * imag_impedance * R_sens[8.8] * mlc * Vbat0[12.4] * inv_vbat0
	call fp_mult

	neg regA, wreg
	mov regA+2, w1					
	neg w1, w1						;as M45 was inverted earlier
	asr w1, w0, w0
	mov w0, meas_Kl

	IPD_return_main		
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
									;100 * (1e6 / (256000 * 16 * 33349)) = 732u = 24562^-25
	mov #-25, w0
	mov w0, [w12]
	mov #24562, w0
	mov w0, [w12+2]
									;regA = (1e6 / (256000 * 16 * 33349)) * R_sens[8.8] * mlc * Vbat0[12.4] * inv_vbat0
	call fp_mult
	
	mov #matrix+M25, w12
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
									;100*(1000*1.15*4915)/(16*256000*65536) = 210e-5 = 17616 2^-23
	mov #-23, w0
	mov w0, [w12]
	mov #17616, w0
	mov w0, [w12+2]
									;regA = (1000*1.15*4915)/(16*256000*65536) * R_sens[8.8] * Vbat0[12.4] * inv_vbat0
	call fp_mult
	
	mov #matrix+M15, w12
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
			
reg_mult:		.space 4
copy_wwiaia:	.space 4
copy_wiaib:	.space 4
	


.end

	