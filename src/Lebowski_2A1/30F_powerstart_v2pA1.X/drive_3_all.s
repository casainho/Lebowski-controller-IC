.include "p30F4011.inc"
.include "defines.inc"

.macro led_on
	bset LATD, #2
.endm
.macro led_off
	bclr LATD, #2
.endm
.text

.global initialise_drive_3_all
initialise_drive_3_all:
                                                    ;indicate drive_3
    bclr LATC, #15
    bclr LATC, #13
    bclr LATC, #14
    bset LATE, #8
													;clear error bits
	bclr flags1, #over_i_imag
	bclr flags1, #over_i_total
    bclr flags1, #over_erpm
													;clear count_here
	clr count_ldm
	clr count_ldm+2
	
	clr ampli_imag_prop
	clr phi_step
	clr phi_offset
													;restart matrix processing
	call reset_process_imp_data
	
drive_3:
                                                    ;wait for 40 kHz operation
	led_off
    btss IFS0, #3
    bra drive_3
    bclr IFS0, #3
                                                    ;indicate when busy
    led_on
													;update time spent here counter
	clr w0
	inc count_ldm
	addc count_ldm+2
	inc count_tot
	addc count_tot+2
;---------------------------------------------- get measured currents
    bclr ADCON1, #1
    nop
                                                    ;temp reading intermezzo
    mov temp_readout, w14
    btsc flags_rom, #use_temp_sensors
    call w14
													;matrix inversion intermezzo
	mov imp_process_address, w14
	btsc flags_rom2, #use_KvLR
    call w14										
													
    call ADC_read_current
													;filter ADC offset
	call ADC_online_filter_offset
;---------------------------------------------- process throttle based on TMR4
    btsc IFS1, #5
    call throttle_read
	
	call throttle_ramp
;---------------------------------------------- calculate ampli_imag
													;includes throttle limiting so must be before determine_direction
    call calc_ampli_imag
;---------------------------------------------- demodulate 
    mov phi_motor, w0
    call demod
;---------------------------------------------- current filtering
	call current_filtering
;---------------------------------------------- impedance measurement
														;apply random i_imag for inductor measurement
	btsc flags_rom, #use_sine_iimag
	call update_sine_i_imag
												;collect data
    mov imp_collect_address, w14
	btsc flags_rom2, #use_KvLR
    call w14

	bset flags1, #valid_data_imp_meas
;---------------------------------------------- safety first ! check error current stuff
    call safety
    btsc flags1, #over_i_imag
    bra dr3_end_to_dr1
    btsc flags1, #over_erpm
    bra dr3_end_to_dr1
;---------------------------------------------- determine loop update direction
													;alleen update_clipping wanneer clipping !
;	btss flags1, #clipping
	call determine_update_direction
;	btsc flags1, #clipping
;	call determine_update_clipping

;---------------------------------------------- amplitude control
    call current_control
	call fieldweakening
;---------------------------------------------- phase control
	mov #plic_3, w12
    call backemf_phase_control
													;hall assisted: run halls and overwrite speed info
	btss flags_rom2, #use_hall_assisted_sl
	bra 1f
	call hall_read_and_pll
	mov pll_int, w0
	mov w0, phi_int
1:
;---------------------------------------------- send signals to motor
    call write_motor_sinus
;---------------------------------------------- end to drive_2 when rpm (abs(phi_int)) drops too low
    mov phi_int, w0
    btsc w0, #15
    neg w0, w0	
    cp phi_int_3to2
	bra ge, dr3_end_to_dr2
;---------------------------------------------- drive_3 loop end, allow monitoring
    dec monitoring_count
    bra nz, drive_3
    mov monitoring_value, w0
    mov w0, monitoring_count
    call monitoring
    bra drive_3

;*****************************************************************
;* error current event !
;*****************************************************************
dr3_end_to_dr1:
                                                    ;initialise dutycycle at 50%
	mov pwm_period_rec, w0
	mov w0, PDC1
	mov w0, PDC2
	mov w0, PDC3

    goto initialise_drive_1_all

;*****************************************************************
;* rpms too low
;*****************************************************************
dr3_end_to_dr2:
	
    goto correct_drive_2

;*****************************************************************
;*****************************************************************
;*****************************************************************

.bss
	
phi_wii:	.space 2
	
.end
