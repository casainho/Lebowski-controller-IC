.include "p30F4011.inc"
.include "defines.inc"

.text

;*****************************************************************

.global hf_control
; w7: wanted i_hf
;
;corrupted variables:
;w0, w1, w2, w3, w8, w9, w13
hf_control:

;---------------------------------------------- positive demod
    mov phi_hf_motor, w0
    add phi_hf_demod_offset, wreg
    call positive_demod
;---------------------------------------------- update demodulation phase offset
    mov #16, w0
    btsc w9, #15
    neg w0, w0
    add phi_hf_demod_offset
;---------------------------------------------- regulate hf current amplitude
    cp w8, w7
    bra gt, dec_hf_ampli
inc_hf_ampli:
    inc ampli_hf_motor
    bra nz, done_hf_ampli
    setm ampli_hf_motor
    bra done_hf_ampli
dec_hf_ampli:
    dec ampli_hf_motor
    bra c, done_hf_ampli
    clr ampli_hf_motor
done_hf_ampli:

    return

;*****************************************************************

.global hf_ampli_control
; w2: wanted i_hf
;
;no phi_hf_demod_offset controll as this interferes with the online gain calibration
;
;corrupted variables
;w0, w1, w2, w3, w8, w9, w13
hf_ampli_control:

;---------------------------------------------- positive demod
    mov phi_hf_motor, w0
    add phi_hf_demod_offset, wreg
    call positive_demod
;---------------------------------------------- regulate hf current amplitude
    cp w8, w7
    bra gt, dec_hf2_ampli
inc_hf2_ampli:
    inc ampli_hf_motor
    bra nz, done_hf2_ampli
    setm ampli_hf_motor
    bra done_hf2_ampli
dec_hf2_ampli:
    dec ampli_hf_motor
    bra c, done_hf2_ampli
    clr ampli_hf_motor
done_hf2_ampli:

    return

;*****************************************************************

.global hf_position_demod
;corrupted variables
;w0, w1, , w2, w3, w8, w9, w10, w11, w12, w13, w14
hf_position_demod:
;---------------------------------------------- negative demod
    mov phi_hf_motor, w0
    add phi_hf_demod_offset, wreg
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
    mov fil2ord_motor_position, w11
    call filter_2nd_order
    exch w8, w9
    mov #filter_Q, w13
    goto filter_2nd_order

;*****************************************************************


.global hf_control_fast
;fast, 'cause only a few 100 cycles available in drive_3to2
; w7: wanted i_hf
;
;corrupted variables:
;w0, w1, w2, w3, w8, w9, w10
hf_control_fast:

;---------------------------------------------- positive demod
    mov phi_hf_motor, w0
    add phi_hf_demod_offset, wreg
    call positive_demod
;---------------------------------------------- update demodulation phase offset
    mov #16, w0
    btsc w9, #15
    neg w0, w0
    add phi_hf_demod_offset
;---------------------------------------------- regulate hf current amplitude
    mov #20, w0

    cp w8, w7
    bra gt, dec_hf_ampli_fast
inc_hf_ampli_fast:
    add ampli_hf_motor
    bra nc, done_hf_ampli_fast
    setm ampli_hf_motor
    bra done_hf_ampli_fast
dec_hf_ampli_fast:
    sub ampli_hf_motor
    bra c, done_hf_ampli_fast
    clr ampli_hf_motor
done_hf_ampli_fast:

    return

;*****************************************************************

.global hf_position_demod_fast
;fast, 'cause only a few 100 cycles available in drive_3to2
;corrupted variables
;w0, w1, w2, w3, w8, w9, w10, w11, w12, w13, w14
hf_position_demod_fast:

;---------------------------------------------- negative demod
    mov phi_hf_motor, w0
    add phi_hf_demod_offset, wreg
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
    mov #400, w11
    call filter_2nd_order
    exch w8, w9
    mov #filter_Q, w13
    goto filter_2nd_order

;*****************************************************************

.end
