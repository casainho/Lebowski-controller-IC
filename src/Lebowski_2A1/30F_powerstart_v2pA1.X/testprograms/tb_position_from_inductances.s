.include "p30F4011.inc"
.include "defines.inc"

.text

;*****************************************************************

.global main
main:						
						
;---------------------------------------------- initialise
                                                    ;global initialise
    call initialise
                                                    ;wait for any key
;	call rx_char_232

;---------------------------------------------- measure

    call find_dualtone_amplitude

;    mov ampli_tone3, w0
;    mov w0, ampli_tone4
    clr ampli_tone4

;---------------------------------------------- initialise for inductor measurements

    clr ampli_real
    clr ampli_imag
    clr phi

;    mov #2000, w0
;    mov w0, ampli_real
    mov #0xE000, w0
    mov w0, phi

    clr phi_tone1
    clr phi_tone3
    clr phi_tone4

    mov #notch_024, w0
    repeat #190
    clr [w0++]
    clr ptr_024

    mov #notch_3, w0
    repeat #62
    clr [w0++]
    clr ptr_3
                                                    ;switch ADC's to current, start first conversion
    call ADC_current
    repeat #5
    nop
    bclr ADCON1, #1
                                                    ;turn on PWM
   	bset PTCON, #15
                                                    ;turn on tones 3 & 4
    bset flags1, #tone34

;---------------------------------------------- loop
pfi_lp:
                                                    ;wait for 40 kHz operation
    bclr LATD, #2
    btss IFS0, #3
    bra pfi_lp
    bclr IFS0, #3
    bset LATD, #2
;---------------------------------------------- read ADC's, start new conversion
    call ADC_read_current
    bclr ADCON1, #1
;---------------------------------------------- notch filter 0, 2*f0, 4*f0,   1.....-1 64 samples in total
/*
    mov #notch_024, w10
                                                    ;next position in array
    dec2 ptr_024, wreg
    btsc w0, #15
    mov #126, w0
    mov w0, ptr_024
    add w10, w0, w10
                                                    ;process phase A
    mov [w10], w0
    mov w4, [w10]
    sub w4, w0, w4
                                                    ;process phase B
    mov [w10+128], w0
    mov w5, [w10+128]
    sub w5, w0, w5
                                                    ;process phase C
    mov [w10+256], w0
    mov w6, [w10+256]
    sub w6, w0, w6

;---------------------------------------------- notch filter 3*f0, 1...1 21 samples in total
    mov #notch_3, w10
                                                    ;next position in array
    dec2 ptr_3, wreg
    btsc w0, #15
    mov #40, w0
    mov w0, ptr_3
    add w10, w0, w10
                                                    ;process phase A
    mov [w10], w0
    mov w4, [w10]
    add w4, w0, w4
                                                    ;process phase B
    mov [w10+42], w0
    mov w5, [w10+42]
    add w5, w0, w5
                                                    ;process phase C
    mov [w10+84], w0
    mov w6, [w10+84]
    add w6, w0, w6
*/
;---------------------------------------------- demodulate

;    sl w4, #2, w4
;    sl w5, #2, w5
;    sl w6, #2, w6

    mov phi_tone1, w0
    mov w0, phi_disect
    call disect_current

;---------------------------------------------- filter with 4th order filter

    mov i_real, w1
    mov #filter_A, w11
    call filter_4th_order

    mov i_imag, w1
    mov #filter_B, w11
    call filter_4th_order

    mov filter_A+12, w0
    mov w0, dummy1
    mov filter_B+12, w0
    mov w0, dummy2

;---------------------------------------------- update tone34, tone1
    mov phi_int_tone1, w0
    add phi_tone1
    mov phi_int_tone3, w0
    add phi_tone3
    mov phi_int_tone4, w0
    add phi_tone4

;---------------------------------------------- output to motor
    call write_motor_sinus
;---------------------------------------------- loop end, allow monitoring
    dec monitoring_count
    bra nz, pfi_cont
    mov monitoring_value, w0
    mov w0, monitoring_count
    call monitoring
                                                    ;loop
pfi_cont:
    dec counter
    bra nz, pfi_lp

    btg LATC, #15

	bra pfi_lp

;***********************************************************

.bss
monitoring_count: .space 2



.end

