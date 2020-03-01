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

;--------------------------------------- only when allowed (when Kv, L and R current, no fieldweakening)
	bclr flags2, #use_emergency_coeffs
	
	btss flags2, #allow_check_phase_loop
	return
	
	cp0 fieldweak
	btss SR, #Z
	return
;--------------------------------------- w10 = Va - Ia*R*invvbat
	mov filter_inv_vbat, w0
	mul real_impedance+2
											;w3:w2 = R*invvbat
    mov filter_I, w0
	mul.us w3, w0, w2
											;w3:w2 = Ia*R*invvbat
	mov real_impedance, w0
	add #32, w0
	bra n, 1f
											;exponent >= 0, shift left 
	sl w3, w0, w3
	subr w0, #16, w0
	lsr w2, w0, w2
	ior w3, w2, w10
	bra 2f
1:
	neg w0, w0
	asr w3, w0, w10
2:
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
											;w5 2^w4 = w * invvbat
	mov phi_int, w1
	mov filter_inv_vbat, w0
	mul.us w0, w1, w4
	fbcl w5, w4
	neg w4, w3
	sl w5, w3, w5
	add #16, w4
											;w11 = -Ib*L * w * invvbat
	mov imag_impedance+2, w0
	mul.us w0, w5, w0
	neg filter_Q, wreg
	mul.ss w0, w1, w2
	
	mov w4, w0
	add #32, w0
	add imag_impedance, wreg
	bra n, 1f
											;exponent >= 0, shift left 
	sl w3, w0, w3
	subr w0, #16, w0
	lsr w2, w0, w2
	ior w3, w2, w11
	bra 2f
1:
	neg w0, w0
	asr w3, w0, w11
2:
											;w12 = Kv * w * invvbat	
	mov Kv+2, w0
	mul.us w0, w5, w2
	add w4, #16, w0
	add Kv, wreg
	bra n, 1f
											;exponent >= 0, shift left 
	sl w3, w0, w3
	subr w0, #16, w0
	lsr w2, w0, w2
	ior w3, w2, w12
	bra 2f
1:
	neg w0, w0
	asr w3, w0, w12
2:
	add w11, w12, w11
	btss SR, #OV
	bra 1f
	mov #0x7FFF, w11
	btsc phi_int, #15
	mov #0x8001, w11
1:	

mov w11, dummy2
;--------------------------------------- which of the 4 cases?
											;prepare the margin to w0
	mov match_KvLR, w0
	asr w10, w0, w0
	
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
;	bclr flags1, #valid_data_imp_meas
											
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
	mov w0, filter_I
								;Ib = 3A
	mov #590, w0
	mov w0, filter_Q
	
	setm filter_inv_vbat
*/	

	
.end
