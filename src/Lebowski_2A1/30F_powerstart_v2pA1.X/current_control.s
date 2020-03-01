.include "p30F4011.inc"
.include "defines.inc"

.text
.global current_control
current_control:
;-------------------------------------- clear clipping
	bclr flags1, #clipping
;-------------------------------------- initialise
    mov #ampli_real+2, w10	
;-------------------------------------- normal amplitude control
											;based on direction flag
	btss flags2, #direction_ampli_loop
	bra cc_add
;-------------------------------------- substract

cc_subtract:            
                                            ;place w12 at array of negative coeffs
    mov #alic_3+6, w12

    mov [w12++], w1                         ;w1.w2 to be added to ampli_real (this is the 1st integrator bypass path)
    mov [w12++], w2
                                            ;add to ampli_real
    add w2, [w10], [w10--]
    addc w1, [w10], w0
                                            ;and don't forget the ampli_prop
    mov [w12], w1
    mov w1, ampli_prop
                                            ;at this point there should be no overflow
    bra ov, cc_overflow

    mov w0, ampli_real

    return

;-------------------------------------- add
cc_add:
                                            ;place w12 at array of positive coeffs
    mov #alic_3+0, w12

    mov [w12++], w1                         ;w1.w2 to be added to ampli_real (this is the 1st integrator bypass path)
    mov [w12++], w2
                                            ;add to ampli_real
    add w2, [w10], [w10--]
    addc w1, [w10], w0
                                            ;and don't forget the ampli_prop
    mov [w12], w1
    mov w1, ampli_prop
                                            ;at this point there should be no overflow
    bra ov, cc_overflow

    mov w0, ampli_real

    return

;-------------------------------------- process overflow
cc_overflow:
											;since ampli_real was not updated so far we can use it's sign bit
    mov #0x7FF0, w1
	btsc ampli_real, #15
    neg w1, w1

;-------------------------------------- process too high or too low
cc_toohigh_toolow:
	
    mov w1, ampli_real
    clr ampli_real+2
    clr ampli_prop

;-------------------------------------- set clipping, may be cleared in fieldweakening routine
	
	bset flags1, #clipping
	
;-------------------------------------- end
	
    return
	

;**********************************************************************************************
	
.global fieldweakening
fieldweakening:
;-------------------------------------- disable impedance data gathering while in fieldweakening
	cp0 fieldweak
	bra z, 1f
	
	bclr flags1, #valid_data_imp_meas
											;also disable sine_i_imag while in fieldweakening
	bclr flags1, #allow_sine_iimag
1:
;-------------------------------------- only continuing if fieldweakening in use	
	clr wanted_i_imag
	cp0 max_fieldweak_ratio
	btsc SR, #Z
	return
;-------------------------------------- can we do fieldweakening ? if not reduce								
											;field weakening not allowed when drive_2 LED on
	btss LATC, #14
	bra cc_fw_allowed
											;must reduce fieldweak, jump based on sign, do not clear clipping bit	
	bra fw_reduce
	
cc_fw_allowed:
;-------------------------------------- check the impedance angle limit
ccfw_check_angle:
											;Z_imag*ampli_real - Z_real*wanted_ampli_imag > 0 ? yes then continue, no force reduction
											;Z_imag = abs(phi_int)
											;ampli_real = ampli_fw
											;Z_real = Z_ratio
											;wanted_ampli_imag is always positive
	mov phi_int, w0
	btsc w0, #15
	neg w0, w0
	mul ampli_fw							;w3:w2 = Z_imag*ampli_real
	
	mov Z_ratio, w0
	mov ampli_imag, w1
	mul.uu w0, w1, w0						;w1:w0 = Z_real*wanted_ampli_imag

	sub w2, w0, w2
	subb w3, w1, w3							;this 32 bit subtract acts as a cp so results in valid status bit for all bra flavours
											;decide to continue as normal or to force wanted_i_imag reduction 
	bra geu, ccfw_cont
											;must reduce fieldweak, jump based on sign, do not clear clipping bit
	bra fw_reduce
	
;-------------------------------------- not angle limited, therefore decide to add or substract
ccfw_cont:
											;check if clipping bit can be cleared
	mov fieldweak, w0
											;do not clear when at positive max
	cp max_fieldweak_ratio
	bra z, 1f
											;do not clear when at negative max
	neg w0, w0
	cp max_fieldweak_ratio
	bra z, 1f

	bclr flags1, #clipping
