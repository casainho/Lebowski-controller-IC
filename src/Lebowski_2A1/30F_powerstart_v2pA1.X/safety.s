.include "p30F4011.inc"
.include "defines.inc"
.include "macros.mac"

.text
.global safety

;check that a filtered i_imag is less than X Amps, else unlock
;
;corrupted variables
;w0, w1, w2, w3, w4, w11, w12, w13, w14
safety:

;--------------------------------------- filter i_imag - wanted_i_imag
											;subtract wanted_i_imag, rnd_i_imag
	mov wanted_i_imag, w0
	add sine_i_imag, wreg
	sub w9, w0, w0
											;absolute ? 
	btss flags_rom, #I_error_absolute
	bra 1f
	btsc w0, #15
	neg w0, w0
1:	
    mov #filter_I_error, w13
    mov fil2ord_i_error, w11
    filter w0

;--------------------------------------- check (i_imag - wanted_i_imag) limit

    mov filter_I_error, w4                ;compare filtered i_imag with limit
    btsc w4, #15
    neg w4, w4                              ;make positive

    mov ampli_real, w2
    btsc w2, #15
    neg w2, w2
    
    mov i_error_max_fixed, w0
    mov i_error_max_prop, w1
    mul.uu w1, w2, w2                      	;w3 = i_imag_max_prop * amplitude/2
    add w0, w3, w0
    add w0, w3, w0                          ;therefore add 2 times
                                            ;set over_i_imag bit if over limit
    cpslt w4, w0
    bset flags1, #over_i_imag

;--------------------------------------- check over-erpm limit

    mov phi_int, w0
    btsc w0, #15
    neg w0, w0

    mov phi_int_max_erpm_shutdown, w1

    cpslt w0, w1
    bset flags1, #over_erpm
	
;--------------------------------------- end

    return


;*****************************************************************

.global safety_dr2

;corrupted variables
;w0, w1, w2, w3, w4, w11, w12, w13, w14
safety_dr2:

;--------------------------------------- filter i_imag

											;subtract sine_i_imag
	mov sine_i_imag, w0
	sub w9, w0, w0
											
    mov #filter_I_error, w13
    mov fil2ord_i_error, w11
    filter w0

;--------------------------------------- check i_imag limit

    mov filter_I_error, w4                ;compare filtered i_imag with limit
    btsc w4, #15
    neg w4, w4                              ;make positive

                                            ;in dr2, compare i_imag with the allowed i_imag_max_fixed
    mov i_error_max_fixed, w0
;    lsr w0, #3, w0
                                            ;set over_i_imag bit if over limit
    bclr flags1, #over_i_imag
    cpslt w4, w0
    bset flags1, #over_i_imag

;--------------------------------------- check over-erpm limit

    mov phi_int, w0
    mov phi_int_max_erpm_shutdown, w1
	
    btsc w0, #15
    neg w0, w0

    cpslt w0, w1
    bset flags1, #over_erpm
	
;--------------------------------------- based on selection: check over_i_total
;											;use filtered wanted_i_real
;	mov filter_wir, w0         
											;use throttle indicated current (to prevent immediate conkout when coming from drive_1, as wanted_i_real is at the beginning of ramping) 
	mov throttle, w0
	btsc w0, #15
    neg w0, w0
	mul i_max_phase
	sl w3, w0								;(throttle was Q15, times 2 to correct)
                                            ;times 4 because of 400% range
    mul over_i_total_prop
	sl w3, #2, w0
    add over_i_total_fixed, wreg

    btss flags_rom, #check_i_total
    bra over_error

over_total:
                                            
    call diff_norm_2_filt
    btsc w0, #15
    bset flags1, #over_i_total

    return
;--------------------------------------- or check for over error current
over_error:
    mov filter_w9, w1
    btsc w1, #15
    neg w1, w1

    cpslt w1, w0
    bset flags1, #over_i_total

    return

;*****************************************************************

diff_norm_2_filt:
;calculates w0^2 - filter_w8^2 - filter_w9^2
;MSW result in w0 upon end
;
;corrupts w0, w1, w2, w3
;---------------------------------------------- w3:w2 = w0^2
    mul.uu w0, w0, w2
;---------------------------------------------- subtract filter_I^2
    mov filter_w8, w0
    mul.ss w0, w0, w0

    sub w2, w0, w2
    subb w3, w1, w3
;---------------------------------------------- subtract filter_Q^2
    mov filter_w9, w0
    mul.ss w0, w0, w0

    sub w2, w0, w2
    subb w3, w1, w0
;---------------------------------------------- end
    return
;*****************************************************************

.global diff_norm_2
diff_norm_2:
;calculates w0^2 - w8^2 - w9^2
;MSW result in w0 upon end
;
;corrupts w0, w1, w2, w3
;---------------------------------------------- w3:w2 = w0^2
    mul.uu w0, w0, w2
;---------------------------------------------- subtract w8^2
    mul.ss w8, w8, w0

    sub w2, w0, w2
    subb w3, w1, w3
;---------------------------------------------- subtract w9^2
    mul.ss w9, w9, w0

    sub w2, w0, w2
    subb w3, w1, w0
;---------------------------------------------- end
    return

;*****************************************************************

.global sqrt_w8_w9
sqrt_w8_w9:
;---------------------------------------------- initialise
    clr w4
    mov #0x8000, w5
;---------------------------------------------- calculate
sqrt_lp:
    ior w4, w5, w4
;---------------------------------------------- keep bit ?
    mov w4, w0
    call diff_norm_2

    btss w0, #15
    xor w4, w5, w4
;---------------------------------------------- loop
    lsr w5, w5
    bra nc, sqrt_lp
;---------------------------------------------- end
    mov w4, w0

    return

.end