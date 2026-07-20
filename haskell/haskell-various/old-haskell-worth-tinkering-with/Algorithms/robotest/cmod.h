#ifndef INCLUDE_CMOD_H
#define INCLUDE_CMOD_H

#include <avr/interrupt.h>
#include <avr/io.h>

void initializeCommandModule(void);
void sendByte(uint8_t value);
uint8_t getByte(void);
void delay(uint16_t time_ms);


#endif
