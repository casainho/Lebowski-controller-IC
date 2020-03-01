.include "p30F4011.inc"

.text

.global init_232
;initalise UART2 for RS232 communication
;speed with 120MHz clk: 115200 baud

init_232:
						;select 115200 baud
    mov #15, w0
    mov w0, U2BRG
						;enable, no loopback, no auto-baud, 8bit no parity, 1 stop bit
    mov #0x8000, w0
    mov w0, U2MODE
						;normal TX pin, enable TX, no address detect, interrupt when character RX-ed
    mov #0x0400, w0
    mov w0, U2STA
	
    return

;*****************************************************************

.global tx_ram_str_232
;w0: start of string (in RAM)

tx_ram_str_232:
						;save register
    push w1
						;address to w1
    mov w0, w1
trs2_lp:
						;get char
    mov.b [w1++], w0                
						;test for end of string
    cp0.b w0                       
    bra z, trs2_end				;if yes end
							;if no display char
    call tx_char_232                       
    bra trs2_lp
trs2_end:
						;restore registers
    pop w1
    return

;*****************************************************************

.global tx_str_232
;w0: start of string (in prog memory), higher 8 bits of address
;w1: start of string (in prog memory), lower 16 bits of address
	
tx_str_232:
    and #0xff, w0				;clr top 8 bits of w0
								;write TBLPAG
    mov w0, TBLPAG
ts2_lp:		
								;read first low character
	tblrdl [w1], w0
	ze w0, w0
    cp0 w0
    btsc SR,#Z
    return
    call tx_char_232
								;read second low character
	tblrdl [w1], w0
	lsr w0, #8, w0
    cp0 w0
    btsc SR,#Z
    return
    call tx_char_232
								;read high character
	tblrdh [w1], w0
    cp0 w0
    btsc SR,#Z
    return
    call tx_char_232

	inc2 w1, w1
    cp0 w1						;if w1=0x0000 then ++TBLPAG
    btsc SR, #Z
    inc TBLPAG
								;continue with next character
    bra ts2_lp
	
	
	
;*****************************************************************

.global tx_char_232
;w0: contains character

tx_char_232:
    btsc U2STA, #9                              ;make sure no longer tx-ing
    bra tx_char_232
						;tx character
    mov w0, U2TXREG

    return

;*****************************************************************
.global tx_word_232
;w0: contains word to be send, top byte first

tx_word_232:
						;save registers, input value
    push w1
    mov w0, w1
						;send top byte
    swap w1						;swap so top byte is not at bottom
    mov #0x00FF, w0
    and w1, w0, w0					;mask, only bottom byte
    call tx_char_232
						;send lower byte
    swap w1						;swap back
    mov #0x00FF, w0
    and w1, w0, w0					;mask, only bottom byte
    call tx_char_232
						;restore registers
    pop w1
    return

;*****************************************************************
.global clr_scr_232

clr_scr_232:
						;save registers
    push w0
						;send 30 \n characters
    mov #'\n', w0
    do #29, cs3_last
    call tx_char_232
    nop
cs3_last:
    nop
						;restore registers
    pop w0
    return


;*****************************************************************

.global rx_str_232
;w0: length of buffer for rx
;w1: start of string in data memory, max w0 characters
;terminates on '\r' (carriage return, = pressing enter)

rx_str_232:
						;store registers
    push w3					;w3 is buffer lenght-1
    push w2						;w2 (0 to 9) is offset character storage address
						;initialise registers
    dec w0, w3					;w3 = w0-1
    clr w2                                          ;start at beginning
rs2_lp:
    call rx_char_232
						;w0 = backspace ?
    cp w0, #'\b'
    bra nz, rs2_no_bs				;continue if not backspace
                                                    ;w2 = 0 ? then do nothing
    cp0 w2
    bra z, rs2_lp
                                                    ;else delete previous char
    mov #' ', w0                                        ;necessary for if we're on last character
    call tx_char_232
    mov #'\b', w0
    call tx_char_232
    mov #'\b', w0
    call tx_char_232
    mov #' ', w0
    call tx_char_232
    mov #'\b', w0
    call tx_char_232
                                                    ;decrement w2
    dec w2, w2
    bra rs2_lp
	
rs2_no_bs:
						;w0 = '\r' ? (enter key = carriage return)
    cp w0, #'\r'
    bra nz, rs2_no_ret				;continue if not return
                                                    ;store \0 and display \n
    clr.b w0
    mov.b w0, [w1+w2]
    mov #' ', w0                                    ;in case we're on last character
    call tx_char_232
    mov #'\n', w0
    call tx_char_232
                                                    ;exit routine
    pop w2
    pop w3
    return
rs2_no_ret:
						;store and display character
    mov.b w0, [w1+w2]
    call tx_char_232
                                                    ;if w2 = w3 send backspace for overwrite (buffer end)
    mov #'\b', w0                                   ;prepare the backspace, just in case it needs to be send
    cp w2, w3
    btsc SR, #Z
    call tx_char_232
                                                    ;if w2 != w3 then w2+=1
    cp w2, w3
    btss SR, #Z
    inc w2, w2
						;next character
    bra rs2_lp

;*****************************************************************

.global rx_char_232
;w0: contains character after return

rx_char_232:
						;wait until data available
    btss U2STA, #0
    bra rx_char_232
						;get rx data
    mov U2RXREG, w0
    and #0xff, w0

    return

;*****************************************************************

.global rx_hex_232
;w0: contains read word after return

rx_hex_232:
                                                ;save variables
    push w1
                                                ;wait for '0x'
rh2_lp1:
    call rx_char_232
    sub #'0', w0
    bra nz, rh2_lp1
    call rx_char_232
    sub #'x', w0
    bra nz, rh2_lp1
                                                ;process the next 4 characters
    call rx_char_232
    sub #'0', w0
    cp w0, #10
    btsc SR, #C
    sub #'A'-'0'-10, w0
    sl w0, #4, w1

    call rx_char_232
    sub #'0', w0
    cp w0, #10
    btsc SR, #C
    sub #'A'-'0'-10, w0
    add w0, w1, w1

    sl w1, #4, w1
    call rx_char_232
    sub #'0', w0
    cp w0, #10
    btsc SR, #C
    sub #'A'-'0'-10, w0
    add w0, w1, w1

    sl w1, #4, w1
    call rx_char_232
    sub #'0', w0
    cp w0, #10
    btsc SR, #C
    sub #'A'-'0'-10, w0
    add w0, w1, w0
                                               ;restore variables
    pop w1

    return

;*****************************************************************

.global rx_endchar_232

rx_endchar_232:
    call rx_char_232
    sub #'*', w0
    bra nz, rx_endchar_232

    return

;*****************************************************************


.end

