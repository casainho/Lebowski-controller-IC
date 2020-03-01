.include "p30F4011.inc"
.include "defines.inc"
.include "temp_macros.s"

.text

;*****************************************************************

.global main_tb
main_tb:
						
;---------------------------------------------- initialise
                                                    ;global initialise
    call initialise
;---------------------------------------------- read id's
    call temp_read_ids
;---------------------------------------------- display error code
/*
    push w0

    mov #'\n', w0
    call tx_char_232
    mov #'\n', w0
    call tx_char_232

    pop w0

    mov #str_buf, w1
    call word_to_hex_str
    mov #str_buf, w0
    call tx_ram_str_232

    mov #'\n', w0
    call tx_char_232
*/
hangloop:
    bra hangloop


;***********************************************
;error code in w0 on exit:
;0: all OK


.global temp_read_ids
temp_read_ids:
;---------------------------------------------- initialise
    call initialise_read_ids
;---------------------------------------------- sensor loop
tri_sens_loop:
;---------------------------------------------- reset sensors
    call temp_sensors_reset
                                                    ;exit with error code 1 if no sensors found
    btss flags1, #temp_sensor_found
    retlw #1, w0
                                                    ;reset counter, keeps track of the bit we're processing
    clr counter
;---------------------------------------------- send 'search rom' command
    call tri_search_rom_command

;---------------------------------------------- bit loop
tri_bit_loop:

    push counter

    call print_data

    pop counter

    mov counter, w0
    mov #str_buf, w1
    call word_to_hex_str
    mov #str_buf, w0
    call tx_ram_str_232

    mov #' ', w0
    call tx_char_232

    mov temp_sens_now, w0
    mov #str_buf, w1
    call word_to_hex_str
    mov #str_buf, w0
    call tx_ram_str_232


;---------------------------------------------- prepare address (w11) and bit variable (w12)
                                                    ;calc address
    mov #temp_ids, w11
    mov temp_sens_now, w0
    sl w0, #3, w0
    add w11, w0, w11
    mov counter, w0
    lsr w0, #4, w0
    add w11, w0, w11
    add w11, w0, w11
                                                    ;calc bit
    mov #0x000F, w12
    mov counter, w0
    and w12, w0, w12

