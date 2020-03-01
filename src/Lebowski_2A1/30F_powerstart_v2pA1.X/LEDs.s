.include "p30F4011.inc"
.include "defines.inc"

.text
.global LEDs_open
LEDs_open:

    bclr TRISC, #15
    bclr TRISC, #13
    bclr TRISC, #14
    bclr TRISE, #8

    bclr LATC, #15
    bclr LATC, #13
    bclr LATC, #14
    bclr LATE, #8

    return

;*******************************************
.global LED_menu_error
LED_menu_error:
	
;-------------------------------------- TMR1 blink rate
	                                        
    bclr IEC0, #3                          	;NO INTERRUPT !
    mov #0b1000000000110000, w0
    mov w0, T1CON                           ;start TMR1, 1:256 pre-scale 
    mov #30000, w0
    mov w0, PR1                             ;blinkrate = (30e6/256) / PR1
    clr TMR1
    bclr IFS0, #3	
	
;-------------------------------------- initialise LED's
	
	call LEDs_open
	
	bclr LATC, #15
    bset LATC, #13
    bclr LATC, #14
    bset LATE, #8

;-------------------------------------- endless blink loop
1:
	btss IFS0, #3
    bra 1b
    bclr IFS0, #3

	btg LATC, #15
    btg LATC, #13
    btg LATC, #14
    btg LATE, #8
	
	bra 1b

.end
