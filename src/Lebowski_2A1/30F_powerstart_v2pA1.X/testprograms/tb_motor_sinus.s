.include "p30F4011.inc"
.include "defines.inc"

.text

;*****************************************************************

.global main_tb
main_tb:						
						
;---------------------------------------------- initialise
                                                    ;global initialise
    call initialise
    bclr PTCON, #15
                                                    ;wait for any key
	call rx_char_232

    mov #1000, w0
    mov w0, pwm_period
    mov #32760, w0
    mov w0, ampli_real
    mov #0, w0
    mov w0, ampli_imag
    mov #0, w0
    mov w0, ampli_hf_motor

    clr phi_hf_motor
    clr phi_prop
    clr ampli_prop
    clr phi_motor

;---------------------------------------------- report
lp:
    call write_motor_sinus

    push w6
    push w5

    mov w4, w0
    mov #str_buf, w1
    call word_to_udec_str
    mov #str_buf, w0
    call tx_ram_str_232

    mov #'\t', w0
    call tx_char_232

    pop w0
    mov #str_buf, w1
    call word_to_udec_str
    mov #str_buf, w0
    call tx_ram_str_232

    mov #'\t', w0
    call tx_char_232

    pop w0
    mov #str_buf, w1
    call word_to_udec_str
    mov #str_buf, w0
    call tx_ram_str_232

    mov #'\n', w0
    call tx_char_232

    mov #256, w0
    add phi_motor

    bra nz, lp

hangloop:
    bra hangloop


.end

