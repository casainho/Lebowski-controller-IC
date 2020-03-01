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

    call temp_sensors_reset

    call read_rom_command

    mov #temp_ids, w0
    repeat #3
    clr [w0++]

    clr counter
    clr temp_crc

main_lp:
    call tri_receive_bit
                                                    ;calc address
    mov #temp_ids, w11
    mov counter, w0
    lsr w0, #4, w0
    add w11, w0, w11
    add w11, w0, w11
                                                    ;calc bit
    mov #0x000F, w12
    mov counter, w0
    and w12, w0, w12
                                                    ;update address content
    mov #ic2_triplevel, w0
    subr IC2BUF, wreg

    bsw.c [w11], w12
;---------------------------------------------- update crc
    mov #0x008C, w0
                                                    ;rotate
    lsr temp_crc
                                                    ;XOR based on carry
    btsc SR,#C
    xor temp_crc
                                                    ;XOR based on carry from the just received bit
    btst.c [w11], w12
    btsc SR,#C
    xor temp_crc
;---------------------------------------------- print crc

    mov temp_crc, w0
    mov #str_buf, w1
    call word_to_hex_str
    mov #str_buf, w0
    call tx_ram_str_232
    mov #'\n', w0
    call tx_char_232

;---------------------------------------------- continue with receiving

    inc counter
    mov #64, w0
    cp counter
    bra nz, main_lp

;---------------------------------------------- print output

    mov temp_ids+6, w0
    mov #str_buf, w1
    call word_to_hex_str
    mov #str_buf, w0
    call tx_ram_str_232
    mov #' ', w0
    call tx_char_232

    mov temp_ids+4, w0
    mov #str_buf, w1
    call word_to_hex_str
    mov #str_buf, w0
    call tx_ram_str_232
    mov #' ', w0
    call tx_char_232

    mov temp_ids+2, w0
    mov #str_buf, w1
    call word_to_hex_str
    mov #str_buf, w0
    call tx_ram_str_232
    mov #' ', w0
    call tx_char_232

    mov temp_ids+0, w0
    mov #str_buf, w1
    call word_to_hex_str
    mov #str_buf, w0
    call tx_ram_str_232
    mov #' ', w0
    call tx_char_232

hangloop:
    bra hangloop


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
read_rom_command:
                                                    ;tx 0x33, LSB's first
    call tri_send_1
    call tri_send_1
    call tri_send_0
    call tri_send_0
    call tri_send_1
    call tri_send_1
    call tri_send_0
    call tri_send_0

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

extra_sensor:
;---------------------------------------------- calc amount of data to be moved, (7-temp_sens_now) - 1
    mov #7, w0
    subr temp_sens_now, wreg
    dec w0, w0
;---------------------------------------------- calc addresses in temp_data array
    mov #temp_data+14, w12
    mov #temp_data+12, w13
;---------------------------------------------- move data from [w13] to [w12]
    repeat w0
    mov [w13--], [w12--]
;---------------------------------------------- calc amount of data to be moved, 4*(7-temp_sens_now) - 1
    mov #7, w0
    subr temp_sens_now, wreg
    sl w0,#2, w0
    dec w0, w0
;---------------------------------------------- calc addresses in temp_ids array
    mov #temp_ids+62, w12
    mov #temp_ids+54, w13
;---------------------------------------------- move data
    repeat w0
    mov [w13--], [w12--]
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
;---------------------------------------------- end
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


.end