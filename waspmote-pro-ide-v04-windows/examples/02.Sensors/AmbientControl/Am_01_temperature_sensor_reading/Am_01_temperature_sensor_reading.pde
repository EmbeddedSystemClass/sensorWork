/*  
 *  ------------  [AM_01] - Temperature sensor reading  -------------- 
 *  
 *  Explanation: This is the basic code to read the temperature from the 
 *  Sensirion module
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
 *  Version:		    0.1
 *  Design:             David Gascón
 *  Implementation:     Luis Miguel Marti
 */

#include <WaspSensorAmbient.h>
#include <WaspFrame.h>

float digitalTemperature; 
char node_ID[] = "Node_01";


void setup() 
{
  USB.ON();
  USB.println(F("Temperature example"));

  // Set the Waspmote ID
  frame.setID(node_ID); 
}

void loop()
{
  ///////////////////////////////////////////
  // 1. Turn on the sensors
  /////////////////////////////////////////// 

  // Power on the temperature sensor
  SensorAmbient.setSensorMode(SENS_ON, SENS_AMBIENT_TEMPERATURE);
  delay(100);


  ///////////////////////////////////////////
  // 2. Read sensors
  ///////////////////////////////////////////  

  // Read the temperature sensor
  digitalTemperature = SensorAmbient.readValue(SENS_AMBIENT_TEMPERATURE);


  ///////////////////////////////////////////
  // 3. Turn off the sensors
  /////////////////////////////////////////// 

  // Power off the temperature sensor
  SensorAmbient.setSensorMode(SENS_OFF, SENS_AMBIENT_TEMPERATURE);


  ///////////////////////////////////////////
  // 4. Create ASCII frame
  /////////////////////////////////////////// 

  // Create new frame (ASCII)
  frame.createFrame(ASCII);

  // Add temperature
  frame.addSensor(SENSOR_TCB, digitalTemperature);

  // Show the frame
  frame.showFrame();

  //wait 2 seconds
  delay(2000);
}

