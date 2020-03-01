.include "p30F4011.inc"
.include "defines.inc"

.text

;*****************************************************************
;* calculate phi_int at 100 % amplitude
;*****************************************************************

.global calculate_phi_int_100
calculate_phi_int_100:
;---------------------------------------------- phi_int_100 = 2^-16 * inv_vbat0 * phi_int / (ampli_real - I*R)
													;recover phi_int, make positive
	mov filter_spd+4, w1
	btsc w1, #15
	neg w1, w1
	clr w0
													;recover ampli_real-I*R, make positive
	mov filter_general+4, w2
	btsc w2, #15
	neg w2, w2
													;double amplitude as now in [0..1] instead of [-1..1]
	sl w2, w2
	
	repeat #17
	div.ud w0, w2
													;phi_int_max_display = phi_int / (ampli_real - I*R)
	mov w0, phi_int_max_display
	
	return


;*****************************************************************
;* calculate mfa_x
;*****************************************************************

.global calculate_mfa_x
calculate_mfa_x:
;---------------------------------------------- mfa_x = 2^-39 * induct_scale * imag_impedance * phi_int_max_display * inv_vbat0
;---------------------------------------------- induct_scale * inv_vbat0
    mov induct_scale, w0
	mov filter_inv_vbat, w1
	mul.uu w0, w1, w2
													;w3:w2 = induct_scale * inv_vbat0
;---------------------------------------------- phi_int_max_display * induct_scale * inv_vbat0
    mov phi_int_max_display, w0
    mul.uu w2, w0, w4                   			;00:w5:w4 = 0.U.U
    mul.uu w3, w0, w2                   			;w3:w2:00 = V.V.0

    sl w4, w4
    addc w5, w2, w2
    addc w3, #0, w3					
													;w3:w2 = 2^-16 * phi_int_max_display * induct_scale * inv_vbat0
;---------------------------------------------- * imag_impedance
    mov imag_impedance, w0
    mul.uu w2, w0, w4                   			;00:w5:w4 = 0.U.U
    mul.uu w3, w0, w2                   			;w3:w2:00 = V.V.0

    sl w4, w4
    addc w5, w2, w2
    addc w3, #0, w3					
													;w3:w2 = 2^-32 * induct_scale * imag_impedance * phi_int_max_display * inv_vbat0
													;w3:w2 = xxxx xxxx xUUU UUUU : UUUU UUUU Uyyy yyyy
	sl w3, #9, w3
	lsr w2, #7, w2
	ior w3, w2, w3
													;w3 = 2^-39 * induct_scale * imag_impedance * phi_int_max_display * inv_vbat0
	mov w3, mfa_x 
	
	return
		
;*****************************************************************
;* 
;*****************************************************************
.end

