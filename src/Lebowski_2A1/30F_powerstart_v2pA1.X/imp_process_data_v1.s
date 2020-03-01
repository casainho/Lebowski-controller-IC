.include "p30F4011.inc"
.include "defines.inc"
.include "fp_macros.mac"
.include "print_macros.mac"

.macro IPD_return_main

    mov #6, w0
    add PCL, wreg
    mov w0, imp_process_address
    return

.endm
	
.macro reg_copy
	mov [w12++], [w13++]
	mov [w12--], [w13--]
.endm
	
.macro led_on
	bset LATD, #2
.endm
.macro led_off
	bclr LATD, #2
.endm
	
.text

;*****************************************************************	

.global reset_process_imp_data
reset_process_imp_data:
	
	mov #tbloffset(imp_process_data), w0
    mov w0, imp_process_address
	
	return
	
;*****************************************************************	
	
.global imp_process_data
imp_process_data:
;--------------------------------------- check if data valid
		
;	IPD_return_main	
;	
;	btss flags1, #new_matrix_data
;	bra imp_process_data
;		
;	bclr flags1, #new_matrix_data
	
;--------------------------------------- build matrix
	mov #matrix, w13
											;1st row
	mov #data_for_matrix+2*iatiapibtib, w12
	mov [w12++], [w13++]
	mov [w12++], [w13++]	
	mov #0xC000, w0
	mov w0, [w13++]
	clr [w13++]	
	mov #data_for_matrix+2*wtia, w12
	mov [w12++], [w13++]
	mov [w12++], [w13++]	
	mov #data_for_matrix+2*wtiatib, w12
	mov [w12++], [w13++]
	mov [w12++], [w13++]	
	mov #data_for_matrix+2*iatvapibtvb, w12
	mov [w12++], [w13++]
	mov [w12++], [w13++]
											;2nd row
	mov #0xC000, w0
	mov w0, [w13++]
	clr [w13++]								
	mov #data_for_matrix+2*wtwtiatiapibtib, w12
	mov [w12++], [w13++]
	mov [w12++], [w13++]
	mov #data_for_matrix+2*mwtwtib, w12
	mov [w12++], [w13++]
	mov [w12++], [w13++]
	mov #data_for_matrix+2*wtiatwtia, w12
	mov [w12++], [w13++]
	mov [w12++], [w13++]
	mov #data_for_matrix+2*wtiatvbmwtibtva, w12
	mov [w12++], [w13++]
	mov [w12++], [w13++]
											;3rd row
	mov #data_for_matrix+2*wtia, w12
	mov [w12++], [w13++]
	mov [w12++], [w13++]
	mov #data_for_matrix+2*mwtwtib, w12
	mov [w12++], [w13++]
	mov [w12++], [w13++]
	mov #data_for_matrix+2*wtw, w12
	mov [w12++], [w13++]
	mov [w12++], [w13++]
	mov #0xC000, w0
	mov w0, [w13++]
	clr [w13++]								
	mov #data_for_matrix+2*wtva, w12
	mov [w12++], [w13++]
	mov [w12++], [w13++]
											;4th row
	mov #data_for_matrix+2*wtiatib, w12
	mov [w12++], [w13++]
	mov [w12++], [w13++]
	mov #data_for_matrix+2*wtiatwtia, w12
	mov [w12++], [w13++]
	mov [w12++], [w13++]
	mov #0xC000, w0
	mov w0, [w13++]
	clr [w13++]								
	mov #data_for_matrix+2*wtiatwtia, w12
	mov [w12++], [w13++]
	mov [w12++], [w13++]
	mov #data_for_matrix+2*wtiatvb, w12
	mov [w12++], [w13++]
	mov [w12++], [w13++]
print_matrix	
	
;--------------------------------------- eliminate first column
											;determine mult for 3rd row ( - M11/M31 )
	cp0 matrix+M31+2
	bra z, 1f
	mov #reg_mult, w13
	mov #matrix+M31, w12
	reg_copy
	call fp_oneover
	mov #matrix+M11, w12
	call fp_mult
	neg [++w13], [w13--]
											;mult all of 3rd row
	mov #reg_mult, w12
	mov #matrix+M32, w13
	call fp_mult
	mov #matrix+M33, w13
	call fp_mult
	mov #matrix+M35, w13
	call fp_mult
											;perform addition
clr matrix+M31
clr matrix+M31+2
	mov #matrix+M13, w12									
	mov #matrix+M33, w13
	call fp_add
	mov #matrix+M14, w12
	mov #matrix+M34, w13
	reg_copy
	mov #matrix+M15, w12									
	mov #matrix+M35, w13
	call fp_add						
	
