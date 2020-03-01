.include "p30F4011.inc"
.include "defines.inc"
 
.text
.global CAN_open_RX
CAN_open_RX:
;-------------------------------------- request and wait for CAN configuration mode

    mov #0x0C00, w0
    mov w0, C1CTRL
						
    mov #0x00E0, w1                         ;request accepted mask
    mov #0x0080, w2                         ;request accepted code
cor_req_lp:
    mov w1, w0
    and C1CTRL, wreg
    cpseq w0, w2
    bra cor_req_lp

;-------------------------------------- initialise CAN
                                            ;CAN clk=Fcy, no interrupts
    mov #0x0C00, w0
    mov w0, C1CTRL
                                            ;no RXB0 buffer overflow
    mov #0, w0
    mov w0, C1RX0CON

    mov #0, w0
    mov w0, C1RX1CON
                                            ;message acceptance mask, RXB0, match all bits,
    mov #0b0001111111111101, w0
    mov w0, C1RXM0SID
                                            ;mask filter RXF0, '16', throttle_raw1 and throttle_raw2
;    mov #0b0000000001000000, w0
    mov can_rxsid, w0
    mov w0, C1RXF0SID
                                            ;mask filter RXF1, '2047', not used
    mov #0b0001111111111100, w0
    mov w0, C1RXF1SID
                                            ;Tq pattern: S PP 1111 222 (100 kbaud with Tq = 1usec)
;    mov #0b0000001010011000, w0
    mov can_cfg2, w0
    mov w0, C1CFG2
                                            ;SJW = 1, BPR = 14 for Tq = 1 usec @ 30 MHz
;    mov #0b0000000000001110, w0
    mov can_cfg1, w0
    mov w0, C1CFG1

;-------------------------------------- enable interrupt on RXB0

    bclr C1INTF, #0
    bset C1INTE, #0
                                            ;set CAN1 interrupt level to 4
    bset IPC6, #14
    bclr IPC6, #13
    bclr IPC6, #12
                                            ;enable CAN interrupts in general
    bclr IFS1, #11
    bset IEC1, #11

;-------------------------------------- set in operational mode

    bclr C1CTRL, #10
    bset C1CTRL, #15

    return

;************************************************************

.global CAN_open_TX
CAN_open_TX:
;-------------------------------------- request and wait for CAN configuration mode

    mov #0x0C00, w0
    mov w0, C1CTRL
						
    mov #0x00E0, w1                         ;request accepted mask
    mov #0x0080, w2                         ;request accepted code
cot_req_lp:
    mov w1, w0
    and C1CTRL, wreg
    cpseq w0, w2
    bra cot_req_lp

;-------------------------------------- initialise CAN
                                            ;CAN clk=Fcy, no interrupts
    mov #0x0C00, w0
    mov w0, C1CTRL
                                            ;lowest priority messages
    clr C1TX0CON
    clr C1TX1CON
                                            ;Tq pattern: S PP 1111 222 (100 kbaud with Tq = 1usec)
;    mov #0b0000001010011000, w0
    mov can_cfg2, w0
    mov w0, C1CFG2
                                            ;SJW = 1, BPR = 14 for Tq = 1 usec @ 30 MHz
;    mov #0b0000000000001110, w0
    mov can_cfg1, w0
    mov w0, C1CFG1

;-------------------------------------- disable RX ?
;-------------------------------------- no interrupts in TX mode

    clr C1INTE
    bclr IEC1, #11

;-------------------------------------- set in operational mode

    bclr C1CTRL, #10
    bset C1CTRL, #15

    return

;************************************************************


.end      
