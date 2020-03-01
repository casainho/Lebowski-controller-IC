.include "p30F4011.inc"
.include "defines.inc"
.include "macros.mac"

.text

.global initialise_drive_2to3_sensorless
initialise_drive_2to3_sensorless:
                                                    ;indicate drive_2to3
    bclr LATC, #15
    bclr LATC, #13
    bset LATC, #14
    bset LATE, #8
                                                    ;filter_I is used for phase current filtering by the FOC routine
    clr filter_I
    clr filter_I+2
                                                    ;filter_Q is used for phase current filtering by the FOC routine
    clr filter_Q
    clr filter_Q+2
                                                    ;filter_I_error is used for error current filtering by the safety_dr2 routine
    clr filter_I_error
    clr filter_I_error+2
                                                    ;spend at least cycles_2to3 cycles here ('cause the current filters starts at 0)
    mov cycles_2to3, w0
    mov w0, counter
													;clear error bits
	bclr flags1, #over_i_imag
	bclr flags1, #over_i_total
    bclr flags1, #over_erpm
													;clear count_here
	clr count_ldm
	clr count_ldm+2

	clr ampli_imag_prop
	clr phi_step
	clr phi_offset
	
drive_2to3:
                                                    ;wait for 40 kHz operation
    bclr LATD, #2
    btss IFS0, #3
    bra drive_2to3
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
;---------------------------------------------- calculate ampli_imag
													;includes throttle limiting so must be before determine_direction
    call calc_ampli_imag
;---------------------------------------------- demodulate 
    mov phi_motor, w0
	mov w0, phi_motor_prev
    call demod
;---------------------------------------------- current filtering
	call current_filtering
;---------------------------------------------- safety first ! check over-erpm and over_i_total
    call safety_dr2
    btsc flags1, #over_erpm
    bra dr23_end_to_dr1
    btsc flags1, #over_i_total
    bra dr23_end_to_dr1
;---------------------------------------------- determine loop update direction
;	btss flags1, #clipping
	call determine_update_direction
;	btsc flags1, #clipping
;	call determine_update_clipping
													;sanity check on phase loop
;	btsc flags_rom2, #check_KvLR
;	call check_phase_loop
;---------------------------------------------- torque/current control
    call current_control
	call fieldweakening
	
	btsc flags_rom, #use_sine_iimag
	call reduce_sine_i_imag

;---------------------------------------------- phase control
    mov #plic_3, w12
;	btss flags_rom2, #check_KvLR
;	bra 1f
;	btsc flags2, #use_emergency_coeffs
;	mov #plc_emergency, w12
;1:
    call backemf_phase_control
;---------------------------------------------- send signals to motor
    call write_motor_sinus
;---------------------------------------------- end to drive_3 if error current low enough and more than 1000 cycles
    cp0 counter
    bra z, check_error_current
    dec counter
    bra continue
    
check_error_current:    
    btss flags1, #over_i_imag
    bra dr23_end_to_dr3

continue:
;---------------------------------------------- filter phi_int for better estimation of motor speed
	mov phi_motor, w0
    subr phi_motor_prev, wreg									

    mov #filter_spd, w13
    mov fil2ord_dr2_motor_speed, w11
    filter w0
;---------------------------------------------- end back to drive_2 if rpms drop too low
    mov filter_spd, w0
    btsc flags1, #reverse
    neg w0, w0
    cp phi_int_3to2
    bra ge, dr23_end_to_dr2
;---------------------------------------------- drive_2to3 loop end, allow monitoring
    dec monitoring_count
    bra nz, drive_2to3
    mov monitoring_value, w0
    mov w0, monitoring_count
    call monitoring
    bra drive_2to3

;*****************************************************************
;* 1000 cycles done and no over_i_imag event
;*****************************************************************
dr23_end_to_dr3:

    goto correct_drive_3

;*****************************************************************
;* slowed down too much
;*****************************************************************
dr23_end_to_dr2:

    goto correct_drive_2

;*****************************************************************
;* over_erpm or over_i_total event !
;*****************************************************************
dr23_end_to_dr1:
                                                    ;initialise dutycycle at 50%
	mov pwm_period_rec, w0
	mov w0, PDC1
	mov w0, PDC2
	mov w0, PDC3

    goto initialise_drive_1_all

;*****************************************************************
;*****************************************************************
;*****************************************************************


.end

