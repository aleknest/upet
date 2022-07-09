#include <Arduino.h>
#include <stdio.h>
#include <stdarg.h>
#include <stdlib.h>
#include "application.h"

#define FASTADC 1
// defines for setting and clearing register bits
#ifndef cbi
#define cbi(sfr, bit) (_SFR_BYTE(sfr) &= ~_BV(bit))
#endif
#ifndef sbi
#define sbi(sfr, bit) (_SFR_BYTE(sfr) |= _BV(bit))
#endif

Application::Application()
	: m_device(m_settings)
{
}

void Application::setup()
{
	#if FASTADC
	// set prescale to 16
	sbi(ADCSRA,ADPS2) ;
	cbi(ADCSRA,ADPS1) ;
	cbi(ADCSRA,ADPS0) ;
	#endif

	m_device.setup();
}

void Application::loop()
{
	m_device.loop();
	delay(1);
}

