.include "p30F4011.inc"
.include "defines.inc"
.include "temp_macros.s"

.text
.global temp_open
temp_open:
                                        ;initialise routine
    mov #tbloffset(temp_read), w0
    mov w0, temp_readout
                                        ;initialise pin to high-Z
    bset TRISD, #1
    bclr LATD, #1

    return

;***********************************************

.global temp_read
temp_read:
;***********************************************
; reset sensors
;***********************************************
    reset_temp_sensors
;***********************************************
; give 'skip rom'
;***********************************************
    skip_rom
;***********************************************
; give 'all convert'
;***********************************************
    all_convert
;***********************************************
; wait for conversion to finish
;***********************************************
                                                    ;conversion done when rx '1'
1:
    call temp_receive_bit
    mov #ic2_triplevel, w0
    subr IC2BUF, wreg
    bra nc, 1b

;***********************************************
; wait for 'temp_sensor_cycle' bit to be cleared, indicating temp_data was processed by throttle
;***********************************************
1:
    T_return_main
    btsc flags1, #temp_sensor_cycle
    bra 1b
;***********************************************
; loop for all sensors
;***********************************************

    clr temp_sens_now
tere_main_lp:
;***********************************************
; reset sensors
;***********************************************
    reset_temp_sensors
;***********************************************
; give 'match rom'
;***********************************************
    match_rom
;***********************************************
; send all 64 bits identifying sensor
;***********************************************
                                                    ;use temp_counter as bitcounter
    clr temp_counter
tere_id_lp:
                                                    ;prepare address (w11) and bit variable (w12)
                                                    ;calc address
    mov #temp_ids, w11
    mov temp_sens_now, w0
    sl w0, #3, w0
    add w11, w0, w11
    mov temp_counter, w0
    lsr w0, #4, w0
    add w11, w0, w11
    add w11, w0, w11
                                                    ;calc bit
    mov #0x000F, w12
    mov temp_counter, w0
    and w12, w0, w12
                                                    ;tx 0 or 1 based on result
    btst.c [w11], w12
    bra c, tere_send_1

    call temp_send_0
    bra tere_id_cont
tere_send_1:
    call temp_send_1
                                                    ;do for all 64 bit
tere_id_cont:
    inc temp_counter
    mov #64, w0
    cp temp_counter
    bra nz, tere_id_lp

;***********************************************
; give 'read scratchpad'
;***********************************************
    read_scratchpad

;***********************************************
; store first 16 bits in temp_data, continue to receive for CRC
;***********************************************
                                                    ;initialise
    clr temp_counter
    clr temp_crc
tere_rx_lp:
    call temp_receive_bit
    mov IC2BUF, w1
                                                    ;only store the 16 first bits
    mov #16, w0
    cp temp_counter
    bra c, tere_skip_store
                                                    ;store bit, lsb first
    mov #temp_data_rxed, w13
    mov #ic2_triplevel, w0
    mov temp_counter, w12
    cp w0, w1
    bsw.c [w13], w12

tere_skip_store:
                                                    ;process for CRC
    mov #0x008C, w0
                                                    ;rotate
    lsr temp_crc
                                                    ;XOR based on carry
    btsc SR,#C
    xor temp_crc
                                                    ;XOR based on carry from the just received bit
    mov #ic2_triplevel, w0
    cp w0, w1
    mov #0x008C, w0
    btsc SR,#C
    xor temp_crc
                                                   ;do for all 72 bits
    inc temp_counter
    mov #72, w0
    cp temp_counter
    bra nz, tere_rx_lp

;***********************************************
; if CRC not correct, keep previously read temperature, else store
;***********************************************
    mov #temp_data, w13
    sl temp_sens_now, wreg
    add w13, w0, w13
	mov temp_data_rxed, w0
                                                    ;write rxed only for good crc, so when crc = 0 
    cp0 temp_crc
    btsc SR,#Z
    mov w0, [w13]

;***********************************************
; loop for all sensors
;***********************************************
    inc temp_sens_now
    mov number_temp_sensors, w0
    cp temp_sens_now
    bra nz, tere_main_lp
	
;***********************************************
; generate data for the throttle routine
;***********************************************
														;the calculation may take some time, so back to main routine first
	T_return_main
	
;--------------------------------------------------- initialise
	mov number_temp_sensors, w0
	mov w0, temp_counter
														;w1 is largest current reduction
	clr w1
	mov #temp_limit, w13
	mov #temp_current_red, w12
	mov #temp_data, w11
;--------------------------------------------------- loop through all sensors
gdftr_lp:
;--------------------------------------------------- calculate current reduction based on this sensor
    mov [w11++], w2
	sub w2, [w13++], w0
	mul.ss w0, [w12++], w2
														; if w3 = 0: w2 is current reduction, process normally
														; if w3 is >0 (indicates overflow): current reduction (w2) is i_max_phase 
	cp0 w3
	btss SR, #Z
	mov i_max_phase, w2
														; if w3 is <0 (indicates negative result): current reduction (w2) is 0
	btsc w3, #15
	clr w2
														;make sure bit 15 of w2 is clear, bit 15 set (with w3=0) indicates an overflow condition)
	btsc w2, #15
	mov i_max_phase, w2
                                                        
;--------------------------------------------------- keep the largest current reduction
	cpslt w2, w1
	mov w2, w1
;--------------------------------------------------- end loop
	dec temp_counter
	bra nz, gdftr_lp
;--------------------------------------------------- subtract reduction from i_max_phase
	mov i_max_phase, w0
	sub w0, w1, w0
;--------------------------------------------------- make sure it is positive, store
	btsc w0, #15
	clr w0
	
	mov w0, temp_red_i_max_phase
	
;***********************************************
; set 'temp_sensor_cycle' bit to indicate new data for throttle routine
;***********************************************
    bset flags1, #temp_sensor_cycle
;***********************************************
; back from the beginning for next iteration
;***********************************************
    bra temp_read


;***********************************************************************************
temp_send_0:
                                                    ;pop address, store
    pop temp_stack
    pop temp_stack+2
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
    T_return_main
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
    T_return_main
    btss IFS0, #6
    bra 1b
                                                    ;push address
    push temp_stack+2
    push temp_stack
    return
;***********************************************
temp_send_1:
                                                    ;pop address, store
    pop temp_stack
    pop temp_stack+2
                                                    ;clr pin, low-Z
    bclr LATD, #1
    bclr TRISD, #1
                                                    ;initialise timer for 2 usec
    mov #t2_2u, w0
    mov w0, PR2
    clr TMR2
    bclr IFS0, #6
                                                    ;wait for timer to trip (DO NOT RETURN TO MAIN PROGRAM, ONLY 2u SEC !!!)
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
    T_return_main
    btss IFS0, #6
    bra 1b
                                                    ;push address
    push temp_stack+2
    push temp_stack

    return

;***********************************************
temp_receive_bit:
                                                    ;pop address, store
    pop temp_stack
    pop temp_stack+2
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
                                                    ;wait for timer to trip (DO NOT RETURN TO MAIN PROGRAM, ONLY 2u SEC !!!)
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
    T_return_main
    btss IFS0, #6
    bra 1b

    push temp_stack+2
    push temp_stack

    return
				
.end
