.include "p30F4011.inc"
.include "defines.inc"

.text

;*****************************************************************

.global main
main:						

;---------------------------------------------- initialise
    call initialise
;    call rx_char_232

    mov #12, w0
    mov w0, monitoring_value
                                                    ;get hf values
    mov #1500, w0
    mov w0, wanted_i_hf
    call find_hf_amplitude_adc_offset

	bset PTCON, #15

    mov #32768, w0
    mov w0, phi_motor
    clr ampli_real
    clr ampli_imag
    mov #7500, w0
    mov w0, i_force_position
    call force_motor_position

    mov ampli_hf_for_i, w0
    mov w0, ampli_hf_motor
                                                    ;ADC to current sensors
    call ADC_current
    repeat #5
    nop
    bclr ADCON1, #1
                                                    ;turn on PWM
    bset PTCON, #15

    mov #44623, w0
    mov w0, adc_gain_correction
    mov #44584, w0
    mov w0, adc_gain_correction+2
    mov #41969, w0
    mov w0, adc_gain_correction+4


igc_loop:
                                                    ;wait for 40 kHz operation
    btss IFS0, #3
    bra igc_loop
    bclr IFS0, #3
;---------------------------------------------- get measured currents
    call ADC_read_current
    bclr ADCON1, #1
;---------------------------------------------- negative demod
    mov phi_hf_motor, w0
    add phi_rotation_hf, wreg
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
    mov w8, dummy1
    mov w9, dummy2

;---------------------------------------------- butterworth filtering
    mov #filter_I, w13
    mov #65, w11
    mov #131, w12
    call filter_2nd_order
    exch w8, w9
    mov #filter_Q, w13
    call filter_2nd_order
    exch w8, w9
;---------------------------------------------- send signals to motor
    mov #2048, w0
    add phi_hf_motor

    call write_motor_sinus

 ;---------------------------------------------- loop end, allow monitoring
    dec monitoring_count
    bra nz, igc_loop
    mov monitoring_value, w0
    mov w0, monitoring_count
    call monitoring
    bra igc_loop


.bss
monitoring_count: .space 2

.end

