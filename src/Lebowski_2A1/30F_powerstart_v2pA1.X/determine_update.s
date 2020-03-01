.include "p30F4011.inc"
.include "defines.inc"

.text

;*****************************************************************

.global determine_update_direction
determine_update_direction:
;--------------------------------------- calculate Real part delta current (to w8)
	mov wanted_i_real, w1
                                            ;negate when wanted_i_real > 0 and reverse = 1
                                            ;negate when wanted_i_real < 0 and phi_int < 0
    btsc wanted_i_real, #15
    bra wir_is_neg
wir_is_pos:
    btsc flags1, #reverse
    neg w1, w1
    bra dud_cont
wir_is_neg:	
	btsc phi_int, #15
	neg w1, w1
											;i_delta_real = corrected(wanted_i_real) - w8
dud_cont:
	sub w1, w8, w8
;--------------------------------------- calculate Imag part delta current (to w9) 
	mov wanted_i_imag, w0
	add sine_i_imag, wreg
	sub w0, w9, w9
;--------------------------------------- maximize w8, w9 content
											;no 0! so set LSB to force small value
	bset w8, #0
	bset w9, #0
											;find negative value how many bit can be shifted
	fbcl w8, w1
	fbcl w9, w2
											;find highest and negate into w0
	neg w1, w0
	cpslt w2, w1
	neg w2, w0
	
	sl w8, w0, w8
	sl w9, w0, w9
;--------------------------------------- rotate over phi_offset for smooth hall23 transition
	cp0 phi_offset
	bra z, 1f
	
	mov phi_offset, w0
    lsr w0, #7, w13
    bclr w13, #0
    bset w13, #11
	
	mov [w13], w7
	add #128, w13
    bclr w13, #9
	mov [w13], w6
											;rotate w8+jw9 over w6+jw7 (adds phase together)
											;w8_new = w8 * w6 - w9 * w7
											;w9_new = w9 * w6 + w8 * w7
	mul.ss 	w8, w6, w0
	mul.ss w9, w7, w2
	sub w1, w3, w2
	mul.ss w9, w6, w0
	mul.ss w8, w7, w8
	add w9, w1, w9
	mov w2, w8	
1:
;--------------------------------------- rotate over impedance
											;w7 = Z_imag = phi_int
	mov phi_int, w7
											;w6 = Z_real = Z_ratio
	mov Z_ratio, w6
											;maximize w6 and w7
	bset w6, #0
	bset w7, #0
	fbcl w6, w1
	fbcl w7, w2
	neg w1, w0
	cpslt w2, w1
	neg w2, w0
	sl w6, w0, w6
	sl w7, w0, w7	
											;rotate w8+jw9 over w6+jw7 (adds phase together)
											;w8_new = w8 * w6 - w9 * w7
											;w9_new = w9 * w6 + w8 * w7
	mul.ss 	w8, w6, w0
	mul.ss w9, w7, w2
	sub w1, w3, w2
	mul.ss w9, w6, w0
	mul.ss w8, w7, w8
	add w9, w1, w9
	mov w2, w8										

;--------------------------------------- determine direction_ampli_loop bit
	bclr flags2, #direction_ampli_loop
	btsc w8, #15
	bset flags2, #direction_ampli_loop
;--------------------------------------- rotate over - angle (ampli_real, ampli_imag) vector
/*
	mov ampli_real, w6
	mov ampli_imag, w7
											;negate angle
	neg w7, w7								
											;maximize content
	bset w6, #0
	bset w7, #0
	fbcl w6, w1
	fbcl w7, w2
	neg w1, w0
	cpslt w2, w1
	neg w2, w0
	sl w6, w0, w6
	sl w7, w0, w7
											;rotate w8+jw9 over w6+jw7 (adds phase together)
											;w9_new = w9 * w6 + w8 * w7
	mul.ss w9, w6, w0
	mul.ss w8, w7, w8
	add w9, w1, w9
*/			
	
												;change sign w9 based on phi_int as done in older versions
	btsc phi_int, #15			
	neg w9, w9
;--------------------------------------- determine direction_phase_loop bit
	bclr flags2, #direction_phase_loop
	btsc w9, #15
	bset flags2, #direction_phase_loop
;--------------------------------------- make sure phase is good
											;for safety: override when Ar*phi_i < 0 such that |phi| reduces
	mov ampli_real, w0
	mov phi_int, w1
	mul.ss w0, w1, w0
	btss w1, #15
	bra 1f
	
	bclr flags2, #direction_ampli_loop
	btss ampli_real, #15
	bset flags2, #direction_ampli_loop
	
	bclr flags2, #direction_phase_loop
	btss phi_int, #15
	bset flags2, #direction_phase_loop
