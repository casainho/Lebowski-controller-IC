.include "p30F4011.inc"
.include "defines.inc"

.text

.global initialise_drive_1_all
initialise_drive_1_all:
													;write status for debug
	call store_status
                                                    ;switch to discontinuous PWM
    call PWM_discontinuous
                                                    ;indicate drive_1
    bclr LATC, #15
    bset LATC, #13
    bclr LATC, #14
    bclr LATE, #8
                                                    ;start recovery from scratch
    clr phi_motor+2
    clr phi_int
    clr phi_int+2
    clr ampli_real
    clr ampli_real+2
    clr ampli_imag	
	clr ampli_sf
	clr phi_mfa_comp
                                                    ;reset wir filter (used for %-age filtering)
    mov #filter_wir, w0
    repeat #3
    clr [w0++]
                                                    ;reset spd filter (used for speed filtering)
    mov #filter_spd, w0
    repeat #3
    clr [w0++]
                                                    ;initialise counter
    mov cycles_try_recov, w0
    mov w0, counter
                                                    ;use phi_ind_prev to determine phase update / speed filter
    mov phi_motor, w0
    mov w0, phi_motor_prev
													;no HF tone
	clr ampli_hf_motor
                                                    ;no wanted_i_imag (for when we came here from drive 3)
    clr wanted_i_imag
	clr fieldweak
	clr fieldweak_prop
													;clear count_here
	clr count_here
	clr count_here+2


;---------------------------------------------- drive_1 loop
dr1_lp:
                                                    ;wait for 40 kHz operation
    bclr LATD, #2
    btss IFS0, #3
    bra dr1_lp
    bclr IFS0, #3
                                                    ;indicate when busy
    bset LATD, #2
													;update time spent here counter
	clr w0
	inc count_here
	addc count_here+2
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
;---------------------------------------------- demodulate
    mov phi_motor, w0
    call positive_demod
;---------------------------------------------- torque/current control
													;this one works fine without determine_direction
    call current_control_1
;---------------------------------------------- phase control
													;this one needs to know direction
    btsc phi_int, #15
    neg w9, w9
	
	bclr flags2, #direction_phase_loop
    btss w9, #15
	bset flags2, #direction_phase_loop
	
    mov #plic_1, w12
    call backemf_phase_control
;---------------------------------------------- compare to wanted |current|
    mov i_min_recov, w0
    call diff_norm_2

    btss w0, #15
    bset PTCON, #15
;---------------------------------------------- filter average updates
    clr w8
    btss w0, #15
    mov #1000, w8

    mov #filter_wir, w13
    mov fil2ord_percentage, w11
    sl w11, #2, w12                                 ;w12 = 4*w11 for no overshoot
    call filter_2nd_order_w12
;---------------------------------------------- filter speed info
    mov phi_motor, w0                               ;w0 = phi_n
    subr phi_motor_prev, wreg                         ;w0 = phi_n - phi_n-1
    add phi_motor_prev                                ; = w0 + phi_n-1
    mov w0, w8

    mov #filter_spd, w13
    mov fil2ord_speed_recovery, w11
    sl w11, #2, w12                                 ;w12 = 4*w11 for no overshoot
    call filter_2nd_order_w12
;---------------------------------------------- reset phi_int when too high
    mov phi_int, w0
    btsc w0, #15
    neg w0, w0
    cp phi_int_max_erpm_shutdown
    btss SR, #C
    clr phi_int
;---------------------------------------------- how about exiting drive_1 ?
                                                    ;end to dr0 when counter expires
    dec counter
    bra z, dr1_to_dr0
                                                    ;continue in dr1 when %-age not met
    mov filter_wir+4, w0
    cp pulse_perc_to_reach
    bra gt, dr1_cont
                                                    ;exit to dr2 or dr2to3 based on speed low or high
    bra dr1_to_dr2
;---------------------------------------------- send signals to motor
dr1_cont:
    call write_motor_sinus
;---------------------------------------------- drive_1 loop end, allow monitoring
    dec monitoring_count
    bra nz, dr1_lp
    mov monitoring_value, w0
    mov w0, monitoring_count
    call monitoring
    bra dr1_lp

;*****************************************************************
dr1_to_dr0:
    goto initialise_drive_0_all

;*****************************************************************
dr1_to_dr2:

                                                    ;to PWM continuous
    call PWM_continuous
                                                    ;calculate new PDC's as PTPER has changed
    call write_motor_sinus
                                                    ;PWM on
    bset PTCON, #15
                                                    ;store speed in phi_int
    mov filter_spd+4, w0
    mov w0, phi_int
                                                    ;drive 2 or drive_2to3, based on phi_int_2to3
    btsc w0, #15
    neg w0, w0
    cp phi_int_2to3
    bra le, dr1_to_dr2to3
                                                    ;reset wanted_i_real filter
    mov #filter_wir, w0
    repeat #3
    clr [w0++]

    goto correct_drive_2
	
dr1_to_dr2to3:
													;reset current filters to prevent new conkout
	                                                ;reset I filter
    mov #filter_I, w0
    repeat #3
    clr [w0++]
                                                    ;reset Q filter
    mov #filter_Q, w0
    repeat #3
    clr [w0++]
                                                    ;reset wanted_i_real filter
    mov #filter_wir, w0
    repeat #3
    clr [w0++]
                                                    ;reset filter_wI going into drive 23
    mov #filter_wI, w0
    repeat #3
    clr [w0++]
	
    goto correct_drive_2to3

;*****************************************************************
;*****************************************************************
;*****************************************************************


.end

