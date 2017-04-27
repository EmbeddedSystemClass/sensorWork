#include <WaspBLE.h>
// Put your libraries here (#include ...)

void setup()
{
  USB.ON();
  BLE.ON(SOCKET1);

}


void loop()
{
  BLE.OFF();
  USB.println(F("enter deep sleep"));
  PWR.deepSleep("00:00:00:10",RTC_OFFSET,RTC_ALM1_MODE1,ALL_OFF);
  USB.ON();
  USB.println(F("\nwake up"));
  // put your setup code here, to run once:

  if( intFlag & RTC_INT ){
  intFlag &= ~(RTC_INT);
  USB.println(F("---------------------"));
   USB.println(F("RTC INT captured"));
   USB.println(F("---------------------"));
   Utils.blinkLEDs(300);
   Utils.blinkLEDs(300);
   Utils.blinkLEDs(300);
   BLE.ON(SOCKET1);
  }
}



