.include "p30F4011.inc"
.include "defines.inc"

.text

;*****************************************************************

;w13: ampli_imag address

.global update_ampli_imag
update_ampli_imag:
	
;--------------------------------------- initialise	
	mov ailic, w0
;--------------------------------------- determine sign	
	mov wanted_ampli_imag, w1
	mov [w13], w2
	
	cpslt w2, w1
	neg w0, w0
;--------------------------------------- perform update
	add w0, [w13], [w13]
;--------------------------------------- prevent overflow, undo add if necessary
	btsc SR, #OV
	subr w0, [w13], [w13]
;--------------------------------------- no impedance data if difference ampli_imag and wanted too large
	mov [w13], w0
	sub wanted_ampli_imag, wreg
	
	btsc w0, #15
	neg w0, w0
    mov #100, w1

    cpslt w0, w1
    bclr flags1, #valid_data_imp_meas
;--------------------------------------- end
	clr ampli_imag_prop
	
	return
	
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

.global calc_wanted_ampli_imag
calc_wanted_ampli_imag:

;--------------------------------------- result to regA
	
	mov #regA, w13
	
	clr regA+2
	mov #-127, w0
	mov w0, regA
	
;*****************************************************************
;**** first the inductive part                                ****
;*****************************************************************

                                        ;V_inductor[lsb] = phi_int * I[lsb] * imag_impedance (* inv_vbat)
;--------------------------------------- perform multiplication
	mov phi_int, w0
	mov filter_I+4, w1

    mul.ss w0, w1, w2
;--------------------------------------- phi_int * filter_I+4 must be > 0, else end with ampli_imag = 0 as we're in regen
	btsc w3, #15
										;do not collect data when no inductive part in wanted_ampli_imag
	bclr flags1, #valid_data_imp_meas
	
    btsc w3, #15
										;still process resistive part to prevent conk out during fieldweakening
    bra cwai_res
;--------------------------------------- convert phi_int * I[lsb] to fp
	fbcl w3, w0
	add w0, #16, [w13++]
	neg w0, w0
	sl w3, w0, w3
	subr w0, #16, w0
	lsr w2, w0, w2
	ior w3, w2, [w13--]
;--------------------------------------- mult with imag_impedance
	mov #imag_impedance, w12
	call fp_mult
	
;*****************************************************************
;**** add to this the resistive part                          ****
;*****************************************************************
cwai_res:
;--------------------------------------- skip if not in field weakening (so when wanted_i_imag = 0)
;	cp0 wanted_i_imag
;	bra z, cwai_to_integer		
										;use sine_i_imag or filter_Q+4, dependent on field weakening
	mov sine_i_imag, w3
	cp0 wanted_i_imag
	btss SR, #Z
	mov filter_Q+4, w3
										;V_resistor[lsb] = I[lsb] * real_impedance ( * inv_vbat)
	mov #regB, w13
										;convert I[lsb] to fp
	fbcl w3, w0
	mov w0, [w13]
	neg w0, w0
	sl w3, w0, w3
	mov w3, [w13+2]
										;mult with real_impedance
	mov #real_impedance, w12
	call fp_mult
										;sum inductive and resistive parts
	mov #regA, w13
	mov #regB, w12
	call fp_add
	
;*****************************************************************
;**** convert to integer                                      ****
;*****************************************************************	
cwai_to_integer:
;--------------------------------------- mult with inv_vbat
	mov filter_inv_vbat, w0
	mul.us w0, [++w13], w2
	fbcl w3, w0
	add #16, w0
	add w0, [--w13], [w13]
	subr w0, #16, w0
	sl w3, w0, w3
	mov w3, [w13+2]
;--------------------------------------- convert to integer, watch out for overflow
	cp0 regA
	bra le, cwai_exp_zero_or_neg
										;positive exponent larger than 0, so overflow
										;Overflow will push the imag. backemf into the negative, this should not
										;be counted as inductance... therefore declare data unvalid for imp measurement.
	bclr flags1, #valid_data_imp_meas
	mov #0x7FF0, w0
	btsc regA+2, #15
	mov #0x8010, w0
	bra cwai_end
										
cwai_exp_zero_or_neg:
										;negative exponent or exponent = 0, no danger of overflow
	neg regA, wreg
	mov regA+2, w3
	asr w3, w0, w0
	
;--------------------------------------- store and end
cwai_end:
	mov w0, wanted_ampli_imag
	
    return

;*****************************************************************

.end
