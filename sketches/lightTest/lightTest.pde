#include <Wasp485.h>
#include <ModbusMaster485.h>
#include <Math.h>

#include <string.h>
#include <stddef.h>

#include <Wire.h>
#include "Adafruit_LEDBackpack.h"
#include "Adafruit_GFX.h"

union {
   int ints[2];   
   float toFloat;
} 
reading;

float oldfinalValue = 0;
float threshold = 0.5;
float finalValue = 1.11;
int count = 0;

unsigned long previousMillisSen = 0; 
long intervalSen = 120000; 

unsigned long previousMillisLig = 0; 
long intervalLig = 60000; 

unsigned long startTime = 0; 
unsigned long endTime = 0; 

char* hour;
char *timeNow;
char *saveptr1;

// Instantiate ModbusMaster object as slave ID 1
ModbusMaster485 node(1);
int result = 0;

Adafruit_8x8matrix matrix = Adafruit_8x8matrix();


void setup()
{
  // Power on the USB for viewing data in the serial monitor
  USB.ON();
  RTC.ON();
  USB.println("8x8 LED Matrix Test");
  matrix.begin(0x70);  // pass in the address
  delay(1000);
  setTime();
}

void setTime(){
  // Setting time [yy:mm:dd:dow:hh:mm:ss]
  RTC.setTime("16:11:08:03:12:33:00");
  USB.print(F("Setting time: "));
  USB.println(F("16:11:08:06:12:33:00"));
}


void loop()
{

  // Read data from sensor every 5 seconds
  unsigned long currentMillisSen = millis();
  if((unsigned long)currentMillisSen - previousMillisSen > intervalSen) {
       previousMillisSen = currentMillisSen;
       USB.print("Inside Sensor Read ");
       
       USB.print("Count Is ");
       USB.print(count);
       
       timeNow = RTC.getTime();
       USB.print(" time Sensor Read is: ");
       USB.println(timeNow); 
       count ++;
       if (count > 5) {
         finalValue = 2.6;
       }
  }
  
  // Display Lights every 15 seconds
  unsigned long currentMillisLig = millis();
  if( ((unsigned long)currentMillisLig - previousMillisLig > intervalLig) || finalValue > 2.5) {
      previousMillisLig = currentMillisLig;
      startTime = millis();
      PWR.setSensorPower(SENS_5V,SENS_ON);
      
      USB.print("Inside Light ");
      //USB.print(F("Time [Day of week, YY/MM/DD, hh:mm:ss]: "));
      timeNow = RTC.getTime();
      USB.print("Time is: ");
      USB.println(timeNow);
      
      hour = calculateMin(timeNow);
      int hourVal1 = hour[0] - '0';
      int hourVal2 = hour[1] - '0';
     
      if(hourVal1 == 3 && hourVal2 == 6){
          USB.println("yes hr if matched"); 
          //("16:11:08:03:12:33:00");
          PWR.deepSleep("00:00:00:40", RTC_OFFSET, RTC_ALM1_MODE2,ALL_OFF); // Sleep switching all off, waking up after 10 second
      }
    
    // After wake up check interruption source
      if( intFlag & RTC_INT )
      {
        USB.ON();
        RTC.ON();  
        USB.println(F("\nwake up"));
        // clear interruption flag
        intFlag &= ~(RTC_INT);
      }
    
      matrix.clear();
      matrix.drawCircle(3,3, 3, LED_ON);
      matrix.writeDisplay();  // write the changes we just made to the display
      
      USB.print(F("Battery Level: "));
      USB.print(PWR.getBatteryLevel(),DEC);
      USB.print(F(" %"));
      
      // Show the battery Volts
      USB.print(F(" | Battery1 (Volts): "));
      USB.print(PWR.getBatteryVolts());
      USB.println(F(" V"));
      
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
        matrix.print("ft");
        matrix.writeDisplay();
        delay(70);
      }
      matrix.setRotation(0); 
     
      PWR.setSensorPower(SENS_5V,SENS_OFF); 
      
      endTime = millis();
      long diff = endTime - startTime;
      USB.print("Time Taken for Light Run is: ");
      USB.println(diff);
    }
    //PWR.sleep(WTD_32MS, ALL_OFF); 
}


/*
char * calculateHour(char * input){
  char *delimeter1 = ",";
  char *delimeter2 = ":";
  char **dataArr = (char**)malloc(3);
  char *first = strtok_r(input, delimeter1 , &saveptr1);
    for (int i=0; i< 3; i++) {
      dataArr[i] =  strtok_r(NULL, delimeter1, &saveptr1);
      if (dataArr[i] == NULL)
          break;
      USB.print("time is ");
      USB.println(dataArr[i]); 
    }
  char *hr = strtok_r(dataArr[1], delimeter2 , &saveptr1);
  return hr;
 }*/
 
 char * calculateMin(char * input){
  char *delimeter1 = ",";
  char *delimeter2 = ":";
  char **dataArr = (char**)malloc(3);
  char *first = strtok_r(input, delimeter1 , &saveptr1);
    for (int i=0; i< 3; i++) {
      dataArr[i] =  strtok_r(NULL, delimeter1, &saveptr1);
      if (dataArr[i] == NULL)
          break;
    }
  char *hr = strtok_r(dataArr[1], delimeter2 , &saveptr1);
  char *min1 = strtok_r(NULL, delimeter2, &saveptr1);
  USB.print("minutes is ");
  USB.println(min1);
  return min1;
 }
