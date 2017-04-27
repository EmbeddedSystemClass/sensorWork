
#include <ModbusMaster.h>
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
}reading;

float oldfinalValue = 0;
float threshold = 0.5;
float finalValue = 0;
float finalValueDiff = 0;
int count = 0;

unsigned long previousMillisSen = 0;
long intervalSen = 5000;

unsigned long previousMillisLig = 0;
long intervalLig = 80000;
unsigned long startTime = 0;
unsigned long endTime = 0;
char *hour;
char *timeNow;
char *saveptr1;

 // RTC time format [yy:mm:dd:dow:hh:mm:ss]       dow = DATE OF WEEK , SUNDAY = 00, MONDAY = 01 and so on
const char *RTC_TIME = "17:02:07:02:10:10:00";
int HOUR_FIRST_DIGIT = 1;
int HOUR_SECOND_DIGIT = 0;

Adafruit_8x8matrix matrix = Adafruit_8x8matrix();
float LEVEL_DIFFERENCE_THRESHOLD = 0.02;
const char *LIGHT_TEXT_ONE = "Groundwater Level is";
const char *LIGHT_TEXT_TWO = "ft";

void setup() {
    // Power on the USB for viewing data in the serial monitor
    USB.ON();
    //PWR.setSensorPower(SENS_5V, SENS_OFF);
    PWR.setSensorPower(SENS_3V3, SENS_ON);
    RTC.ON();
    setTime();
    RTC.OFF();
    PWR.setSensorPower(SENS_3V3, SENS_OFF);
}

void setTime() {
    RTC.setTime(RTC_TIME);
    USB.print(F("Setting time Done: "));
}


void loop() {


 if (intFlag & RTC_INT) {
            USB.println("Inside Wakeup");
            intFlag &= ~(RTC_INT);
            
            USB.ON();  
            
           // RTC.ON();
            RTC.setMode(RTC_ON, RTC_I2C_MODE);
            PWR.setSensorPower(SENS_3V3, SENS_ON);
            USB.println(F("\nwake up"));
  }

    unsigned long currentMillisSen = millis();
    if ((unsigned long) currentMillisSen - previousMillisSen > intervalSen) {
        previousMillisSen = currentMillisSen;
        USB.print("Inside Sensor Read ");
        delay(1000);
       // PWR.setSensorPower(SENS_3V3, SENS_OFF);
        delay(1000);
        RTC.ON();
       // PWR.setSensorPower(SENS_3V3, SENS_ON);
        timeNow = RTC.getTime();
        USB.print(" time Sensor Read is: ");
        USB.println(timeNow);
        hour = calculateMin(timeNow);
        int hourVal1 = hour[0] - '0';
        int hourVal2 = hour[1] - '0';

        USB.print("hour is: ");
        USB.println(hour);

        if (hourVal1 == HOUR_FIRST_DIGIT && hourVal2 == HOUR_SECOND_DIGIT) {
          
            USB.println("sleep mode initiated");
            matrix.clear();
            PWR.setSensorPower(SENS_5V, SENS_OFF);
            PWR.setSensorPower(SENS_3V3, SENS_OFF);
             //PWR.setSensorPower(SENS_3V3, SENS_ON);
             PWR.deepSleep("00:00:00:05", RTC_OFFSET, RTC_ALM1_MODE1,SENS_OFF);
        }
    }


    // LIGHTS
    // Display Lights every 15 seconds
    unsigned long currentMillisLig = millis();
    if (((unsigned long) currentMillisLig - previousMillisLig > intervalLig) || finalValueDiff > LEVEL_DIFFERENCE_THRESHOLD) {
        previousMillisLig = currentMillisLig;
        startTime = millis();
        //PWR.setSensorPower(SENS_5V,SENS_ON);
        delay(1000);

        if (RTC.isON) RTC.OFF();
        delay(1000);
        USB.print("Inside Light ");

        PWR.setSensorPower(SENS_3V3, SENS_ON);
        //delay(1000);
        //RTC.ON();
        //delay(1000);
        //timeNow = RTC.getTime();
        //USB.print(" time Sensor Read is: ");
        //USB.println(timeNow);
        //delay(1000);

        RTC.OFF();
        PWR.setSensorPower(SENS_3V3, SENS_OFF);
        delay(3000);

        PWR.setSensorPower(SENS_5V, SENS_ON);
        matrix.begin(0x70);  // pass in the address
        delay(1000);

        matrix.clear();
        matrix.setTextSize(1);
        matrix.setTextWrap(false);  // we dont want text to wrap so it scrolls nicely
        matrix.setTextColor(LED_ON);
        for (int8_t x = 0; x >= -120; x--) {
            matrix.clear();
            matrix.setCursor(x, 0);
            matrix.print(LIGHT_TEXT_ONE);
            matrix.writeDisplay();
            delay(100);
        }
        matrix.setRotation(0);
        for (int8_t x = 7; x >= -50; x--) {
            matrix.clear();
            matrix.setCursor(x, 0);
            matrix.print(finalValue);
            matrix.print(LIGHT_TEXT_TWO);
            matrix.writeDisplay();
            delay(100);
        }
        matrix.setRotation(0);
        // finalValueDiff = 0;
        PWR.setSensorPower(SENS_5V, SENS_OFF);
        endTime = millis();
        long diff = endTime - startTime;
        USB.print("Time Taken for Light Run in ms is:");
        USB.println(diff);
    }



    
}

char * calculateMin(char * input){
 const char *delimeter1 = ",";
 const char *delimeter2 = ":";
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

