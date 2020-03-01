.include "p30F4011.inc"
.include "defines.inc"
.include "macros.mac"

.text

.global initialise_drive_2_sensorless
initialise_drive_2_sensorless:
                                                    ;indicate drive_2
    bclr LATC, #15
    bclr LATC, #13
    bset LATC, #14
    bclr LATE, #8
													;clear error bits
	bclr flags1, #over_i_imag
	bclr flags1, #over_i_total
    bclr flags1, #over_erpm

    clr phi_wiggle
                                                    ;no ampli_imag
    clr ampli_imag
	clr wanted_i_imag
	clr fieldweak
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
													;clear count_here
	clr count_ldm
	clr count_ldm+2

	clr phi_step
	clr phi_offset
	clr ampli_imag_prop

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
;---------------------------------------------- demodulate with wiggle
													;keep phi_motor for speed filtering
	mov phi_motor, w0
	mov w0, phi_motor_prev
                                                    ;wiggle
    mov phi_int_wiggle, w0
    add phi_wiggle
    mov phi_wiggle, w0

    lsr w0, #7, w10
	bclr w10, #0
	bset w10, #11

    mov ampli_wiggle, w0
    mul.us w0, [w10], w0
    mov w1, w0

    add phi_motor, wreg

    call demod
;---------------------------------------------- current filtering
	call current_filtering
;---------------------------------------------- safety first ! check over erpm, over i_total
    call safety_dr2
    btsc flags1, #over_erpm
    bra dr2_end_to_dr1
    btsc flags1, #over_i_total
    bra dr2_end_to_dr1	
;---------------------------------------------- determine loop update direction
	call determine_update_direction_dr2sl
;---------------------------------------------- torque/current control
    call current_control
	
	btsc flags_rom, #use_sine_iimag
	call reduce_sine_i_imag
;---------------------------------------------- phase control
    mov #plic_2, w12
    call backemf_phase_control
;---------------------------------------------- send signals to motor
    call write_motor_sinus
;---------------------------------------------- filter phi_int for better estimation of motor speed
	mov phi_motor, w0
    subr phi_motor_prev, wreg									

    mov #filter_spd, w13
    mov fil2ord_dr2_motor_speed, w11
    filter w0
;---------------------------------------------- jump to drive_2to3 if motor speed high enough
                                                    ;use filtered version of phi_int
    mov filter_spd, w0
    btsc flags1, #reverse
    neg w0, w0
    cp phi_int_2to3
    bra le, dr2_end_to_dr23
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