1:

;--------------------------------------- end
	
    return
;*****************************************************************
/*	
.global determine_update_clipping
;
; during clipping the ampli control directly depends on the real error current
; as there is no control over this variable it only serves to maintain clipping
; or to regulate the fieldweakening
;
; for the phase update the real part of the error current is declared 0
;
determine_update_clipping:
;--------------------------------------- calculate Real part delta current (to w8)
	mov wanted_i_real, w1
                                            ;negate when wanted_i_real > 0 and reverse = 1
                                            ;negate when wanted_i_real < 0 and phi_int < 0
    btsc wanted_i_real, #15
    bra wir_is_neg_clip
wir_is_pos_clip:
    btsc flags1, #reverse
    neg w1, w1
    bra dud_cont_clip
wir_is_neg_clip:	
	btsc phi_int, #15
	neg w1, w1
											;i_delta_real = corrected(wanted_i_real) - w8
dud_cont_clip:
	sub w1, w8, w8
;--------------------------------------- calculate Imag part delta current (to w9) 
	mov wanted_i_imag, w0
	add sine_i_imag, wreg
	sub w0, w9, w9
;--------------------------------------- maximize w8, w9 content
											;no 0! so set LSB to force small value
	bset w8, #0
	bset w9, #0
											;find negative value how many bit can be shifted
	fbcl w8, w1
	fbcl w9, w2
											;find highest and negate into w0
	neg w1, w0
	cpslt w2, w1
	neg w2, w0
	
	sl w8, w0, w8
	sl w9, w0, w9
;--------------------------------------- rotate over phi_offset for smooth hall23 transition
	cp0 phi_offset
	bra z, 1f
	
	mov phi_offset, w0
    lsr w0, #7, w13
    bclr w13, #0
    bset w13, #11
	
	mov [w13], w7
	add #128, w13
    bclr w13, #9
	mov [w13], w6
											;rotate w8+jw9 over w6+jw7 (adds phase together)
											;w8_new = w8 * w6 - w9 * w7
											;w9_new = w9 * w6 + w8 * w7
	mul.ss 	w8, w6, w0
	mul.ss w9, w7, w2
	sub w1, w3, w2
	mul.ss w9, w6, w0
	mul.ss w8, w7, w8
	add w9, w1, w9
	mov w2, w8	
1:	
;--------------------------------------- determine direction_ampli_loop bit
	bclr flags2, #direction_ampli_loop
	btsc w8, #15
	bset flags2, #direction_ampli_loop
;--------------------------------------- now declare real part 0
	clr w8
;--------------------------------------- rotate over impedance
											;w7 = Z_imag = phi_int
	mov phi_int, w7
											;w6 = Z_real = Z_ratio
	mov Z_ratio, w6
											;maximize w6 and w7
	bset w6, #0
	bset w7, #0
	fbcl w6, w1
	fbcl w7, w2
	neg w1, w0
	cpslt w2, w1
	neg w2, w0
	sl w6, w0, w6
	sl w7, w0, w7	
											;rotate w8+jw9 over w6+jw7 (adds phase together)
											;w8_new = w8 * w6 - w9 * w7
											;w9_new = w9 * w6 + w8 * w7
	mul.ss 	w8, w6, w0
	mul.ss w9, w7, w2
	sub w1, w3, w2
	mul.ss w9, w6, w0
	mul.ss w8, w7, w8
	add w9, w1, w9
	mov w2, w8						

;--------------------------------------- rotate over - angle (ampli_real, ampli_imag) vector		
												;change sign w9 based on phi_int as done in older versions
	btsc phi_int, #15			
	neg w9, w9
;--------------------------------------- determine direction_phase_loop bit
	bclr flags2, #direction_phase_loop
	btsc w9, #15
	bset flags2, #direction_phase_loop
;--------------------------------------- make sure phase is good
											;for safety: override when Ar*phi_i < 0 such that |phi| reduces
	mov ampli_real, w0
	mov phi_int, w1
	mul.ss w0, w1, w0
	btss w1, #15
	bra 1f
	
	bclr flags2, #direction_ampli_loop
	btss ampli_real, #15
	bset flags2, #direction_ampli_loop
	
	bclr flags2, #direction_phase_loop
	btss phi_int, #15
	bset flags2, #direction_phase_loop
1:	
;--------------------------------------- end
	
    return
*/	
;*****************************************************************
	
