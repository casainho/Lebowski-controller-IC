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
                                                    ;initialise filter array
    mov #filter_I, w11
    repeat #3
    clr [w11++]

;---------------------------------------------- loop 
mlp:
;---------------------------------------------- calculate filter response

    mov #1000, w8
    mov #filter_I, w13
    mov #5, w11
    mov #10, w12

   call filter_2nd_order

;---------------------------------------------- transmit filter output

    mov filter_I+4, w0
    btg w0, #15
    call tx_word_232

;---------------------------------------------- loop

    bra mlp

;---------------------------------------------- end

.end