1:											;determine mult for 4th row ( - M11/M41 )
	cp0 matrix+M41+2
	bra z, 1f
	mov #reg_mult, w13
	mov #matrix+M41, w12
	reg_copy
	call fp_oneover
	mov #matrix+M11, w12
	call fp_mult
	neg [++w13], [w13--]
											;mult all 
	mov #reg_mult, w12
	mov #matrix+M42, w13
	call fp_mult
	mov #matrix+M44, w13
	call fp_mult
	mov #matrix+M45, w13
	call fp_mult
											;perform addition
clr matrix+M41
clr matrix+M41+2
	mov #matrix+M13, w12									
	mov #matrix+M43, w13
	reg_copy
	mov #matrix+M14, w12
	mov #matrix+M44, w13
	call fp_add
	mov #matrix+M15, w12									
	mov #matrix+M45, w13
	call fp_add						
1:
print_matrix
;--------------------------------------- eliminate second column
											;determine mult for 3rd row ( - M22/M32 )
	cp0 matrix+M32+2
	bra z, 1f
	mov #reg_mult, w13
	mov #matrix+M32, w12
	reg_copy
	call fp_oneover
	mov #matrix+M22, w12
	call fp_mult
	neg [++w13], [w13--]										
											;mult all of 3rd row
	mov #reg_mult, w12
	mov #matrix+M33, w13
	call fp_mult
	mov #matrix+M34, w13
	call fp_mult
	mov #matrix+M35, w13
	call fp_mult
											;perform addition
clr matrix+M32
clr matrix+M32+2
	mov #matrix+M23, w12									
	mov #matrix+M33, w13
	call fp_add			
	mov #matrix+M24, w12									
	mov #matrix+M34, w13
	call fp_add			
	mov #matrix+M25, w12									
	mov #matrix+M35, w13
	call fp_add			
1:
											;determine mult for 4th row ( - M22/M42 )
	cp0 matrix+M42+2
	bra z, 1f
	mov #reg_mult, w13
	mov #matrix+M42, w12
	reg_copy
	call fp_oneover
	mov #matrix+M22, w12
	call fp_mult
	neg [++w13], [w13--]
											;mult all of 4th row
	mov #reg_mult, w12
	mov #matrix+M43, w13
	call fp_mult
	mov #matrix+M44, w13
	call fp_mult
	mov #matrix+M45, w13
	call fp_mult
											;perform addition
clr matrix+M42
clr matrix+M42+2
	mov #matrix+M23, w12									
	mov #matrix+M43, w13
	call fp_add			
	mov #matrix+M24, w12									
	mov #matrix+M44, w13
	call fp_add			
	mov #matrix+M25, w12									
	mov #matrix+M45, w13
	call fp_add			
1:	
print_matrix
;--------------------------------------- eliminate third column
											;determine mult for 1st row ( - M33/M13 )
	cp0 matrix+M13+2
	bra z, 1f
	mov #reg_mult, w13
	mov #matrix+M13, w12
	reg_copy
	call fp_oneover
	mov #matrix+M33, w12
	call fp_mult
	neg [++w13], [w13--]		
											;mult all of 1st row
	mov #reg_mult, w12
	mov #matrix+M11, w13
	call fp_mult
	mov #matrix+M14, w13
	call fp_mult
	mov #matrix+M15, w13
	call fp_mult	
											;perform addition
clr matrix+M13
clr matrix+M13+2
	mov #matrix+M34, w12									
	mov #matrix+M14, w13
	call fp_add			
	mov #matrix+M35, w12									
	mov #matrix+M15, w13
	call fp_add			
1:								
											;determine mult for 2nd row ( - M33/M23 )
	cp0 matrix+M23+2
	bra z, 1f
	mov #reg_mult, w13
	mov #matrix+M23, w12
	reg_copy
	call fp_oneover
	mov #matrix+M33, w12
	call fp_mult
	neg [++w13], [w13--]		
											;mult all of 2nd row
	mov #reg_mult, w12
	mov #matrix+M22, w13
	call fp_mult
	mov #matrix+M24, w13
	call fp_mult
	mov #matrix+M25, w13
	call fp_mult							
											;perform addition
clr matrix+M23
clr matrix+M23+2
	mov #matrix+M34, w12									
	mov #matrix+M24, w13
	call fp_add			
	mov #matrix+M35, w12									
	mov #matrix+M25, w13
	call fp_add							