.global determine_update_direction_dr2hl
determine_update_direction_dr2hl:
;--------------------------------------- calculate Real part delta current (to w8)
	mov wanted_i_real, w1
                                            ;negate when wanted_i_real > 0 and reverse = 1
                                            ;negate when wanted_i_real < 0 and phi_int < 0
    btsc wanted_i_real, #15
    bra wir_is_neg_2hl
wir_is_pos_2hl:
    btsc flags1, #reverse
    neg w1, w1
    bra dud_cont_2hl
wir_is_neg_2hl:	
	btsc phi_int, #15
	neg w1, w1
											;i_delta_real = corrected(wanted_i_real) - w8
dud_cont_2hl:
	sub w1, w8, w8
;--------------------------------------- calculate Imag part delta current (to w9) 
	mov wanted_i_imag, w0
	add sine_i_imag, wreg
	sub w0, w9, w9
;--------------------------------------- maximize w8, w9 content
											;no 0! so set LSB to force small value
	bset w8, #0
	bset w9, #0
											;find negative value how many bit can be shifted
	fbcl w8, w1
	fbcl w9, w2
											;find highest and negate into w0
	neg w1, w0
	cpslt w2, w1
	neg w2, w0
	
	sl w8, w0, w8
	sl w9, w0, w9
	
;--------------------------------------- rotate over impedance
											;w7 = Z_imag = phi_int
	mov phi_int, w7
											;w6 = Z_real = Z_ratio
	mov Z_ratio, w6
											;maximize w6 and w7
	bset w6, #0
	bset w7, #0
	fbcl w6, w1
	fbcl w7, w2
	neg w1, w0
	cpslt w2, w1
	neg w2, w0
	sl w6, w0, w6
	sl w7, w0, w7	
											;rotate w8+jw9 over w6+jw7 (adds phase together)
											;w8_new = w8 * w6 - w9 * w7
											;w9_new = w9 * w6 + w8 * w7
	mul.ss 	w8, w6, w0
	mul.ss w9, w7, w2
	sub w1, w3, w2
	mul.ss w9, w6, w0
	mul.ss w8, w7, w8
	add w9, w1, w9
	mov w2, w8										
;--------------------------------------- determine direction_ampli_loop bit
	bclr flags2, #direction_ampli_loop
	btsc w8, #15
	bset flags2, #direction_ampli_loop
;--------------------------------------- determine direction_imag_loop bit
	bclr flags2, #direction_imag_loop
	btsc w9, #15
	bset flags2, #direction_imag_loop
;--------------------------------------- end
    return
;*****************************************************************
/*	
.global determine_update_clipping_dr2hl
determine_update_clipping_dr2hl:
;--------------------------------------- calculate Real part delta current (to w8)
	mov wanted_i_real, w1
                                            ;negate when wanted_i_real > 0 and reverse = 1
                                            ;negate when wanted_i_real < 0 and phi_int < 0
    btsc wanted_i_real, #15
    bra wir_is_neg_2hl_cl
wir_is_pos_2hl_cl:
    btsc flags1, #reverse
    neg w1, w1
    bra dud_cont_2hl_cl
wir_is_neg_2hl_cl:	
	btsc phi_int, #15
	neg w1, w1
											;i_delta_real = corrected(wanted_i_real) - w8
dud_cont_2hl_cl:
	sub w1, w8, w8
;--------------------------------------- calculate Imag part delta current (to w9) 
	mov wanted_i_imag, w0
	add sine_i_imag, wreg
	sub w0, w9, w9
;--------------------------------------- determine direction_ampli_loop bit
	bclr flags2, #direction_ampli_loop
	btsc w8, #15
	bset flags2, #direction_ampli_loop
;--------------------------------------- determine direction_imag_loop bit
	bclr flags2, #direction_imag_loop
	btsc w9, #15
	bset flags2, #direction_imag_loop
;--------------------------------------- end
	
    return
*/	
;*****************************************************************
	
.global determine_update_direction_dr2sl
determine_update_direction_dr2sl:
;--------------------------------------- calculate Real part delta current (to w8)
	mov wanted_i_real, w1
                                            ;negate when wanted_i_real > 0 and reverse = 1
                                            ;negate when wanted_i_real < 0 and phi_int < 0
    btsc wanted_i_real, #15
    bra wir_is_neg2
wir_is_pos2:
    btsc flags1, #reverse
    neg w1, w1
    bra dud_cont2

wir_is_neg2:
    btsc phi_int, #15
    neg w1, w1
											;i_delta_real = corrected(wanted_i_real) - w8
dud_cont2:
	sub w1, w8, w8
