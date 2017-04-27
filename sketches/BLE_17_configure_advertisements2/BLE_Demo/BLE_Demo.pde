
#include <WaspBLE.h>
// Auxiliary variable
uint16_t aux = 0;
uint8_t flag = 0;
float value;
char broadcast_string[13];
char floatString[5];
// Variable to store advertisement data
//char advData[30];
//uint8_t advData[2];
uint8_t advData[] = {0x07, 0x06, 0xFF, 'H', 'E','L','L','O'};

void setup() 
{  

  value = 1.4444;

  USB.println(F("BLE_17 Example"));  

  // 0. Turn BLE module ON
  BLE.ON(SOCKET1);

}

void loop() 
{

  // 1.1 Make device no discoverable to stop advertisement.
  aux = BLE.setDiscoverableMode(BLE_GAP_NON_DISCOVERABLE);

  value = value + 1.0;
   
  // 1.2 Set advertisement interval of 100 ms and three channels
  /* NOTE 3: intervals are specified in units of 625 uS
   Example: 100 ms / 0.625 = 160
   */
  aux = BLE.setAdvParameters(160, 160, 7);
  USB.println(F("\tB - Setting advertisement interval"));

  // 1.3 Set a dummy string for demonstration, but clear the variable first.
  memset(advData, 0x00, sizeof(advData));
  //sprintf(advData, "Test");

  aux = BLE.setAdvData(BLE_GAP_ADVERTISEMENT, advData,sizeof(advData));
  
  Utils.float2String(value, floatString,3);
  dtostrf(value, 1, 3, floatString);
  delay(1000);
  memset(broadcast_string, 0x00, sizeof(broadcast_string));
  snprintf(broadcast_string,sizeof(broadcast_string),"Well01-%s",floatString);

  delay(100);
  flag = BLE.writeLocalAttribute(3, broadcast_string);
  USB.println(F("\tC - Setting data"));


 // aux = BLE.setDiscoverableMode(BLE_GAP_USER_DATA);
  aux = BLE.setDiscoverableMode(BLE_GAP_GENERAL_DISCOVERABLE);
  //BLE.setConnectableMode(BLE_GAP_NON_CONNECTABLE);
  BLE.setConnectableMode(BLE_GAP_UNDIRECTED_CONNECTABLE);
  USB.println(F("\tD - Start advertisements"));

  // 1.5 Go to sleep and but remain advertising to save power.
  BLE.sleep();

  // 1.7 Wait for 10 seconds
  delay(20000);
  //aux = BLE.wakeUp();
 
  USB.println();

}



