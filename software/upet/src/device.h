#ifndef DEVICE_H
#define DEVICE_H

#include "configuration.h"
#include "settings.h"
#include "oled.h"
#include <Arduino.h>

class Device
{
private:
	Settings&		m_settings;
    oled            m_oled;
public:
    Device(Settings& a_settings);

	void setup();
	void loop();
};

#endif
