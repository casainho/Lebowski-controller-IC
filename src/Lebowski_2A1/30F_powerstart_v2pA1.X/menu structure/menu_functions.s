.include "p30F4011.inc"
.include "defines.inc"

.text

;******************************************************************

.global smap_any_key_to_continue
smap_any_key_to_continue:
    push w0
    push w1

    mov #tblpage(smap_message), w0
    mov #tbloffset(smap_message), w1
    call tx_str_232

    call rx_char_232

    pop w1
    pop w0

    return

smap_message:
    .pascii "\nSpin the motor then press any key to start measurement\n\0"

;******************************************************************

.global get_number
;on call: w0: number of digits allowed
;on return: w0: typed number
get_number:

    push w1
    push w2

    inc w0, w2
                                            ;show input line
    mov #tblpage(gn_message), w0
    mov #tbloffset(gn_message), w1
    call tx_str_232
                                            ;get typed characters
    mov w2, w0
    mov #str_buf, w1
    call rx_str_232
                                            ;convert to number
    clr w0
    clr w1
    mov #str_buf, w2
gn_loop:
    mov.b [w2], w1
    cp0 w1                                  ;end if '\0'
    bra z, gn_end
                                            ;multiply last value with 10
    mul.uu w0, #10, w0                          ;this destroys w1 !
    mov.b [w2++], w1
    sub.b #'0', w1                          ;add current digit
    add w0, w1, w0
    bra gn_loop

gn_end:
    pop w2
    pop w1

    return

gn_message:
    .pascii "new value -> \0"

;******************************************************************

.global get_choise
;on return: w0:first character
get_choise:
    push w1
                                            ;show input line
    mov #tblpage(gc_message), w0
    mov #tbloffset(gc_message), w1
    call tx_str_232
                                            ;get typed characters
    mov #10, w0
    mov #str_buf, w1
    call rx_str_232
                                            ;get character
    mov #str_buf, w1
    mov.b [w1], w0
    ze w0, w0

    pop w1

    return

gc_message:
    .pascii "------> \0"

;******************************************************************

.global get_signed_decimal_number

;on call: w0: number of characters allowed (including '-' and '.' and '\0')
;on return:
;w0: integer part, 2's complement,
;w1: decimal part.

get_signed_decimal_number:
;-------------------------------------- store variables		

    push w8
    push w9
    push w10
    push w11
    push w12
    push w13
		
;-------------------------------------- display line and get characters

    inc w0, w13
                                            ;show input line
    mov #tblpage(gn_message), w0
    mov #tbloffset(gn_message), w1
    call tx_str_232
                                            ;get typed characters
    mov w13, w0
    mov #str_buf, w1
    call rx_str_232

;-------------------------------------- skip over sign, if applicable

    mov #str_buf, w13                       ;w13: string pointer
    mov #'-', w0
    mov.b [w13], w1
    cpsne.b w0, w1
    inc w13, w13                            ;w13 += 1 if first character is negative sign

;-------------------------------------- get integer part

    clr w10                                 ;w10: integer part
gsdn_integer_lp:
                                            ;jump out of integer loop if character is '\0' or '.'
    cp0.b [w13]
    bra z, gsdn_integer_done
    mov #'.', w0
    cp.b w0, [w13]
    bra z, gsdn_integer_done
                                            ;multiply current w10 by 10 (destroys w11)
    mul.uu w10, #10, w10
                                            ;add character
    mov #'0', w0
    sub w10, w0, w10
    mov.b [w13++], w0
    add w10, w0, w10
                                            ;next character
    bra gsdn_integer_lp

;-------------------------------------- get decimal part
gsdn_integer_done:	
    mov w10, w12                            ;keep integer part in w12

    clr w10                                 ;w10: decimal part
    mov #1, w8                                  ;final divider
                                            ;skip decimal part if character was a '\0'
    cp0.b [w13]
    bra z, gsdn_decimal_allread
                                            ;else increment (to skip over '.')
    inc w13, w13
gsdn_decimal_lp:
                                            ;jump out of decimal loop if character is '\0'
    cp0.b [w13]
    bra z, gsdn_decimal_allread
                                            ;multiply current w10 and w8 both by 10 (destroys w9 and w11)
    mul.uu w10, #10, w10
    mul.uu w8, #10, w8
                                            ;add character
    mov #'0', w0
    sub w10, w0, w10
    mov.b [w13++], w0                            
    add w10, w0, w10
                                            ;next character, max 4 characters
    cp0.b [w13]
    bra z, gsdn_decimal_allread
    mul.uu w10, #10, w10
    mul.uu w8, #10, w8
    mov #'0', w0
    sub w10, w0, w10
    mov.b [w13++], w0
    add w10, w0, w10

    cp0.b [w13]
    bra z, gsdn_decimal_allread
    mul.uu w10, #10, w10
    mul.uu w8, #10, w8
    mov #'0', w0
    sub w10, w0, w10
    mov.b [w13++], w0
    add w10, w0, w10

    cp0.b [w13]
    bra z, gsdn_decimal_allread
    mul.uu w10, #10, w10
    mul.uu w8, #10, w8
    mov #'0', w0
    sub w10, w0, w10
    mov.b [w13++], w0
    add w10, w0, w10


gsdn_decimal_allread:	
                                            ;divide w10 by w8 to arrive at decimal part
    mov w10, w11
    clr w10
    repeat #17
    div.ud w10, w8
						
    mov w0, w11                             ;keep decimal part in w11

;-------------------------------------- make negative if first character is sign

    mov #str_buf, w13                       ;w13: string pointer
    mov #'-', w0
    mov.b [w13], w1
    cp.b w0, w1
    bra z, gsdn_make_negative

    mov w12, w0
    mov w11, w1
    bra gsdn_end

gsdn_make_negative:
    com w12, w0
    neg w11, w1
    addc w0, #0, w0

;-------------------------------------- restore variables and end
gsdn_end:
    pop w13
    pop w12
    pop w11
    pop w10
    pop w9
    pop w8

    return

.end

