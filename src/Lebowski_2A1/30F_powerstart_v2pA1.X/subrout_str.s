.include "p30F4011.inc"
.include "defines.inc"

.text

;*****************************************************************

.global word_to_hex_str
;w0 contains word to be converted to hex string
;w1 contains start address of string

word_to_hex_str:
						;save registers
    push w5
    push w4
    push w3
    push w2
						;initialise registers
    mov w1, w2					;w2 contains string address
    mov w0, w3					;w3 contains number to be converted
    mov #0x1000, w4				;w4 contains divider (start with 0x1000)
    mov #0x0010, w5				;w5 contains update div ratio for w4
						;do 4 times
    do #3,wths_last
						;determine quotient and remainder
    repeat #17
    div.u w3, w4
						;write character to string
    cp.b w0, #9
    bra leu, wths_smaller			;if less or equal, only add '0'
    add #('A'-'9'-1), w0			;if lager than '9', add 'A'-'9'-1
wths_smaller:
    add #'0', w0				;add '0'
    mov.b w0, [w2++]
						;update number to be divided
    mov w1, w3
						;calculate new divider ratio
    repeat #17
    div.u w4, w5
    mov w0, w4					;w4 starts as 0x1000, then 0x0100, then 0x0010 and finally 0x0001
wths_last:
    nop                                         	;last statement in do_loop
						;write '\0' to indicate string end
    clr.b [w2]
						;restore registers
    pop w2
    pop w3
    pop w4
    pop w5
					
    return

;*****************************************************************

.global word_to_Q15_str
;w0 contains word to be converted, in range[-1..1]
;w1 contains start address of string

word_to_Q15_str:
                                                ;print '-' if necessary, make positive
    btss w0, #15
    bra wtqs_cont

    push w2
    mov w0, w2

    mov.b #'-', w0
    mov.b w0, [w1++]

    neg w2, w0
    pop w2

wtqs_cont:
                                                ;multiply with 2
    sl w0, #1, w0
                                                ;continue as 01_str
    goto word_to_01_str

;*****************************************************************

.global word_to_01_str
;w0 contains word to be converted, in range[0..1]
;w1 contains start address of string

word_to_01_str:
						;save registers
    push w2
    push w3
    push w4
						;put '.' as first in output string
    mov #'.', w2
    mov.b w2, [w1++]
						;multiply w0 by 1 / 6.5536 (which is 10000 in 16bits)
    mov #10000, w4
    mul.uu w0, w4, w2					;top part answer is in w3
                                                ;< 1000 ? print '0'
    mov #'0', w2
    mov #1000, w4
    cp w3, w4
    bra geu, wt0s_convert
    mov.b w2, [w1++]
                                                ;< 100 ? print '0'
    mov #'0', w2
    mov #100, w4
    cp w3, w4
    bra geu, wt0s_convert
    mov.b w2, [w1++]
                                                ;< 10 ? print '0'
    mov #10, w4
    cp w3, w4
    bra geu, wt0s_convert
    mov.b w2, [w1++]

wt0s_convert:
						;convert w0 as udec string
    mov w3, w0
    call word_to_udec_str
						;restore registers
    pop w4
    pop w3
    pop w2

    return

;*****************************************************************

.global word_to_udec_str
;w0 contains word to be converted to unsigned decimal string
;w1 contains start address of string

word_to_udec_str:
						;save registers
    push w5
    push w4
    push w3
    push w2
						;initialise registers
    mov w1, w2                                      ;w2 contains string address
    mov w0, w3                                      ;w3 contains number to be converted
    mov #10000, w4                                  ;w4 contains divider (start with 10000)
    mov #10, w5                                     ;w5 contains update div ratio for w4
						;do 5 times
    do #4,wtus_last
						;determine quotient and remainder
    repeat #17
    div.u w3, w4                                    ;result in w0 (quotient) and w1 (remainder)
						;write character to string
    add #'0', w0                                    ;add ascii code for '0'
    mov.b w0, [w2++]
						;update number to be divided
    mov w1, w3
						;calculate new divider ratio
    repeat #17
    div.u w4, w5				;result in w0 (quotient) and w1 (remainder, should be 0)
    mov w0, w4                                      ;w4 starts as 10000, then 1000, then 100, then 10 and finally 1
wtus_last:
    nop                                         ;last statement in do_loop
						;write '\0' to indicate string end
    clr.b [w2]
						;remove leading 0's
							;initialise
    mov #4, w0						;w0: remove only initial 4 leading 0's
    mov #'0', w4					;w4 = '0',  the character to be removed
    sub w2, #5, w3					;w3: recover start address to w3, w3 = w2-5

wtus_rlz_lp:
							;recover start address to w2
    mov w3, w2
    inc w2, w1
	
    cp.b w4,[w2]
    bra nz, wtus_rlz_end			;if not equal, finished with rlz

    repeat #4					;move 5 characters
    mov.b [w1++], [w2++]

wtus_rlz_next:
    dec w0, w0
    bra nz, wtus_rlz_lp
							;finished with rlz
wtus_rlz_end:	
						;restore registers
    pop w2
    pop w3
    pop w4
    pop w5

    return

;*****************************************************************

.global word_to_sdec_str
;w0 contains word to be converted to signed decimal string (2's complement)
;w1 contains start address of string

word_to_sdec_str:
						;check MSB to see if negative
    btss w0, #15
						;no ? write as if unsigned
    goto word_to_udec_str			;use goto as no clue where linker will put this other routine
						;yes ? write '-'
    push w0
    mov.b #'-', w0
    mov.b w0, [w1++]
    pop w0
						;make positive
    neg w0, w0
						;write as if unsigned
    goto word_to_udec_str			;use goto as no clue where linker will put this other routine

.end