;--------------------------------------- calculate Imag part delta current (to w9) 
	mov wanted_i_imag, w0
	add sine_i_imag, wreg
	sub w0, w9, w9
;--------------------------------------- maximize w8, w9 content
											;no 0! so set LSB to force small value
	bset w8, #0
	bset w9, #0
											;find negative value how many bit can be shifted
	fbcl w8, w1
	fbcl w9, w2
											;find highest and negate into w0
	neg w1, w0
	cpslt w2, w1
	neg w2, w0
	
	sl w8, w0, w8
	sl w9, w0, w9

;--------------------------------------- rotate over impedance
											;w7 = Z_imag = phi_int
	mov phi_int, w7
											;w6 = Z_real = Z_ratio
	mov Z_ratio, w6
											;maximize w6 and w7
	bset w6, #0
	bset w7, #0
	fbcl w6, w1
	fbcl w7, w2
	neg w1, w0
	cpslt w2, w1
	neg w2, w0
	sl w6, w0, w6
	sl w7, w0, w7	
											;rotate w8+jw9 over w6+jw7 (adds phase together)
											;w8_new = w8 * w6 - w9 * w7
											;w9_new = w9 * w6 + w8 * w7
	mul.ss 	w8, w6, w0
	mul.ss w9, w7, w2
	sub w1, w3, w2
	mul.ss w9, w6, w0
	mul.ss w8, w7, w8
	add w9, w1, w9
	mov w2, w8		

;--------------------------------------- determine direction_ampli_loop bit
	bclr flags2, #direction_ampli_loop
	btsc w8, #15
	bset flags2, #direction_ampli_loop
;--------------------------------------- rotate over - angle (ampli_real, ampli_imag) vector
											;since ampli_real unreliable in this mode
											;change sign w9 based on phi_int as done in older versions
	btsc phi_int, #15
	neg w9, w9
											
;--------------------------------------- determine direction_phase_loop bit
	bclr flags2, #direction_phase_loop
	btsc w9, #15
	bset flags2, #direction_phase_loop
;--------------------------------------- end
    return

;*****************************************************************

.global determine_update_direction_dr1
determine_update_direction_dr1:
;--------------------------------------- calculate Real part delta current (to w8)
	neg w8, w8
;--------------------------------------- calculate Imag part delta current (to w9) 
	neg w9, w9
;--------------------------------------- maximize w8, w9 content

											;no 0! so set LSB to force small value
	bset w8, #0
	bset w9, #0
											;find negative value how many bit can be shifted
	fbcl w8, w1
	fbcl w9, w2
											;find highest and negate into w0
	neg w1, w0
	cpslt w2, w1
	neg w2, w0
	
	sl w8, w0, w8
	sl w9, w0, w9
;--------------------------------------- rotate over impedance
											;rotate over +45 or -45 deg as a compromise for dr1
	mov #16384, w6
	mov #16384, w7
	btsc phi_int, #15
	neg w7, w7
											;rotate w8+jw9 over w6+jw7 (adds phase together)
											;w8_new = w8 * w6 - w9 * w7
											;w9_new = w9 * w6 + w8 * w7
	mul.ss 	w8, w6, w0
	mul.ss w9, w7, w2
	sub w1, w3, w2
	mul.ss w9, w6, w0
	mul.ss w8, w7, w8
	add w9, w1, w9
	mov w2, w8	

;--------------------------------------- determine direction_ampli_loop bit
	bclr flags2, #direction_ampli_loop
	btsc w8, #15
	bset flags2, #direction_ampli_loop
;--------------------------------------- rotate over - angle (ampli_real, ampli_imag) vector
											;since ampli_real unreliable in this mode, and ampli_imag = 0  anyway
											;change sign w9 based on phi_int as done in older versions
	btsc phi_int, #15			
	neg w9, w9
											
;--------------------------------------- determine direction_phase_loop bit
	bclr flags2, #direction_phase_loop
	btsc w9, #15
	bset flags2, #direction_phase_loop
;--------------------------------------- make sure phase is good
											;for safety: override when Ar*phi_i < 0 such that |Ar| reduces
	mov ampli_real, w0
	mov phi_int, w1
	mul.ss w0, w1, w0
	btss w1, #15
	bra 1f
											;|phi| reduction skipped as this doesn't play nice in recovery, the |Ar| reduction is enough
	bclr flags2, #direction_ampli_loop
	btss ampli_real, #15
	bset flags2, #direction_ampli_loop
1:																					
;--------------------------------------- end
    return

;*****************************************************************
.end
