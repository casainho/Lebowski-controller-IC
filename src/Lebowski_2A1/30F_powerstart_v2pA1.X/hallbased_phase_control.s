.include "p30F4011.inc"
.include "defines.inc"

.text


.global hall_read_and_pll
hall_read_and_pll:
;--------------------------------------- keep old magphase for speed filtering calculation
											;w1 will be PLL input
	mov phi_motor_magbased, w1
	mov w1, phi_motor_magbased+2		
	
;--------------------------------------- get phase
											;determine hall code (times 2)
	mov #hall_array, w10
	btsc PORTF, #2
    add #8, w10
	btsc PORTF, #3
	add #4, w10
	btsc PORTD, #0
	add #2, w10
                                            
    mov #0xFF00, w0
    and w0, [w10], w0
											;add offset, forward
	btss flags1, #reverse
	add hall_offset, wreg
											;add offset, reverse
	btsc flags1, #reverse
	add hall_offset+2, wreg
;--------------------------------------- continue if use bit on, else keep previous
	
    btss [w10], #0
	bra 1f
											;overwrite pll input with (valid) raw data
	mov w0, w1
	
;--------------------------------------- pmm += 0.25 * (w0-pmm)
	
    subr phi_motor_magbased, wreg
	asr w0, #2, w0
	add phi_motor_magbased
1:	
;--------------------------------------- run pll (used as a phi_int reference during 2->3 transition)
	
	mov #pll_phi, w13
	mov #pll_int, w11
											;phase error signal in w0
	sub w1, [w13], w0
											;w5.w4 = a0*delta_phi = w0.0 * 0.w2
	mov pll_coefs, w2
	mul.su w0, w2, w4
											;mult w5.0 with a1
	mov pll_coefs+2, w2
												;w3.w2 = 0.w2 * w5.0, add to pll_phiint
	mul.su w5, w2, w2
	add w2, [++w11], [w11]
	addc w3, [--w11], [w11]
											;add pll_int to w5.w4 
	add w4, [++w11], w4	
	addc w5, [--w11], w5
											;add w5.w4 to pll_phi
	add w4, [++w13], [w13]
	addc w5, [--w13], [w13]
	
;--------------------------------------- end

	return


;*****************************************************************

.global hall_measure_phase
;
;
; corrupted registers:
; w0, w10
hall_measure_phase:
;--------------------------------------- run 10 times to allow proper filtering and settling
	do #9, hmp_do_lp
	
;--------------------------------------- keep previous phi_magbased
	mov phi_motor_magbased, w0
	mov w0, phi_motor_magbased+2
;--------------------------------------- read hall based phase, store in phi_motor_magbased if valid
                                            ;determine hall code (times 2)
	mov #hall_array, w10
	btsc PORTF, #2
    add #8, w10
	btsc PORTF, #3
	add #4, w10
	btsc PORTD, #0
	add #2, w10
                                            
    mov #0xFF00, w0
    and w0, [w10], w0
											;add offset, forward
	btss flags1, #reverse
	add hall_offset, wreg
											;add offset, reverse
	btsc flags1, #reverse
	add hall_offset+2, wreg	
;--------------------------------------- continue if use bit on, else keep previous
	
    btss [w10], #0
	bra hmp_cont
	
;--------------------------------------- pmm += 0.25 * (w0-pmm)
	
    subr phi_motor_magbased, wreg
	asr w0, #2, w0
	add phi_motor_magbased
hmp_cont:	
	nop
	nop
hmp_do_lp:
	nop
;--------------------------------------- end	
	
	return

;*****************************************************************
	
;checks to see if we are crossing a perfect hall phase angle
;when this happens pll error input is 0, so phase and speed are
;not incremented -> perfect moment for transition.
	
.global pll_error_check
pll_error_check:	
	
;--------------------------------------- find the hall we are closest to
											;counter
	mov #8, w4
											;lowest error
	mov #0x7FFF, w5
											;current hall based location
	mov phi_motor_magbased, w3
	
	mov #hall_array, w10
pec_lp:	
											;only when hall is valid
    btss [w10], #0
	bra pec_lp_end
											;hall phase to w1
	mov #0xFF00, w0
	and w0, [w10], w0
	btss flags1, #reverse
	add hall_offset, wreg
	btsc flags1, #reverse
	add hall_offset+2, wreg	
	mov w0, w1
											;determine difference, keep if lower	
	sub w3, w1, w0
	btsc w0, #15
	neg w0, w0
	
	cp w0, w5
	bra gt, pec_lp_end
											;keep difference in w5, absolute hall phase in w6
	mov w0, w5
	mov w1, w6
	
pec_lp_end:
	inc2 w10, w10
	dec w4, w4
	bra nz, pec_lp
	
;--------------------------------------- are we close enough to this hall to not be jumping from one hall to the next ?
											;closer than 10 degrees ?
	mov #2000, w0
	cp w5, w0
	bra lt, 1f
											;if not, no transition and end
	bclr flags2, #can_transition
	bra pec_end
1:
;--------------------------------------- is the difference between the hall and phi_motor less than one phi_int ? if yes, allow transition
	mov phi_motor, w0
	sub w6, w0, w6
	btsc w6, #15
	neg w6, w6
	
	mov phi_int, w0
	btsc w0, #15
	neg w0, w0
	
	cpslt w6, w0
	bclr flags2, #can_transition
;--------------------------------------- end	
pec_end:
	return	
	

.end
