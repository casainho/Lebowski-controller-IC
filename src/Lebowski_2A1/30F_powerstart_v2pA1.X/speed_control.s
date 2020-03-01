.include "p30F4011.inc"
.include "defines.inc"

.text
.global speed_control
speed_control:

;-------------------------------------- make sure current not too high or too low
											;w1: upper limit: wir (forward) or imp/8 (reverse)
											;w0: lower limit: -imp/8 (forward) or -wir (reverse)
	mov wanted_i_real, w1
											;do not support throttle indicated regen
	btsc w1, #15
	clr w1
	
	mov i_max_phase, w0
	lsr w0, #3, w0
	btsc flags1, #reverse
	exch w0, w1
	neg w0, w0
	
	cp w8, w1
	bra ge, sc_subtract
	
	cp w8, w0
	bra le, sc_add

;-------------------------------------- else compare phase increase with wanted_phi_int

	mov filt_spd_ctrl, w0
											;compare with wanted_phi_int
	cp wanted_phi_int
	bra le, sc_subtract
	
;-------------------------------------- increase amplitude
sc_add:
    mov #ampli_real+2, w10
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
    bra ov, sc_overflow
                                            ;and we should be below ampli_upper_limit
    mov ampli_upper_limit, w1
    cp w0, w1
    bra ge, sc_toohigh_toolow
                                            ;and we should be above -ampli_upper_limit
    neg w1, w1					   
    cp w0, w1
    bra le, sc_toohigh_toolow				

    mov w0, ampli_real

    return

;-------------------------------------- decrease amplitude
sc_subtract:
    mov #ampli_real+2, w10
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
    bra ov, sc_overflow
                                            ;and we should be below ampli_max
    mov ampli_upper_limit, w1
    cp w0, w1
    bra ge, sc_toohigh_toolow
                                            ;and we should be above -ampli_max
    neg w1, w1					   
    cp w0, w1
    bra le, sc_toohigh_toolow				
			
    mov w0, ampli_real

    return
	
;-------------------------------------- process overflow
sc_overflow:
											;since ampli_real was not updated so far we can use it's sign bit
    mov ampli_upper_limit, w1
    btsc ampli_real, #15
    neg w1, w1

;-------------------------------------- process too high or too low
sc_toohigh_toolow:
                         
    mov w1, ampli_real
    clr ampli_real+2
    clr ampli_prop

    return	
	

.end
