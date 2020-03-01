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

    call find_dualtone_amplitude

;---------------------------------------------- report

    mov ampli_tone3, w0
    mov #str_buf, w1
    call word_to_udec_str
    mov #str_buf, w0
    call tx_ram_str_232

    mov #'\n', w0
    call tx_char_232

    mov ampli_tone4, w0
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