;---------------------------------------------- bit not known yet ? (bit is not known when counter = [temp_data for this sensor]

    mov #temp_data, w13
    sl temp_sens_now, wreg
    add w13, w0, w13
    mov [w13], w0
    cp counter
    bra z, tri_new_bit

tri_known_bit:
                                                    ;receive and discard two bits
    call tri_receive_bit
    cp0 w0
    bra nz, tri_error
    call tri_receive_bit
    cp0 w0
    bra nz, tri_error
                                                    ;tx known bit
    btst.c [w11], w12
    btss SR,#C
    call tri_send_0

    btst.c [w11], w12
    btsc SR,#C
    call tri_send_1
                                                    ;prevent increase of bit counter by decreasing [w13]
    dec [w13], [w13]

    bra tri_continue

;---------------------------------------------- receive first bit
tri_new_bit:
    call tri_receive_bit
    cp0 w0
    bra nz, tri_error

    mov #ic2_triplevel, w0
    subr IC2BUF, wreg
    bra c, tri_code_1x
tri_code_0x:
    call tri_receive_bit
    cp0 w0
    bra nz, tri_error

    mov #ic2_triplevel, w0
    subr IC2BUF, wreg
    bra c, tri_code_01
;---------------------------------------------- code 00: two sensor conflict
tri_code_00:
                                                    ;add extra sensor, exit with error if not possible
    mov #7, w0
    cp temp_sens_now
    bra z, tri_error

    call tri_extra_sensor
                                                    ;set this sensor to '0'
    bclr SR, #C
    bsw.c [w11], w12
                                                    ;set extra sensor to '1'
    add #8, w11
    bset SR, #C
    bsw.c [w11], w12
    sub #8, w11
                                                    ;increase bit counter extra sensor (as bit is set to '1')
    add #2, w13
    inc [w13], [w13]
    sub #2, w13
                                                    ;add sensor
    inc number_temp_sensors
                                                    ;tx '0'
    call tri_send_0
    bra tri_continue

;---------------------------------------------- code 01: 0 received
tri_code_01:
                                                    ;set bit to '0'
    bclr SR, #C
    bsw.c [w11], w12
                                                    ;tx '0'
    call tri_send_0
    bra tri_continue

tri_code_1x:
    call tri_receive_bit
    cp0 w0
    bra nz, tri_error

    mov #ic2_triplevel, w0
    subr IC2BUF, wreg
    bra c, tri_code_11
;---------------------------------------------- code 10: 1 received
tri_code_10:
                                                    ;set bit to '1'
    bset SR, #C
    bsw.c [w11], w12
                                                    ;tx '1'
    call tri_send_1
    bra tri_continue
;---------------------------------------------- code 11: contact lost with sensors
tri_code_11:
    bra tri_error
;---------------------------------------------- continue, update bit counters
tri_continue:
                                                    ;increase bit counter for this sensor [w13]
    inc [w13], [w13]
                                                    ;increase counter and continue with this sensor if < 64
    inc counter
    mov #64, w0
    cp counter
    bra nz, tri_bit_loop
;---------------------------------------------- another sensor ?
    inc temp_sens_now
    mov number_temp_sensors, w0
    cp temp_sens_now
    bra nz, tri_sens_loop
;---------------------------------------------- all sensors found successfully, end
    return


tri_error:
    clr number_temp_sensors
    call LEDs_open
    bset LATC, #15
    bset LATC, #13
    bset LATC, #14
    bset LATE, #8

    return


;***********************************************

tri_extra_sensor:
;---------------------------------------------- calc amount of data to be moved, (7-temp_sens_now) - 1
    mov #7, w0
    subr temp_sens_now, wreg
    dec w0, w0
;---------------------------------------------- calc addresses in temp_data array
    mov #temp_data+14, w2
    mov #temp_data+12, w3
;---------------------------------------------- move data from [w3] to [w2]
    repeat w0
    mov [w3--], [w2--]
;---------------------------------------------- calc amount of data to be moved, 4*(7-temp_sens_now) - 1
    mov #7, w0
    subr temp_sens_now, wreg
    sl w0,#2, w0
    dec w0, w0
;---------------------------------------------- calc addresses in temp_ids array
    mov #temp_ids+62, w2
    mov #temp_ids+54, w3
;---------------------------------------------- move data
    repeat w0
    mov [w3--], [w2--]
;---------------------------------------------- end
    return


;***********************************************

initialise_read_ids:
;---------------------------------------------- initialise temp_data to 0x0000
    mov #temp_data, w10

    repeat #7
    clr [w10++]

;---------------------------------------------- initialise temp_ids to 0x0000
    mov #temp_ids, w10

    repeat #31
    clr [w10++]
;---------------------------------------------- initialise temp_sens_now to 0x0000
    clr temp_sens_now
;---------------------------------------------- set number_temp_sensors to 1
    mov #1, w0
    mov w0, number_temp_sensors
;---------------------------------------------- end
    return


;***********************************************
tri_receive_bit:
                                                    ;clr pin, low-Z
    bclr LATD, #1
    bclr TRISD, #1
                                                    ;initialise timer for 2 usec
    mov #t2_2u, w0
    mov w0, PR2
    clr TMR2
    bclr IFS0, #6
                                                    ;initialise rising edge capture
    mov #0b0000000010000000, w0
    mov w0, IC2CON
    nop
    nop
    mov #0b0000000010000011, w0
    mov w0, IC2CON
                                                    ;wait for timer to trip
1:
    btss IFS0, #6
    bra 1b
                                                    ;make pin high-Z
    bset TRISD, #1
                                                    ;move timer to 80 usec
    mov #t2_80u, w0
    mov w0, PR2
    bclr IFS0, #6
                                                    ;wait for timer to trip
1:
    btss IFS0, #6
    bra 1b
                                                    ;print capture content, if any
    btss IC2CON, #3
    retlw #1, w0

    retlw #0, w0

;***********************************************
tri_send_0:
                                                    ;clr pin, low-Z
    bclr LATD, #1
    bclr TRISD, #1
                                                    ;initialise timer for 80 usec
    mov #t2_80u, w0
    mov w0, PR2
    clr TMR2
    bclr IFS0, #6
                                                    ;wait for timer to trip
1:
    btss IFS0, #6
    bra 1b
                                                    ;make pin high-Z
    bset TRISD, #1
                                                    ;initialise timer for 5 usec
    mov #t2_5u, w0
    mov w0, PR2
    clr TMR2
    bclr IFS0, #6
                                                    ;wait for timer to trip
1:
    btss IFS0, #6
    bra 1b

    return
;***********************************************
tri_send_1:
                                                    ;clr pin, low-Z
    bclr LATD, #1
    bclr TRISD, #1
                                                    ;initialise timer for 5 usec
    mov #t2_5u, w0
    mov w0, PR2
    clr TMR2
    bclr IFS0, #6
                                                    ;wait for timer to trip
1:
    btss IFS0, #6
    bra 1b
                                                    ;make pin high-Z
    bset TRISD, #1
                                                    ;initialise timer for 80 usec
    mov #t2_80u, w0
    mov w0, PR2
    clr TMR2
    bclr IFS0, #6
                                                    ;wait for timer to trip
1:
    btss IFS0, #6
    bra 1b


    return

;***********************************************
tri_search_rom_command:
                                                    ;tx 0xF0, LSB's first
    call tri_send_0
    call tri_send_0
    call tri_send_0
    call tri_send_0
    call tri_send_1
    call tri_send_1
    call tri_send_1
    call tri_send_1

    return
;***********************************************
temp_sensors_reset:
;---------------------------------------------- send reset pulse
                                                    ;clr pin, low-Z
    bclr LATD, #1
    bclr TRISD, #1
                                                    ;initialise timer for 600 usec
    mov #t2_600u, w0
    mov w0, PR2
    clr TMR2
    bclr IFS0, #6
                                                    ;wait for timer to trip
1:
    btss IFS0, #6
    bra 1b
                                                    ;make pin high-Z
    bset TRISD, #1

;---------------------------------------------- wait for (possible) response
                                                    ;initialise timer for 100 usec
    mov #t2_100u, w0
    mov w0, PR2
    clr TMR2
    bclr IFS0, #6
                                                    ;wait for timer to trip
1:
    btss IFS0, #6
    bra 1b
                                                    ;read pin and (re)set temp_sensor_found
    bclr flags1, #temp_sensor_found
    btss PORTD, #1
    bset flags1, #temp_sensor_found
;---------------------------------------------- wait for 100usec after presence pulse
                                                    ;wait for pin to be high
1:
    btss PORTD, #1
    bra 1b
                                                    ;initialise timer for 100 usec
    mov #t2_100u, w0
    mov w0, PR2
    clr TMR2
    bclr IFS0, #6
                                                    ;wait for timer to trip
1:
    btss IFS0, #6
    bra 1b
;---------------------------------------------- end
    return

;***********************************************

patern_ids:
    mov #temp_data, w10
    clr w0

    do #7, pi_end1
    inc w0, w0
    mov w0, [w10++]
    nop
pi_end1:
    nop

    mov #temp_ids, w10
    mov #0xF000, w0

    do #31, pi_end2
    inc w0, w0
    mov w0, [w10++]
    nop
pi_end2:
    nop

    return

;***********************************************

print_data:
;---------------------------------------------- initialise
                                                    ;w10: counter for with which sensor we're busy
    mov #8, w10
    mov #temp_data, w11
    mov #temp_ids, w12

    mov #'\n', w0
    call tx_char_232
    mov #'\n', w0
    call tx_char_232

pd_lp:
;---------------------------------------------- display temp_data
    mov [w11++], w0
    mov #str_buf, w1
    call word_to_hex_str
    mov #str_buf, w0
    call tx_ram_str_232

    mov #' ', w0
    call tx_char_232
    mov #':', w0
    call tx_char_232
    mov #' ', w0
    call tx_char_232
;---------------------------------------------- display temp_ids
    mov #4, w0
    mov w0, counter
pd_ilp:
    mov [w12++], w0
    mov #str_buf, w1
    call word_to_hex_str
    mov #str_buf, w0
    call tx_ram_str_232
    mov #' ', w0
    call tx_char_232
    
    dec counter
    bra nz, pd_ilp
;---------------------------------------------- display all 8 sensors
    mov #'\n', w0
    call tx_char_232

    dec w10, w10
    bra nz, pd_lp
;---------------------------------------------- end
    return