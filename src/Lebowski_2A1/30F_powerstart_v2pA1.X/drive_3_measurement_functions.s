.include "p30F4011.inc"
.include "defines.inc"
.include "macros.mac"

.text

;*****************************************************************
;* to_erpm:
;* reach phi_int_max_erpm automatically
;*****************************************************************

.global to_erpm
to_erpm:
;---------------------------------------------- initialise
	clr phi_step
	clr phi_offset
to_erpm_lp:
;---------------------------------------------- wait for f_sample operation
    bclr LATD, #2
    btss IFS0, #3
    bra to_erpm_lp
    bclr IFS0, #3
                                                    ;indicate when busy
    bset LATD, #2
;---------------------------------------------- get measured currents
    bclr ADCON1, #1
    nop
                                                    ;temp reading intermezzo
    mov temp_readout, w14
    btsc flags_rom, #use_temp_sensors
    call w14

    call ADC_read_current
;---------------------------------------------- process throttle based on TMR4
    btsc IFS1, #5
    call throttle_read
	call throttle_ramp
;---------------------------------------------- demodulate 
    mov phi_motor, w0
    call demod
;---------------------------------------------- current filtering
	call current_filtering
;---------------------------------------------- safety first ! check error current stuff

	call safety
    btsc flags1, #over_i_imag
    bra end_to_dr1
													;check erpm hasn't dropped too low
	mov filter_spd, w0
    btsc w0, #15
    neg w0, w0
    cp phi_int_3to2
    bra ge, end_to_dr1

;---------------------------------------------- determine loop update direction
													;save w8 as needed by speed_control
	push w8
	push wanted_i_real
													;show 0 error current in the amplitude loop (as we're in speed control)
													;for correct operation of the phase control loop
	clr w8
	clr wanted_i_real

	call determine_update_direction
	
	pop wanted_i_real
	pop w8
;---------------------------------------------- torque/current control
    call speed_control
;---------------------------------------------- calculate ampli_imag
													;by exception: base on filter_I and filter_Q
	push wanted_i_real
	
	mov filter_I, w0
	mov w0, wanted_i_real
	clr wanted_i_imag
	clr sine_i_imag
	
    call calc_ampli_imag
	
	pop wanted_i_real
;---------------------------------------------- phase control
    mov #plic_3, w12
    call backemf_phase_control
;---------------------------------------------- filter erpm
	mov phi_int, w8
    mov #filter_spd, w13
    mov fil2ord_dr2_motor_speed, w11
    filter w8
;---------------------------------------------- end when erpm reached	
													;make rpm's positive
	mov filter_spd, w1
	btsc w1, #15
	neg w1, w1
	
	mov wanted_phi_int, w2
	btsc w2, #15
	neg w2, w2
													;end when above 94%
	lsr w2, #4, w3
	sub w2, w3, w2
	cpsgt w1, w2
	bra to_erpm_cont
													;and below 106%
	add w3, w2, w2
	add w3, w2, w2
	cpslt w1, w2
	bra to_erpm_cont
	
	bra to_erpm_end
to_erpm_cont:
;---------------------------------------------- send signals to motor
    call write_motor_sinus
;---------------------------------------------- drive_3 loop end, allow monitoring
    dec monitoring_count
    bra nz, to_erpm_lp
    mov monitoring_value, w0
    mov w0, monitoring_count
    call monitoring
    bra to_erpm_lp
;---------------------------------------------- end when filtered erpm = wanted erpm
to_erpm_end:
	return
	
;*****************************************************************
;* measure_halls
;*****************************************************************

.global measure_halls
measure_halls:
;---------------------------------------------- initialise
													;calculate coefficient for hall filters
														;w11 = mlc/(46*T), with T = 3 seconds
	mov main_loop_count, w0
	mov #138, w2
	repeat #17
	div.u w0, w2
	inc w0, w0
	mov w0, filter_general_coeff
													;calculate how many cycles in T = 4 seconds, place in counter
														;#cycles = T * 30e6/mlc
	mov #1831, w11
	mov #3584, w10
	mov main_loop_count, w2
	repeat #17
	div.u w11, w2
	mov w0, counter+2
	mov w1, w11
	repeat #17
	div.ud w10, w2
	mov w0, counter
														;due to the way the counter is used the MSW (counter+2) must be one higher than necessary
	inc counter+2
	
	clr phi_step
	clr phi_offset
;---------------------------------------------- wait for f_sample operation
mkv_lp:
	bclr LATD, #2
    btss IFS0, #3
    bra mkv_lp
    bclr IFS0, #3
                                                    ;indicate when busy
    bset LATD, #2
;---------------------------------------------- get measured currents
    bclr ADCON1, #1
    nop
													;run hall calibration 
    call update_hall_positions
                                                    ;temp reading intermezzo
    mov temp_readout, w14
    btsc flags_rom, #use_temp_sensors
    call w14

    call ADC_read_current
;---------------------------------------------- process throttle based on TMR4
    btsc IFS1, #5
    call throttle_read
	call throttle_ramp
;---------------------------------------------- demodulate 
    mov phi_motor, w0
    call demod
;---------------------------------------------- current filtering
	call current_filtering
;---------------------------------------------- safety first ! check error current stuff
    call safety
    btsc flags1, #over_i_imag
    bra end_to_dr1
													;check erpm hasn't dropped too low
	mov phi_int, w0
    btsc w0, #15
    neg w0, w0
    cp phi_int_3to2
    bra ge, end_to_dr1
;---------------------------------------------- determine loop update direction
													;save w8 as needed by speed_control
	push w8
	push wanted_i_real
													;show 0 error current in the amplitude loop (as we're in speed control)
													;for correct operation of the phase control loop
	clr w8
	clr wanted_i_real
	
	call determine_update_direction
	
	pop wanted_i_real
	pop w8
;---------------------------------------------- speed control
	call speed_control
;---------------------------------------------- calculate ampli_imag
														;by exception: base on filter_I and filter_Q
	push wanted_i_real
	
	mov filter_I, w0
	mov w0, wanted_i_real
	clr wanted_i_imag
	clr sine_i_imag
	
    call calc_ampli_imag
	
	pop wanted_i_real
;---------------------------------------------- phase control
    mov #plic_3, w12
    call backemf_phase_control
;---------------------------------------------- filter erpm
	mov phi_int, w8
    mov #filter_spd, w13
    mov fil2ord_dr2_motor_speed, w11
    filter w8
;---------------------------------------------- end when counter = 0
	dec counter
	bra nz, mkv_cont
	dec counter+2
	bra z, mkv_end
;---------------------------------------------- send signals to motor
mkv_cont:
    call write_motor_sinus
;---------------------------------------------- mhe loop end, allow monitoring
    dec monitoring_count
    bra nz, mkv_lp
    mov monitoring_value, w0
    mov w0, monitoring_count
    call monitoring
    bra mkv_lp
;---------------------------------------------- end when counter = 0
mkv_end:
	
	return
	
	
;*****************************************************************
;* error current event !
;*****************************************************************
end_to_dr1:
                                                    ;start recovery from scratch
;    clr phi_motor
    clr phi_motor+2
    clr phi_int
    clr phi_int+2
    clr ampli_real
    clr ampli_real+2
    clr ampli_imag
                                                    ;initialise dutycycle at 50%
	mov pwm_period_rec, w0
	mov w0, PDC1
	mov w0, PDC2
	mov w0, PDC3
													;indicate error
	mov #1, w14
	
	reset

;*****************************************************************
;*****************************************************************
;*****************************************************************


.end

