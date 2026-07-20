#include <avr/interrupt.h>
#include <avr/io.h>

void initializeCommandModule(void)
{
	// Turn off interrupts.
	cli();

	// Set I/O pins
	DDRB = 0x10;
	PORTB = 0xCF;
	DDRC = 0x00;
	PORTC = 0xFF;
	DDRD = 0xE6;
	PORTD = 0x7D;
	
	// Initialize baud rate to 57600.
	UBRR0 = 19;
	UCSR0B = 0x18;
	UCSR0C = 0x06;

	// Set up timer 1 to generate an interrupt every 1 ms.
	TCCR1A = 0x00;
	TCCR1B = (_BV(WGM12) | _BV(CS12));
	OCR1A = 71;
	TIMSK1 = _BV(OCIE1A);

	// Turn on interrupts.
	sei();
}

void sendByte(uint8_t value) {
	while(!(UCSR0A & 0x20));
	UDR0 = value;
}

uint8_t getByte(void) {
	while(!(UCSR0A & 0x80));
	return UDR0;
}

volatile uint16_t timerCount;
volatile uint8_t timerOn;
void delay(uint16_t time_ms) {
  timerOn = 1;
  timerCount = time_ms;
  while(timerOn) ;
}

SIGNAL(SIG_OUTPUT_COMPARE1A) {
  if(timerCount)
    timerCount--;
  else
    timerOn = 0;
}

