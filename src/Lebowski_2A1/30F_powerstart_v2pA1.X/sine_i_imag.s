.include "p30F4011.inc"
.include "defines.inc"

.text

;*****************************************************************

.global initialise_sine_walk
initialise_sine_walk:
	
;--------------------------------------- initialise
											;initialise pseudo value
	clr ampl_sine_iimag
	clr phi_sine_iimag
											;set to 10 Hz (phiint = Hz*mlc/458)
	mov #10, w0
	mul main_loop_count
	mov #458, w4
	repeat #17
	div.ud w2, w4
	mov w0, phiint_sine_iimag
	
;--------------------------------------- end
    return

	
;*****************************************************************
	
.global update_sine_i_imag
update_sine_i_imag:
;--------------------------------------- update sine amplitude
											;are we allowed to run ? increase or decrease amplitude
	mov #33, w0
	btss flags1, #allow_sine_iimag
	
.global reduce_sine_i_imag
reduce_sine_i_imag:
	
	mov #-33, w0
	mov #ampl_sine_iimag, w13
	
	add w0, [w13], w1
	btsc SR, #OV
	mov #0x7FF0, w1
	btsc w1, #15
	clr w1
	mov w1, [w13]
/*
											;filter, 1 tau = 1000 steps
	sub w0, [w13], w0
	mov #65, w1
	mul.us w1, w0, w0
	
	add w0, [++w13], [w13--]
	addc w1, [w13], [w13]

;--------------------------------------- update sine phase
*/	
	mov phiint_sine_iimag, w0
	add phi_sine_iimag

;--------------------------------------- generate output	

	mov phi_sine_iimag, w0
    lsr w0, #7, w12
    bclr w12, #0
    bset w12, #11
	mov [w12], w0
	
	mul.ss w0, [w13], w0			
											;times 2 compensates for ampl_sine_iimag being Q15
	sl w1, w1
											;times 3 (rnd_walk_val is Q15) to get walk with 1.5 rimes data_current_limit_L amplitude)
	mov data_current_limit_L, w0
	add data_current_limit_L, wreg
	add data_current_limit_L, wreg

	mul.us w0, w1, w0
	mov w1, sine_i_imag
;--------------------------------------- end
											;for next time
	bset flags1, #allow_sine_iimag
	btss flags_rom, #use_sine_iimag
	bclr flags1, #allow_sine_iimag
	
	return
	
	
.end
