.include "p30F4011.inc"
.include "defines.inc"
.include "fp_macros.mac"

.text

.global initialise_drive_2to3_hall
initialise_drive_2to3_hall:
                                                    ;indicate drive_2to3
    bclr LATC, #15
    bclr LATC, #13
    bset LATC, #14
    bset LATE, #8
                                                    ;filter_I_error is used for error current filtering by the safety_dr2 routine
    clr filter_I_error
    clr filter_I_error+2
													;determine phi_offset and perform initial phase step
	call phase_step_dr23hl
 													;1000 resting cycles before phi_offset reduction
	mov #1000, w0
	mov w0, counter+2
                                                    ;spend at least cycles_2to3 + |phi_offset| + 256 cycles here
    add cycles_2to3, wreg
	mov phi_offset, w1
	btsc w1, #15
	neg w1, w1
	add w0, w1, w0
    mov w0, counter
													;clear error bits
	bclr flags1, #over_i_imag
	bclr flags1, #over_i_total
    bclr flags1, #over_erpm
													;must initialise halls, just in case we came here from drive_1
	call hall_measure_phase
													;reset filter_spd (as then will show up as 0 in chipstatus)
	clr filter_spd
													;clear count_here
	clr count_ldm
	clr count_ldm+2
	bclr flags1, #exit_to_dr3

	clr phi_step
	clr ampli_imag_prop

drive_2to3:
                                                    ;wait for 40 kHz operation
    bclr LATD, #2
    btss IFS0, #3
    bra drive_2to3
    bclr IFS0, #3
                                                    ;indicate when busy
    bset LATD, #2
													;update time spent here counter
	clr w0
	inc count_ldm
	addc count_ldm+2
	inc count_tot
	addc count_tot+2
;---------------------------------------------- get measured currents
    bclr ADCON1, #1
    nop
    nop
    nop
                                                    ;temp reading intermezzo
    mov temp_readout, w14
    btsc flags_rom, #use_temp_sensors
    call w14

    call ADC_read_current
;---------------------------------------------- process throttle based on TMR4
    btsc IFS1, #5
    call throttle_read

	call throttle_ramp
;---------------------------------------------- calculate ampli_imag
													;includes throttle limiting so must be before determine_direction
    call calc_ampli_imag
;---------------------------------------------- demodulate 
    mov phi_motor, w0
	add phi_offset, wreg

    call demod
;---------------------------------------------- current filtering
	call current_filtering
;---------------------------------------------- safety first ! check over-erpm and over_i_total
    call safety_dr2
	
    btsc flags1, #over_erpm
    bra dr23_end_to_dr1
    btsc flags1, #over_i_total
    bra dr23_end_to_dr1
;---------------------------------------------- determine loop update direction
;	btss flags1, #clipping
	call determine_update_direction
;	btsc flags1, #clipping
;	call determine_update_clipping
;---------------------------------------------- torque/current control
	call current_control
	call fieldweakening
	
	btsc flags_rom, #use_sine_iimag
	call reduce_sine_i_imag
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
;---------------------------------------------- phase offset reduction
													;only after initial # of resting cycles has passed
	cp0 counter+2
	bra z, 1f

	dec counter+2
	bra 2f
1:													;reduce phi_offset
	cp0 phi_offset
	bra z, 2f

	mov #1, w0
	btss phi_offset, #15
	neg w0, w0

	add phi_offset
2:
;---------------------------------------------- end to drive_3 
	cp0 counter
    bra z, check_error_current
    dec counter
    bra continue
    
check_error_current:    
    btss flags1, #over_i_imag
    bra dr23_end_to_dr3

continue:
;---------------------------------------------- end back to drive_2 if rpms drop too low
    mov phi_int, w0
    btsc w0, #15
    neg w0, w0	
    cp phi_int_3to2
	bra ge, dr23_end_to_dr2
;---------------------------------------------- drive_2to3 loop end, allow monitoring	
    dec monitoring_count
    bra nz, drive_2to3
    mov monitoring_value, w0
    mov w0, monitoring_count
    call monitoring
    bra drive_2to3

;*****************************************************************
;* 1000 cycles done and no over_i_imag event
;*****************************************************************
dr23_end_to_dr3:

    goto correct_drive_3

;*****************************************************************
;* slowed down too much
;*****************************************************************
dr23_end_to_dr2:

    goto correct_drive_2

