/*  
 *  ------  GPRS_SIM928A_20 - Uploading files to a FTP server  -------- 
 *  
 *  Explanation: This example shows how to upload a file to a FTP server
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
 *  Version:           0.1 
 *  Design:            David Gascón 
 *  Implementation:    Alejandro Gállego
 */

#include "WaspGPRS_SIM928A.h"

char apn[] = "apn";
char login[] = "login";
char password[] = "password";

int answer;

void setup()
{
    USB.println(F("**************************"));
    // 1. sets operator parameters
    GPRS_SIM928A.set_APN(apn, login, password);
    // And shows them
    GPRS_SIM928A.show_APN();
    USB.println(F("**************************")); 
}

void loop()
{

    // setup for Serial port over USB:
    USB.ON();
    USB.println(F("USB port started..."));

    // 2. activates the GPRS_SIM928A module:
    answer = GPRS_SIM928A.ON(); 
    if ((answer == 1) || (answer == -3))
    {
        USB.println(F("GPRS_SIM928A module ready..."));

        // 3. sets pin code:
        USB.println(F("Setting PIN code..."));
        // **** must be substituted by the SIM code
        if (GPRS_SIM928A.setPIN("****") == 1) 
        {
            USB.println(F("PIN code accepted"));
        }
        else
        {
            USB.println(F("PIN code incorrect"));
        }

        // 4. waits for connection to the network:
        answer = GPRS_SIM928A.check(180);    
        if (answer == 1)
        {
            USB.println(F("GPRS_SIM928A module connected to the network..."));

            // 5. configures GPRS Connection for HTTP or FTP applications:
            answer = GPRS_SIM928A.configureGPRS_HTTP_FTP(1);
            if (answer == 1)
            {

                USB.println(F("Uploading the file 1..."));

                // 6a. uploads file from SD card to the FTP server:
                answer = GPRS_SIM928A.uploadFile("/dirSD1/dirSD2/fileSD1.txt", "/ftp1/ftp2/fileFTP1.txt", "username", "password", "IP_server", "port", 1);
                
                // checks the answer
                if (answer == 1)
                {
                    USB.println(F("Upload done"));
                }
                else if(answer < -40)
                {
                    USB.print(F("Upload failed. Error code: "));
                    USB.println(answer, DEC);
                    USB.print(F("CME error code: "));
                    USB.println(GPRS_SIM928A.CME_CMS_code, DEC);
                }
                else 
                {
                    USB.print(F("Upload failed1. Error code: "));
                    USB.println(answer, DEC);
                }

                USB.println(F("Uploading the file 2"));

                // 6b. uploads file from SD card to the FTP server:
                answer = GPRS_SIM928A.uploadFile("/fileSD2.txt", "/fileFTP2.txt", "username", "password", "IP_server", "port", 1);
                
                // checks the answer
                if (answer == 1)
                {
                    USB.println(F("Upload done"));
                }
                else if (answer < -40)
                {
                    USB.print(F("Upload failed. Error code: "));
                    USB.println(answer, DEC);
                    USB.print(F("CME error code: "));
                    USB.println(GPRS_SIM928A.CME_CMS_code, DEC);
                }
                else 
                {
                    USB.print(F("Upload failed. Error code: "));
                    USB.println(answer, DEC);
                }
            }
            else
            {
                USB.println(F("Configuration failed. Error code:"));
                USB.println(answer, DEC);
            }
        }
        else
        {
            USB.println(F("GPRS_SIM928A module cannot connect to the network"));     
        }
    }
    else
    {
        USB.println(F("GPRS_SIM928A module not ready"));    
    }
    
    // 7. powers off the GPRS_SIM928A module
    GPRS_SIM928A.OFF(); 

    USB.println(F("Sleeping..."));

    // 8. sleeps one hour
    PWR.deepSleep("00:01:00:00", RTC_OFFSET, RTC_ALM1_MODE1, ALL_OFF);

}

