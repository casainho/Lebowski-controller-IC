.include "p30F4011.inc"
.include "defines.inc"
.include "fp_macros.mac"

.macro ICD_return_main

    mov #6, w0
    add PCL, wreg
    mov w0, imp_collect_address
    return

.endm

;.macro led_on
;	bset LATD, #2
;.endm
;.macro led_off
;	bclr LATD, #2
;.endm
	
.text

;*****************************************************************	

.global reset_collect_imp_data
reset_collect_imp_data:
	
	mov #tbloffset(imp_collect_data), w0
    mov w0, imp_collect_address
	
	bclr flags1, #valid_data_imp_meas
											;clear data variances
	mov #data_variance_R, w13
	repeat #7
	clr [w13++]
	mov #data_variance_L, w13
	repeat #7
	clr [w13++]

	return
	
;*****************************************************************	
.global store_imp_data
store_imp_data:
											;store collected data
	mov #data_collected, w12
	mov #data_collected_rom, w13
	repeat #20
	mov [w12++], [w13++]
											;store impedance data
	mov #real_impedance, w12
	mov #real_impedance_rom, w13
	reg_copy
	
	mov #imag_impedance, w12
	mov #imag_impedance_rom, w13
	reg_copy
	
	mov #Kv, w12
	mov #Kv_rom, w13
	reg_copy
											;store data collection counter
	mov data_collect_countdown_R, w0
	mov w0, data_collect_countdown_R_rom
	mov data_collect_countdown_L, w0
	mov w0, data_collect_countdown_L_rom
	
	return
	
;*****************************************************************	
.global restore_imp_data
restore_imp_data:
											;restore collected data
	mov #data_collected_rom, w12
	mov #data_collected, w13
	repeat #20
	mov [w12++], [w13++]
											;restore impedance data
	mov #real_impedance_rom, w12
	mov #real_impedance, w13
	reg_copy
	
	mov #imag_impedance_rom, w12
	mov #imag_impedance, w13
	reg_copy
	
	mov #Kv_rom, w12
	mov #Kv, w13
	reg_copy
											;restore impedance derived data
	call calc_impedance_based_coeffs																			
											;restore data collection counter
	mov data_collect_countdown_R_rom, w0
	mov w0, data_collect_countdown_R
	mov data_collect_countdown_L_rom, w0
	mov w0, data_collect_countdown_L
											
	return
	
;*****************************************************************	
	
.global imp_collect_data
imp_collect_data:
;--------------------------------------- wait for next iteration

	ICD_return_main	
	
	btss flags1, #valid_data_imp_meas
	bra imp_collect_data
	
;--------------------------------------- capture data and convert to fp
												;1/inv_vbat to reg1
	lsr filter_inv_vbat, wreg
	mov w0, reg1+2
	mov #1, w0
	mov w0, reg1
	
	mov #reg1, w13
	call fp_oneover 
											;V_real to Va, * 1/invvbat
	signed_to_fp Va_raw Va
	mov #Va, w13
	mov #reg1, w12
	call fp_mult
											;I_real to Ia
	signed_to_fp filter_I Ia
											;I_imag to Ib
	signed_to_fp filter_Q Ib
											;phi_int to w
	mov phi_int, w3
	mov phi_int+2, w2
	mov phi_step, w0
	add w3, w0, w3
	signed32_w3w2_to_fp w
											
	mov filter_I, w0
	mov w0, Ia_sampled
	mov filter_Q, w0						
	mov w0, Ib_sampled
	mov phi_int, w0
	mov w0, phi_int_sampled
	
	ICD_return_main		
	
;--------------------------------------- check if data valid
											;phi_int must be higher than specified
	mov phi_int_sampled, w0
	btsc w0, #15
	neg w0, w0
	cp data_speed_limit
	bra gt, imp_collect_data
											;no need to do L when still busy with initial R
	cp0 data_collect_countdown_R
	bra nz, try_R
											;if I_imag higher than specified: do L
	mov Ib_sampled, w0
	btsc w0, #15
	neg w0, w0
	cp data_current_limit_L
	bra gt, try_R
	
	goto process_for_L
	
.global try_R
try_R:
											;I_real must be higher than specified
	mov Ia_sampled, w0
	btsc w0, #15
	neg w0, w0
	cp data_current_limit_R
	bra gt, imp_collect_data

	goto process_for_R

;*****************************************************************	
.global filter_collected
filter_collected:
;input in [w12]
;filter integrator in [w13]
;--------------------------------------- determine difference
											;difference to reg_filt
	mov #reg_filt, w11
	mov [w13++], [w11++]
	neg [w13--], [w11--]
	btsc SR, #OV
	com reg_filt+2
	exch w11, w13
	call fp_add
	exch w11, w13
;--------------------------------------- mult with filter coefficient (exponent only)   
	mov data_filt_exponent, w10
											;override with 10 (1024) for initial data collection
	cp0 data_collect_countdown_L
	btss SR, #Z
	mov #10, w10
	
	subr w10, [w11], [w11]
;--------------------------------------- add to integrator			
											;which exponent is bigger ?
	mov [w13], w10
    sub w10, [w11], w0
    bra ge, 1f
											;w11_e > w13_e
											;build the two 32 bit words
	mov [w11], w10
	sub w10, [w13], w0
	
	mov [w13+2], w1
	mov [w13+4], w2
	
	asr w1, w0, w3
	lsr w2, w0, w2
	subr w0, #16, w0
	sl w1, w0, w1
	ior w2, w1, w2

	add w3, [++w11], w3
	bra fc_cont
1:	
											;w13_e >= w11_e
											;build the two 32 bit words
	mov [w11+2], w2
											;w13_e >= w11_e, if larger by more than 31, skip alltogether, 
	cp w0, #31
	bra ge, fc_end
	cp w0, #16
	bra lt, fc_small_shift
fc_big_shift:								;shift of 16 bits or more
	asr w2, #15, w3
	sub w0, #16, w0
	asr w2, w0, w2
	bra fc_add
	
fc_small_shift:							;shift of less than 16 bits
	asr w2, w0, w3
	subr w0, #16, w0
	sl w2, w0, w2
	
fc_add:
	mov [w13+2], w1
	mov [w13+4], w0
											;add
	add w0, w2, w2
	addc w1, w3, w3
fc_cont:
											;deal with possible overflow
	bra nov, 1f
	rrc w3, w3
	rrc w2, w2
	inc w10, w10
1:	
											;calculate exponent, shift mantissa
	fbcl w3, w0
    neg w0, w0
	sub w10, w0, w10
	
	sl w3, w0, w3
	sl w2, w0, w1
	subr w0, #16, w0
	lsr w2, w0, w2
	ior w3, w2, w3
											;store
	mov w1, [w13+4]
	mov w3, [w13+2]
	mov w10, [w13]
;--------------------------------------- end
fc_end:
	return
;*****************************************************************
	
.bss
	
	
.global w
w:		.space 4
.global Va
Va:		.space 4
.global Ia
Ia:		.space 4
.global Ib
Ib:		.space 4

Ia_sampled:		.space 2
Ib_sampled:		.space 2
phi_int_sampled:	.space 2

			
.global reg1
reg1:	.space 4
.global reg2
reg2:	.space 4
	
reg_filt:	.space 4
	


.end

	