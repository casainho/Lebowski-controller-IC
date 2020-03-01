.include "p30F4011.inc"
.include "defines.inc"

.text

;*****************************************************************

.global PWM_open
PWM_open:
                        						;pwm time base off for now, postscale 1:1, prescale 1:1, updown with dual update
	mov #0b0000000000000011, w0
	mov w0, PTCON
                        						;50 kHz @ 30 MHz clock (30e6/50e3 = 600 / 2 because of updown = 300)
	mov pwm_period, w0
	mov w0, PTPER
                        						;complementary mode, enable all pins for PWM use
	mov #0x0077, w0			
	mov w0, PWMCON1
                        						;update PDC registers and OSYNC on pwm boundary, updates enabled
	mov #0b0000000000000000, w0
	mov w0, PWMCON2
                        						;configure only deadtime generator A, 15*33 = 500 ns dead time
	mov pwm_deadtime, w0
	mov w0, DTCON1
                        						;no fault control A
	mov #0x0000, w0
	mov w0, FLTACON
                        						;all pins controlled by PWM
	mov #0x3F00, w0
	mov w0, OVDCON
                        						;initialise 50% dutycycle
	mov pwm_period, w0
	mov w0, PDC1
	mov w0, PDC2
	mov w0, PDC3

    return
    
;*****************************************************************

.global PWM_continuous
PWM_continuous:
                        						;turn off before changing
    bclr PTCON, #15
	bset PTCON, #1
	
	mov pwm_period, w0
	mov w0, PTPER

	return

;*****************************************************************

.global PWM_discontinuous
PWM_discontinuous:
                        						;turn off before changing
    bclr PTCON, #15
	bclr PTCON, #1
	
	mov pwm_period_rec, w0
	mov w0, PTPER


	return

;*****************************************************************


.end

