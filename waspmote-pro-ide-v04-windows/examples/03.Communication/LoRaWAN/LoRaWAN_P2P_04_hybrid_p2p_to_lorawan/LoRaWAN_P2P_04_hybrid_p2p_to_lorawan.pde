/*  
 *  ------ P2P Code Example -------- 
 *  
 *  Explanation: This example shows how to configure the module
 *  for P2P mode and LoRaWAN mode too. In this code, the Waspmote
 *  waits for new incoming P2P packets. Then routes the information
 *  received to the LoRaWAN gateway.
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
 *  Design:            David Gascon
 *  Implementation:    Luismi Marti
 */

#include <WaspLoRaWAN.h>

//////////////////////////////////////////////
uint8_t socket = SOCKET0;
//////////////////////////////////////////////

// define radio settings (P2P interface)
//////////////////////////////////////////////
uint8_t power = 15;
uint32_t frequency = 868100000;
char spreading_factor[] = "sf12";
char coding_rate[] = "4/5";
uint16_t bandwidth = 125;
char crc_mode[] = "on";
//////////////////////////////////////////////


// Define LoRaWAN settings (LoRaWAN interface)
////////////////////////////////////////////////////////////
uint8_t PORT = 3;
char DEVICE_EUI[]  = "0102030405060708";
char DEVICE_ADDR[] = "05060708";
char NWK_SESSION_KEY[] = "01020304050607080910111213141516";
char APP_SESSION_KEY[] = "000102030405060708090A0B0C0D0E0F";
////////////////////////////////////////////////////////////

// define
char packet[512];

// variable
uint8_t error;



void setup() 
{
  USB.ON();
  USB.println(F("P2P to LoRaWAN gateway\n"));


  // module setup
  error = lorawanModuleSetup();

  // Check status
  if (error == 0)
  {
    USB.println(F("LoRaWAN interface configured OK"));     
  }
  else 
  {
    USB.println(F("LoRaWAN interface configured ERROR"));     
  }  


  // module setup
  error = radioModuleSetup();

  // Check status
  if (error == 0)
  {
    USB.println(F("Radio interface configured OK"));     
  }
  else 
  {
    USB.println(F("Radio interface configured ERROR"));     
  }
  USB.println();

}


void loop() 
{

  USB.println(F("\n-------------------------------------------------------"));
  USB.println(F("Listening to packets:"));
  USB.println(F("-------------------------------------------------------"));

  // Set receive mode 
  error = LoRaWAN.receiveRadio(10000);

  // Check status
  if (error == 0)
  {
    USB.println(F("--> Packet received"));
    
    USB.print(F("data: "));
    USB.println((char*) LoRaWAN._buffer);
    
    USB.print(F("length: "));
    USB.println(LoRaWAN._length);
        
    // copy packet contents into a global buffer
    strncpy( packet, (char*) LoRaWAN._buffer, sizeof(packet));
    
    USB.println(F("\n-------------------------------------------------------"));
    USB.println(F("Route data to LoRaWAN gateway:"));
    USB.println(F("-------------------------------------------------------"));


    // switch to LoRaWAN mode
    LoRaWAN.macResume();


    // join 
    error = LoRaWAN.joinABP();

    // Check status
    if( error == 0 ) 
    {
      USB.println(F("Join network OK"));     
    }
    else 
    {
      USB.print(F("Join network error = ")); 
      USB.println(error, DEC);
    }


    // send received packet to LoRaWAN gateway
    error = LoRaWAN.sendConfirmed( PORT, packet);

    // Check status
    if( error == 0 ) 
    {
      USB.println(F("Send Confirmed packet OK"));     
    }
    else 
    {
      USB.print(F("Send Confirmed packet error = ")); 
      USB.println(error, DEC);
    }


    // module setup
    error = radioModuleSetup();

    // Check status
    if (error == 0)
    {
      USB.println(F("Radio interface configured OK"));     
    }
    else 
    {
      USB.println(F("Radio interface configured ERROR"));     
    }
    USB.println(); 

  }
  else 
  {
    // error code
    //  1: error
    //  2: no incoming packet
    USB.print(F("Error waiting for packets. error = "));  
    USB.println(error, DEC);   
  }  
}




/***********************************************************************************
 *
 * radioModuleSetup()
 *
 *   This function includes all functions related to the module setup and configuration
 *   The user must keep in mind that each time the module powers on, all settings are set
 *   to default values. So it is better to develop a specific function including all steps
 *   for setup and call it everytime the module powers on.
 *
 *
 ***********************************************************************************/
