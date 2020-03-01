.text

.global init_interrupts
;initialise interrupts

init_interrupts:
                            ;turn off all interrupts by disabling them
    clr IEC0
    clr IEC1
    clr IEC2
                            ;no CAN interrupts
    clr C1INTE
                            ;set all interrupts to level 0
    clr IPC0
    clr IPC1
    clr IPC2
    clr IPC3
    clr IPC4
    clr IPC5
    clr IPC6
    clr IPC9
    clr IPC10
                            ;interrupt nesting allowed
    bclr INTCON1, #15
    						;use default IVT
    bclr INTCON2, #15
    						;set processor interrupt level 1 or higher
    bclr CORCON, #3
    bclr SR, #7
    bclr SR, #6
    bclr SR, #5

    return

.end
