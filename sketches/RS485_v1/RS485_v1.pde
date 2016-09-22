#include <Wasp485.h>
#include <ModbusMaster485.h>
#include <Math.h>

#include <Wire.h>
#include "Adafruit_LEDBackpack.h"
#include "Adafruit_GFX.h"

union {
   int ints[2];   
   float toFloat;
} 
reading;

float finalValue = 0;
int count = 0;

// Instantiate ModbusMaster object as slave ID 1
ModbusMaster485 node(1);
int result = 0;

Adafruit_8x8matrix matrix = Adafruit_8x8matrix();


void setup()
{
// Power on the USB for viewing data in the serial monitor
USB.ON();
USB.println("8x8 LED Matrix Test");
PWR.setSensorPower(SENS_5V,SENS_ON);
matrix.begin(0x70);  // pass in the address
// Initialize Modbus communication baud rate
node.begin(19200); //19200 8 N 1
USB.println("Starting Modbus....");
node.clearResponseBuffer();
delay(1000);
}

void loop()
{
unsigned long currentMillis = millis();
 
    count = 0;
    
    result = node.readHoldingRegisters(53,2); 
    while(result != 0 || count < 5){
    count++;  
    delay(100);
    result = node.readHoldingRegisters(53,2); 
    }

    USB.print("Level in feet: ");
    if(result == 0)
    {
    reading.ints[0] = node.getResponseBuffer(1);
    reading.ints[1] = node.getResponseBuffer(0);
    node.clearResponseBuffer();
    finalValue = reading.toFloat;
    USB.print(finalValue);
    Utils.blinkGreenLED(50,1);
    reading.ints[0] = 0;
    reading.ints[1] = 0;
    }
    else {
    reading.ints[0] = 0;
    reading.ints[1] = 0;
    Utils.blinkRedLED(50,1);
    }
    USB.print("\n");
   
  matrix.clear();
  matrix.drawCircle(3,3, 3, LED_ON);
  matrix.writeDisplay();  // write the changes we just made to the display
  delay(500);

  matrix.setTextSize(1);
  matrix.setTextWrap(false);  // we dont want text to wrap so it scrolls nicely
  matrix.setTextColor(LED_ON);
  for (int8_t x=0; x>=-120; x--) {
    matrix.clear();
    matrix.setCursor(x,0);
    matrix.print("Groundwater Level is");
    matrix.writeDisplay();
    delay(70);
  }
  matrix.setRotation(0);
  for (int8_t x=0; x>=-120; x--) {
    matrix.clear();
    matrix.setCursor(x,0);
    matrix.print(finalValue);
    matrix.print("ft below grade");
    matrix.writeDisplay();
    delay(70);
  }
  matrix.setRotation(0); 
  
}