;*****************************************************************
;* over_erpm or over_i_total event !
;*****************************************************************
dr23_end_to_dr1:
													;initialise dutycycle at 50%
	mov pwm_period_rec, w0
	mov w0, PDC1
	mov w0, PDC2
	mov w0, PDC3

    goto initialise_drive_1_all

;*****************************************************************
;*****************************************************************
;*****************************************************************
 
;both phi_motor and ampli_real, ampli_imag are rotated such that the output
;signal does not change, but ampli_imag is equal to the calculated inductor
;voltage. In the main routine phi_offset (the phi_motor change) is slowly
;reduced
/*
nop
nop
nop
	
call fill_pwm_and_sin_arrays

mov #-10000, w0
mov w0, ampli_real
mov #10000, w0
mov w0, ampli_imag

mov #5000, w0
mov w0, wanted_ampli_imag
	
mov #40000, w0
mov w0, phi_motor
	
setm flags1
*/	
.global phase_step_dr23hl
phase_step_dr23hl:	
;---------------------------------------------- determine wanted_ampli_imag

	push ampli_imag
	
	call calc_ampli_imag
		
	mov ampli_real, w8		
	pop w9											;w9: old ampli_imag
	mov ampli_imag, w7								;w7: new ampli_imag
	
													;change sign of ampli_real based on reverse
	btsc flags1, #reverse
	neg w8, w8
;---------------------------------------------- determine phi_offset
													;initialise loop
														;w12 at -sin (so at 180 deg of sin array), w13 at cos (so at 90 deg)
														;done so that w12 and w13 will stay within the data_sin_array during the search, no overflow check necessary
	mov #data_array_sin+256, w12
	mov #data_array_sin+128, w13
														;w11 = (phase) update for w12, w13, start with 45 deg (= 64)
	mov #64, w11
													;loop 6 times
    do #5, 1f
													;determine update direction
														;imag_new = ampli_imag * [w13] - ampli_real * -[w12]
	mul.ss w9, [w13], w2
	mul.ss w8, [w12], w0
	sub w2, w0, w2
	subb w3, w1, w3
	rlc w2, w2
	rlc w3, w3
														;base w12, w13 update on calc_wanted_ampli_imag - imag_new
	mov w11, w10
	cpslt w3, w7
	neg w10, w10

	add w12, w10, w12
	add w13, w10, w13													
1:													;end loop	
	lsr w11, w11
;---------------------------------------------- determine phi_offset 
													;calculate phi_offset from w13
	mov #data_array_sin+128, w1
	sub w13, w1, w1
													;invert sign if reverse
	btsc flags1, #reverse
	neg w1, w1
													;demodulation angle shifted by phi_offset (to stay on the w8, w9 current values)
	sl w1, #7, w0	
	mov w0, phi_offset
													;phi_motor -= phi_offset, to not move the effective output voltage with the new ampli_real, ampli_imag
	sub phi_motor
;---------------------------------------------- determine new ampli_real and ampli_imag
													;initialise, w9 and w13 are still correct (reverse independent)
	mov ampli_real, w8
    mov #data_array_sin+256, w12
	add w12, w1, w12
													;real_new = ampli_real * [w13] + ampli_imag * -[w12]
	mul.ss w8, [w13], w2
	mul.ss w9, [w12], w0
	add w2, w0, w2
	addc w3, w1, w3
	rlc w2, w2
	rlc w3, w3
	mov w3, ampli_real
													;imag_new = ampli_imag * [w13] - ampli_real * -[w12]
	mul.ss w9, [w13], w2
	mul.ss w8, [w12], w0
	sub w2, w0, w2
	subb w3, w1, w3
	rlc w2, w2
	rlc w3, w3
	mov w3, ampli_imag
;---------------------------------------------- end
	
	call hall_collect_stat	
	
	return
;*****************************************************************
			
hall_collect_stat:
;---------------------------------------------- initialise hallstat pointer	
	mov #hall_stat, w10
	btsc flags1, #reverse
	mov #hall_stat+10, w10
;---------------------------------------------- inc count
													;skip if at max, 0x7FFF
	mov #0x7FFF, w0
	cp w0, [w10]
	bra z, 1f
	
	inc [w10], [w10++]
;---------------------------------------------- convert phi_offset to fp	
	signed_to_fp phi_offset regA
;---------------------------------------------- update average	
	mov #regA, w12
	mov w10, w13
	call fp_add
;---------------------------------------------- update average^2
	mov #regA, w13
	call fp_mult
	
	add w10, #4, w13
	call fp_add
;---------------------------------------------- end	
1:
	return
	
.end

