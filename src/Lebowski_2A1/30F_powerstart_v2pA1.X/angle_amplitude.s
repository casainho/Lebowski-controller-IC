.include "p30F4011.inc"
.include "defines.inc"

.text

;*****************************************************************

.global angle_amplitude_fast
;w8: I or X
;w9: Q or Y
;after routine
;w8: amplitude
;w9: angle
;
;corrupted variables:
; w0, w1, w2, w3, w8, w9, w12, w13
angle_amplitude_fast:
						
;---------------------------------------------- initialise
												;preliminary angle in w13
	clr w13
	
;---------------------------------------------- y(w9)<0 ? rotate over 180 deg
	btss w9, #15
	bra endover180
												;add 32768 to w13
	bset w13, #15
												;xn=-x, yn=y (w8=-w8, w9=-w9)
	neg w8, w8
	neg w9, w9
	
endover180:	
;---------------------------------------------- x(w8)<0 ? rotate over 90 deg
	btss w8, #15
	bra endover90
												;add 16384 to w13
	bset w13, #14
												;yn=-x, xn=y (w9=-w8, w8=w9)
	exch w8, w9
	neg w9, w9
												
endover90:
;---------------------------------------------- remaining angle =  90deg * w9/(w8+w9)
	add w8, w9, w2
	btsc SR, #Z
	mov #1, w2
												;the 90 comes down to divide by 4, can be done here already.
	lsr w9, #2, w1
	clr w0
	
	repeat #17
	div.ud w0, w2
												;add remaining angle to previously found result
	add w13, w0, w13
;---------------------------------------------- rotate w8,w9 over w12 to find vector length
												;length = w8 * cos(w12) + w9 * sin(w12)
											    ;get position in sin array [w12]
    lsr w0, #7, w12
    bclr w12, #0
    bset w12, #11
	
	mul.ss w9, [w12], w0
												;go to cos position, no overflow as original angle below 90 deg.
	add #128, w12
	
	mul.ss w8, [w12], w2
													;length in w8 (compensate for Q15)
	add w1, w3, w8
	sl w8, w8
;---------------------------------------------- results in w8 and w9
	mov w13, w9
;---------------------------------------------- end	
	return
;*****************************************************************

.global angle_amplitude_accurate
;w8: I or X
;w9: Q or Y
;after routine
;w8: amplitude
;w9: angle
;
;corrupted variables:
; w0, w1, w4, w5, w6, w7, w10, w12, w13
angle_amplitude_accurate:
						
;---------------------------------------------- initialise

    clr w10
    mov #angle_coeff_array, w13

;---------------------------------------------- loop 8 times

    mov #8, w12
aa_loop:
;---------------------------------------------- angle times 2

    sl w10, w10

;---------------------------------------------- apply rotation
                                                    ;w5: new X, w7: new Y
                                                    ;mult with cosine first
    mul.ss w8, [w13], w4
    mul.ss w9, [w13++], w6
                                                    ;mult with sine
    mul.ss w9, [w13], w0
    add w1, w5, w5
    mul.ss w8, [w13++], w0
    sub w7, w1, w7

;---------------------------------------------- keep ? yes, lets keep it
                                                    ;keep if Y still positive
    btsc w7, #15
    bra aa_discard
aa_keep:                                            ;still need to compensate for Q.15 multiplication
    sl w5, w8
    sl w7, w9
                                                    ;and update angle
    inc w10, w10
;---------------------------------------------- no, discard or just continue
aa_discard:
    dec w12, w12
    bra nz, aa_loop

;---------------------------------------------- end
    sl w10, #8, w9

    return

;*****************************************************************

.global initialise_angle_amplitude_accurate
initialise_angle_amplitude_accurate:

    mov #angle_coeff_array, w13
;---------------------------------------------- cos 360/2
    mov #-32767, w0
    mov w0, [w13++]
;---------------------------------------------- sin 360/2
    mov #0, w0
    mov w0, [w13++]
;---------------------------------------------- cos 360/4
    mov #0, w0
    mov w0, [w13++]
;---------------------------------------------- sin 360/4
    mov #32767, w0
    mov w0, [w13++]
;---------------------------------------------- cos 360/8
    mov #23170, w0
    mov w0, [w13++]
;---------------------------------------------- sin 360/8
    mov #23170, w0
    mov w0, [w13++]
;---------------------------------------------- cos 360/16
    mov #30274, w0
    mov w0, [w13++]
;---------------------------------------------- sin 360/16
    mov #12540, w0
    mov w0, [w13++]
;---------------------------------------------- cos 360/32
    mov #32138, w0
    mov w0, [w13++]
;---------------------------------------------- sin 360/32
    mov #6393, w0
    mov w0, [w13++]
;---------------------------------------------- cos 360/64
    mov #32610, w0
    mov w0, [w13++]
;---------------------------------------------- sin 360/64
    mov #3212, w0
    mov w0, [w13++]
;---------------------------------------------- cos 360/128
    mov #32728, w0
    mov w0, [w13++]
;---------------------------------------------- sin 360/128
    mov #1608, w0
    mov w0, [w13++]
;---------------------------------------------- cos 360/256
    mov #32758, w0
    mov w0, [w13++]
;---------------------------------------------- sin 360/256
    mov #804, w0
    mov w0, [w13++]

    return

;*****************************************************************

.bss
.align 2
angle_coeff_array:  .space 32

.end




