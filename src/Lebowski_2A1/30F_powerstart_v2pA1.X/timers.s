.include "p30F4011.inc"
.include "defines.inc"

.text
.global timers_open
timers_open:
;-------------------------------------- TMR1 for loop frequency
	                                        
    bclr IEC0, #3                          	;NO INTERRUPT !
    mov #0b1000000000000000, w0
    mov w0, T1CON                           ;start TMR1, 1:1 pre-scale
    mov main_loop_count, w0
    mov w0, PR1                             ;loopfreq = 30e6 / main_loop_count
    clr TMR1
    bclr IFS0, #3

;-------------------------------------- TMR2 for temperature measurement timings

    bclr IEC0, #6                           ;no interrupts on TMR2
    clr TMR2                                ;set count to 0
    mov #0b1000000000010000, w0             ;tmr2 on, 266.66 nsec/count
    mov w0, T2CON
    setm PR2

;-------------------------------------- TMR4 for throttle timing (when analog throttles are used)

    bclr IEC1, #5                           ;no interrupts on TMR4
    clr TMR4                                ;set count to 0
    mov #0b1000000000110000, w0             ;tmr4 on, 8.5usec/count
    mov w0, T4CON
    mov #1200, w0                           ;once every 10 msec
    mov w0, PR4

;-------------------------------------- watchdog timer on when in motor mode and RX can (reset if no throttle within 48 msec)
                                            ;skip if analog throttle
    btsc flags_rom, #analog_throttle
    bra timers_end
                                            ;else turn on watchdog timer (motor mode only)
    clrwdt
    btsc flags1, #motor_mode
    bset RCON, #5

;-------------------------------------- end
timers_end:
    return
					
.end
