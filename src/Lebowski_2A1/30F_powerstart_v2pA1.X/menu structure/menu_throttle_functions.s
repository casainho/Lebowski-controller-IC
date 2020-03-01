.include "p30F4011.inc"
.include "defines.inc"

.text

;******************************************************

.global throttle_tryout
throttle_tryout:
;-------------------------------------- initialise

    call throttle_open
                                            ;ADC's on
    call ADC_open
                                            ;initalise TMR4 for 30 msec
    bclr IEC1, #5                           		;no interrupts on TMR4
    clr TMR4                                		;set count to 0
    mov #0b1000000000110000, w0             		;tmr4 on, 8.5usec/count
    mov w0, T4CON
    mov #3600, w0                           ;once every 30 msec
    mov w0, PR4

;-------------------------------------- run every 30 msec (based on timer or can RX interrupt)
thtr_mainloop:
    btss IFS1, #5
    bra thtr_mainloop
                                            ;reset TMR4 overflow
    bclr IFS1, #5

;-------------------------------------- compute throttle values
                                            ;analog throttles -> do read manually. Else all is taken care of by CAN RX interrupt
    call throttle_read

;-------------------------------------- generate string 
                                            ;empty string
    mov #str_buf, w13
    mov #' ', w0
    repeat #63
    mov.b w0, [w13++]
                                            ;place markers, \n and \0
    mov #'-', w0
    mov.b wreg, str_buf+24
    mov #'+', w0
    mov.b wreg, str_buf+64
    mov #'|', w0
    mov.b wreg, str_buf
    mov.b wreg, str_buf+20
    mov #'0', w0
    mov.b wreg, str_buf+44
    mov #'\n', w0
    mov.b wreg, str_buf+65
    clr.b str_buf+66
                                            ;place '1', '2','X' and 'F'or'R'
    mov #str_buf, w13

    mov throttle_raw1, w0
    mov #21, w1
    mul.uu w0, w1, w0
    mov #'1', w0
    mov.b w0, [w13+w1]

    mov throttle_raw2, w0
    mov #21, w1
    mul.uu w0, w1, w0
    mov #'2', w0
    mov.b w0, [w13+w1]

    mov #str_buf+44, w13
	
    mov throttle, w0
    mov #40, w1
    mul.su w0, w1, w0
    mov #0x8000, w2
    add w0, w2, w0
    addc #0, w1
    mov #'X', w0
    mov.b w0, [w13+w1]

	mov #'F', w0
	btsc flags1, #reverse_request
	mov #'R', w0
	mov.b wreg, str_buf+22
	
;-------------------------------------- send string

    mov #str_buf, w0
    call tx_ram_str_232

;-------------------------------------- repeat until button pressed

    btss U2STA, #0
    bra thtr_mainloop
                                            ;read character to get rid of it
    call rx_char_232

;-------------------------------------- shutdown and end
                                            ;shutdown TMR4
    bclr T4CON, #15
                                            ;shutdown CAN
    bclr IEC1, #11
    bclr C1CTRL, #15
                                            ;shutdown ADC's
    bclr ADCON1, #15

    return

;*****************************************************************

;on call: w13 constains start address coefficient array

.global mthr_enter_poly_coeff
mthr_enter_poly_coeff:

    mov #tblpage(menu_enter_coeff), w0
    mov #tbloffset(menu_enter_coeff), w1
    call tx_str_232

    mov #10, w0
    call get_signed_decimal_number
    sl w0, #12, w0
    lsr w1, #4, w1
    ior w0, w1, w0
    mov w0, [w13++]

    mov #10, w0
    call get_signed_decimal_number
    sl w0, #12, w0
    lsr w1, #4, w1
    ior w0, w1, w0
    mov w0, [w13++]

    mov #10, w0
    call get_signed_decimal_number
    sl w0, #12, w0
    lsr w1, #4, w1
    ior w0, w1, w0
    mov w0, [w13]

    return

;------------------------------------------------------

;on call: w0 contains measured voltage (in 5 mV per LSB)

.global mthr_print_voltage
mthr_print_voltage:
    push w0

    mov #tblpage(mthr_print_volt_msg1), w0
    mov #tbloffset(mthr_print_volt_msg1), w1
    call tx_str_232

    pop w0
    mov #20000, w1
    mul.uu w0, w1, w0                       ;0..1023 * (65536 * 5 * 1/16 * 1/1.024)

    mov w1, w0
    mov #str_buf, w1
    call word_to_udec_str
    mov #str_buf, w0
    call tx_ram_str_232

    mov #tblpage(mthr_print_volt_msg2), w0
    mov #tbloffset(mthr_print_volt_msg2), w1
    call tx_str_232

    return

;------------------------------------------------------

;on call: w0 contains number [-8..8] to print

.global menu_thr_print_number
menu_thr_print_number:

    mov w0, w2
    btss w2, #15
    bra mtpn_positive
                                            ;if negative, print '-' and make positive
    mov #'-', w0
    call tx_char_232
    neg w2, w2
mtpn_positive:                              ;print integer part
    lsr w2, #12, w0
    mov #str_buf, w1
    call word_to_udec_str
    mov #str_buf, w0
    call tx_ram_str_232
                                            ;print decimal part
    sl w2, #4, w0
    mov #str_buf, w1
    call word_to_01_str
    mov #str_buf, w0
    call tx_ram_str_232

    return

;**********************************************************

menu_enter_coeff:
    .pascii " enter the 3 coefficients [-8..8]\n\0"
mthr_print_volt_msg1:
    .pascii "\n measured voltage: \0"
mthr_print_volt_msg2:
    .pascii " mV\n\0"


.end

