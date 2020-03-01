.include "p30F4011.inc"
.include "defines.inc"


.global throttle_ramp
throttle_ramp:
;------------------------------------------ restore original unramped wanted_i_real
	mov wir_thr, w0
	mov w0, wanted_i_real
;------------------------------------------ post drive 1 throttle ramping
											;check if necessary
	setm w0
	cp post_dr1_ramp
	bra z, post_dr1_end
											;update post_dr1_ramp
	mov #post_dr1_ramp, w13
	mov post_dr1_incr+2, w0
	add w0, [++w13], [w13--]
	mov post_dr1_incr, w0
	addc w0, [w13], [w13]
											;overflow ? set to 0xFFFF
	btsc SR, #C
	setm [w13]
											;ramp wanted_i_real
do_dr1_ramp:
	mov wanted_i_real, w0
	mul.su w0, [w13], w0
	mov w1, wanted_i_real
		
post_dr1_end:
;------------------------------------------ regen ramping
											;skip regen ramp if not in regen
	btss wanted_i_real, #15
	bra regen_rampup_end
											;mult factor y = (|phi_int| - phi_int_start_regen) * regen_rampup
	mov phi_int, w0
	btsc w0, #15
	neg w0, w0	
	
	subr phi_int_start_regen, wreg
											;if  phi_int_start_regen > |phi_int| then no regen
	bra gtu, 1f
	clr wanted_i_real
	bra regen_rampup_end
1:	
											;mult with regen_rampup (w0 > 0 here)
	mul regen_rampup
											;y = 2^-16 * w3:w2, must be <1
	cp0 w3
	bra nz, regen_rampup_end
											;mult wanted_i_real with y
	mov wanted_i_real, w1
	mul.su w1, w2, w0
	mov w1, wanted_i_real

regen_rampup_end:								
;------------------------------------------ erpm limiter
											;skip limiter if regen
	btsc wanted_i_real, #15
	bra erpm_limit_end
											;chose proper forward or reverse limits
	mov #phi_int_max_erpm, w13
	btsc phi_int, #15
	inc2 w13, w13
	mov #max_erpm_rampdown, w12
	btsc phi_int, #15
	inc2 w12, w12
											;mult factor y = 1 - (|phi_int| - [w13]) * [w12]
											;[w12] contains 1 / phi_int_rampdown_range
	mov phi_int, w1
	btsc w1, #15
	neg w1, w1
											;(|phi_int| - [w13]) must be > 0, else we have not hit limiter yet
	sub w1, [w13], w1
	bra n, erpm_limit_end
	
	mul.uu w1, [w12], w0
											;clr wanted_i_real when erpm way too high (overflow into w1 from mult)
	cp0 w1
	btss SR, #Z
	clr wanted_i_real
											;calc y and mult with wanted_i_real
	com w0, w0
	mul wanted_i_real
	mov w3, wanted_i_real
	
erpm_limit_end:	
;------------------------------------------ ampli based throttle limiter
											;skip limiter if regen
	btsc wanted_i_real, #15
	bra ampli_based_end
	
	mov ampli_real, w0
	btsc w0, #15
	neg w0, w0
	
	subr ampli_lower_limit, wreg
											;(|ampli_real| - ampli_lower_limit) must be > 0, else we have not hit limiter yet
	bra n, ampli_based_end	
	
	mul ampli_rampdown
											;clr wanted_i_real when ampli_real way too high (overflow into w3 from mult)
	cp0 w3
	btss SR, #Z
	clr wanted_i_real
											;calc y and mult with wanted_i_real
	com w2, w0
	mul wanted_i_real
	mov w3, wanted_i_real
	
ampli_based_end:	
;------------------------------------------ accelleration based limiter
	btss flags_rom2, #limit_accel
	bra accel_based_end
									;------ filter phi_int derivative
											;correct phi_int with reverse flag, then increasing phi_int means motor increasing speed
	mov phi_int, w1
	mov phi_int+2, w0
											
;mov phi_motor, w1
;mov phi_motor+2, w0
;mov phi_old, w3
;mov phi_old+2, w2
;mov w1, phi_old
;mov w0, phi_old+2
;sub w0, w2, w0
;subb w1, w3, w1											
											
	btss flags1, #reverse
	bra 1f
	com w1, w1
	neg w0, w0
	addc #0, w1
1:												;get previous and store current
	mov phi_int_prev, w3
	mov phi_int_prev+2, w2
	mov w1, phi_int_prev
	mov w0, phi_int_prev+2
												;difference = accelleration to w3.w2
	sub w0, w2, w2
	subb w1, w3, w3
												;subtract filter state ( = sign_extended(filter_accel).filter_accel )
	mov #filter_accel, w13
	mov [w13], w0
	asr w0, #15, w1
	sub w2, w0, w2
	subb w3, w1, w3
												;w3.w2 times 0.accel_filt_coef, answer in 0.w11:w10
	mov accel_filt_coef, w7
												
	mul.uu w7, w2, w10							;0.w2*0.w7 = 0.w11:w10
	mul.us w7, w3, w0							;w3.0*0.w7 = w1.w0:00   with w1 = 0x0000 or 0xFFFF, w0 contains valid sign info
	add w0, w11, w11
												;extra divide by 16 as accel_filt_coef is 16 times the actual value
	lsr w10, #4, w10
	sl w11, #12, w1
	ior w10, w1, w10
	asr w11, #4, w11
												;add to 0.filter_accel:filter_accel+2
	add w10, [++w13], [w13]
	addc w11, [--w13], [w13]
												;process overflow, undo add operation
	bra nov, 1f
	sub w10, [++w13], [w13]
	subb w11, [--w13], [w13]
1:
									;------ implement ramping
											;skip limiter if regen
	btsc wanted_i_real, #15
	bra accel_based_end
											;only if accelleration is too much
	mov filter_accel, w0
	subr max_accel, wreg 
	bra le, accel_based_end
											;y = 1 - w0 * accel_ramp, w0 is positive
	mul accel_ramp
	
	cp0 w3
	btss SR, #Z
	clr wanted_i_real
											;calc y and mult with wanted_i_real
	com w2, w0
	mul wanted_i_real
	mov w3, wanted_i_real
	
accel_based_end:	
;------------------------------------------ end
	return
	
;*****************************************************************
.section *, bss
	phi_old: .space 4
	
.end




