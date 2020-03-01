.include "p30F4011.inc"
.include "defines.inc"

.text

;*****************************************************************

.global disect_current
disect_current:
;--------------------------------------- calculate phase current values
                                            
    mov phi_disect, w0
                                            ;measured currents are already in w4, w5, w6
;--------------------------------------- disect currents into real and imaginary part, store i_real, i_imag
                                            ;calculate address in sine array
    lsr w0, #7, w10
	bclr w10, #0
	bset w10, #11
	bset w10, #10
                                            ;calculate i_real, start with phase A, add B, add C
    mul.ss w4, [w10], w0
    mov w1, w8

	add #170, w10
	bclr w10, #9
    mul.ss w5, [w10], w0
    add w1, w8, w8

	add #172, w10
	bclr w10, #9
    mul.ss w6, [w10], w0
    add w1, w8, w8
                                            ;calculate i_imag
                                            ;move to -cos in array
    add #42, w10
	bclr w10, #9
    mul.ss w4, [w10], w0
    mov w1, w9

  	add #170, w10
	bclr w10, #9
    mul.ss w5, [w10], w0
    add w1, w9, w9

	add #172, w10
	bclr w10, #9
    mul.ss w6, [w10], w0
    add w1, w9, w9

;--------------------------------------- perform comb filtering if requested

    btss flags_rom, #comb_filter
    bra dc_store

    mov w8_nm1, w6
    mov w9_nm1, w7

    mov w8, w8_nm1
    mov w9, w9_nm1

    add w6, w8, w8
    asr w8, w8
    add w7, w9, w9
    asr w9, w9

;--------------------------------------- store I_real, I_imag	
dc_store:

    mov w8, i_real
    mov w9, i_imag
                                            ;invert i_imag if we're in reverse
    sl direction, wreg
    xor i_imag

;--------------------------------------- filter i_real
                                            ;filt[n] = filt[n-1] + alpha * ( I[n] - filt[n-1] )
    mov i_real_filtcoef, w1

    mov i_real, w0
    subr i_real_filt, wreg                  ;i[n] - filt[n-1]
    asr w0, w1, w0                          ;alpha = 1/(2^filtercoefficient+1)
    asr w0, w0                              ;separate asr statement to rotate remainder into carry
    addc i_real_filt                        ;filt[n] = filt[n-1] + alpha * ( I[n] - filt[n-1] )

;--------------------------------------- filter i_imag
    mov i_imag_filtcoef, w1
                                            ;filt[n] = filt[n-1] + alpha * ( I[n] - filt[n-1] )
    mov i_imag, w0
    subr i_imag_filt, wreg                  ;i[n] - filt[n-1]
    asr w0, w1, w0                          ;alpha = 1/(2^filtercoefficient+1)
    asr w0, w0                              ;separate asr statement to rotate remainder into carry
    addc i_imag_filt                        ;filt[n] = filt[n-1] + alpha * ( I[n] - filt[n-1] )

;--------------------------------------- end

    return

;*****************************************************************

.bss
w8_nm1:	.space 2	;keep previous value for comb filtering
w9_nm1: .space 2	;keep previous value for comb filtering

.end
