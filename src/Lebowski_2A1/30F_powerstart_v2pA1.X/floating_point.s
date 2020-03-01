.include "p30F4011.inc"
.include "defines.inc"
.include "print_macros.mac"

.text

;*****************************************************************
;[w13] = 1 / [w13]                                   
.global fp_oneover
fp_oneover:
                                    ;ye = -29 - xe 
    mov #-29, w0
    sub w0, [w13], [w13]
                                    ;ym = 2^29-1 / xm
    mov #0x1FFF, w1
    setm w0
    mov [++w13], w2
    repeat #17
    div.sd w0, w2
    mov w0, [w13--]

	return
	

;************************************************************************************
;[w13] = [w12] * [w13]
.global fp_mult
fp_mult:
                                    ;zm = xm * ym
    mov [w12+2], w0
    mul.ss w0, [++w13], w2
                                    ;find shift in w3
    fbcl w3, w0
    neg w0, w0
    subr w0, #16, w1
                                    ;shift mantissa
    sl w3, w0, w3
    lsr w2, w1, w2
    ior w3, w2, [w13--]
                                    ;calculate exponent
    add w1, [w12], w1
    add w1, [w13], [w13]

	return


;************************************************************************************
;[w13] = [w12] + [w13]
.global fp_add
fp_add:
                                    ;which exponent is bigger ?
    mov [w12], w0
    sub w0, [w13], w0
    bra gt, 9f
                                    ;[w13]_e > [w12]_e
    neg w0, w0
                                    ;allign [w12]_m with [w13]_m
    mov [w12+2], w3
    asr w3, w0, w3
                                    ;get exponent
    mov [w13++], w1
                                    ;perform addition
    add w3, [w13--], w3
                                    ;deal with possible overflow
    bra nov, 8f
    rrc w3, w3
    inc w1, w1
    bra 8f                                
9:                                  ;[reg1]_e > [reg2]_e
                                    ;allign [reg2]_m with [reg1]_m
    mov [w13+2], w3
    asr w3, w0, w3
                                    ;get exponent
    mov [w12++], w1
                                    ;perform addition
    add w3, [w12--], w3
                                    ;deal with possible overflow
    bra nov, 8f
    rrc w3, w3
    inc w1, w1
8:
                                    ;find shift in w3
    fbcl w3, w0
    neg w0, w0
                                    ;calculate exponent
    sub w1, w0, [w13++]
                                    ;shift mantissa
    sl w3, w0, w3
	mov w3, [w13--]

	return


;************************************************************************************
	
.global fp_sqrt
fp_sqrt:		
									;result = 0 if negative
	mov [w13+2], w7
	clr w6
	btss w7, #15
	bra 1f
	
	clr [w13++]
	clr [w13--]
	return
1:
									;div2 to prevent overflow (sqrt result > 0x8000, so negative)
	inc [w13], [w13]
	lsr w7, w7
	rrc w6, w6
									;account for shift in exponent, make even, divide by 2
	mov [w13], w0
	sub #16, w0
	btss w0, #0
	bra 1f
	
	lsr w7, w7
	rrc w6, w6
	inc w0, w0
1:
	asr w0, w0
	mov w0, [w13]
									;loop, initialise
	clr w4
    mov #0x8000, w5
fpsqrt_lp:
    ior w4, w5, w4
									;keep bit ?, yes if w7:w6 - w4*w4 > 0
    mul.uu w4, w4, w0
	sub w6, w0, w0
    subb w7, w1, w1

    btsc w1, #15
    xor w4, w5, w4

    lsr w5, w5
    bra nc, fpsqrt_lp
									;allign result, find shift in w4
    fbcl w4, w0
    neg w0, w0
                                    ;calculate exponent
    subr w0, [w13], [w13]
                                    ;shift mantissa
    sl w4, w0, w4
	mov w4, [w13+2]							

	return
									
;************************************************************************************
	
.global fp_print	
fp_print:
									;print sign
	mov [w13+2], w0
	print_sign
									;shift over exponent
	neg [w13], w1
	lsr w0, w1, w3
	subr w1, #16, w1
	sl w0, w1, w2
									;print units
	mov w3, w0
	push w2
	print_udec
									;print frac
	pop w0
	print_frac 2
	
	return