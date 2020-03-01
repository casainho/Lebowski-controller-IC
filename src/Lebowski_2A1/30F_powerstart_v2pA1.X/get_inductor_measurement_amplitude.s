.include "p30F4011.inc"
.include "defines.inc"

.text

;*****************************************************************

.global get_inductor_measurement_amplitude

;determines the ampli_real for a certain amount
;of current (wanted_i_real) through the motor.

get_inductor_measurement_amplitude:						
						
;--------------------------------------- initialise
                                            ;switch ADCs over to current measurement, wait a bit before 1st measurement
    call ADC_current
    repeat #5
    nop
                                            ;start first current measurement
    bclr ADCON1, #1

	mov inductor_amplitude_measurement_count, w0

;--------------------------------------- execute measurement

gima_lp:
                                            ;wait for next iteration
	btss IFS0, #3
	bra gima_lp
	bclr IFS0, #3

    push w0
                                            ;get current measurements
    call ADC_read_current
                                            ;start new current measurement
    bclr ADCON1, #1
                                            ;disect currents
    call disect_current
                                            ;update amplitude
    call i_real_control
                                            ;negate i_imag to lock motor
    neg i_imag

;--------------------------------------- update phi and loopfilter

    mov #plic+4, w12                        ;positive array position, only need 1st order coefficients
    btsc i_imag, #15
    add w12, #8, w12                        ;shift to negative if i_imag < 0

    mov [w12++], w5                         ;w5.w6 to be added to phi (this is the 1st integrator bypass path)
    mov [w12], w6

    mov #phi+2, w1
                                            ;add to phi
    add w6, [w1], [w1--]
    addc w5, [w1], [w1]

;--------------------------------------- output sine waves

	call write_motor_sinus
                                            ;loop
    pop w0
	dec w0, w0
	bra nz, gima_lp

;----------------------------------------------	end

	return

;*****************************************************************





.end

