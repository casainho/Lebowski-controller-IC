.include "p30F4011.inc"
.include "defines.inc"

.text
	
;*****************************************************************
	
.global hall_control_imag
hall_control_imag:

;-------------------------------------- initialise
    mov #ampli_imag+2, w10	
;-------------------------------------- normal amplitude control
											;based on direction flag
	btss flags2, #direction_imag_loop
	bra hci_add
;-------------------------------------- subtract

hci_subtract:            
                                            ;place w12 at array of negative coeffs, same as for ampli_real
    mov #alic_3+6, w12

    mov [w12++], w1                         ;w1.w2 to be added to ampli_imag (this is the 1st integrator bypass path)
    mov [w12++], w2
                                            ;add to ampli_imag
    add w2, [w10], [w10--]
    addc w1, [w10], w0
                                            ;and don't forget the ampli_imag_prop
    mov [w12], w1
    mov w1, ampli_imag_prop
                                            ;at this point there should be no overflow
    bra ov, hci_overflow

    mov w0, ampli_imag

    return

;-------------------------------------- add
hci_add:
                                            ;place w12 at array of positive coeffs
    mov #alic_3+0, w12

    mov [w12++], w1                         ;w1.w2 to be added to ampli_imag (this is the 1st integrator bypass path)
    mov [w12++], w2
                                            ;add to ampli_imag
    add w2, [w10], [w10--]
    addc w1, [w10], w0
                                            ;and don't forget the ampli_imag_prop
    mov [w12], w1
    mov w1, ampli_imag_prop
                                            ;at this point there should be no overflow
    bra ov, hci_overflow

    mov w0, ampli_imag

    return

;-------------------------------------- process overflow
hci_overflow:
											;since ampli_imag was not updated so far we can use it's sign bit
    mov #0x7FF0, w1
	btsc ampli_imag, #15
    neg w1, w1

;-------------------------------------- process too high or too low
hci_toohigh_toolow:
	
    mov w1, ampli_imag
    clr ampli_imag+2
    clr ampli_imag_prop
	
;-------------------------------------- end
	
    return
	

;*****************************************************************

.global calc_ampli_imag
calc_ampli_imag:

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
	mov #5000, w0
	mov w0, phi_int
								;Ia = 10 A
	mov #1966, w0
	mov #4000, w0
	mov w0, wanted_i_real
								;Ib = 3A
	mov #590, w0
	mov #5900, w0
	mov w0, wanted_i_imag
	mov w0, sine_i_imag
	
	setm filter_inv_vbat
*/															
										
;*****************************************************************
;**** first the inductive part                                ****
;*****************************************************************
	clr ampli_imag_prop
										;final result in w10
	clr w10

;--------------------------------------- wanted_i_real must be > 0, else end with ampli_imag = 0 as we're in regen
	btsc wanted_i_real, #15
										;do not collect data when no inductive part in wanted_ampli_imag
	bclr flags1, #valid_data_imp_meas
	
    btsc wanted_i_real, #15
										;still process resistive part to prevent conk out during fieldweakening
    bra cwai_res
;--------------------------------------- V_inductor[lsb] = phi_int * I[lsb] * imag_impedance * inv_vbat
											;w3 2^w11 2^-16 = imag_impedance * inv_vbat
	mov filter_inv_vbat, w0
	mul imag_impedance+2
	mov imag_impedance, w12
											
	mov wanted_i_real, w0
	btsc flags1, #reverse
	neg w0, w0
	
	fbcl w0, w1
	neg w1, w1
	sl w0, w1, w0
	sub w12, w1, w12
	mov phi_int, w1
	mul.ss w0, w1, w0
	
	mul.us w3, w1, w2
											;convert to integer, generate only quarter output to prevent overflow !!!!!
	add #46, w12							
	bra n, 1f
											;exponent >= 0, shift left 
	sl w3, w12, w3
	subr w12, #16, w12
	lsr w2, w12, w2
	ior w3, w2, w10
	bra 2f
1:
	neg w12, w12
	asr w3, w12, w10
2:
	
;*****************************************************************
;**** add to this the resistive part                          ****
;*****************************************************************
cwai_res:	
											;resistive part to w11
	mov wanted_i_imag, w7
	mov sine_i_imag, w0
	btsc flags_rom, #use_sine_iimag
	add w0, w7, w7
											;V_resistor[lsb] = I[lsb] * real_impedance ( * inv_vbat)
	mov filter_inv_vbat, w0
	mul real_impedance+2
	mov real_impedance, w12
	
	fbcl w7, w1
	neg w1, w1
	sl w7, w1, w7
	sub w12, w1, w12

	mul.us w3, w7, w2
											;convert to integer, generate only quarter output to prevent overflow !!!!!
	add #30, w12							
	bra n, 1f
											;exponent >= 0, shift left 
	sl w3, w12, w3
	subr w12, #16, w12
	lsr w2, w12, w2
	ior w3, w2, w11
	bra 2f
1:
	neg w12, w12
	asr w3, w12, w11
2:


;*****************************************************************
;**** add resistive and inductive parts                       ****
;*****************************************************************	
										;add, check for overflow
	add w10, w11, w0
										;must be lower than 32700/4
	mov #8175, w1
	sub w0, w1, w1
	bra gt, cwai_overflow
										;times 4 as resistive and inductive parts were divided by 4
	add w0, w0, w0
	add w0, w0, w0
	mov w0, ampli_imag

    return	
	
;--------------------------------------- handle overflow by reducting wanted_i_real
cwai_overflow:
										;limit wanted_i_real
										;wanted_i_real *= (w10-w1)/w10
	sub w10, w1, w3
	clr w2
	repeat #17
	div.ud w2, w10
	mov wanted_i_real, w1
	mul.us w0, w1, w2
	mov w3, wanted_i_real
										;clip wanted_ampli_imag
	mov #32700, w0
	mov w0, ampli_imag
	
    return

;*****************************************************************

.end
