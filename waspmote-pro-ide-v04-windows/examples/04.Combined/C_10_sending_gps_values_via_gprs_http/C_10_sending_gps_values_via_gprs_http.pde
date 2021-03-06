/*  
 *  ------ [C_10] - Sending GPS values via GPRS HTTP  -------- 
 *  
 *  Explanation: THis example shows how to obtain GPS data and 
 *  send it via GPRS HTTP
 *  
 *  Copyright (C) 2015 Libelium Comunicaciones Distribuidas S.L. 
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
 *  Version:           0.2 
 *  Design:            David Gascón 
 *  Implementation:    Javier Siscart
 */

#include <WaspFrame.h>
#include <WaspGPS.h>
#include <WaspGPRS_Pro.h>


// Define GPS timeout when connecting to satellites
// this time is defined in seconds (240sec = 4minutes)
#define TIMEOUT 240

// Define status variable for GPS connection
bool status;

// Variable to store function returns
int8_t answer;

// Variable to store sleeping period. Format DD:HH:MM:SS
char sleepTime[] = "00:00:00:10"; 


void setup()
{
    // 0. Init USB port for debugging
    USB.ON();
    USB.println(F("C_10 Example"));

    // 0.1 Clear pending interruptions
    clearIntFlag();
    RTC.ON();
    RTC.clearAlarmFlag();
    RTC.OFF();


    ////////////////////////////////////////////////
    // 1. Initial message composition
    ////////////////////////////////////////////////

    // 1.1 Set mote Identifier (16-Byte max)
    frame.setID("WASPMOTE_001");	

    // 1.2 Create new ASCII frame
    frame.createFrame(ASCII);  

    // 1.3 Set frame fields (String - char*)
    frame.addSensor(SENSOR_STR, (char*) "C_10 Example");

    // 1.4 Print frame
    frame.showFrame();


    ////////////////////////////////////////////////
    // 2. Send initial message
    ////////////////////////////////////////////////

    // 2.1 Activates the GPRS_Pro module:
    if (GPRS_Pro.ON() == 1)
    {
        USB.println(F("GPRS_Pro module ready..."));

        // 2.2 Sets pin code:
        // **** must be substituted by the SIM code
        if (GPRS_Pro.setPIN("****") == 1) 
        {
            USB.println(F("PIN code accepted"));
        }
        else
        {
            USB.println(F("PIN code incorrect"));
        }

        // 2.3 Waits for connection to the network:
        if (GPRS_Pro.check(60) == 1)
        {
            USB.println(F("GPRS_Pro module connected to the network..."));

            // 2.4 Configures GPRS connection for HTTP or FTP applications:
            answer = GPRS_Pro.configureGPRS_HTTP_FTP(1);
            if (answer == 1)
            {
                USB.print(F("Getting URL..."));
                answer = GPRS_Pro.readURL(
                "pruebas.libelium.com/test-get-post.php?var1=10&var2=20&var3=30",
                frame.buffer, frame.length,1);

                // 2.5 Gets URL from the solicited URL
                if ( answer == 1)
                {
                    USB.println(F("Done"));  
                    USB.println(GPRS_Pro.buffer_GPRS);
                }
                else if (answer < -9)
                {
                    USB.print(F("Failed. Error code: "));
                    USB.println(answer, DEC);
                    USB.print(F("CME error code: "));
                    USB.println(GPRS_Pro.CME_CMS_code, DEC);
                }
                else 
                {
                    USB.print(F("Failed. Error code: "));
                    USB.println(answer, DEC);
                }

            }
            else
            {
                USB.println(F("Configuration 1 failed. Error code: "));
                USB.println(answer, DEC);
            }
        }
        else
        {
            USB.println(F("GPRS_Pro module NOT connected to the network..."));
        }
    }
    else
    {
        USB.println(F("GPRS_Pro module NOT started"));
    }

    // 2.6 powers off the GPRS_Pro module
    GPRS_Pro.OFF(); 



}

