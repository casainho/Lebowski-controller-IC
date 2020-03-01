.include "p30F4011.inc"
.include "defines.inc"
.include "temp_macros.s"

.text

;***********************************************
.global temperature_readings
temperature_readings:

;---------------------------------------------- exit on error
                                                    ;number_temp_sensors > 0
    cp0 number_temp_sensors
    btsc SR, #Z
    return
                                                    ;exit when no sensors found
    call temp_sensors_reset
    btss flags1, #temp_sensor_found
    return
;---------------------------------------------- initialise
    call temp_open
                                                    ;initialise flags
    bclr flags1, #temp_sensor_cycle
                                                    ;start timers
    call timers_open
;---------------------------------------------- get readings
tr_1:

    btss IFS0, #3
    bra tr_1
    bclr IFS0, #3

;    bset LATD, #2

    mov temp_readout, w14
    call w14

;    bclr LATD, #2

    btss flags1, #temp_sensor_cycle
    bra tr_1

    bclr flags1, #temp_sensor_cycle

;---------------------------------------------- display results
    mov number_temp_sensors, w12
    mov #temp_data, w13

tr_disp_lp:
                                                    ;print before comma part
    asr [w13], w0
    mov #str_buf, w1
    call word_to_sdec_str
    mov #str_buf, w0
    call tx_ram_str_232
                                                    ;print after comma part, only 2 characters
    mov [w13++], w0
    sl w0, #15, w0
    mov #str_buf, w1
    call word_to_01_str
    clr.b str_buf+2
    mov #str_buf, w0
    call tx_ram_str_232
                                                    ;print tab
    mov #'\t', w0
    call tx_char_232
                                                    ;loop
    dec w12, w12
    bra nz, tr_disp_lp
                                                    ;print temp_red_i_max_phase
	mov temp_red_i_max_phase, w0
	call display_current										
    mov #' ', w0
    call tx_char_232
    mov #'A', w0
    call tx_char_232
													;print return
    mov #'\n', w0
    call tx_char_232

;---------------------------------------------- again if no key pressed
    btss U2STA, #0
    bra tr_1
                                                    ;read character to get rid of it
    call rx_char_232
;---------------------------------------------- reset and shutdown sensors
    call temp_sensors_reset
;---------------------------------------------- end
    return

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
                                                    ;exit with error message when no sensors found
    btsc flags1, #temp_sensor_found
    bra tri_sens_found
                                                    ;make number_temp_sensors 0
    clr number_temp_sensors

    mov #tblpage(tri_msg_not_found), w0
    mov #tbloffset(tri_msg_not_found), w1
    return

tri_sens_found:
                                                    ;reset counter, keeps track of the bit we're processing
    clr counter
;---------------------------------------------- send 'search rom' command
    call tri_search_rom_command

;---------------------------------------------- bit loop
tri_bit_loop:
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
    bra nz, tri_error_sensors_stuck_0
    call tri_receive_bit
    cp0 w0
    bra nz, tri_error_sensors_stuck_0
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
    bra nz, tri_error_sensors_stuck_0

    mov #ic2_triplevel, w0
    subr IC2BUF, wreg
    bra c, tri_code_1x
tri_code_0x:
    call tri_receive_bit
    cp0 w0
    bra nz, tri_error_sensors_stuck_0

    mov #ic2_triplevel, w0
    subr IC2BUF, wreg
    bra c, tri_code_01
;---------------------------------------------- code 00: two sensor conflict
tri_code_00:
                                                    ;add extra sensor, exit with error if not possible
    mov #7, w0
    cp temp_sens_now
    bra z, tri_error_too_many_sensors

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
    bra nz, tri_error_sensors_stuck_0

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
    bra tri_error_contact_lost
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
;---------------------------------------------- at this point sensors all found
;---------------------------------------------- run CRC check on all sensors
    call temp_check_id_CRC
    cp0 w0
    bra nz, tri_crc_error
;---------------------------------------------- all sensors found successfully, end
    mov #tblpage(tri_msg_all_ok), w0
    mov #tbloffset(tri_msg_all_ok), w1
    return

;***********************************************

tri_error_sensors_stuck_0:
    clr number_temp_sensors
    mov #tblpage(tri_msg_stuck_0), w0
    mov #tbloffset(tri_msg_stuck_0), w1
    return

tri_error_too_many_sensors:
    clr number_temp_sensors
    mov #tblpage(tri_msg_too_many_sensors), w0
    mov #tbloffset(tri_msg_too_many_sensors), w1
    return

tri_error_contact_lost:
    clr number_temp_sensors
    mov #tblpage(tri_msg_contact_lost), w0
    mov #tbloffset(tri_msg_contact_lost), w1
    return

tri_crc_error:
    clr number_temp_sensors
    mov #tblpage(tri_msg_crc_error), w0
    mov #tbloffset(tri_msg_crc_error), w1
    return

;***********************************************
tri_msg_not_found:
    .pascii "\n no sensors found\0"
tri_msg_stuck_0:
    .pascii "\n sensor output stuck at 0\0"
tri_msg_too_many_sensors:
    .pascii "\n too many temp sensors (max 8 supported)\0"
tri_msg_contact_lost:
    .pascii "\n contact lost with sensors\0"
tri_msg_crc_error:
    .pascii "\n CRC error\0"
tri_msg_all_ok:
    .pascii "\n sensor(s) identified successfully\0"

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
.global print_sensor_ids
print_sensor_ids:
;---------------------------------------------- initialise
                                                    ;w10: counter for with which sensor we're busy
    mov number_temp_sensors, w10
    cp0 w10
    btsc SR, #Z
    return

    mov #temp_ids+6, w11

    mov #'\n', w0
    call tx_char_232


