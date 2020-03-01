.include "p30F4011.inc"
.include "defines.inc"

.text

;*****************************************************************

.global main_tb
main_tb:

;---------------------------------------------- initialise
    call initialise

    mov #120, w0
    mov w0, monitoring_value
                                                     ;turn off and wait for signal from labview
    bclr PTCON, #15
    call rx_char_232

    clr w0
    call tx_word_232
    clr w0
    call tx_word_232
    clr w0
    call tx_word_232
    mov #61642, w0
    call tx_word_232

                                                    ;ADC to current sensors
    call ADC_current
    repeat #5
    nop
    bclr ADCON1, #1
                                                    ;turn on PWM
    bset PTCON, #15

    mov #43000, w0
    mov w0, adc_gain_correction
    mov #43000, w0
    mov w0, adc_gain_correction+2
    mov #43000, w0
    mov w0, adc_gain_correction+4

    bclr flags123, #0

igc_loop:
                                                    ;wait for 40 kHz operation
    btss IFS0, #3
    bra igc_loop
    bclr IFS0, #3
;---------------------------------------------- get measured currents
    call ADC_read_current
    bclr ADCON1, #1
;---------------------------------------------- hf amplitude control
    mov i_hf_fixed, w7
    call hf_control
;---------------------------------------------- hf position demod
    call hf_position_demod
;---------------------------------------------- send signals to motor
    mov #2048, w0
    add phi_hf_motor

    call write_motor_sinus
 ;---------------------------------------------- loop end, allow monitoring
    dec monitoring_count
    bra nz, igc_loop
    mov monitoring_value, w0
    mov w0, monitoring_count

    btg flags123, #0
    mov filter_I+4, w0
    btss flags123, #0
    mov filter_Q+4, w0

    btg w0, #15
    call tx_word_232

    bra igc_loop


.bss
monitoring_count: .space 2
flags123:.space 2
.end

