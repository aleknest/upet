#include "application.h"
#include <Arduino.h>

Application app;

void setup()
{
	app.setup();
}

void loop()
{
	app.loop();
}
