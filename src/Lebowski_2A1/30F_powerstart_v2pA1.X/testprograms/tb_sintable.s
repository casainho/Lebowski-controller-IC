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

	clr w11
	mov #256, w10
	mov #data_array_sin, w13

;---------------------------------------------- loop 
mlp:

;---------------------------------------------- retrieve sine

    mov [w13++], w0
	add w11, w0, w11
	
	push w13
	push w11
	push w10
;---------------------------------------------- transmit filter output

    mov #str_buf, w1
    call word_to_sdec_str
    mov #str_buf, w0
    call tx_ram_str_232
	
	mov #'\n', w0
	call tx_char_232

;---------------------------------------------- loop
	pop w10
	pop w11
	pop w13
	
	dec w10, w10
	bra nz, mlp
;---------------------------------------------- end
	
	mov #'\n', w0
	call tx_char_232
	mov #'\n', w0
	call tx_char_232
	mov #'\n', w0
	call tx_char_232
													;print total
	mov w11, w0
	mov #str_buf, w1
    call word_to_sdec_str
    mov #str_buf, w0
    call tx_ram_str_232
	
	mov #'\n', w0
	call tx_char_232

	

hangloop:
	bra hangloop
	
	
.end

