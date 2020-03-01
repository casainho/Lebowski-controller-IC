.include "p30F4011.inc"
.include "defines.inc"
.include "fp_macros.mac"

.text

.global check_phase_loop
;
;when all is well:
; (Va / invvbat) = Kv*w + Ia*R - Ib*w*L
;
;if too much deviation -> force phase loop in correct direction (based on w)
;
check_phase_loop:
;--------------------------------------- only when allowed (when Kv, L and R current)
	bclr flags2, #use_emergency_coeffs
	
	btss flags2, #allow_check_phase_loop
	return
;--------------------------------------- w10 = Va - Ia*R*invvbat
	mov filter_I+4, w0
	mov filter_inv_vbat, w1
	mul.us w1, w0, w2
	signed32_w3w2_to_fp regA
	
	mov #real_impedance, w12
	mov #regA, w13
	mov #16, w0								;not done in signed32_to_fp !
	add w0, [w13], [w13]
	call fp_mult
	
	fp_to_int regA w10
	
	mov ampli_real, w0
	sub w0, w10, w10
	btss SR, #OV
	bra 1f
	mov #0x7FFF, w10
	btsc ampli_real, #15
	mov #0x8001, w10
1:	
mov w10, dummy1	
;--------------------------------------- w11 = (kV - Ib*L) * w * invvbat	
	neg filter_Q+4, wreg
	signed_w0_to_fp regA
	mov #imag_impedance, w12
	mov #regA, w13
	call fp_mult
	mov #Kv, w12
	call fp_add
	
	mov phi_int, w0
	mov filter_inv_vbat, w1
	mul.us w1, w0, w2
	signed32_w3w2_to_fp regB
	
	mov #regB, w12
	mov #16, w0								;not done in signed32_to_fp !
	add w0, [w12], [w12]
	call fp_mult
	
	fp_to_int regA w11
mov w11, dummy2
;--------------------------------------- which of the 4 cases?
											;prepare the margin (0.125 of w10) to w0
	asr w10, #3, w0
	
	btsc flags1, #reverse
	bra cpl_reverse
											;forward
cpl_forward:
	btss flags2, #direction_phase_loop
	bra forward_advance
	return
											;reverse
cpl_reverse:
	btss flags2, #direction_phase_loop
	return
	bra reverse_retard
	
forward_advance:
											;invoke when w11 > 1.125 w10, or w11 - 0.125 * w10 > w10
	sub w11, w0, w11
	cpslt w11, w10
	bra cpl_invoke
	return
/*	
forward_retard:
											;invoke when w11 < 0.875 w10
	sub w10, w0, w10
	cpsgt w11, w10
	bra cpl_invoke
	return
	
reverse_advance:
											;invoke when w11 > 0.875 w10
	sub w10, w0, w10
	cpslt w11, w10
	bra cpl_invoke
	return
*/	
reverse_retard:
											;invoke when w11 < 1.125 w10, or w11 - 0.125 w10 < w10
	sub w11, w0, w11
	cpsgt w11, w10
	bra cpl_invoke
	return
		
;--------------------------------------- invoke emergency coeffs
cpl_invoke:	
	
	bset flags2, #use_emergency_coeffs
											;no data collection
	bclr flags1, #valid_data_imp_meas
											
    return
	
	
	
	
	
/*								
	nop
	nop
	nop
								;Kv, w=1400 at va=0x7FFF
	mov #0xFFE6, w0
	mov w0, Kv
	mov #0x5DFC, w0
	mov w0, Kv+2
								;154 mOhm
	mov #0xFFE1, w0
	mov w0, real_impedance
	mov #0x5826, w0
	mov w0, real_impedance+2
								;145.8 uH
	mov #0xFFD8, w0
	mov w0, imag_impedance
	mov #0x7480, w0
	mov w0, imag_impedance+2
								;w=500 <=> 217 Hz
	mov #500, w0
	mov w0, phi_int
								;Ia = 10 A
	mov #1966, w0
	mov w0, filter_I+4
								;Ib = 3A
	mov #590, w0
	mov w0, filter_Q+4
	
	setm filter_inv_vbat
*/	

	
.end
