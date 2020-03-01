.include "p30F4011.inc"
.include "defines.inc"

.text

;*****************************************************************

.global filter_2nd_order
; w8: input, signed, -25000 .. 25000
; w11: filter coef 1 (a0 in labview)
; w13: start of integrator array
; output in [w13+4]
;
; corrupted registers:
; w0, w1, w12, w14
filter_2nd_order:
.global filter_2nd_order_w12
filter_2nd_order_w12:	
	
;---------------------------------------------- 	
                                                    ;w13 points to int_1, MSW, LSW
	add #4, w13
													;difference
	sub w8, [w13], w0
													;mult with coeff
	mul.us w11, w0, w0
													;add to output
	add w0, [++w13], [w13]
	addc w1, [--w13], [w13]
;---------------------------------------------- end

    return
	
	
	
	
	
	
	
	
	
	
	
	
	
	
	
	
	
	
	
	
	
	
/*	
	
; --------------------------------------------- w12: filter coef 2 (a1 in labview), double of w11

    sl w11, w12
                                                    ;or jump in here with w12 (a1 in labview) already given
.global filter_2nd_order_w12
filter_2nd_order_w12:
                                                    ;w13 points to int_1, MSW, LSW
    add w13, #4, w14                                ;w14 points to int_2, MSW, LSW

;---------------------------------------------- mult input with coef1, add to 1st integrator
                                                    ;w8: input
    mul.su w8, w11, w0
    add w0, [++w13], [w13]
    addc w1, [--w13], [w13]

;---------------------------------------------- mult int_2 with coef1, sub from 1st integrator

    mul.us w11, [w14], w0
    subr w0, [++w13], [w13]
    subbr w1, [--w13], [w13]

;---------------------------------------------- mult int_2 with coef2, sub from 2nd integrator

    mul.us w12, [w14], w0
    subr w0, [++w14], [w14]
    subbr w1, [--w14], [w14]

;---------------------------------------------- mult int_1 with coef2, add to 2nd integrator

    mul.us w12, [w13], w0
    add w0, [++w14], [w14]
    addc w1, [--w14], [w14]

;---------------------------------------------- end

    return
*/
;*****************************************************************
/*
.global filter_notches
; w4,5,6: input, signed, -25000 .. 25000
; w4,5,6: filtered output
;
; w13: start of variable array
;	[w13   ]:x1 
;	[w13+ 2]:x3 
;	[w13+ 4]:r2
;	[w13+ 6]:x2 
;	[w13+ 8]:x4 
;	[w13+10]:r4 
;	[w13+12]:r3 
;
filter_notches:
	mov #notch_array, w13
	mov notch_alpha, w11
;---------------------------------------------- start with w4
	mov w13, w12
												;x2 = x2 + a(x1-x3)
	mov [w13++], w2									;w13 -> x3
	sub w2, [w13++], w2								;w13 -> r2
	mul.us w11, w2, w0
	add w0, [w13], [w13++]							;w13 -> x2
	addc w1, [w13], [w13]
	mov [w13], w2		
												;x1 = I
	mov w4, [w12++]									;w12 -> x3
												;u = I-x2+x3-x4
	add w4, [w12], w4							
	sub w4, [w13++], w4								;w13 -> x4
	sub w4, [w13++], w4								;w13 -> r4
												;x4=x4+ a*u
	mul.us w11, w4, w0
	add w0, [w13], [w13--]							;w13 -> x4
	addc w1, [w13], [w13++]							;w13 -> r4 
												;x3=x3+a(x2-x3)
	sub w2,[w12], w2
	mul.us w11, w2, w0
	add w0, [++w13], [w13++]						;w13 -> r3 -> w5 array
	addc w1, [w12], [w12]
;---------------------------------------------- process w5
	mov w13, w12
	mov [w13++], w2									
	sub w2, [w13++], w2								
	mul.us w11, w2, w0
	add w0, [w13], [w13++]						
	addc w1, [w13], [w13]
	mov [w13], w2		
	mov w5, [w12++]									
	add w5, [w12], w5							
	sub w5, [w13++], w5								
	sub w5, [w13++], w5								
	mul.us w11, w5, w0
	add w0, [w13], [w13--]							
	addc w1, [w13], [w13++]							 
	sub w2,[w12], w2
	mul.us w11, w2, w0
	add w0, [++w13], [w13++]						
	addc w1, [w12], [w12]
;---------------------------------------------- process w6
	mov w13, w12
	mov [w13++], w2									
	sub w2, [w13++], w2								
	mul.us w11, w2, w0
	add w0, [w13], [w13++]						
	addc w1, [w13], [w13]
	mov [w13], w2		
	mov w6, [w12++]									
	add w6, [w12], w6							
	sub w6, [w13++], w6								
	sub w6, [w13++], w6								
	mul.us w11, w6, w0
	add w0, [w13], [w13--]							
	addc w1, [w13], [w13++]							 
	sub w2,[w12], w2
	mul.us w11, w2, w0
	add w0, [++w13], [w13++]						
	addc w1, [w12], [w12]
;---------------------------------------------- end
    return	
*/
;*****************************************************************
/*
.global filter_lpf
; w8,9: input, signed, -25000 .. 25000
; w8,9: filtered output
;
;gain:16
;
; w13: start of variable array
;	[w13   ]:r1
;	[w13+ 2]:x1 
;	[w13+ 4]:x2
;	[w13+ 6]:r2 

filter_lpf:
;	mov #lpf_array, w13
;	mov lpf_alpha, w11
;---------------------------------------------- start with w8
												;x1 = x1 + 16*a*I - a*x2
	sl w11, #4, w10
	mul.us w10, w8, w0
	add w0, [w13], [w13++]							;w13 -> x1
	addc w1, [w13], [w13++]							;w13 -> x2
	mul.us w11, [w13--], w0							;w13 -> x1
	subr w0, [--w13], [w13++]						;w13 -> r1 -> x1
	subbr w1, [w13], [w13]		
												;x2 = x2 + 2*a*(x1-x2)
	sl w11, #1, w10
	mov [w13++], w0									;w13 -> x2
	sub w0, [w13++], w0								;w13 -> r2
	mul.us w10, w0, w0
	add w0, [w13], [w13--]							;w13 -> x2
	addc w1, [w13], [w13]							
	
	mov [w13++], w8									;w13 -> r2
	
;---------------------------------------------- process w9							
												
	sl w11, #4, w10
	mul.us w10, w9, w0
	add w0, [++w13], [w13++]						;w13 -> r1 (of w9 array) -> x1							
	addc w1, [w13], [w13++]							
	mul.us w11, [w13--], w0							
	subr w0, [--w13], [w13++]						
	subbr w1, [w13], [w13]	
	sl w11, #1, w10
	mov [w13++], w0									
	sub w0, [w13++], w0								
	mul.us w10, w0, w0
	add w0, [w13], [w13--]							
	addc w1, [w13], [w13]							
	mov [w13++], w9									
												
;---------------------------------------------- end

    return	
*/
;*****************************************************************										
/*								
.global filter_hf_notch
; w4,5,6: input, signed, -25000 .. 25000
; w4,5,6: filtered output
;
; w13: start of variable array
;	[w13   ]:x1 
;	[w13+ 2]:x3 
;	[w13+ 4]:r2
;	[w13+ 6]:x2 
;	[w13+ 8]:r3 
;
filter_hf_notch:
	mov #hf_notch_array, w13
	mov notch_alpha, w11
;---------------------------------------------- start with w4		
	mov w13, w12									;w13 -> x1
													;w12 -> x1
												;x2 = x2 + a * (x1 - x3)
	mov [w13++], w0									;w13 -> x3
	sub w0, [w13++], w0								;w13 -> r2
	mul.us w11, w0, w0
	add w0, [w13], [w13++]							;w13 -> x2
	addc w1, [w13], [w13]
												;x1 = I
	mov w4, [w12++]									;w12 -> x3
												;u = I + x3 - x2
	add w4, [w12], w4
	sub w4, [w13], w4
												;x3 = x3 + a * (x2 - x3)
	mov [w13++], w0									;w13 -> r3
	sub w0, [w12], w0
	mul.us w11, w0, w0
	add w0, [w13], [w13++]							;w13 -> x1 of w5
	addc w1, [w12], [w12]

;---------------------------------------------- process w5		

	mov w13, w12									
	mov [w13++], w0									
	sub w0, [w13++], w0								
	mul.us w11, w0, w0
	add w0, [w13], [w13++]							
	addc w1, [w13], [w13]												
	mov w5, [w12++]																					
	add w5, [w12], w5
	sub w5, [w13], w5							
	mov [w13++], w0									
	sub w0, [w12], w0
	mul.us w11, w0, w0
	add w0, [w13], [w13++]							
	addc w1, [w12], [w12]

;---------------------------------------------- process w6		

	mov w13, w12									
	mov [w13++], w0									
	sub w0, [w13++], w0								
	mul.us w11, w0, w0
	add w0, [w13], [w13++]							
	addc w1, [w13], [w13]												
	mov w6, [w12++]																					
	add w6, [w12], w6
	sub w6, [w13], w6							
	mov [w13++], w0									
	sub w0, [w12], w0
	mul.us w11, w0, w0
	add w0, [w13], [w13++]							
	addc w1, [w12], [w12]

;---------------------------------------------- end		

	return
*/	
;*****************************************************************										
/*	
.global filter_dc_notch
; w4,5,6: input, signed, -25000 .. 25000
; w4,5,6: filtered output
;
; w13: start of variable array
;	[w13   ]:x1 
;	[w13+ 2]:r1 
;
filter_dc_notch:

	mov #dc_notch_array, w13
	mov notch_alpha, w11
;---------------------------------------------- start with w4		
												;U = I - x1
	sub w4, [w13], w4
												;x1 = x1 + a * u
	mul.us w11, w4, w0								
	add w0, [++w13], [w13--]						;w13 -> r1 -> x1
	addc w1, [w13], [w13++]							;w13 -> r1
;---------------------------------------------- process w5	
	sub w5, [++w13], w5
	mul.us w11, w5, w0								
	add w0, [++w13], [w13--]						
	addc w1, [w13], [w13++]							
;---------------------------------------------- process w6
	sub w6, [++w13], w6
	mul.us w11, w6, w0								
	add w0, [++w13], [w13--]						
	addc w1, [w13], [w13++]							
;---------------------------------------------- end		

	return
*/

.end

