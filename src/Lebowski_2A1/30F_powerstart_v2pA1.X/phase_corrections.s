.include "p30F4011.inc"
.include "defines.inc"

.text

;*****************************************************************

.global calc_mfa_phase_cor
;
;corrupted variables:
; w0, w1, w2, w3, w4
;
calc_mfa_phase_cor:
;--------------------------------------- phi_mfa_comp = 2^-2 * 2^16 * 2^-14 * mfa_x * I_real[lsb] / (2^12 + | 2^-14 * mfa_x * I_real[lsb] | )	
	mov mfa_x, w0
											;later addition: correct with mfa_x_percentage
	mul mfa_x_percentage
	
	mov filter_w8+4, w1
	mul.us w3, w1, w2
											;w3:w2 = 2^-2 * 2^16 * 2^-14 * mfa_x * wanted_I_real[lsb]
											;w3:w2 = xxUU UUUU UUUU UUUU:UUyy yyyy yyyy yyyy
	sl w3, #2, w1
	lsr w2, #14, w0
	ior w1, w0, w0
											;w0 = 2^-14 * mfa_x * wanted_I_real[lsb]
	btsc w0, #15
	neg w0, w0
	mov #4096, w1
	add w0, w1, w4
											;w4 = 2^12 + | 2^-14 * mfa_x * wanted_I_real[lsb] |
	repeat #17
	div.sd w2, w4
											;w0 = 2^-2 * 2^16 * 2^-14 * mfa_x * I_real[lsb] / (2^12 + | 2^-14 * mfa_x * I_real[lsb] | )
	mov w0, phi_mfa_comp					
;--------------------------------------- end
	return

;*****************************************************************
	
.end
