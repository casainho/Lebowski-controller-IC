.include "p30F4011.inc"
.include "defines.inc"

.text

;*****************************************************************
.global main
main:
;---------------------------------------------- initialise
                                                    ;global initialise
    call initialise
retry:                                              ;wait for any key
	call rx_char_232

    mov #1000, w0
    mov w0, wanted_i_hf

    call find_hf_amplitude_adc_offset

;---------------------------------------------- report

    mov ampli_hf_for_i, w0
    mov #str_buf, w1
    call word_to_udec_str
    mov #str_buf, w0
    call tx_ram_str_232

    mov #'\n', w0
    call tx_char_232

    mov phi_rotation_hf, w0
    mov #str_buf, w1
    call word_to_udec_str
    mov #str_buf, w0
    call tx_ram_str_232

    mov #'\n', w0
    call tx_char_232
    mov #'\n', w0
    call tx_char_232

    mov filter_I+4, w0
    mov #str_buf, w1
    call word_to_udec_str
    mov #str_buf, w0
    call tx_ram_str_232

    mov #'\n', w0
    call tx_char_232

    mov filter_Q+4, w0
    mov #str_buf, w1
    call word_to_udec_str
    mov #str_buf, w0
    call tx_ram_str_232

    mov #'\n', w0
    call tx_char_232

    mov filter_C+4, w0
    mov #str_buf, w1
    call word_to_udec_str
    mov #str_buf, w0
    call tx_ram_str_232

    mov #'\n', w0
    call tx_char_232
    mov #'\n', w0
    call tx_char_232


;---------------------------------------------- verify
                                                    ;turn on PWM
	bset PTCON, #15

    clr phi_motor
    clr ampli_real
    clr ampli_imag
    clr phi_hf_motor

    call reset_filters

    mov ampli_hf_for_i, w0
    mov w0, ampli_hf_motor

    mov #1000, w0
    mov w0, counter

;---------------------------------------------- loop for measurement
tfhfa_lp:
                                                    ;wait for 40 kHz operation
    btss IFS0, #3
    bra tfhfa_lp
    bclr IFS0, #3
;---------------------------------------------- get ADC measurements
    call ADC_read_current
    bclr ADCON1, #1
;---------------------------------------------- demodulate
    mov phi_hf_motor, w0
    call positive_demod
;---------------------------------------------- filter I and Q
    mov #655, w11
    mov #1310, w12

    mov #filter_I, w13
    call filter_2nd_order

    mov #filter_Q, w13
    exch w8, w9
    call filter_2nd_order
;---------------------------------------------- update phase, send to motor
    mov #2048, w0
    add phi_hf_motor

    call write_motor_sinus
;---------------------------------------------- loop
    dec counter
    bra nz, tfhfa_lp
                                                    ;turn off PWM
	bclr PTCON, #15
;---------------------------------------------- cordic

    mov filter_I+4, w8
    mov filter_Q+4, w9
    call angle_amplitude

;---------------------------------------------- report results

    push w9

    mov w8, w0
    mov #str_buf, w1
    call word_to_udec_str
    mov #str_buf, w0
    call tx_ram_str_232

    mov #'\n', w0
    call tx_char_232

    pop w0
    mov #str_buf, w1
    call word_to_udec_str
    mov #str_buf, w0
    call tx_ram_str_232

    mov #'\n', w0
    call tx_char_232
    mov #'\n', w0
    call tx_char_232







    bra retry


.end

