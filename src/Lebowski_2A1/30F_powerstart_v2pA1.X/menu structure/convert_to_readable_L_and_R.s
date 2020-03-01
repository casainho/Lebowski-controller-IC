.include "p30F4011.inc"
.include "defines.inc"
.include "print_macros.mac"
.include "fp_macros.mac"

.text

;*****************************************************************
;
;L[uH] = 1e6 * L[H] = (1e6 / (256000 * 16 * 33349)) * imag_impedance * R_sens[8.8] * mlc * Vbat0[12.4] * inv_vbat0
;
;w11: address of imag_impedance
;
.global print_readable_L
print_readable_L:
	push w13
	
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
									;(1e6 / (256000 * 16 * 33349)) = 7.32u = 31443^-32
	mov #-32, w0
	mov w0, [w12]
	mov #31443, w0
	mov w0, [w12+2]
									;regA = (1e6 / (256000 * 16 * 33349)) * R_sens[8.8] * mlc * Vbat0[12.4] * inv_vbat0
	call fp_mult
	
	mov w11, w12
									;regA = (1e6 / (256000 * 16 * 33349)) * imag_impedance * R_sens[8.8] * mlc * Vbat0[12.4] * inv_vbat0
	call fp_mult
		
;--------------------------------------- end

    bra print_value

;*****************************************************************
;
;R[mOhm] = (1000*1.15*4915)/(16*256000*65536) * real_impedance * R_sens[8.8] * Vbat0[12.4] * inv_vbat0
;
;w11: address of real_impedance
;
.global print_readable_R
print_readable_R:
	push w13
		
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
									;(1000*1.15*4915)/(16*256000*65536) = 2.1e-5 = 22609^-30	
	mov #-30, w0
	mov w0, [w12]
	mov #22609, w0
	mov w0, [w12+2]
									;regA = (1000*1.15*4915)/(16*256000*65536) * R_sens[8.8] * Vbat0[12.4] * inv_vbat0
	call fp_mult
	
	mov w11, w12
									;regA = (1000*1.15*4915)/(16*256000*65536) * real_impedance * R_sens[8.8] * Vbat0[12.4] * inv_vbat0
	call fp_mult
	
;--------------------------------------- print_value
print_value:
		
	neg regA, wreg
	mov regA+2, w1
	asr w1, w0, w0
	print_sdec
	mov regA, w0
	add #16, w0
	mov regA+2, w1
	sl w1, w0, w0
	print_frac 2
	
;--------------------------------------- end	
	pop w13
	
    return

;*****************************************************************
;
;L[uH] = 1e6 * L[H] = (1e6 / (256000 * 16 * 33349)) * imag_impedance * R_sens[8.8] * mlc * Vbat0[12.4] * inv_vbat0
;
;
.global input_L
input_L:
;--------------------------------------- input number
	
	mov #10, w0
    call get_signed_decimal_number
	
	mov w0, w3
	mov w1, w2
	signed32_w3w2_to_fp imag_impedance
	
;--------------------------------------- imag_impedance = L[uH] / { (1e6/(256000 * 16 * 33349)) * R_sens[8.8] * mlc * Vbat0[12.4] * inv_vbat0 } 
											;(1e6/(256000 * 16 * 33349)) = 7.32e-6 = 31443 ^ -32
	mov #-32, w0
	mov w0, regA
	mov #31443, w0
	mov w0, regA+2
											;regA *= R_sens[8.8]
	unsigned_to_fp transimpedance regB
	
	mov #regA, w13
	mov #regB, w12
	call fp_mult
											;regA *= mlc
	unsigned_to_fp main_loop_count regB
	call fp_mult
											;regA *= Vbat0[12.4]
	unsigned_to_fp vbat0 regB
	call fp_mult
											;regA *= inv_vbat0
	unsigned_to_fp inv_vbat0 regB
	call fp_mult
											;imag_impedance *= 1/regA
	call fp_oneover
	
	mov #imag_impedance, w13
	mov #regA, w12
	call fp_mult

;--------------------------------------- end
	
    return
	
;*****************************************************************
;
;R[mOhm] = (1000*1.15*4915)/(16*256000*65536) * real_impedance * R_sens[8.8] * Vbat0[12.4] * inv_vbat0
;
.global input_R
input_R:
;--------------------------------------- input number
	
	mov #10, w0
    call get_signed_decimal_number
	
	mov w0, w3
	mov w1, w2
	signed32_w3w2_to_fp real_impedance
	
;--------------------------------------- real_impedance = R[mOhm] / { (1000*1.15*4915)/(16*256000*65536) * R_sens[8.8] * Vbat0[12.4] * inv_vbat0 }
											;(1000*1.15*4915)/(16*256000*65536) = 2.1e-5 = 22609^-30	
	mov #-30, w0
	mov w0, regA
	mov #22609, w0
	mov w0, regA+2
											;regA *= R_sens[8.8]
	unsigned_to_fp transimpedance regB
	
	mov #regA, w13
	mov #regB, w12
	call fp_mult
											;regA *= Vbat0[12.4]
	unsigned_to_fp vbat0 regB
	call fp_mult
											;regA *= inv_vbat0
	unsigned_to_fp inv_vbat0 regB
	call fp_mult
											;real_impedance *= 1/regA
	call fp_oneover
	
	mov #real_impedance, w13
	mov #regA, w12
	call fp_mult
	
;--------------------------------------- end
	
    return

.end
