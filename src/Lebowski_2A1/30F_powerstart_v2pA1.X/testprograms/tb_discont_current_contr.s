.include "p30F4011.inc"
.include "defines.inc"

.text

;*****************************************************************

.global main_tb
main_tb:						
						
;---------------------------------------------- initialise
                                                    ;global initialise
    call initialise
    call PWM_discontinuous
    call ADC_current
                                                    ;initialise dutycycle at 50%
	mov PTPER, w0
	mov w0, PDC1
	mov w0, PDC2
	mov w0, PDC3
                                                    ;initialise monitoring
    mov monitoring_value, w0
    mov w0, monitoring_count

;---------------------------------------------- discontinuous current control loop
tb1:
                                                    ;wait for 40 kHz operation
    btss IFS0, #3
    bra tb1
    bclr IFS0, #3
;---------------------------------------------- get measured currents
    bclr ADCON1, #1
    nop
    nop
    nop
    nop
    nop
    call ADC_read_current
;---------------------------------------------- demodulate
    mov phi_motor, w0
    add phi_prop, wreg
    call positive_demod
    mov w8, dummy1
    mov w9, dummy2
    push w8
    push w9
;---------------------------------------------- torque/current control
    call current_control
;---------------------------------------------- phase control
    mov #900, w0
    mov filter_I+4, w1
    mov #tbloffset(backemf_phase_control), w13
    cpsgt w1, w0
    mov #tbloffset(backemf_phase_control_2), w13

    call w13

    pop w9
    pop w8

;---------------------------------------------- compare to wanted |current|
    mov #500, w0
    call diff_norm_2

    btss w0, #15
    bset PTCON, #15
;---------------------------------------------- filter average updates
    clr w8
    btsc PTCON, #15
    mov #1000, w8

    mov #filter_I, w13
    mov #200, w11
    call filter_2nd_order

;---------------------------------------------- send signals to motor
    call write_motor_sinus
;---------------------------------------------- drive_3 loop end, allow monitoring
    dec monitoring_count
    bra nz, tb1
    mov monitoring_value, w0
    mov w0, monitoring_count
    call monitoring
    bra tb1



diff_norm_2:
;calculates w0^2 - w8^2 - w9^2
;MSW result in w0 upon end
;
;corrupts w0, w1, w2, w3
;---------------------------------------------- w3:w2 = w0^2
    mul.ss w0, w0, w2
;---------------------------------------------- subtract w8^2
    mul.ss w8, w8, w0

    sub w2, w0, w2
    subb w3, w1, w3
;---------------------------------------------- subtract w9^2
    mul.ss w9, w9, w0

    sub w2, w0, w2
    subb w3, w1, w0
;---------------------------------------------- end
    return




pfd_control:
;at output: w0 = MSW[ w9*w8_prev - w8*w9_prev ]
;
;corrupts: w0, w1, w2, w3
;---------------------------------------------- recover w8_prev and w9_prev, write new ones
    mov w8_prev, w2
    mov w9_prev, w3

    mov w8, w8_prev
    mov w9, w9_prev
;---------------------------------------------- calculate cross product
                                                    ;w1:w0 = w9*w8_prev
    mul.ss w9, w2, w0
                                                    ;w3:w2 = w8*w9_prev
    mul.ss w8, w3, w2

    sub w0, w2, w0
    subb w1, w3, w0
;---------------------------------------------- update phase based on sign of cross product

    mov #plic_2, w12                              ;positive array position
    btsc w0, #15
    add w12, #10, w12                           ;shift to negative if i_imag (w9) > 0 (note the inversion !!!!!!)

    mov #phi_motor+2, w10
    mov #phi_int+2, w11

    mov [w12++], w1                             ;w1.w2 to be added to phi_int
    mov [w12++], w2
                                                ;update phi_int with coefficients
    add w2, [w11], [w11--]
    addc w1, [w11], [w11++]

    mov [w12++], w1                             ;w1.w2 to be added to phi_motor (this is the 1st integrator bypass path)
    mov [w12++], w2
                                                ;add phi_int to the coefficients of phi
    add w2, [w11--], w2
    addc w1, [w11], w1
                                                ;and add to phi_motor
    add w2, [w10], [w10--]
    addc w1, [w10], [w10]
                                                ;and don't forget the phi_prop
    mov [w12], w0
    add phi_prop


;---------------------------------------------- end
    return


.end

