.include "p30F4011.inc"
.include "defines.inc"

.text

;*****************************************************************

.global ADC_open
ADC_open:
					;define AN0 - AN6 pins as analog inputs
    bclr ADPCFG, #0
    bclr ADPCFG, #1
    bclr ADPCFG, #2
    bclr ADPCFG, #3
    bclr ADPCFG, #4
    bclr ADPCFG, #5
    bclr ADPCFG, #6

    bset TRISB, #0
    bset TRISB, #1
    bset TRISB, #2
    bset TRISB, #3
    bset TRISB, #4
    bset TRISB, #5
    bset TRISB, #6
					;no interrupt
    bclr IEC0, #11
					;setup ADC's
    mov #0b1000000000001111, w0
    mov w0, ADCON1				;module on, integer output, manual start, sample all simultaneous
    mov #0b0000001000000000, w0
    mov w0, ADCON2				;no scan, convert all, interrupt every sample, 16 word buffer, mux A
    mov #0b0000000000000101, w0
    mov w0, ADCON3				;no auto sample, use system clock, Tad=99ns
    mov #0b0000000000100110, w0
    mov w0, ADCHS				;preset to back-EMF channels (AN3, 5 and AN6 for midpoint-reference)

    bclr flags1, #ADCs_to_current_sensors
								;set current sensor polarity
	clr w0
	btsc flags_rom2, #negative_current_sensors
	mov #0x03FF, w0
	mov w0, adc_current_polarity

    return

;*****************************************************************
.global ADC_current
ADC_current:
                                                    ;turn off backemf voltage channels (AN3, 5, 6)
    bset ADPCFG, #3
    bset ADPCFG, #5
    bset ADPCFG, #6	
                                                    ;set to current channels (AN0, 1, 2)
    bclr ADCHS, #5
                                                    ;measure supply on channel 4 (pin 6)
    bclr ADCHS, #3
    bset ADCHS, #2
    bclr ADCHS, #1
    bclr ADCHS, #0

    bset flags1, #ADCs_to_current_sensors
													;set current sensor polarity (done here to make sure is also current during setup menu functions)
	clr w0
	btsc flags_rom2, #negative_current_sensors
	mov #0x03FF, w0
	mov w0, adc_current_polarity

    return

;*****************************************************************
.global ADC_voltage
ADC_voltage:	
                                                    ;turn on backemf voltage channels (AN3, 5, 6)
    bclr ADPCFG, #3
    bclr ADPCFG, #5
    bclr ADPCFG, #6	
                                                    ;set to voltage channels (AN3, 5 and AN6)
    bset ADCHS, #5
    bclr ADCHS, #3
    bset ADCHS, #2
    bset ADCHS, #1
    bclr ADCHS, #0
    
    bclr flags1, #ADCs_to_current_sensors

    repeat #5
    nop

    return

;*****************************************************************

.global ADC_read_voltage

;conversion must be started externally (in the calling program) for speed reasons.
;conversion is started by:	bclr ADCON1, #1	
;after this routine:
;w4 = AN3 - 512
;w5 = AN6 - 512
;w6 = AN5 - 512

ADC_read_voltage:
                                                    ;save registers
    push w0
                                                    ;wait for conversion to be finished
arv_wait:
    btss ADCON1, #0
    bra arv_wait
					;compute w4, w5, w6 					
    mov ADCBUF1, w4
    mov ADCBUF0, w5
    mov ADCBUF3, w6

    mov #512, w0

    sub w4, w0, w4
    sub w5, w0, w5
    sub w6, w0, w6
					;restore registers
    pop w0
	
    return

;*****************************************************************

.global ADC_read_current

;conversion must be started externally (in the calling program) for speed reasons.
;conversion is started by:	bclr ADCON1, #1	

ADC_read_current:
					;wait for conversion to be finished
arc_wait:
    btss ADCON1, #0
    bra arc_wait

;---------------------------------- store supply voltage
    mov ADCBUF0, w0
    mov w0, supply_voltage
;---------------------------------- process A

    mov ADCBUF1, w0
	xor adc_current_polarity, wreg
    sl w0, w7                           ;keep (doubled) value for possible offset calibration
                                        ;FIR filtering, implies * 2
    add adc_current_prev, wreg          ;w0 = x_n + x_n-1
    subr adc_current_prev               ;prev=x_n = w0 - x_n-1
                                        ;offset correction
    subr adc_current_offset, wreg
										;mult with 16 (as FIR implies *2), store in w4
	sl w0, #4, w4

;---------------------------------- process B

    mov ADCBUF2, w0
	xor adc_current_polarity, wreg
    sl w0, w8
    add adc_current_prev+2, wreg
    subr adc_current_prev+2
    subr adc_current_offset+2, wreg
	sl w0, #4, w5

;---------------------------------- process C

    mov ADCBUF3, w0
	xor adc_current_polarity, wreg
    sl w0, w9
    add adc_current_prev+4, wreg
    subr adc_current_prev+4
    subr adc_current_offset+4, wreg
	sl w0, #4, w6

;---------------------------------- end

    return
;*****************************************************************

.global ADC_online_filter_offset

;implements a 1st order filter, coefficient 1/65536:
;on call: w7, w8 and w9 contain the (doubled) raw ADC data

ADC_online_filter_offset:
	
;---------------------------------- check we're allowed to filter

	cp0 i_filter_offset
	btsc SR, #Z
	return
	
	mov wanted_i_real, w0
	mul.ss w0, w0, w10
	mov wanted_i_imag, w0
	mul.ss w0, w0, w12
	add w10, w12, w12
	addc w11, w13, w13
	
	mov i_filter_offset, w0
	mul.ss w0, w0, w10
	
	sub w10, w12, w12
	subb w11, w13, w13
	
	btsc w13, #15
	return
	
;---------------------------------- process A
	mov #adc_current_offset_lsbs, w12
	clr w0				
                                        ;subtract offset from lsbs
	mov adc_current_offset, w1
	subr w1, [w12], [w12]
                                        ;and process the carry
	subb adc_current_offset			
                                        ;add measured (input)value
	add w7, [w12], [w12++]
                                        ;and process the carry
	addc adc_current_offset
	
;---------------------------------- process B

	mov adc_current_offset+2, w1
	subr w1, [w12], [w12]
	subb adc_current_offset+2		
	add w8, [w12], [w12++]
	addc adc_current_offset+2

;---------------------------------- process C

	mov adc_current_offset+4, w1
	subr w1, [w12], [w12]
	subb adc_current_offset+4		
	add w9, [w12], [w12++]
	addc adc_current_offset+4

;---------------------------------- end

	return
	


;*****************************************************************

.global ADC_find_max
ADC_find_max:

    btsc w4, #15				;make readings positive
    neg w4, w4
    btsc w5, #15
    neg w5, w5
    btsc w6, #15
    neg w6, w6
						;find max
    mov w4, w0
    cpslt w5, w0
    mov w5, w0
    cpslt w6, w0
    mov w6, w0

    return

;*****************************************************************






.end

