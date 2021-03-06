/*  
 *  -----------  3G_07 - Sending SMS  ------------ 
 *  
 *  Explanation: This example shows how to send a SMS.
 *  
 *  Copyright (C) 2014 Libelium Comunicaciones Distribuidas S.L. 
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
 *  Version:           1.1
 *  Design:            David Gascón 
 *  Implementation:    Alejandro Gállego
 */

#include "Wasp3G.h"

int8_t answer;
char text_message[]="This is a test message from Waspmote!";

void setup()
{
    // setup for Serial port over USB:
    USB.ON();
    USB.println(F("USB port started..."));

    // 1. activates the 3G module:
    answer = _3G.ON();
    if ((answer == 1) || (answer == -3))
    {
        USB.println(F("3G module ready..."));

        // 2. sets pin code:
        USB.println(F("Setting PIN code..."));
        // **** must be substituted by the SIM code
        if (_3G.setPIN("****") == 1) 
        {
            USB.println(F("PIN code accepted"));
        }
        else
        {
            USB.println(F("PIN code incorrect"));
        }

        // 3. waits for connection to the network
        answer = _3G.check(180);    
        if (answer == 1)
        { 
            USB.println(F("3G module connected to the network..."));
            // ********* should be replaced by the desired tlfn number
            // 4. sends an SMS
            answer = _3G.sendSMS(text_message,"*********");
            if ( answer == 1) 
            {
                USB.println(F("SMS Sent OK")); 
            }
            else if (answer == 0)
            {
                USB.println(F("Error sending sms"));
            }
            else
            {
                USB.println(F("Error sending sms")); 
                USB.print(F("CMS error code:")); 
                USB.println(answer, DEC);
                USB.print(F("CMS error code: "));
                USB.println(_3G.CME_CMS_code, DEC);
            }
        }
        else
        {
            USB.println(F("3G module cannot connect to the network..."));
        }
    }
    else
    {
        // Problem with the communication with the 3G module
        USB.println(F("3G module not started"));
    }    

    // 5. powers off the 3G module
    _3G.OFF();


}

void loop()
{

}


