#include <Wasp485.h>
#include <ModbusMaster485.h>
#include <Math.h>
#include <WaspBLE.h>

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
float finalValue = 0;
float finalValueDiff = 0;
int count = 0;

unsigned long previousMillisSen = 0; 
long intervalSen = 5000; 

unsigned long previousMillisLig = 0; 
long intervalLig = 80000; 

unsigned long previousMillisBLE = 0;
long intervalBLE = 5000;

unsigned long startTime = 0; 
unsigned long endTime = 0; 

char* hour;
char *timeNow;
char *saveptr1;

// Instantiate ModbusMaster object as slave ID 1
ModbusMaster485 node(1);
int result = 0;

Adafruit_8x8matrix matrix = Adafruit_8x8matrix();

/*
char broadcast_string[13];
char floatString[5];
uint8_t advData[] = {0x04, 0xFF, 'H', 'E'};
// Auxiliary variable
uint16_t aux = 0;
uint8_t flag = 0;
const char *WELL_NAME = "Well01-%s"; // Only change value before the - , example if you want to make Well02 then it should be WELL02-%s
*/

void setup()
{
  // Power on the USB for viewing data in the serial monitor
  USB.ON();
  RTC.ON();
  //BLE.ON(SOCKET1);
  USB.println("8x8 LED Matrix Test");
  matrix.begin(0x70);  // pass in the address
  // Initialize Modbus communication baud rate
  node.begin(19200); //19200 8 N 1
  USB.println("Starting Modbus....");
  node.clearResponseBuffer();
  delay(1000);
  setTime();
}

void setTime(){
  // Setting time [yy:mm:dd:dow:hh:mm:ss]
  RTC.setTime("17:02:23:05:21:00:00");
  USB.print(F("Setting time: "));
  //USB.println(F("16:11:11:06:12:33:00"));
}


void loop()
{

  // Read data from sensor every 5 seconds
  unsigned long currentMillisSen = millis();
  if((unsigned long)currentMillisSen - previousMillisSen > intervalSen) {
       previousMillisSen = currentMillisSen;
       USB.print("Inside Sensor Read ");
       timeNow = RTC.getTime();
       USB.print(" time Sensor Read is: ");
       USB.println(timeNow); 
       
       
      hour = calculateHour(timeNow);
      int hourVal1 = hour[1] - '0';
      int hourVal2 = hour[2] - '0';
      
      USB.print("hour is: ");
      USB.println(hour);
     
      if(hourVal1 == 1 && hourVal2 == 9){
          USB.println("sleep mode initiated"); 
          //("days:hr:min:sec);
          PWR.deepSleep("00:12:00:00", RTC_OFFSET, RTC_ALM1_MODE2,ALL_OFF);
      }
    
    // After wake up check interruption source
      if( intFlag & RTC_INT )
      {
        USB.ON();
        RTC.ON();  
        node.begin(19200); //19200 8 N 1
        USB.println("Starting Modbus....");
        node.clearResponseBuffer();
        USB.println(F("\nwake up"));
        // clear interruption flag
        intFlag &= ~(RTC_INT);
      }
       //finalValue = 2.999;
       USB.print("depth values are ");
       USB.print(" final: ");
       USB.print(finalValue);
      
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
        finalValue = 2.2 - finalValue;
        if(oldfinalValue == 0){
          finalValueDiff = 0;
        }
        else
        {
          finalValueDiff = finalValue - oldfinalValue; 
        }
        if (finalValueDiff < 0){
            finalValueDiff = finalValueDiff * -1;
        }
        
        //finalValue = 2.999;
        USB.print("depth values are ");
        USB.print(" final: ");
        USB.print(finalValue);
        USB.print(" old: ");
        USB.print(oldfinalValue);
        USB.print(" difference: ");
        USB.println(finalValueDiff);
        oldfinalValue = finalValue;
     
      //Utils.blinkGreenLED(50,1);
        reading.ints[0] = 0;
        reading.ints[1] = 0;
      }
      else {
        reading.ints[0] = 0;
        reading.ints[1] = 0;
      //Utils.blinkRedLED(50,1);
      }  
  }
  

/*
    // Update BLE every 5 seconds
    unsigned long currentMillisBLE = millis();
    if ((unsigned long) currentMillisBLE - previousMillisBLE > intervalBLE) {
        previousMillisBLE = currentMillisBLE;

           aux = BLE.wakeUp();

           // 1.1 Make device no discoverable to stop advertisement.
            aux = BLE.setDiscoverableMode(BLE_GAP_NON_DISCOVERABLE);
            aux = BLE.setAdvParameters(160, 160, 7);
            USB.println(F("\tB - Setting advertisement interval"));

            // 1.3 Set a dummy string for demonstration, but clear the variable first.
            memset(advData, 0x00, sizeof(advData));
            //sprintf(advData, "Test");
            aux = BLE.setAdvData(BLE_GAP_ADVERTISEMENT, advData, sizeof(advData));

            //Utils.float2String(value, floatString,3);
            dtostrf(finalValue, 1, 3, floatString);
            delay(1000);
            //memset(broadcast_string, 0x00, sizeof(broadcast_string));
            snprintf(broadcast_string, sizeof(broadcast_string), WELL_NAME, floatString);
            delay(100);
            flag = BLE.writeLocalAttribute(3, broadcast_string);
            USB.println(F("\tC - Setting data"));

            //aux = BLE.setDiscoverableMode(BLE_GAP_USER_DATA);
            aux = BLE.setDiscoverableMode(BLE_GAP_GENERAL_DISCOVERABLE);
            //BLE.setConnectableMode(BLE_GAP_NON_CONNECTABLE);
            BLE.setConnectableMode(BLE_GAP_UNDIRECTED_CONNECTABLE);
            USB.println(F("\tD - Start advertisements"));

            // 1.5 Go to sleep and but remain advertising to save power.
            BLE.sleep();
            //delay(5000);
            //


    }
    */

  // Display Lights every 15 seconds
  unsigned long currentMillisLig = millis();
  if( ((unsigned long)currentMillisLig - previousMillisLig > intervalLig) || finalValueDiff > 0.02) {
      previousMillisLig = currentMillisLig;
      startTime = millis();
      PWR.setSensorPower(SENS_5V,SENS_ON);
      
      USB.print("Inside Light ");
      //USB.print(F("Time [Day of week, YY/MM/DD, hh:mm:ss]: "));
      timeNow = RTC.getTime();
      USB.print("Time is: ");
      USB.print (timeNow);
      
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
     // finalValueDiff = 0;
      PWR.setSensorPower(SENS_5V,SENS_OFF); 
      
      endTime = millis();
      long diff = endTime - startTime;
      USB.print("Time Taken for Light Run in ms is: ");
      USB.println(diff);
    }
    //PWR.sleep(WTD_32MS, ALL_OFF); 
}



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
 }
 
 /*
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
  //USB.print("minutes is ");
  //USB.println(min1);
  return min1;
 }
 */
