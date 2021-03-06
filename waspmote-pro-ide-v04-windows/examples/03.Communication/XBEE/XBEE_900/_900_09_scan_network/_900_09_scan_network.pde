/*  
 *  ------   [900_09] - scan network     -------- 
 *  
 *  Explanation: This program shows how to scan the XBee's network
 *  in order to find other XBee modules. This example prints all
 *  available data within the API structures
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
 *  Version:           0.3
 *  Design:            David Gascón 
 *  Implementation:    Yuri Carmona
 */

#include <WaspXBee900.h>


void setup()
{ 
  // init USB port
  USB.ON();
  USB.println(F("900_09 example"));

  // init XBee 
  xbee900.ON(); 
  
}

void loop()
{ 
  ////////////////////////////////
  // 1. scan network
  ////////////////////////////////
  xbee900.scanNetwork(); 

  ////////////////////////////////
  // 2. print info
  ////////////////////////////////  
  USB.print(F("\n\ntotalScannedBrothers:"));
  USB.println(xbee900.totalScannedBrothers,DEC); 

  // print all scanned nodes information
  printScanInfo();

}  


/*
 *  printScanInfo
 *
 *  This function prints all info related to the scan 
 *  process given by the XBee module
 */
void printScanInfo()
{  
  USB.println(F("----------------------------"));

  for(int i=0; i<xbee900.totalScannedBrothers; i++)
  {  
    USB.print(F("MAC:"));
    USB.printHex(xbee900.scannedBrothers[i].SH[0]);	
    USB.printHex(xbee900.scannedBrothers[i].SH[1]);	
    USB.printHex(xbee900.scannedBrothers[i].SH[2]);	
    USB.printHex(xbee900.scannedBrothers[i].SH[3]);
    USB.printHex(xbee900.scannedBrothers[i].SL[0]);	
    USB.printHex(xbee900.scannedBrothers[i].SL[1]);	
    USB.printHex(xbee900.scannedBrothers[i].SL[2]);	
    USB.printHex(xbee900.scannedBrothers[i].SL[3]);

    USB.print(F("\nNI:"));
    USB.print(xbee900.scannedBrothers[i].NI);		

    USB.print(F("\nDevice Type:"));
    switch(xbee900.scannedBrothers[i].DT)
    {
    case 0: 
      USB.print(F("End Device"));
      break;
    case 1: 
      USB.print(F("Router"));
      break;
    case 2: 
      USB.print(F("Coordinator"));
      break;
    }

    USB.print(F("\nPMY:"));
    USB.printHex(xbee900.scannedBrothers[i].PMY[0]);	
    USB.printHex(xbee900.scannedBrothers[i].PMY[1]);

    USB.print(F("\nPID:"));
    USB.printHex(xbee900.scannedBrothers[i].PID[0]);	
    USB.printHex(xbee900.scannedBrothers[i].PID[1]);

    USB.print(F("\nMID:"));
    USB.printHex(xbee900.scannedBrothers[i].MID[0]);	
    USB.printHex(xbee900.scannedBrothers[i].MID[1]);
    
    USB.println(F("\n----------------------------"));

  }
}






