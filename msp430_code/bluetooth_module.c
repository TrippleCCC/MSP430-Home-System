/*
 * bluetooth_module.c
 *
 *  Created on: May 11, 2021
 *      Author: nonsochukwurah
 */

#include <msp430.h>

#include "bluetooth_module.h"

void setup_bluetooth_module() {
    P1SEL = BIT1 + BIT2;                     // P1.1 = RXD, P1.2=TXD
    P1SEL2 = BIT1 + BIT2;
    UCA0CTL1 |= UCSSEL_2;                     // SMCLK
    UCA0BR0 = 104;                            // 1MHz 9600
    UCA0BR1 = 0;                              // 1MHz 9600
    UCA0MCTL = UCBRS0;                        // Modulation UCBRSx = 1
    UCA0CTL1 &= ~UCSWRST;                     // **Initialize USCI state machine**
    IE2 |= UCA0RXIE;                          // Enable USCI_A0 RX interrupt
}

// This interrupt is triggered whenever we recive data over bluetooth
#if defined(__TI_COMPILER_VERSION__) || defined(__IAR_SYSTEMS_ICC__)
#pragma vector=USCIAB0RX_VECTOR
__interrupt void USCI0RX_ISR(void)
#elif defined(__GNUC__)
void __attribute__ ((interrupt(USCIAB0RX_VECTOR))) USCI0RX_ISR (void)
#else
#error Compiler not supported!
#endif
{
    P1OUT ^= BIT0;
    IFG2 = IFG2 & 0x0A; //this clears the flags
}
