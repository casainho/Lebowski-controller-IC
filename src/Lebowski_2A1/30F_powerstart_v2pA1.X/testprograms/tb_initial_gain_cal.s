.include "p30F4011.inc"
.include "defines.inc"

.text

;*****************************************************************

.global main
main:						

;---------------------------------------------- initialise
    call initialise
    call rx_char_232
                                                    ;get hf values
    mov #1000, w0
    mov w0, wanted_i_hf
    call find_hf_amplitude_adc_offset
retry:
    call initial_gain_cal

    mov filter_I+4, w0
    mov #str_buf, w1
    call word_to_sdec_str
    mov #str_buf, w0
    call tx_ram_str_232

    mov #'\t', w0
    call tx_char_232

    mov filter_Q+4, w0
    mov #str_buf, w1
    call word_to_sdec_str
    mov #str_buf, w0
    call tx_ram_str_232

    mov #'\n', w0
    call tx_char_232

    mov adc_gain_correction, w0
    mov #str_buf, w1
    call word_to_01_str
    mov #str_buf, w0
    call tx_ram_str_232

    mov #'\t', w0
    call tx_char_232

    mov adc_gain_correction+2, w0
    mov #str_buf, w1
    call word_to_01_str
    mov #str_buf, w0
    call tx_ram_str_232

    mov #'\t', w0
    call tx_char_232

    mov adc_gain_correction+4, w0
    mov #str_buf, w1
    call word_to_01_str
    mov #str_buf, w0
    call tx_ram_str_232

    mov #'\n', w0
    call tx_char_232
    mov #'\n', w0
    call tx_char_232

;---------------------------------------------- again
    bra retry


.end