1:	
											;determine mult for 4th row ( - M33/M43 )	
	cp0 matrix+M43+2
	bra z, 1f
	mov #reg_mult, w13
	mov #matrix+M43, w12
	reg_copy
	call fp_oneover
	mov #matrix+M33, w12
	call fp_mult
	neg [++w13], [w13--]										
											;mult all of 4th row
	mov #reg_mult, w12
	mov #matrix+M44, w13
	call fp_mult
	mov #matrix+M45, w13
	call fp_mult				
											;perform addition
clr matrix+M43
clr matrix+M43+2
	mov #matrix+M34, w12									
	mov #matrix+M44, w13
	call fp_add			
	mov #matrix+M35, w12									
	mov #matrix+M45, w13
	call fp_add			
1:	
print_matrix
	
;--------------------------------------- eliminate fourth column
											;determine mult for 1st row ( - M44/M14 )	
	cp0 matrix+M14+2
	bra z, 1f
	mov #reg_mult, w13
	mov #matrix+M14, w12
	reg_copy
	call fp_oneover
	mov #matrix+M44, w12
	call fp_mult
	neg [++w13], [w13--]	
											;mult all of 1st row
	mov #reg_mult, w12
	mov #matrix+M11, w13
	call fp_mult
	mov #matrix+M15, w13
	call fp_mult												
											;perform addition
clr matrix+M14
clr matrix+M14+2
	mov #matrix+M45, w12									
	mov #matrix+M15, w13
	call fp_add	
1:	
											;determine mult for 2nd row ( - M44/M24 )	
	cp0 matrix+M24+2
	bra z, 1f
	mov #reg_mult, w13
	mov #matrix+M24, w12
	reg_copy
	call fp_oneover
	mov #matrix+M44, w12
	call fp_mult
	neg [++w13], [w13--]										
											;mult all of 2nd row
	mov #reg_mult, w12
	mov #matrix+M22, w13
	call fp_mult
	mov #matrix+M25, w13
	call fp_mult												
											;perform addition
clr matrix+M24
clr matrix+M24+2
	mov #matrix+M45, w12									
	mov #matrix+M25, w13
	call fp_add	
1:	
											;determine mult for 3rd row ( - M44/M34 )	
	cp0 matrix+M34+2
	bra z, 1f
	mov #reg_mult, w13
	mov #matrix+M34, w12
	reg_copy
	call fp_oneover
	mov #matrix+M44, w12
	call fp_mult
	neg [++w13], [w13--]												
											;mult all of 3rd row
	mov #reg_mult, w12
	mov #matrix+M33, w13
	call fp_mult
	mov #matrix+M35, w13
	call fp_mult
											;perform addition
	clr matrix+M34
	clr matrix+M34+2
	mov #matrix+M45, w12									
	mov #matrix+M35, w13
	call fp_add	
1:
print_matrix
;--------------------------------------- make unit matrix

	mov #matrix+M11, w13
	call fp_oneover
	mov #matrix+M15, w13
	mov #matrix+M11, w12
	call fp_mult
	
	mov #matrix+M22, w13
	call fp_oneover
	mov #matrix+M25, w13
	mov #matrix+M22, w12
	call fp_mult
	
	mov #matrix+M33, w13
	call fp_oneover
	mov #matrix+M35, w13
	mov #matrix+M33, w12
	call fp_mult
	
	mov #matrix+M44, w13
	call fp_oneover
	mov #matrix+M45, w13
	mov #matrix+M44, w12
	call fp_mult
	
mov #1, w0
clr  matrix+M11
clr  matrix+M22
clr  matrix+M33
clr  matrix+M44
mov w0, matrix+M11+2  	
mov w0, matrix+M22+2  	
mov w0, matrix+M33+2  	
mov w0, matrix+M44+2  	
	
print_matrix
	
;--------------------------------------- determine new impedance based variables
											;real_impedance, imag_impedance
push real_impedance
push imag_impedance
								
print_CR
print_CR
											
mov #matrix+M15, w12
mov #real_impedance, w13
reg_copy
call print_readable_R
											
print_CR
	
mov #matrix+M25, w12
mov #imag_impedance, w13
reg_copy
call print_readable_L
						
print_CR
									
pop imag_impedance
pop real_impedance
											;Z_ratio
											;motor_filt_coeff, phase_comp_coeff
	
;--------------------------------------- loop
	return
;*****************************************************************
	
.bss
			
reg_mult:	.space 4

	


.end

	