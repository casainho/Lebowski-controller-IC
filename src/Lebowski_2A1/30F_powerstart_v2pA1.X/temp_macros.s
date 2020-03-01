;************************************************************************************

.macro T_return_main

    mov #6, w0
    add PCL, wreg
    mov w0, temp_readout
    return

.endm

;************************************************************************************

.macro reset_temp_sensors

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
    T_return_main

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
    T_return_main

    btss IFS0, #6
    bra 1b
                                                    ;read pin and (re)set temp_sensor_found
    bclr flags1, #temp_sensor_found
    btss PORTD, #1
    bset flags1, #temp_sensor_found
;---------------------------------------------- wait for 100usec after presence pulse
                                                    ;wait for pin to be high
1:
    T_return_main

    btss PORTD, #1
    bra 1b
                                                    ;initialise timer for 100 usec
    mov #t2_100u, w0
    mov w0, PR2
    clr TMR2
    bclr IFS0, #6
                                                    ;wait for timer to trip
1:
    T_return_main

    btss IFS0, #6
    bra 1b
;---------------------------------------------- end
.endm
;************************************************************************************
.macro skip_rom
                                                    ;tx 0xCC, LSB's first
    call temp_send_0
    call temp_send_0
    call temp_send_1
    call temp_send_1
    call temp_send_0
    call temp_send_0
    call temp_send_1
    call temp_send_1
.endm
;************************************************************************************
.macro all_convert
                                                    ;tx 0x44, LSB's first
    call temp_send_0
    call temp_send_0
    call temp_send_1
    call temp_send_0
    call temp_send_0
    call temp_send_0
    call temp_send_1
    call temp_send_0
.endm
;************************************************************************************
.macro match_rom
                                                    ;tx 0x55, LSB's first
    call temp_send_1
    call temp_send_0
    call temp_send_1
    call temp_send_0
    call temp_send_1
    call temp_send_0
    call temp_send_1
    call temp_send_0
.endm
;************************************************************************************
.macro read_scratchpad
                                                    ;tx 0xBE, LSB's first
    call temp_send_0
    call temp_send_1
    call temp_send_1
    call temp_send_1
    call temp_send_1
    call temp_send_1
    call temp_send_0
    call temp_send_1
.endm