uint8_t radioModuleSetup()
{ 

  uint8_t status = 0;
  uint8_t e = 0;

  USB.println(F("\n-------------------------------------------------------"));
  USB.println(F("P2P mode configuration:"));
  USB.println(F("-------------------------------------------------------"));

  //////////////////////////////////////////////
  // 1. switch on
  //////////////////////////////////////////////

  e = LoRaWAN.ON(socket);

  // Check status
  if (e == 0)
  {
    USB.println(F("1. Switch ON OK"));     
  }
  else 
  {
    USB.print(F("1. Switch ON error = ")); 
    USB.println(e, DEC);
    status = 1;
  }


  //////////////////////////////////////////////
  // 2. Enable P2P mode
  //////////////////////////////////////////////

  e = LoRaWAN.macPause();

  // Check status
  if (e == 0)
  {
    USB.println(F("2. P2P mode enabled OK"));
  }
  else 
  {
    USB.print(F("2. Enable P2P mode error = "));
    USB.println(e, DEC);
    status = 1;
  }



  //////////////////////////////////////////////
  // 3. Set/Get Radio Power
  //////////////////////////////////////////////

  // Set power
  e = LoRaWAN.setRadioPower(power);

  // Check status
  if (e == 0)
  {
    USB.println(F("3.1. Set Radio Power OK"));
  }
  else 
  {
    USB.print(F("3.1. Set Radio Power error = "));
    USB.println(e, DEC);
    status = 1;
  }

  // Get power
  e = LoRaWAN.getRadioPower();

  // Check status
  if (e == 0) 
  {
    USB.print(F("3.2. Get Radio Power OK. ")); 
    USB.print(F("Power: "));
    USB.println(LoRaWAN._radioPower);
  }
  else 
  {
    USB.print(F("3.2. Get Radio Power error = ")); 
    USB.println(e, DEC);
    status = 1;
  }



  //////////////////////////////////////////////
  // 4. Set/Get Radio Frequency
  //////////////////////////////////////////////

  // Set frequency
  e = LoRaWAN.setRadioFreq(frequency);

  // Check status
  if (e == 0)
  {
    USB.println(F("4.1. Set Radio Frequency OK"));
  }
  else 
  {
    USB.print(F("4.1. Set Radio Frequency error = "));
    USB.println(e, DEC);
    status = 1;
  }

  // Get frequency
  e = LoRaWAN.getRadioFreq();

  // Check status
  if (e == 0) 
  {
    USB.print(F("4.2. Get Radio Frequency OK. ")); 
    USB.print(F("Frequency: "));
    USB.println(LoRaWAN._radioFreq);
  }
  else 
  {
    USB.print(F("4.2. Get Radio Frequency error = ")); 
    USB.println(e, DEC);
    status = 1;
  }


  //////////////////////////////////////////////
  // 5. Set/Get Radio Spreading Factor (SF)
  //////////////////////////////////////////////

  // Set SF
  e = LoRaWAN.setRadioSF(spreading_factor);

  // Check status
  if (e == 0)
  {
    USB.println(F("5.1. Set Radio SF OK"));
  }
  else 
  {
    USB.print(F("5.1. Set Radio SF error = "));
    USB.println(e, DEC);
    status = 1;
  }

  // Get SF
  e = LoRaWAN.getRadioSF();

  // Check status
  if (e == 0) 
  {
    USB.print(F("5.2. Get Radio SF OK. ")); 
    USB.print(F("Spreading Factor: "));
    USB.println(LoRaWAN._radioSF);
  }
  else 
  {
    USB.print(F("5.2. Get Radio SF error = ")); 
    USB.println(e, DEC);
    status = 1;
  }



  //////////////////////////////////////////////
  // 6. Set/Get Radio Coding Rate (CR)
  //////////////////////////////////////////////

  // Set CR
  e = LoRaWAN.setRadioCR(coding_rate);

  // Check status
  if (e == 0)
  {
    USB.println(F("6.1. Set Radio CR OK"));
  }
  else 
  {
    USB.print(F("6.1. Set Radio CR error = "));
    USB.println(e, DEC);
    status = 1;
  }

  // Get CR
  e = LoRaWAN.getRadioCR();

  // Check status
  if (e == 0) 
  {
    USB.print(F("6.2. Get Radio CR OK. ")); 
    USB.print(F("Coding Rate: "));
    USB.println(LoRaWAN._radioCR);
  }
  else 
  {
    USB.print(F("6.2. Get Radio CR error = ")); 
    USB.println(e, DEC);
    status = 1;
  }


  //////////////////////////////////////////////
  // 7. Set/Get Radio Bandwidth (BW)
  //////////////////////////////////////////////

  // Set BW
  e = LoRaWAN.setRadioBW(bandwidth);

  // Check status
  if (e == 0)
  {
    USB.println(F("7.1. Set Radio BW OK"));
  }
  else 
  {
    USB.print(F("7.1. Set Radio BW error = "));
    USB.println(e, DEC);
  }

  // Get BW
  e = LoRaWAN.getRadioBW();

  // Check status
  if (e == 0) 
  {
    USB.print(F("7.2. Get Radio BW OK. ")); 
    USB.print(F("Bandwidth: "));
    USB.println(LoRaWAN._radioBW);
  }
  else 
  {
    USB.print(F("7.2. Get Radio BW error = ")); 
    USB.println(e, DEC);
    status = 1;
  }


  //////////////////////////////////////////////
  // 8. Set/Get Radio CRC mode
  //////////////////////////////////////////////

  // Set CRC
  e = LoRaWAN.setRadioCRC(crc_mode);

  // Check status
  if (e == 0)
  {
    USB.println(F("8.1. Set Radio CRC mode OK"));
  }
  else 
  {
    USB.print(F("8.1. Set Radio CRC mode error = "));
    USB.println(e, DEC);
    status = 1;
  }

  // Get CRC
  e = LoRaWAN.getRadioCRC();

  // Check status
  if (e == 0) 
  {
    USB.print(F("8.2. Get Radio CRC mode OK. ")); 
    USB.print(F("CRC status: "));
    USB.println(LoRaWAN._crcStatus);
  }
  else 
  {
    USB.print(F("8.2. Get Radio CRC mode error = ")); 
    USB.println(e, DEC);
    status = 1;
  }
  USB.println(F("-------------------------------------------------------"));


  return status;
}










