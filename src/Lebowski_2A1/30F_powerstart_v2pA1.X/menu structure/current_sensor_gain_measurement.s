.include "p30F4011.inc"
.include "defines.inc"

.text

;*****************************************************************
.global current_sensor_gain_measurement
current_sensor_gain_measurement:
;---------------------------------------------- initialise
    call reset_filters
	call timers_open
	call PWM_open
    call ADC_open
    call fill_pwm_and_sin_arrays
    call clear_variables
                                                    ;turn on PWM
	bset PTCON, #15
                                                    ;switch ADCs over to current measurement, wait a bit before 1st measurement
    call ADC_current

    repeat #5
    nop
                                                    ;start first current measurement
    bclr ADCON1, #1

;----------------------------------------------
; force motor position
;----------------------------------------------

    clr phi_motor
    call force_motor_position

;----------------------------------------------
; ramp up hf current over 16384 cycles
;----------------------------------------------

    call reset_filters

    clr ampli_hf_motor
    clr phi_hf_motor
    clr phi_hf_demod_offset

    clr counter

csgm_ramp:
    btss IFS0, #3
    bra csgm_ramp
    bclr IFS0, #3
;---------------------------------------------- get measured currents
    call ADC_read_current
    bclr ADCON1, #1
;---------------------------------------------- ramp up wanted hf level
    mov i_hf_prop_factor, w0
    mov i_force_position, w1
    mul.uu w0, w1, w0
    sl w1, w1
    mov i_hf_fixed, w0
    add w0, w1, w1
                                                    ;w1: wanted hf current
    mov #8, w0
    mul counter
                                                    ;as long as w3=0, w2 contains ramp up factor, w1 = w1*w2
                                                    ;if w3 <> 0, skip the mult of w1 and w2, keep w1
    cp0 w3
    btsc SR, #Z
    mul.uu w1, w2, w0
                                                    ;now wanted current in w1
    mov w1, w2
;---------------------------------------------- regulate hf
    call hf_control
;---------------------------------------------- hf position demod
    call hf_position_demod_csgm
;---------------------------------------------- positive demod
    mov phi_motor, w0
    call positive_demod
;---------------------------------------------- regulate i_force_position
    mov i_force_position, w1
    cp w8, w1
    bra gt, csgm_dec_ampli_real
csgm_inc_ampli_real:
    inc ampli_real
    bra nz, csgm_done_ampli_real
    setm ampli_real
    bra csgm_done_ampli_real
csgm_dec_ampli_real:
    dec ampli_real
    bra c, csgm_done_ampli_real
    clr ampli_real
csgm_done_ampli_real:
;---------------------------------------------- increase hf phase, send to motor
    mov #2048, w0
    add phi_hf_motor

    call write_motor_sinus
;---------------------------------------------- end when counter has reached 16384
    inc counter
    mov #16384, w0
    cp counter
    bra nz, csgm_ramp

;----------------------------------------------
; measure and adapt gain over 1 rotation(s) (first do 1 dummy rotation)
;----------------------------------------------
    mov #2, w0
    mov w0, counter+2
    clr phi_motor
several_times:
    clr average_X
    clr average_Y
    clr flags_gc
one_rotation:
    btss IFS0, #3
    bra one_rotation
    bclr IFS0, #3
;---------------------------------------------- get measured currents
    call ADC_read_current
    bclr ADCON1, #1
;---------------------------------------------- regulate hf level
    mov i_hf_prop_factor, w0
    mov i_force_position, w1
    mul.uu w0, w1, w0
    sl w1, w1
    mov i_hf_fixed, w0
    add w0, w1, w2
    call hf_ampli_control
;---------------------------------------------- hf position demod
    call hf_position_demod_csgm
;---------------------------------------------- positive demod
    mov phi_motor, w0
    call positive_demod
;---------------------------------------------- regulate i_force_position
    mov i_force_position, w1
    cp w8, w1
    bra gt, csgm2_dec_ampli_real
csgm2_inc_ampli_real:
    inc ampli_real
    bra nz, csgm2_done_ampli_real
    setm ampli_real
    bra csgm2_done_ampli_real
csgm2_dec_ampli_real:
    dec ampli_real
    bra c, csgm2_done_ampli_real
    clr ampli_real
csgm2_done_ampli_real:
;---------------------------------------------- online gain calibration
    mov filter_I+4, w8
    mov filter_Q+4, w9
    call keep_track_circle_center
