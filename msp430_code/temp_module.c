/*
 * temp_module.c
 *
 *  Created on: May 11, 2021
 *      Author: nonsochukwurah
 */

#include <msp430.h>

#include "data_protocol.h"

void setup_temp_module() {
    // Setting up temp sensor
    ADC10CTL1 = INCH_10 + ADC10DIV_3;         // Temp Sensor ADC10CLK/4
    ADC10CTL0 = SREF_1 + ADC10SHT_3 + REFON + ADC10ON + ADC10IE;
    __delay_cycles(100000);
}

void get_temperature_sample(struct data_packet *packet) {
    long temp;

    // Collect temp data
    ADC10CTL0 |= ENC + ADC10SC;             // Sampling and conversion start
    __bis_SR_register(CPUOFF + GIE);        // LPM0 with interrupts enabled
    temp = ADC10MEM;
    packet->temp = ((temp - 630) * 761) / 1024;
}

// ADC10 interrupt service routine
#if defined(__TI_COMPILER_VERSION__) || defined(__IAR_SYSTEMS_ICC__)
#pragma vector=ADC10_VECTOR
__interrupt void ADC10_ISR (void)
#elif defined(__GNUC__)
void __attribute__ ((interrupt(ADC10_VECTOR))) ADC10_ISR (void)
#else
#error Compiler not supported!
#endif
{
    __bic_SR_register_on_exit(CPUOFF);        // Clear CPUOFF bit from 0(SR)
}
