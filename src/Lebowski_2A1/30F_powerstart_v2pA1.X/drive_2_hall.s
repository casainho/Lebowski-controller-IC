.include "p30F4011.inc"
.include "defines.inc"
.include "macros.mac"

.text

.global initialise_drive_2_hall
initialise_drive_2_hall:
                                                    ;indicate drive_2
    bclr LATC, #15
    bclr LATC, #13
    bset LATC, #14
    bclr LATE, #8
													;clear error bits
	bclr flags1, #over_i_imag
	bclr flags1, #over_i_total
    bclr flags1, #over_erpm
                                                    ;no ampli_imag
    clr ampli_imag
	clr wanted_i_imag
	clr fieldweak
                                                    ;filter_wI is used for wanted_i_real current filtering by the mfa routine
    clr filter_I
	clr filter_I+2
													;filter_wQ is used for wanted_i_imag current filtering by the FOC routine
	clr filter_Q
	clr filter_Q+2
                                                    ;reset speed filter
    clr filter_spd
    clr filter_spd+2
                                                    ;reset error current filter
    clr filter_I_error
    clr filter_I_error+2
                                                    ;reset I filter
    clr filter_w8
    clr filter_w8+2
                                                    ;reset Q filter
    clr filter_w9
    clr filter_w9+2
                                                    ;reset wanted_i_real filter
    clr filter_wir
    clr filter_wir+2
													;to initialise phi_motor_magbased_prev
	call hall_measure_phase
													;initialise pll
	mov phi_motor, w0
	mov w0, pll_phi
	mov phi_int, w0
	mov w0, pll_int
													;initialis a little bit of speed to keep output stage on when we come here from dr23hl
	sl phi_int_direction_change, wreg
	btsc phi_int, #15
	neg w0, w0
	mov w0, filter_spd
													;clear count_here
	clr count_ldm
	clr count_ldm+2
	
	clr phi_step
	clr phi_int
	clr phi_prop
	clr phi_prop+2
	clr phi_offset
;---------------------------------------------- main loop
drive_2:
                                                    ;wait for 40 kHz operation
    bclr LATD, #2
    btss IFS0, #3
    bra drive_2
    bclr IFS0, #3
                                                    ;indicate when busy
    bset LATD, #2
													;update time spent here counter
	clr w0
	inc count_ldm
	addc count_ldm+2
	inc count_tot
	addc count_tot+2
;---------------------------------------------- get measured currents
    bclr ADCON1, #1
    nop
    nop
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
;---------------------------------------------- calculate ampli_imag as it includes throttle limiting... (must be before determine_direction)
	push ampli_imag
	call calc_ampli_imag
	pop ampli_imag
;---------------------------------------------- demodulate
	mov phi_motor, w0
    call demod
;---------------------------------------------- current filtering
	call current_filtering
;---------------------------------------------- safety first ! check over erpm, over i_total
    call safety_dr2
    btsc flags1, #over_erpm
    bra dr2_end_to_dr1
    btsc flags1, #over_i_total
    bra dr2_end_to_dr1
													;only transition when error current low enough, so when over_i_imag not set
	bset flags2, #can_transition
	btsc flags1, #over_i_imag
	bclr flags2, #can_transition
;---------------------------------------------- determine loop update direction (necessary for current_control)
;	btss flags1, #clipping
	call determine_update_direction_dr2hl
;	btsc flags1, #clipping
;	call determine_update_clipping_dr2hl
;---------------------------------------------- torque/current control
    call current_control
													;no fieldweakening allowed
	clr wanted_i_imag				
	
	btsc flags_rom, #use_sine_iimag
	call reduce_sine_i_imag
;---------------------------------------------- ampli_imag control (such that filter_Q = 0)
													;hall_control_imag must be after update_ampli_imag as this last one clears the prop
	call hall_control_imag
;---------------------------------------------- clear amplitude signals when no throttle and rpm low
	cp0 wanted_i_real
	bra nz, do_not_clr_ampli
	
	mov filter_spd, w0
    btsc w0, #15
    neg w0, w0
	cp phi_int_direction_change
    bra lt, do_not_clr_ampli
	
	bset LATC, #15
	bclr PTCON, #15
	
	clr ampli_real
	clr ampli_prop
	clr ampli_imag
	clr ampli_imag_prop

	bra amp_cont
do_not_clr_ampli:	
	bclr LATC, #15
	bset PTCON, #15
amp_cont:
;---------------------------------------------- phase control
	call hall_read_and_pll

	mov pll_int, w0
	mov w0, phi_int
	mov pll_phi, w0
	mov w0, phi_motor
													
	clr phi_step
	clr phi_prop
	clr phi_prop+2
;---------------------------------------------- send signals to motor
	call write_motor_sinus
;---------------------------------------------- filter phi_motor increase for estimation of motor speed
    mov phi_motor_magbased, w0
	subr phi_motor_magbased+2, wreg
													;no overshoot, w12 = 4 * w11
	mov #filter_spd, w13
    mov fil2ord_dr2_motor_speed, w11
	filter w0
;---------------------------------------------- jump to drive_2to3 if motor speed high enough
	call pll_error_check
	btss flags2, #can_transition
	bra 1f
                                                    ;use filtered motor speed
    mov filter_spd, w0
    btsc flags1, #reverse
    neg w0, w0
    cp phi_int_2to3
    bra le, dr2_end_to_dr23
1:
;---------------------------------------------- drive_2 loop end, allow monitoring
    dec monitoring_count
    bra nz, drive_2
    mov monitoring_value, w0
    mov w0, monitoring_count
    call monitoring
    bra drive_2

;*****************************************************************
;* over_erpm event or over_i_total
;*****************************************************************
dr2_end_to_dr1:
													;initialise dutycycle at 50%
	mov pwm_period_rec, w0
	mov w0, PDC1
	mov w0, PDC2
	mov w0, PDC3

    goto initialise_drive_1_all

;*****************************************************************
;* rpms high enough
;*****************************************************************
dr2_end_to_dr23:

    goto correct_drive_2to3

;*****************************************************************
;*****************************************************************
;*****************************************************************


	
	
	

.end

