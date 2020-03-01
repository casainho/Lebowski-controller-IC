.include "p30F4011.inc"
.include "defines.inc"
.include "macros.mac"

.text
.global halls_open
halls_open:
;---------------------------------------------- initialise pins to digital input
                                                    ;hall 1, MSB
    bset TRISF, #2
                                                    ;hall 2
    bset TRISF, #3
                                                    ;hall 3, LSB
    bset TRISD, #0

    return

;*******************************************

.global update_hall_positions
update_hall_positions:
;---------------------------------------------- convert motor phase to X (=0.5*cos phi_motor) and Y (=0.5*sin phi_motor)
                                                    ;position in sine array
    mov phi_motor, w0
    lsr w0, #7, w13
    bclr w13, #0
    bset w13, #11
                                                    ;0.5*[w13] to Y (the 0.5 prevents overshoot - out of range issues in the 2nd order filter
    asr [w13], w9
                                                    ;move to cosine
    add #128, w13
    bclr w13, #9
                                                    ;0.5*[w13] to X
    asr [w13], w8

;---------------------------------------------- sample hall states and calculate filter_hallXY array offset
                                                    ;determine hall code (times 4)
	clr w10
	btsc PORTF, #2
	bset w10, #4
	btsc PORTF, #3
	bset w10, #3
	btsc PORTD, #0
	bset w10, #2
		
;---------------------------------------------- process filter X

	mov #filter_hallX, w13
	add w13, w10, w13
	mov filter_general_coeff, w11
	filter w8
	
;---------------------------------------------- process filter Y

	mov #filter_hallY, w13
	add w13, w10, w13
	filter w9
	
;---------------------------------------------- end

    return

;*******************************************

.global build_hall_array
build_hall_array:

;---------------------------------------------- initialise
	mov #filter_hallX, w8
	mov #filter_hallY, w9
	mov #hall_array, w10
	mov #8, w11
;---------------------------------------------- loop 8 times
bha_loop:
;---------------------------------------------- get X,Y value
	push w8
	push w9
	mov [w8], w8
	mov [w9], w9
;---------------------------------------------- convert to angle, amplitude
	push w10
	
	call angle_amplitude_accurate
	
	pop w10
;---------------------------------------------- build hall word
                                                    ;keep top 8 bits phase info
	mov #0xFF00, w0
	and w9, w0, w9
                                                    ;shift ampli bits down by 8 and or into w9
	lsr w8, #8, w8
	ior w9, w8, w9
                                                    ;set use bit if ampli larger than 33% (keep also 0.5 XY scaling factor in mind)
	bclr w9, #0
	mov #21, w0
	cpslt w8, w0
	bset w9, #0

;---------------------------------------------- store and repeat
	
	mov w9, [w10++]
                                                    ;recover array positions and increase
	pop w9
	add #4, w9
	pop w8
	add #4, w8
	
	dec w11, w11
	bra nz, bha_loop
	
;---------------------------------------------- end

    return

;*******************************************


.end