psi_lp:
;---------------------------------------------- display temp_ids

    mov #'\n', w0
    call tx_char_232
    mov #' ', w0
    call tx_char_232

    mov w10, w0
    sub number_temp_sensors, wreg
    mov #str_buf, w1
    call word_to_udec_str
    mov #str_buf, w0
    call tx_ram_str_232

    mov #':', w0
    call tx_char_232
    mov #' ', w0
    call tx_char_232

    mov #4, w0
    mov w0, counter
psi_ilp:
    mov [w11--], w0
    mov #str_buf, w1
    call word_to_hex_str
    mov #str_buf, w0
    call tx_ram_str_232
    mov #' ', w0
    call tx_char_232
    
    dec counter
    bra nz, psi_ilp
;---------------------------------------------- display all sensors
    add #16, w11


    dec w10, w10
    bra nz, psi_lp
;---------------------------------------------- end
    return

;***********************************************

;on return
;w0 = 0 : good, others -> not good.
;
temp_check_id_CRC:
;---------------------------------------------- initialise
    clr temp_sens_now
;---------------------------------------------- sensor loop
tcic_sensloop:
    clr temp_crc
                                                    ;counter is used as bit counter
    clr counter
;---------------------------------------------- (64) bit loop
tcic_bitloop:
;---------------------------------------------- calc address (w11) and bit (w12)
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
;---------------------------------------------- next bit
    inc counter
    mov #64, w0
    cp counter
    bra nz, tcic_bitloop
;---------------------------------------------- next sensor
    cp0 temp_crc
    bra nz, tcic_error

    inc temp_sens_now
    mov temp_sens_now, w0
    cp number_temp_sensors
    bra nz, tcic_sensloop
;---------------------------------------------- end
    retlw #0, w0

tcic_error:
    retlw #1, w0
	
	
;**********************************************************
.global print_temp_limits
print_temp_limits:

	cp0 number_temp_sensors
	bra nz, ptl_start
	return
ptl_start:
;---------------------------------------------- initialise

	clr counter
	mov #'\n', w0
	call tx_char_232
	mov #'\n', w0
	call tx_char_232
ptl_lp:
;---------------------------------------------- print number
	mov #'0', w0
	add counter, wreg
	call tx_char_232
	
	mov #tblpage(pr_temp_mes_a), w0
    mov #tbloffset(pr_temp_mes_a), w1
    call tx_str_232
;---------------------------------------------- print temp limit
	mov #temp_limit, w13
	sl counter, wreg
	add w13, w0, w13
	                                                ;print before comma part
    asr [w13], w0
    mov #str_buf, w1
    call word_to_sdec_str
    mov #str_buf, w0
    call tx_ram_str_232
                                                    ;print after comma part, only 2 characters
    mov [w13], w0
    sl w0, #15, w0
    mov #str_buf, w1
    call word_to_01_str
    clr.b str_buf+2
    mov #str_buf, w0
    call tx_ram_str_232
													;print text
    mov #tblpage(pr_temp_mes_b), w0
    mov #tbloffset(pr_temp_mes_b), w1
    call tx_str_232
;---------------------------------------------- print current reduction
	mov #temp_current_red, w13
	sl counter, wreg
	add w13, w0, w13
													;double result as data is stored in A/half degC
	sl [w13], w0
	call display_current
													;print text
    mov #tblpage(pr_temp_mes_c), w0
    mov #tbloffset(pr_temp_mes_c), w1
    call tx_str_232	
;---------------------------------------------- end
	inc counter
	mov number_temp_sensors, w0
	cp counter
	bra nz, ptl_lp
		
	return

;---------------------------------------------- text

pr_temp_mes_a:
	.pascii ") reduce max phase current above \0"
pr_temp_mes_b:
	.pascii " degC by \0"
pr_temp_mes_c:
	.pascii " A/degC\n\0"
	
;**********************************************************
.global enter_temp_limits
;
;on call w0 has the entered character
;
enter_temp_limits:

	cp0 number_temp_sensors
	bra nz, etl_start
	return
etl_start:
;---------------------------------------------- initialise
													;keep w0 for menu_temp
	push w0
													;keep track of arrays
	mov #temp_limit, w13
	mov #temp_current_red, w12
	mov number_temp_sensors, w1
	mov w1, counter
	mov #'0', w1
;---------------------------------------------- loop through the characters, exit if not selected
etl_lp:
	cp w0, w1
	bra z, etl_cont
													;next character
	inc2 w13, w13
	inc2 w12, w12
	inc w1, w1
	dec counter
	bra nz, etl_lp
													;exit with w0 preserved !
	pop w0
	return
etl_cont:
;---------------------------------------------- ask for temperature limit, store
    mov #tblpage(etl_temp_mes_a), w0
    mov #tbloffset(etl_temp_mes_a), w1
    call tx_str_232	
													;times 2 as temp is in 0.5 degC/LSB
	mov #10, w0
    call get_signed_decimal_number

	rlc w1, w1
	rlc w0, [w13]
	
;---------------------------------------------- ask for current reduction, store
    mov #tblpage(etl_temp_mes_b), w0
    mov #tbloffset(etl_temp_mes_b), w1
    call tx_str_232	
													;divide by 2 as temp is 0.5 degC/LSB
	mov #10, w0
    call get_signed_decimal_number
    btsc w0, #15
    com w1, w1
    btsc w0, #15
    com w0, w0
    call current_to_lsb
	asr w0, [w12]

;---------------------------------------------- end
													;exit with w0 preserved !
	pop w0
	return
	
;---------------------------------------------- text

etl_temp_mes_a:
	.pascii "\ntemperature above which to reduce phase current [in degC]:\n\0"
etl_temp_mes_b:
	.pascii "\nreduce phase current by [in A/degC]:\n\0"
