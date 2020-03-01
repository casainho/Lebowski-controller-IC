.include "p30F4011.inc"
.include "defines.inc"
.include "print_macros.mac"
	
.text
	
;*****************************************************************
;* calculate phase jump coefficients
;*****************************************************************
;
;phase_comp_coeff = 2^14 * 2*pi / motor_filt_coeff   = 2^14 * imag_impedance / real_impedance
;motor_filt_coeff = 2^16 * R/(fs*L)                  = 2*pi * real_impedance / imag_impedance
;
.global calc_impedance_based_coeffs
calc_impedance_based_coeffs:	

;---------------------------------------------- Z_ratio = real_impedance / imag_impedance
	
	mov imag_impedance, w0
	mov w0, regA
	mov imag_impedance+2, w0
	mov w0, regA+2
	
	mov #regA, w13
	cp0 regA+2
	btss SR, #Z
	call fp_oneover
	
	mov #real_impedance, w12
	call fp_mult	
	
	neg regA, wreg
	mov regA+2, w1
	lsr w1, w0, w0
	mov w0, Z_ratio
	
;---------------------------------------------- motor_filt_coeff = 2*pi * real_impedance / imag_impedance	
												;regB = 2*pi
	mov #-12, w0
	mov w0, regB
	mov #25736, w0
	mov w0, regB+2
												;keep regA unchanged, so result to regB
	mov #regB, w13
	mov #regA, w12
	call fp_mult
	
	neg regB, wreg
	mov regB+2, w1
	lsr w1, w0, w0
	
	mov w0, motor_filt_coeff	
	
;---------------------------------------------- phase_comp_coeff = 2^14 * imag_impedance / real_impedance	
	
	mov #regA, w13
	cp0 regA+2
	btss SR, #Z
	call fp_oneover
												;regA = imag_impedance / real_impedance
	mov #-14, w0
	sub w0, [w13], w0
	mov [w13+2], w1
	lsr w1, w0, w0
	
	mov w0, phase_comp_coeff
	
;---------------------------------------------- end
	return

;*****************************************************************
;* reverse determine imag_impedance
;*****************************************************************
;
;V_imag[lsb] = phi_int * I[lsb] * inv_vbat0 * imag_impedance
;imag_impedance = V_imag[lsb] / (phi_int * inv_vbat0 * I[lsb])
;
.global reverse_determine_imag_impedance
reverse_determine_imag_impedance:
	
	mov #imag_impedance, w13
												;ii = phi_int * inv_vbat
	mov phi_int_for_impedance_measurement, w0
	mov inv_vbat0, w1
	mul.uu w0, w1, w2
	fbcl w3, w0
    neg w0, w0
	sl w3, w0, w3
	subr w0, #16, w0
	lsr w2, w0, w2
	ior w2, w3, [++w13]
	mov w0, [--w13]
												;regA = I[lsb]
	mov #regA, w12
	mov i_inductor_measurement, w3
	fbcl w3, w0
	mov w0, [w12++]
	neg w0, w0
	sl w3, w0, w3
	mov w3, [w12--]
												;mult to ii
	call fp_mult
												;invert ii
	call fp_oneover
												;V_imag[lsb] to regA
	mov ampli_imag, w3
	fbcl w3, w0
	mov w0, [w12++]
	neg w0, w0
	sl w3, w0, w3
	mov w3, [w12--]					
												;mult to ii for result
	call fp_mult
	
	return

;*****************************************************************
;* reverse determine real_impedance
;*****************************************************************
;
;V_real[lsb] = I[lsb] * real_impedance * inv_vbat0
;real_impedance = V_real[lsb] / I[lsb] * inv_vbat0
;
.global reverse_determine_real_impedance
reverse_determine_real_impedance:
	
	mov #real_impedance, w13
												;ri = I[lsb] * inv_vbat
	mov i_inductor_measurement, w0
	mov inv_vbat0, w1
	mul.uu w0, w1, w2
	fbcl w3, w0
    neg w0, w0
	sl w3, w0, w3
	subr w0, #16, w0
	lsr w2, w0, w2
	ior w2, w3, [++w13]
	mov w0, [--w13]
												;regA = v_real
	mov #regA, w12
	mov ampli_real, w3
	fbcl w3, w0
	mov w0, [w12++]
	neg w0, w0
	sl w3, w0, w3
	mov w3, [w12--]
												;oneover ri
	call fp_oneover
												;mult with regA
	call fp_mult
	
	return



.end
