.include "p30F4011.inc"
.include "defines.inc"
 
.text

;this is the CAN bus interrupt routine. It gets called
;when a new message is received in RXB0, filter0
;filter 0: throttle input

.section *,code ;,address (0x58D0)

.global __C1Interrupt
__C1Interrupt:

;--------------------------------------- save registers
                                            ;w0-w3
    push.s

;--------------------------------------- make sure its an RXB0 interrupt

    btss C1INTF, #0
    bra c1i_end

;--------------------------------------- only accept filter 0, else end

    btsc C1RX0CON, #0
    bra c1i_end

;--------------------------------------- make sure buffer full, there's 2 data bytes
                                            ;buffer full ?
    btss C1RX0CON, #7
    bra c1i_end
    bclr C1RX0CON, #7
                                            ;6 bytes ?
    mov #0x000F, w0
    and C1RX0DLC, wreg
    cp w0, #6
    bra nz, c1i_end

;--------------------------------------- read data, assign to throttle_rawx
 
    mov C1RX0B1, w0
    mov w0, throttle_raw1
    mov C1RX0B2, w0
    mov w0, throttle_raw2
    mov C1RX0B3, w0
    mov w0, flags_CAN

;--------------------------------------- process the received flags

	bclr flags1, #reverse_request
	btsc flags_CAN, #reverse_CAN
	bset flags1, #reverse_request

;--------------------------------------- compute wanted_i_real according to polynomals

    push w10
    push w11
    push w12
    push w13

    call throttle_rawx_to_wanted_i_real

    pop w13
    pop w12
    pop w11
    pop w10

;--------------------------------------- end
c1i_end:
    bclr C1INTF, #0
    bclr IFS1, #11
    pop.s
    retfie

;***************************************

.global CAN_tx_throttle
CAN_tx_throttle:
                                        ;re-build flags_CAN
	clr flags_CAN
	btsc flags1, #reverse_request
	bset flags_CAN, #reverse_CAN
		
    mov throttle_raw1, w0
    mov w0, C1TX0B1
    mov throttle_raw2, w0
    mov w0, C1TX0B2
    mov flags_CAN, w0
    mov w0, C1TX0B3

    mov #0x0030, w0                     ;6 bytes, no extended ID
    mov w0, C1TX0DLC
 
                                        ;tx ID
    mov can_txsid, w0
    mov w0, C1TX0SID

    bset C1TX0CON, #3                                   ;set TXREQ

    return

;***************************************

.end      
