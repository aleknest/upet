#include "configuration.h"
#include <stdint.h>

#ifndef SETTINGS_H
#define SETTINGS_H


class Settings
{
private:
    struct SSettings
    {
        int             m_temperature;
    };
public:
    Settings();
    void load();
    void save();
    void set_default();

    SSettings settings;
};

#endif
