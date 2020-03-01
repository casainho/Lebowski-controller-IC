.include "p30F4011.inc"
.include "defines.inc"

.text
.global backemf_phase_control
;w12: address of plic array
;
;corrupted registers:
;w1, w2, w9, w10, w11, w12
backemf_phase_control:
;--------------------------------------- update phi and loopfilter
    			                         ;w12 is at positive array position
    btsc flags2, #direction_phase_loop
    add w12, #10, w12                           ;shift to negative if bit set (note the inversion !!!!!!)

    mov #phi_motor+2, w10
    mov #phi_int+2, w11

    mov [w12++], w1                             ;w1.w2 to be added to phi_int
    mov [w12++], w2
                                                ;update phi_int with coefficients
    add w2, [w11], [w11--]
    addc w1, [w11], [w11++]

    mov [w12++], w1                             ;w1.w2 to be added to phi_motor (this is the 1st integrator bypass path)
    mov [w12++], w2
	
	mov w1, phi_step
                                                ;add phi_int to the coefficients of phi
    add w2, [w11--], w2
    addc w1, [w11], w1
                                                ;and add to phi_motor
    add w2, [w10], [w10--]
	addc #0, w1
	add w1, [w10], [w10]
                                                ;and don't forget the phi_prop
	mov phi_prop, w2
	mov w2, phi_prop+2
    mov [w12], w2
    mov w2, phi_prop

;--------------------------------------- filter for speed control
											;w1 is phi update
	mov #filt_spd_ctrl+2, w10
											;x = x + a * (i - x)
	sub w1, [w10], w1										
	mov #15000, w0
	mul.us w0, w1, w2
	
	add w2, [++w10], [w10--]
	addc w3, [w10], [w10]
											;output = x + sgn(phi_prop) * feedforward_coefficient
	mov filt_spd_ctrl_ffcoef, w0
	btsc phi_prop, #15
	neg w0, w0
	add w0, [w10], [--w10]
	
;--------------------------------------- end

    return

;*****************************************************************


.end
