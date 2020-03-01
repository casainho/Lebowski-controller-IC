.include "p30F4011.inc"

    config __FOSC, FRC_PLL16 & PRI & CSW_FSCM_OFF
    config __FBORPOR, PWRT_64 & PBOR_ON & BORV42 & MCLR_EN & RST_PWMPIN & PWMxL_ACT_HI & PWMxH_ACT_HI
    config __FWDT, WDT_OFF & WDTPSB_3 & WDTPSA_8
    config __FGS, GWRP_OFF & CODE_PROT_ON
	
.bss
.global stackpointer
    .align 2
stackpointer:
    .space 64


.section *,code ;,address (0x15A4)

.global __reset
__reset:
	
    mov #stackpointer, w15
    mov #stackpointer+62, w0
    mov w0, SPLIM

    bset TRISD, #3	
 	btss PORTD, #3
    goto main_menu

    goto main_motor
	
	
	


.end      

