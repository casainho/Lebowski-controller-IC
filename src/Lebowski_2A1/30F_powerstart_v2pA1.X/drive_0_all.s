.include "p30F4011.inc"
.include "defines.inc"

.text

;*****************************************************************

.global initialise_drive_0_all
initialise_drive_0_all:
                                                    ;PWM off
    bclr PTCON, #15
                                                    ;to voltage ADC
    call ADC_voltage
                                                    ;indicate drive_0
    bset LATC, #15
    bclr LATC, #13
    bclr LATC, #14
    bclr LATE, #8
                                                    ;to prevent startup before first throttle reading, max out throttle
    bset throttle, #14
                                                    ;initialise XX msec counter
    mov dr0_XX_msec, w0
    mov w0, dr0_counter
													;clear count_ldm
	clr count_ldm
	clr count_ldm+2
													;clear error bits
	bclr flags1, #over_i_imag
	bclr flags1, #over_i_total
    bclr flags1, #over_erpm
													;initialise counter, at least 5 times throttle closed
	mov #5, w0
	mov w0, counter
                                                    ;skip completely if not perform_voltage_test and not perform_throttle_check
	btsc flags_rom, #perform_voltage_test
	bra dr0_lp
	btss flags_rom, #perform_throttle_check
	bra end_drive_0
	
;*****************************************************************
dr0_lp:
                                                    ;wait for 40 kHz operation
    bclr LATD, #2
    btss IFS0, #3
    bra dr0_lp
    bclr IFS0, #3
                                                    ;indicate when busy
    bset LATD, #2
													;update time spent here counter
	clr w0
	inc count_ldm
	addc count_ldm+2
	inc count_tot
	addc count_tot+2
;---------------------------------------------- process throttle based on TMR4
dr0_throttle:
	btsc IFS1, #5
	dec counter
    btsc IFS1, #5
    call throttle_read
;---------------------------------------------- measure back-emf voltages
    bclr ADCON1, #1
    nop
    nop
    nop

                                                    ;temp reading intermezzo
    mov temp_readout, w14
    btsc flags_rom, #use_temp_sensors
    call w14

    call ADC_read_voltage
;---------------------------------------------- find maximum
    call ADC_find_max
;---------------------------------------------- check for exiting drive_0
                                                    ;bit set in w13 means test passed
    clr w13
                                                    ;check back_emf
    mov motor_standstill_voltage, w1
    cpslt w1, w0
    bset w13, #perform_voltage_test
                                                    ;check throttle
    mov throttle, w1
    clr w0
    cpslt w0, w1
    bset w13, #perform_throttle_check
                                                    ;set bits when test not performed (automatic pass)
    btss flags_rom, #perform_voltage_test
    bset w13, #perform_voltage_test
    btss flags_rom, #perform_throttle_check
    bset w13, #perform_throttle_check
                                                    ;build word to compare with
    clr w0
    bset w0, #perform_voltage_test
    bset w0, #perform_throttle_check
                                                    ;end when tests passed and counter = 0
    cp w0, w13
    bra nz, dr0_not_end
	
	cp0 counter
	bra z, end_drive_0
	
	bra dr0_pulse
	
dr0_not_end:
													;else reset counter to 5 when not passed
	mov #5, w0
	mov w0, counter
;---------------------------------------------- pulse low side FET's
dr0_pulse:
                                                    ;check if enabled, else end
    btss flags_rom, #pulse_low_side
    bra dr0_lp_end
                                                    ;only pulse every XX msec
    dec dr0_counter
    bra nz, dr0_lp_end
                                                    ;re-initialise counter
    mov dr0_XX_msec, w0
    mov w0, dr0_counter
                                                    ;preset for override, low side ON
    mov #0x0015, w0
    mov w0, OVDCON
    bset PTCON, #15
                                                    ;wait 1/2 PWM period time
    mov dr0_pulse_duration, w0
    repeat w0
    nop
                                                    ;back to pins under PWM control, low side OFF again.
    bclr PTCON, #15
    mov #0x3F00, w0
    mov w0, OVDCON
;---------------------------------------------- dr0 loop end, allow monitoring
dr0_lp_end:
    dec monitoring_count
    bra nz, dr0_lp
    mov monitoring_value, w0
    mov w0, monitoring_count
    call monitoring
    bra dr0_lp

;*****************************************************************

end_drive_0:
;---------------------------------------------- switch ADC's to current
    call ADC_current
;---------------------------------------------- start recovery from scratch
    clr phi_motor
    clr phi_motor+2
    clr phi_int
    clr phi_int+2
    clr ampli_real
    clr ampli_real+2
    clr ampli_imag
;---------------------------------------------- initialise dutycycle at 50%
	mov pwm_period_rec, w0
	mov w0, PDC1
	mov w0, PDC2
	mov w0, PDC3
;---------------------------------------------- exit drive_0 to drive_1
    goto initialise_drive_1_all

.end

