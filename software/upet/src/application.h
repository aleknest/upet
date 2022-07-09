#ifndef APPLICATION_H
#define APPLICATION_H

#include "configuration.h"
#include "device.h"
#include "settings.h"

class Application
{
private:
	Settings		m_settings;
	Device			m_device;
public:
	Application();

	void setup();
	void loop();
};

#endif