void loop()
{
    ////////////////////////////////////////////////
    // 3. Measure corresponding values
    ////////////////////////////////////////////////
    USB.println(F("Measuring sensors..."));

    // Set GPS ON  
    GPS.ON();  

    ///////////////////////////////////////////////
    // 1. Wait for GPS signal
    ///////////////////////////////////////////////
    status = GPS.waitForSignal(TIMEOUT);

    // wait for GPS signal for specific time
    if( status == true )
    {
        USB.println(F("\n----------------------"));
        USB.println(F("Connected"));
        USB.println(F("----------------------"));
    }
    else
    {
        USB.println(F("\n----------------------"));
        USB.println(F("GPS TIMEOUT. NOT connected"));
        USB.println(F("----------------------"));
    }




    ///////////////////////////////////////////////
    // 4. Message composition
    ////////////////////////////////////////////////

    // 4.1 Set mote Identifier (16-Byte max)
    frame.setID("WASPMOTE_001");	

    // 4.2 Create new frame
    frame.createFrame(ASCII);  

    // if GPS is connected then get position
    if( status == true )
    {
        // getPosition function gets all basic data 
        GPS.getPosition();   

        USB.print("Latitude (degrees):");
        USB.println(GPS.convert2Degrees(GPS.latitude, GPS.NS_indicator));
        USB.print("Longitude (degrees):");
        USB.println(GPS.convert2Degrees(GPS.longitude, GPS.EW_indicator));

        // add frame fields
        frame.addSensor(SENSOR_GPS, 
        GPS.convert2Degrees(GPS.latitude, GPS.NS_indicator),
        GPS.convert2Degrees(GPS.longitude, GPS.EW_indicator) );
    }
    else
    {    
        // add frame fields
        frame.addSensor(SENSOR_STR,"GPS not connected");
    }

    // 4.3 Print frame
    // Example: <=>\0x80\0x03#35689884#WASPMOTE_001#
    frame.showFrame();


    ////////////////////////////////////////////////
    // 5. Send message
    ////////////////////////////////////////////////

    // 5,1 Power ON GPRS_Pro module:
    if (GPRS_Pro.ON() == 1)
    {
        USB.println(F("GPRS_Pro module ready..."));

        // 5.2 Sets pin code:
        // **** must be substituted by the SIM code
        if (GPRS_Pro.setPIN("****") == 1) 
        {
            USB.println(F("PIN code accepted"));
        }
        else
        {
            USB.println(F("PIN code incorrect"));
        }

        // 5.3 Waits for connection to the network:
        if (GPRS_Pro.check(60) == 1)
        {
            USB.println(F("GPRS_Pro module connected to the network..."));
            // 5.4 Configures GPRS connection for HTTP or FTP applications:
            answer = GPRS_Pro.configureGPRS_HTTP_FTP(1);
            if (answer == 1)
            {
                USB.print(F("Getting URL..."));
                answer = GPRS_Pro.readURL(
                "pruebas.libelium.com/test-get-post.php?var1=10&var2=20&var3=30",
                frame.buffer, frame.length,1);
                // 5.5 Gets URL from the solicited URL
                if ( answer == 1)
                {
                    USB.println(F("Done"));  
                    USB.println(GPRS_Pro.buffer_GPRS);
                }
                else if (answer < -9)
                {
                    USB.print(F("Failed. Error code: "));
                    USB.println(answer, DEC);
                    USB.print(F("CME error code: "));
                    USB.println(GPRS_Pro.CME_CMS_code, DEC);
                }
                else 
                {
                    USB.print(F("Failed. Error code: "));
                    USB.println(answer, DEC);
                }

            }
            else
            {
                USB.println(F("Configuration 1 failed. Error code: "));
                USB.println(answer, DEC);
            }
        }
        else
        {
            USB.println(F("GPRS_Pro module NOT connected to the network..."));
        }
    }
    else
    {
        USB.println(F("GPRS_Pro module NOT started"));
    }

    // 5.6 powers off the GPRS_Pro module
    GPRS_Pro.OFF(); 


    ////////////////////////////////////////////////
    // 6. Entering Deep Sleep mode
    ////////////////////////////////////////////////
    USB.println(F("Going to sleep..."));
    USB.println();
    PWR.deepSleep(sleepTime, RTC_OFFSET, RTC_ALM1_MODE1, ALL_OFF);

    USB.ON();
    USB.println(F("wake"));


}