1:
											;base direction on ampli_real w.r.t. ampli_fw
	mov ampli_real, w0
	mov ampli_fw, w1
                                            ;increase fieldweak when ampli_real > ampli_fw
	cp w0, w1
	bra ge, ccfw_add
                                            ;more negative fieldweak when ampli_real < -ampli_fw
	neg w1, w1
	cp w0, w1
	bra le, ccfw_subtract
                                            ;if neither, reduce fieldweak based on sign
	bra fw_reduce				

;-------------------------------------- substract

ccfw_subtract:            
	clr w1
	
	mov fieldweak, w0
	subr fwlic, wreg
	btsc SR, #OV
	mov fieldweak, w0
	                                        ;sign new fieldweak should be same as that of ampli_real
	mov ampli_real, w2
	xor w2, w0, w2
	btsc w2, #15
	bra ccfw_toohigh_toolow					;else use the w1=0 to clear fieldweak and end fieldweakening
                                            ;we should be above -max_fieldweak_ratio
    mov max_fieldweak_ratio, w1
    neg w1, w1					   
    cp w0, w1
    bra le, ccfw_toohigh_toolow				
											;if not, write new value
	mov w0, fieldweak
	bra ccfw_calc_wii

;-------------------------------------- add
ccfw_add:
	clr w1
	
	mov fieldweak, w0
	add fwlic, wreg
	btsc SR, #OV
	mov fieldweak, w0
	                                        ;sign new fieldweak should be same as that of ampli_real
	mov ampli_real, w2
	xor w2, w0, w2
	btsc w2, #15
	bra ccfw_toohigh_toolow					;else use the w1=0 to clear fieldweak and end fieldweakening.
                                            ;and we should be below max_fieldweak_ratio
    mov max_fieldweak_ratio, w1
    cp w0, w1
    bra ge, ccfw_toohigh_toolow
											;if not, write new value
	mov w0, fieldweak
	bra ccfw_calc_wii
	
ccfw_toohigh_toolow:
	
	mov w1, fieldweak
;-------------------------------------- calc wanted_i_imag, based on abs(fieldweak)
ccfw_calc_wii:
	mov fieldweak, w0
											;make absolute
	btsc w0, #15
	neg w0, w0
											;mult with i_max_phase, compensate for fieldweak being Q15
	mul i_max_phase
	sl w3, w3
;-------------------------------------- end
fw_end:
	mov w3, wanted_i_imag
	
	return
	
;-------------------------------------- reduce fieldweakening
fw_reduce:
	
	mov fwlic, w0
											;larger than fwlic, subtract
	cp fieldweak
	bra gt, ccfw_subtract
											;smaller than -fwlic, add
	neg w0, w0
	cp fieldweak
	bra lt, ccfw_add
											;else make 0, end
	clr fieldweak
	clr wanted_i_imag
	
	return
	
	
;**********************************************************************************************

.global current_control_1
;for use in dr1_recovery
;
;corrupted variables:
;w0, w1, w10, w11, w12
current_control_1:

    mov #ampli_real+2, w10
											;based on direction flag
	btss flags2, #direction_ampli_loop
	bra cc1_add
;-------------------------------------- substract
cc1_subtract:
                                            ;place w12 at array of negative coeffs
    mov #alic_1+6, w12

    mov [w12++], w1                         ;w1.w2 to be added to ampli_real (this is the 1st integrator bypass path)
    mov [w12++], w2
                                            ;add to ampli_real
    add w2, [w10], [w10--]
    addc w1, [w10], w0
                                            ;and don't forget the ampli_prop
    mov [w12], w1
    mov w1, ampli_prop

                                            ;at this point there should be no overflow
    bra ov, cc1_overflow

    mov w0, ampli_real

    return

;-------------------------------------- add
cc1_add:
                                            ;place w12 at array of negative coeffs
    mov #alic_1+0, w12

    mov [w12++], w1                         ;w1.w2 to be added to ampli_real (this is the 1st integrator bypass path)
    mov [w12++], w2
                                            ;add to ampli_real
    add w2, [w10], [w10--]
    addc w1, [w10], w0
                                            ;and don't forget the ampli_prop
    mov [w12], w1
    mov w1, ampli_prop
                                            ;at this point there should be no overflow
    bra ov, cc1_overflow

    mov w0, ampli_real

    return

;-------------------------------------- process overflow
cc1_overflow:
                                            ;since ampli_real was not updated so far we can use it's sign bit
;    mov ampli_max, w1
    mov #0x7FF0, w1
	btsc ampli_real, #15
    neg w1, w1

;-------------------------------------- process too high or too low
cc1_toohigh_toolow:

    mov w1, ampli_real
    clr ampli_real+2
    clr ampli_prop
	
;-------------------------------------- end

    return

;**********************************************************************************************
	
	
.end
