.include "p30F4011.inc"
.include "defines.inc"

.text

;*****************************************************************

.global initialise_rnd_walk
initialise_rnd_walk:
	
;--------------------------------------- initialise
											;initialise pseudo value
	mov #1, w0
	mov w0, pseudo_rnd
	mov w0, rnd_walk_count
	
	clr rnd_i_imag
	clr rnd_walk_val
	clr rnd_walk_update
	
;--------------------------------------- end
    return

;*****************************************************************
	
.global reduce_rnd_i_imag
reduce_rnd_i_imag:
;--------------------------------------- reduce
											;reduce rnd_walk_out, 1 tau = 1000 steps
	mov rnd_walk_val, w0
	mov #65470, w1
	mul.us w1, w0, w0
	mov w1, rnd_walk_val
;--------------------------------------- convert to current and end
	bra rnd_to_i_imag
	
;*****************************************************************
	
.global update_rnd_i_imag
update_rnd_i_imag:
	
;--------------------------------------- are we allowed to run ?
	btss flags1, #allow_rnd_i_imag
	bra reduce_rnd_i_imag
;--------------------------------------- finished with count ? determine new values
/*
	dec rnd_walk_count
	bra nz, rii_continue
											;new pseudo rnd value
	mov pseudo_rnd, w0
	sl w0, #13, w1
	xor w0, w1, w0
	lsr w0, #9, w1
	xor w0, w1, w0
	sl w0, #7, w1
	xor w0, w1, w0
	mov w0, pseudo_rnd
											;calculate update, reach in approx 512 steps				
	mov pseudo_rnd, w0
	asr w0, #11, w0
	mov rnd_walk_val, w1
	asr w1, #11, w1
	sub w0, w1, w0
	mov w0, rnd_walk_update
											;reset counter
	mov #2048, w0
	mov w0, rnd_walk_count
											;end
	bra rii_end
*/
;--------------------------------------- new rnd_walk_value
rii_continue:
	mov #22, w0
	add phi_rw
	mov phi_rw, w0
    lsr w0, #7, w13
    bclr w13, #0
    bset w13, #11
	mov [w13], w0
	mov w0, rnd_walk_val
	
/*											
											;new rnd_walk_value
	mov rnd_walk_update, w0
	mov rnd_walk_val, w1
	add w1, w0, w1
	btsc SR, #OV
	sub w1, w0, w1

	mov rnd_walk_val, w1										
											;remove any remaining DC !! (1 tau = 10000 steps)
	mov #65529, w0
	mul.us w0, w1, w0
	
	mov w1, rnd_walk_val
*/	
rnd_to_i_imag:
											;convert to current
	mov rnd_walk_val, w1
	mov data_current_limit_L, w0
											;times 3 (rnd_walk_val is Q15) to get walk with 1.5 rimes data_current_limit_L amplitude)
	add data_current_limit_L, wreg
	add data_current_limit_L, wreg

	mul.us w0, w1, w0
	mov w1, rnd_i_imag
;--------------------------------------- end
rii_end:
											;for next time
	bset flags1, #allow_rnd_i_imag
	btss flags_rom, #use_rnd_i_imag
	bclr flags1, #allow_rnd_i_imag
	
	return
.bss
	
phi_rw:.space 2	
	
.end
