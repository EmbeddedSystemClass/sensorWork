/*  
 *  ------ [OTA_02] - OTA basic program with XBee ZigBee -------- 
 *  
 *  Explanation: This program shows how build an program which supports
 *  Over The Air Programming (OTA) using XBee modules
 *  
 *  Copyright (C) 2012 Libelium Comunicaciones Distribuidas S.L. 
 *  http://www.libelium.com 
 *  
 *  This program is free software: you can redistribute it and/or modify 
 *  it under the terms of the GNU General Public License as published by 
 *  the Free Software Foundation, either version 3 of the License, or 
 *  (at your option) any later version. 
 *  
 *  This program is distributed in the hope that it will be useful, 
 *  but WITHOUT ANY WARRANTY; without even the implied warranty of 
 *  MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the 
 *  GNU General Public License for more details. 
 *  
 *  You should have received a copy of the GNU General Public License 
 *  along with this program.  If not, see <http://www.gnu.org/licenses/>. 
 *  
 *  Version:           0.1 
 *  Design:            David Gascón 
 *  Implementation:    Yuri Carmona
 */
 


#include <WaspXBeeZB.h>

#define key_access "LIBELIUM"
#define id_mote "WASPMOTE00000001"


void setup()
{
  USB.ON();
  USB.println("OTA_02_ZB example");
  
  // Write Authentication Key to EEPROM memory
  Utils.setAuthKey(key_access);
  
  // Write Mote ID to EEPROM memory
  Utils.setID(id_mote);

  // init XBee
  xbeeZB.ON();
   
  // CheckNewProgram is mandatory in every OTA program
  xbeeZB.checkNewProgram();  

}

void loop()
{
  // Check if new data is available
  if( xbeeZB.available() )
  {
    xbeeZB.treatData();
    // Keep inside this loop while a new program is being received
    while( xbeeZB.programming_ON  && !xbeeZB.checkOtapTimeout() )
    {
      if( xbeeZB.available() )
      {
        xbeeZB.treatData();
      }
    }
  }
  
  // Blink LED1 while messages are not received
  Utils.setLED(LED1,LED_ON);
  delay(100);
  Utils.setLED(LED1,LED_OFF);
  delay(100);
    
}


