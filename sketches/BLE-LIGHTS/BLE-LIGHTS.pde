
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

// Instantiate ModbusMaster object as slave ID 1
ModbusMaster node(RS485_COM, 1);
int result = 0;

Adafruit_8x8matrix matrix = Adafruit_8x8matrix();

char broadcast_string[13];
char floatString[5];
uint8_t advData[] = {0x04, 0xFF, 'H', 'E'};
// Auxiliary variable
uint16_t aux = 0;
uint8_t flag = 0;


// CONFIGURATION VALUE WHICH NEEDS TO BE SET BEFORE INSTALLING THE CODE IN THE WELL
 // RTC time format [yy:mm:dd:dow:hh:mm:ss]       dow = DATE OF WEEK , SUNDAY = 00, MONDAY = 01 and so on
const char *RTC_TIME = "17:02:07:02:10:10:00";
int HOUR_FIRST_DIGIT = 1;
int HOUR_SECOND_DIGIT = 2;
float BASE_LEVEL_DEPTH = 2.2;
float LEVEL_DIFFERENCE_THRESHOLD = 0.02;
const char *LIGHT_TEXT_ONE = "Groundwater Level is";
const char *LIGHT_TEXT_TWO = "ft";
const char *WELL_NAME = "Well01-%s"; // Only change value before the - , example if you want to make Well02 then it should be WELL02-%s


void setup() {
    // Power on the USB for viewing data in the serial monitor
    USB.ON();
    PWR.setSensorPower(SENS_5V, SENS_OFF);
    PWR.setSensorPower(SENS_3V3, SENS_ON);
    RTC.ON();
    BLE.ON(SOCKET1);
    USB.println("8x8 LED Matrix Test");
    PWR.setSensorPower(SENS_5V, SENS_ON);
    // Initialize Modbus communication baud rate
    //node.begin(19200); //19200 8 N 1
    USB.println("Starting Modbus....");
    //node.clearResponseBuffer();
    delay(1000);
    setTime();
    RTC.OFF();
    PWR.setSensorPower(SENS_3V3, SENS_OFF);
}

void setTime() {
    RTC.setTime(RTC_TIME);
    USB.print(F("Setting time Done: "));
}


void loop() {


    //BLE.ON(SOCKET1);
    // Read data from sensor every 5 seconds
    unsigned long currentMillisSen = millis();
    if ((unsigned long) currentMillisSen - previousMillisSen > intervalSen) {
        previousMillisSen = currentMillisSen;
        USB.print("Inside Sensor Read ");
        delay(1000);
        PWR.setSensorPower(SENS_3V3, SENS_ON);
        RTC.ON();
        timeNow = RTC.getTime();
        USB.print(" time Sensor Read is: ");
        USB.println(timeNow);
        //delay(2000);
        // 
        RTC.OFF();
        PWR.setSensorPower(SENS_3V3, SENS_OFF);


        hour = calculateMin(timeNow);
        int hourVal1 = hour[0] - '0';
        int hourVal2 = hour[1] - '0';

        USB.print("hour is: ");
        USB.println(hour);

        if (hourVal1 == HOUR_FIRST_DIGIT && hourVal2 == HOUR_SECOND_DIGIT) {
            USB.println("sleep mode initiated");
            //("days:hr:min:sec);
             //BLE.sleep();
             PWR.deepSleep("00:00:00:20", RTC_OFFSET, RTC_ALM1_MODE2,SENS_OFF);
        }

        // After wake up check interruption source
        if (intFlag & RTC_INT) {
            intFlag &= ~(RTC_INT);
            USB.ON();
            RTC.ON();

            delay(1000);
            aux = BLE.wakeUp();
            delay(3000);
            
     
            // clear interruption flag
           // intFlag &= ~(RTC_INT);
          // BLE.wakeUp();
        }

            finalValue = 1.12256;
            //USB.print("Level in feet: ");
        
            // 1.1 Make device no discoverable to stop advertisement.
            aux = BLE.setDiscoverableMode(BLE_GAP_NON_DISCOVERABLE);

            // 1.2 Set advertisement interval of 100 ms and three channels
            /* NOTE 3: intervals are specified in units of 625 uS
             Example: 100 ms / 0.625 = 160
             */
            aux = BLE.setAdvParameters(1600, 1600, 7);
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
            //aux = BLE.wakeUp();

    }

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
        delay(1000);
        RTC.ON();
        delay(1000);
        timeNow = RTC.getTime();
        USB.print(" time Sensor Read is: ");
        USB.println(timeNow);
        delay(1000);

        RTC.OFF();
        PWR.setSensorPower(SENS_3V3, SENS_OFF);
        delay(3000);

        PWR.setSensorPower(SENS_5V, SENS_ON);
        matrix.begin(0x70);  // pass in the address
        delay(1000);


        //USB.print(F("Battery Level: "));
        //USB.print(PWR.getBatteryLevel(),DEC);
        //USB.print(F(" %"));
        // Show the battery Volts
        //USB.print(F(" | Battery1 (Volts): "));
        //USB.print(PWR.getBatteryVolts());
        //USB.println(F(" V"));

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
    //PWR.sleep(WTD_32MS, ALL_OFF); 
}



// Calculate the Hour from the RTC Time
char *calculateHour(char *input) {
    const char *delimeter1 = ",";
    const char *delimeter2 = ":";
    char **dataArr = (char **) malloc(3);
    char *first = strtok_r(input, delimeter1, &saveptr1);
    for (int i = 0; i < 3; i++) {
        dataArr[i] = strtok_r(NULL, delimeter1, &saveptr1);
        if (dataArr[i] == NULL)
            break;
        USB.print("time is ");
        USB.println(dataArr[i]);
    }
    char *hr = strtok_r(dataArr[1], delimeter2, &saveptr1);
    return hr;
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

