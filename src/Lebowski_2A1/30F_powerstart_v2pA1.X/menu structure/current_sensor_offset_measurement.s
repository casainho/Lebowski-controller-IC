
.include "p30F4011.inc"
.include "defines.inc"
.include "macros.mac"
	
.text

;*****************************************************************
.global current_sensor_offset_measurement
current_sensor_offset_measurement:
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

;----------------------------------------------
; fix rotor for 40000 cycles
;----------------------------------------------

    mov pwm_period, w0

	mov w0, PDC1
	mov w0, PDC2
	mov w0, PDC3

    mov #40000, w0
    mov w0, counter
csom_fix:
    btss IFS0, #3
    bra csom_fix
    bclr IFS0, #3

    dec counter
    bra nz, csom_fix

;----------------------------------------------
; ramp up/down hf tone over 16384 cycles
;----------------------------------------------

;---------------------------------------------- initialise
                                                    ;start first current measurement
    bclr ADCON1, #1

csom_ramp:
    btss IFS0, #3
    bra csom_ramp
    bclr IFS0, #3
;---------------------------------------------- get measured currents
    call ADC_read_current
    bclr ADCON1, #1
;---------------------------------------------- filter currents for finding current sensor offset
    mov #70, w11
    mov #filter_w8, w13
    filter w4

    mov #70, w11
    mov #filter_w9, w13
    filter w5

    mov #70, w11
    mov #filter_spd, w13
    filter w6
;---------------------------------------------- ramp up wanted hf level
    mov i_error_max_fixed, w1
													;this next bit makes the up and down ramping possible
	mov counter, w2
	btsc w2, #15
	com w2, w2
                                                    ;w1: wanted hf current
    mov #8, w0
    mul.uu w0, w2, w2
                                                    ;as long as w3=0, w2 contains ramp up factor, w1 = w1*w2
                                                    ;if w3 <> 0, skip the mult of w1 and w2, keep w1
    cp0 w3
    btsc SR, #Z
    mul.uu w1, w2, w0
                                                    ;now wanted current in w1
    mov w1, w7
;---------------------------------------------- regulate hf
    call hf_control_current_sensors
;---------------------------------------------- increase hf phase, send to motor
    mov #2048, w0
    add phi_hf_motor

    call write_motor_sinus
;---------------------------------------------- end when counter has reached 32768
    inc2 counter
    bra nz, csom_ramp

;---------------------------------------------- turn off PWM

	bclr PTCON, #15

;----------------------------------------------
; store results
;----------------------------------------------
                                                ;div by 32 instead of 16 because of the gain of 2 in the notch filter
    mov filter_w8, w0
    asr w0, #5, w0
    add adc_current_offset

    mov filter_w9, w0
    asr w0, #5, w0
    add adc_current_offset+2

    mov filter_spd, w0
    asr w0, #5, w0
    add adc_current_offset+4

    return
	
;*****************************************************************
	
hf_control_current_sensors:
;---------------------------------------------- positive demod
    mov phi_hf_motor, w0
    add phi_hf_offset, wreg
    call demod
;---------------------------------------------- update demodulation phase offset
    mov #16, w0
    btsc w9, #15
    neg w0, w0
    add phi_hf_offset
;---------------------------------------------- regulate hf current amplitude
    cp w8, w7
    bra gt, dec_hf_ampli
inc_hf_ampli:
    inc ampli_hf_motor
    bra nz, done_hf_ampli
    setm ampli_hf_motor
    bra done_hf_ampli
dec_hf_ampli:
    dec ampli_hf_motor
    bra c, done_hf_ampli
    clr ampli_hf_motor
done_hf_ampli:

    return
.end

