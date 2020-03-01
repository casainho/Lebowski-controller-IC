.include "p30F4011.inc"
.include "defines.inc"

.text

;*****************************************************************

.global filter_4th_order
; w1: input, signed, -25000 .. 25000
; w11: start of integrator array
; output in [w11+12]
filter_4th_order:
                                                    ;w11 points to int_1, MSW, LSW
    add w11, #4, w12                                ;w12 points to int_2, MSW, LSW
    add w11, #8, w13                                ;w13 points to int_3, MSW, LSW
    add w11, #12, w14                               ;w14 points to int_4, MSW, LSW

;---------------------------------------------- mult input with coef1, add to 1st integrator
                                                    ;w1: input
    mov #556, w2                                    ;0.00849 for 100Hz at 40kHz fs
    mul.us w2, w1, w0
    add w0, [++w11], [w11]
    addc w1, [--w11], [w11]

;---------------------------------------------- mult int_2 with coef1, sub from 1st integrator

    mul.us w2, [w12], w0
    subr w0, [++w11], [w11]
    subbr w1, [--w11], [w11]

;---------------------------------------------- mult int_2 with coef2, sub from 2nd integrator

    mov #1901, w2                                   ;0.02901 for 100Hz at 40kHz fs
    mul.us w2, [w12], w0
    subr w0, [++w12], [w12]
    subbr w1, [--w12], [w12]

;---------------------------------------------- mult int_1 with coef2, add to 2nd integrator

    mul.us w2, [w11], w0
    add w0, [++w12], [w12]
    addc w1, [--w12], [w12]

;---------------------------------------------- mult int_2 with coef3, add to 3rd integrator

    mov #1343, w2                                   ;0.0205 for 100Hz at 40kHz fs
    mul.us w2, [w12], w0
    add w0, [++w13], [w13]
    addc w1, [--w13], [w13]

;---------------------------------------------- mult int_4 with coef3, sub from 3rd integrator

    mul.us w2, [w14], w0
    subr w0, [++w13], [w13]
    subbr w1, [--w13], [w13]

;---------------------------------------------- mult int_4 with coef4, sub from 4th integrator

    mov #786, w2                                    ;0.012 for 100Hz at 40kHz fs
    mul.us w2, [w14], w0
    subr w0, [++w14], [w14]
    subbr w1, [--w14], [w14]

;---------------------------------------------- mult int_3 with coef4, add to 4th integrator

    mul.us w2, [w13], w0
    add w0, [++w14], [w14]
    addc w1, [--w14], [w14]

;---------------------------------------------- end
    return


.end

