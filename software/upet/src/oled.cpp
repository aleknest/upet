#include "oled.h"
#include <Arduino.h>

oled::oled()
  : u8g(U8G_I2C_OPT_NONE)	// I2C / TWI 
  , m_full_repaint(false)
{
}

oled::~oled()
{
}

void oled::setup()
{
  if ( u8g.getMode() == U8G_MODE_R3G3B2 ) 
    u8g.setColorIndex(255);     // white
  else if ( u8g.getMode() == U8G_MODE_GRAY2BIT )
    u8g.setColorIndex(3);         // max intensity
  else if ( u8g.getMode() == U8G_MODE_BW )
    u8g.setColorIndex(1);         // pixel on
  else if ( u8g.getMode() == U8G_MODE_HICOLOR )
    u8g.setHiColorByRGB(255,255,255);
}

void oled::loop()
{
  if (m_full_repaint)
  {
    u8g.firstPage();  
    do 
    {
      draw();
    } while( u8g.nextPage() );
    m_full_repaint=false;
  }
}

void oled::repaint()
{
  m_full_repaint=true;
}

void oled::draw()
{
  draw_frame();
}

const int gr1=57;
const int gr2=42;

void oled::draw_frame()
{
  u8g.setColorIndex(1);
  u8g.drawFrame(0, 0, 128, gr1);
  u8g.drawFrame(0, gr2, 128, gr1);
  u8g.drawBox(0, gr1, 128, 64);
}
