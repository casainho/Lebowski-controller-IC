.include "p30F4011.inc"
.include "defines.inc"

.text

;*****************************************************************

.global tb_instability
tb_instability:
	call ADC_current
	call reset_filters
	call clear_variables
                                                    ;indicate tb
    bclr LATC, #15
    bset LATC, #13
    bclr LATC, #14
    bset LATE, #8
	
	bset PTCON, #15
	
	mov phi_int_max_erpm+2, w0
	mov w0, phi_int
    mov i_filter_offset, w0
	mov w0, wanted_i_real
	clr wanted_i_imag
		
tb_lp:
                                                    ;wait for 40 kHz operation
    bclr LATD, #2
    btss IFS0, #3
    bra tb_lp
    bclr IFS0, #3
                                                    ;indicate when busy
    bset LATD, #2

;---------------------------------------------- get measured currents
    bclr ADCON1, #1
    nop
	nop

    call ADC_read_current
;---------------------------------------------- process throttle based on TMR4
;    btsc IFS1, #5
;    call throttle_read
;---------------------------------------------- demodulate 
    mov phi_motor, w0
    call positive_demod
;---------------------------------------------- current filtering
	call current_filtering
;---------------------------------------------- torque/current control
    call current_control
;---------------------------------------------- calculate ampli_imag
    call calc_ampli_imag
;---------------------------------------------- phase control
	mov phi_int, w0
	add phi_motor
	
;   mov #plic_3, w12
;   call backemf_phase_control
;---------------------------------------------- send signals to motor
    call write_motor_sinus
;---------------------------------------------- drive_3 loop end, allow monitoring
	btss PORTD, #3
	bra tb_lp2
	
    dec monitoring_count
    bra nz, tb_lp
    mov monitoring_value, w0
    mov w0, monitoring_count
    call monitoring
    bra tb_lp

	
;***************************************************
; second half
;***************************************************
	
tb_lp2:
                                                    ;wait for 40 kHz operation
    bclr LATD, #2
    btss IFS0, #3
    bra tb_lp2
    bclr IFS0, #3
                                                    ;indicate when busy
    bset LATD, #2

;---------------------------------------------- get measured currents
    bclr ADCON1, #1
    nop
	nop

    call ADC_read_current
;---------------------------------------------- process throttle based on TMR4
;    btsc IFS1, #5
;    call throttle_read
;---------------------------------------------- demodulate 
    mov phi_motor, w0
    call positive_demod
;---------------------------------------------- current filtering
	call current_filtering
;---------------------------------------------- torque/current control
    call current_control
;---------------------------------------------- calculate ampli_imag
    call calc_ampli_imag
;---------------------------------------------- phase control
;	mov phi_int, w0
;	add phi_motor
	
    mov #plic_3, w12
    call backemf_phase_control
;---------------------------------------------- send signals to motor
    call write_motor_sinus
;---------------------------------------------- drive_3 loop end, allow monitoring
    dec monitoring_count
    bra nz, tb_lp2
    mov monitoring_value, w0
    mov w0, monitoring_count
    call monitoring
    bra tb_lp2


.end

