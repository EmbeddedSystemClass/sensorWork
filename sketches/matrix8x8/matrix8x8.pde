/*************************************************** 
  This is a library for our I2C LED Backpacks

  Designed specifically to work with the Adafruit LED Matrix backpacks 
  ----> http://www.adafruit.com/products/872
  ----> http://www.adafruit.com/products/871
  ----> http://www.adafruit.com/products/870

  These displays use I2C to communicate, 2 pins are required to 
  interface. There are multiple selectable I2C addresses. For backpacks
  with 2 Address Select pins: 0x70, 0x71, 0x72 or 0x73. For backpacks
  with 3 Address Select pins: 0x70 thru 0x77

  Adafruit invests time and resources providing this open source code, 
  please support Adafruit and open-source hardware by purchasing 
  products from Adafruit!

  Written by Limor Fried/Ladyada for Adafruit Industries.  
  BSD license, all text above must be included in any redistribution
 ****************************************************/

#include <Wire.h>
#include "Adafruit_LEDBackpack.h"
#include "Adafruit_GFX.h"

float finalValue = 1.21;
Adafruit_8x8matrix matrix = Adafruit_8x8matrix();

void setup()
{
// Power on the USB for viewing data in the serial monitor
USB.ON();
USB.println("8x8 LED Matrix Test");
PWR.setSensorPower(SENS_5V,SENS_ON);
matrix.begin(0x70);  // pass in the address
// Initialize Modbus communication baud rate
delay(1000);
}


void loop() {
  matrix.clear();
  matrix.setTextSize(1);
  matrix.setTextWrap(false);  // we dont want text to wrap so it scrolls nicely
  matrix.setTextColor(LED_ON);
  for (int8_t x=0; x>=-120; x--) {
    matrix.clear();
    matrix.setCursor(x,0);
    matrix.print("Groundwater Level is");
    matrix.writeDisplay();
    delay(100);
  }
  matrix.setRotation(0);
  for (int8_t x=7; x>=-50; x--) {
    matrix.clear();
    matrix.setCursor(x,0);
    matrix.print(finalValue);
    matrix.print("ft");
    matrix.writeDisplay();
    delay(100);
  }
  matrix.setRotation(0);
}
