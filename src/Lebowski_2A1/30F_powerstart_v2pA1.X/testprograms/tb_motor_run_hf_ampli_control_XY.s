.include "p30F4011.inc"
.include "defines.inc"

.text

;*****************************************************************

.global main
main:	

;---------------------------------------------- initialise
    call initialise
    call rx_char_232

    mov #23, w0
    mov w0, monitoring_value
    clr flags123

    mov #200, w0
    mov w0, wanted_i_real
                                                    ;get hf values
    mov #1000, w0
    mov w0, wanted_i_hf
    call find_hf_amplitude_adc_offset

	bset PTCON, #15

    mov #-16384, w0
    mov w0, phi_motor
    clr ampli_real
    clr ampli_imag
    mov #500, w0
    mov w0, i_force_position
    call force_motor_position
                                                    ;ADC to current sensors
    call ADC_current
    repeat #5
    nop
    bclr ADCON1, #1

    clr w0
    call tx_word_232
    clr w0
    call tx_word_232
    clr w0
    call tx_word_232
    mov #61642, w0
    call tx_word_232

;---------------------------------------------- get initial magnet position
    clr ampli_real
    clr_ampli_imag
    mov ampli_hf_for_i, w0
    mov w0, ampli_hf_motor
    call reset_filters

    mov #1000, w0
    mov w0, counter
fmrimp_lp:
                                                    ;wait for 40 kHz operation
    btss IFS0, #3
    bra fmrimp_lp
    bclr IFS0, #3

    call ADC_read_current
    bclr ADCON1, #1

    mov phi_hf_motor, w0
    add phi_rotation_hf, wreg
    call negative_demod

    mov #notch_hf_I, w13
    call notch_hf
    mov #notch_2hf_I,w13
    call notch_2hf
    exch w8, w9
    mov #notch_hf_Q, w13
    call notch_hf
    mov #notch_2hf_Q,w13
    call notch_2hf
    exch w8, w9

    mov #filter_I, w13
    mov #600, w11
    mov #1200, w12
    call filter_2nd_order
    exch w8, w9
    mov #filter_Q, w13
    call filter_2nd_order
    exch w8, w9

    mov #2048, w0
    add phi_hf_motor
    call write_motor_sinus

    dec counter
    bra nz, fmrimp_lp

    mov filter_I+4, w8
    mov filter_Q+4, w9
    call angle_amplitude
    mov w9, phi_mag_prev

    clr phi_motor

fmr_lp:
                                                    ;wait for 40 kHz operation
    bclr LATD, #2
    btss IFS0, #3
    bra fmr_lp
    bclr IFS0, #3
                                                    ;indicate when busy
    bset LATD, #2
;---------------------------------------------- get measured currents
    call ADC_read_current
    bclr ADCON1, #1
;---------------------------------------------- positive demod
    mov phi_motor, w0
    call positive_demod
    mov w9, i_imag
    mov w8, i_real
;---------------------------------------------- update ampli_real
    mov wanted_i_real, w1
    cp w8, w1
    bra gt, fmr_dec_ampli_real
fmr_inc_ampli_real:
    inc ampli_real
    bra nz, fmr_done_ampli_real
    setm ampli_real
    bra fmr_done_ampli_real
fmr_dec_ampli_real:
    dec ampli_real
    bra c, fmr_done_ampli_real
    clr ampli_real
fmr_done_ampli_real:
;---------------------------------------------- positive hf demod, control ampli_hf_motor
    mov phi_hf_motor, w0
    add phi_rotation_hf, wreg
    call positive_demod
    mov wanted_i_hf, w1
    cp w8, w1
    bra gt, fmr_dec_ampli_hf
fmr_inc_ampli_hf:
    inc ampli_hf_motor
    bra nz, fmr_done_ampli_hf
    setm ampli_hf_motor
    bra fmr_done_ampli_hf
fmr_dec_ampli_hf:
    dec ampli_hf_motor
    bra c, fmr_done_ampli_hf
    clr ampli_hf_motor
fmr_done_ampli_hf:
;---------------------------------------------- negative hf demod
    mov phi_hf_motor, w0
    add phi_rotation_hf, wreg
    call negative_demod
;---------------------------------------------- notch filtering
    mov #notch_hf_I, w13
    call notch_hf
    mov #notch_2hf_I,w13
    call notch_2hf
    exch w8, w9
    mov #notch_hf_Q, w13
    call notch_hf
    mov #notch_2hf_Q,w13
    call notch_2hf
    exch w8, w9
;---------------------------------------------- butterworth filtering
    mov #filter_I, w13
    mov #600, w11
    mov #1200, w12
    call filter_2nd_order
    exch w8, w9
    mov #filter_Q, w13
    call filter_2nd_order

    mov filter_I+4, w8
    mov filter_Q+4, w9
;---------------------------------------------- online gain calibration
    call online_gain_cal
;---------------------------------------------- update motor phase
    call angle_amplitude
                                                    ;get phase difference
    mov w9, w0
    sub phi_mag_prev, wreg
    mov w9, phi_mag_prev
                                                    ;div 2
    asr w0, w0
                                                    ;add to motor phase
    add phi_motor
;---------------------------------------------- send signals to motor
    mov #2048, w0
    add phi_hf_motor

    call write_motor_sinus
					
 ;---------------------------------------------- loop end, allow monitoring
    dec monitoring_count
    bra nz, fmr_lp
    mov monitoring_value, w0
    mov w0, monitoring_count

    btg flags123, #0
    mov filter_I+4, w0
    btss flags123, #0
    mov old_Y, w0

    mov filter_Q+4, w1
    mov w1, old_Y

    btg w0, #15
    call tx_word_232

    bra fmr_lp


.bss
monitoring_count: .space 2
old_Y: .space 2
flags123: .space 2



.end