/***********************************************************************************
 *
 * lorawanModuleSetup()
 *
 *   This function includes all functions related to the module setup for LoRaWAN
 *   performance.
 *
 *
 ***********************************************************************************/
uint8_t lorawanModuleSetup()
{ 

  uint8_t status = 0;
  uint8_t e = 0;


  USB.println(F("\n-------------------------------------------------------"));
  USB.println(F("LoRaWAN mode configuration:"));
  USB.println(F("-------------------------------------------------------"));

  //////////////////////////////////////////////
  // 1. Switch on
  //////////////////////////////////////////////

  e = LoRaWAN.ON(socket);

  // Check status
  if( e == 0 ) 
  {
    USB.println(F("1. Switch ON OK"));     
  }
  else 
  {
    USB.print(F("1. Switch ON error = ")); 
    USB.println(e, DEC);
    status = 1;
  }

  LoRaWAN.factoryReset();

  //////////////////////////////////////////////
  // 2. Set Device EUI
  //////////////////////////////////////////////

  e = LoRaWAN.setDeviceEUI(DEVICE_EUI);

  // Check status
  if( e == 0 ) 
  {
    USB.println(F("2.1. Device EUI set OK"));     
  }
  else 
  {
    USB.print(F("2.1. Device EUI set error = ")); 
    USB.println(e, DEC);
    status = 1;
  }


  e = LoRaWAN.getDeviceEUI();

  // Check status
  if( e == 0 ) 
  {
    USB.print(F("2.2. Device EUI get OK. "));   
    USB.print(F("Device EUI: "));
    USB.println(LoRaWAN._devEUI);    
  }
  else 
  {
    USB.print(F("2.2. Device EUI get error = ")); 
    USB.println(e, DEC);
    status = 1;
  }


  //////////////////////////////////////////////
  // 3. Set Device Address
  //////////////////////////////////////////////

  e = LoRaWAN.setDeviceAddr(DEVICE_ADDR);

  // Check status
  if( e == 0 ) 
  {
    USB.println(F("3.1. Device address set OK"));     
  }
  else 
  {
    USB.print(F("3.1. Device address set error = ")); 
    USB.println(e, DEC);
    status = 1;
  }

  e = LoRaWAN.getDeviceAddr();

  // Check status
  if( e == 0 ) 
  {
    USB.print(F("3.2. Device address get OK. "));   
    USB.print(F("Device address: "));
    USB.println(LoRaWAN._devAddr);    
  }
  else 
  {
    USB.print(F("3.2. Device address get error = ")); 
    USB.println(e, DEC);
    status = 1;
  }



  //////////////////////////////////////////////
  // 4. Set Network Session Key
  //////////////////////////////////////////////

  error = LoRaWAN.setNwkSessionKey(NWK_SESSION_KEY);

  // Check status
  if( error == 0 ) 
  {
    USB.println(F("4. Network Session Key set OK"));     
  }
  else 
  {
    USB.print(F("4. Network Session Key set error = ")); 
    USB.println(error, DEC);
    status = 1;
  }


  //////////////////////////////////////////////
  // 5. Set Application Session Key
  //////////////////////////////////////////////

  error = LoRaWAN.setAppSessionKey(APP_SESSION_KEY);

  // Check status
  if( error == 0 ) 
  {
    USB.println(F("5. Application Session Key set OK"));     
  }
  else 
  {
    USB.print(F("5. Application Session Key set error = ")); 
    USB.println(error, DEC);
    status = 1;
  }


  //////////////////////////////////////////////
  // 6. Save configuration
  //////////////////////////////////////////////

  error = LoRaWAN.saveConfig();

  // Check status
  if( error == 0 ) 
  {
    USB.println(F("6. Save configuration OK"));     
  }
  else 
  {
    USB.print(F("6. Save configuration error = ")); 
    USB.println(error, DEC);
    status = 1;
  }

  USB.println(F("-------------------------------------------------------"));

  return status;
}













