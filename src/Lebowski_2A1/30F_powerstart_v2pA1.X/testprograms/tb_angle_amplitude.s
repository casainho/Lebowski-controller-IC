.include "p30F4011.inc"
.include "defines.inc"

.text

;*****************************************************************

.global main
main:						
						
;---------------------------------------------- initialise
                                                    ;global initialise
    call initialise
                                                    ;wait for any key
	call rx_char_232

;---------------------------------------------- measure

    mov #-500, w8
    mov #500, w9
    call angle_amplitude

;---------------------------------------------- report

    push w9

    mov w8, w0
    mov #str_buf, w1
    call word_to_udec_str
    mov #str_buf, w0
    call tx_ram_str_232

    mov #'\n', w0
    call tx_char_232

    pop w9

    mov w9, w0
    mov #str_buf, w1
    call word_to_udec_str
    mov #str_buf, w0
    call tx_ram_str_232

    mov #'\n', w0
    call tx_char_232
    mov #'\n', w0
    call tx_char_232

hangloop:
    bra hangloop


.end