;---------------------------------------------- increase hf phase, send to motor
    mov #2048, w0
    add phi_hf_motor

    call write_motor_sinus
;---------------------------------------------- increase position, loop
    inc2 phi_motor
    bra nz, one_rotation
;---------------------------------------------- do 2 times
    dec counter+2
    bra nz, several_times
;---------------------------------------------- and adapt gain but only after the last rotation (prevents startup issues from 1st rotation)
                                                    ;turn off PWM
	bclr PTCON, #15

    call adapt_gain

    call keep_total_gain

    return

;*****************************************************************
;the sum of the gain must be 2 but will be 2+x
;to correct: coeff = coeff * [1 - x/(2+x)]
keep_total_gain:
                                                                    ;calc x (the 2 drops out due to overflow)
    mov adc_gain_correction, w0
    add adc_gain_correction+2, wreg
    add adc_gain_correction+4, wreg
                                                                    ;div 4
    asr w0, #2, w1
                                                                    ;x/4 / (1/2 + x/4)
    mov #0x8000, w2
    add w2, w1, w2
    clr w0
                                                                    ;make positive
    btsc w1, #15
    neg w1, w1
    repeat #17
    div.ud w0, w2
                                                                    ;if w1 was positive w2+w1 > 0.5, so bit 15 in w2 is set
    btss w2, #15
    neg w0, w0

    mov #adc_gain_correction, w12
    mul.uu w0, [w12], w2
    subr w3, [w12], [w12++]
    mul.uu w0, [w12], w2
    subr w3, [w12], [w12++]
    mul.uu w0, [w12], w2
    subr w3, [w12], [w12++]

    return
;*****************************************************************
 adapt_gain:
;---------------------------------------------- calculate hf current level
    mov i_hf_prop_factor, w0
    mov i_force_position, w1
    mul.uu w0, w1, w0
    sl w1, w1
    mov i_hf_fixed, w0
    add w0, w1, w11
;---------------------------------------------- compute and store new gain settings
    mov #data_array_sin, w13
    mov #adc_gain_correction, w12
    mov average_X, w8
    mov average_Y, w9
                                                    ;divide by 8 to compute true average
    asr w8, #3, w8
    asr w9, #3, w9
                                                    ;X, Y times 0.5 not necessary because of sin array scaling
    do #2, ag_compute_lp
                                                    ;compute rotated version
    mul.ss w9, [w13], w2                                ;Y*.5*sin
    add #128, w13
    mul.ss w8, [w13], w0                                ;X*.5*cos
    add #42, w13
    sub w1, w3, w1                                      ;X*.5*cos - Y*.5*sin
                                                    ;gain -= gain * w1/(w1+w11)
    clr w0
    add w1, w11, w2
    repeat #17
    div.sd w0, w2
                                                    ;mult with ADC gain correction
    mul.su w0, [w12], w0
                                                    ;and subtract from ADC gain correction
 ag_compute_lp:
    subr w1, [w12], [w12++]
;---------------------------------------------- end
    return
;*****************************************************************
keep_track_circle_center:
;---------------------------------------------- end if quadrant already visited
    mov phi_motor, w1
    lsr w1, #13, w1
    mov flags_gc, w0
    btst.c w0, w1
    btsc SR, #C
                                                    ;if bit=0, end
    return

    com w0, w0
    bsw.c w0, w1
    com w0, w0
    mov w0, flags_gc
;---------------------------------------------- upgate averages
    mov w8, w0
    add average_X

    mov w9, w0
    add average_Y
;---------------------------------------------- end
    return
;*****************************************************************
;separate routine because the filter_2nd_order coefficient is not known yet.
hf_position_demod_csgm:
;---------------------------------------------- negative demod
    mov phi_hf_motor, w0
    add phi_hf_demod_offset, wreg
    call negative_demod
;---------------------------------------------- notch filtering
    mov #notch_hf_I, w13
    call notch_hf
    mov #notch_2hf_I,w13
    call notch_2hf
    exch w8, w9
    mov #notch_hf_Q, w13
    call notch_hf
    mov #notch_2hf_Q,w13
    call notch_2hf
    exch w8, w9
;---------------------------------------------- butterworth filtering
    mov #filter_I, w13
    mov #150, w11
    call filter_2nd_order
    exch w8, w9
    mov #filter_Q, w13
    goto filter_2nd_order
;*****************************************************************


.end

