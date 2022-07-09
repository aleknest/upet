#include "device.h"

Device::Device(Settings& a_settings)
    : m_settings(a_settings)
    , m_oled()
{
}

void Device::setup()
{
    m_oled.setup();
}

void Device::loop()
{
    m_oled.loop();
}

