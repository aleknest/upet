#ifndef OLED_H
#define OLED_H

#include "U8glib.h"

class oled
{
private:
  U8GLIB_SH1106_128X64 u8g;

  bool        m_full_repaint;

  void draw_frame();
  void draw();
public:
  oled();
  ~oled();

  void setup();
  void loop();

  void repaint();
};

#endif
