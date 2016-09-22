#include <MS5803_14.h>
#include <SPI.h>
#include <SoftwareSerial.h>
#include <Wire.h>

// ***************LED LIGHTS***************************//
#define REDPIN 10
#define GREENPIN 5
#define BLUEPIN 6

// ***************FLOWMETER***************************//
volatile int FLOW_PULSE;
int Calc;
int FLOWPIN = 2;
float pulsesAux;


// ***************PRESURE VERSION 1*****************************//
//MS5803 sensor(ADDRESS_HIGH);

float temperature_c, temperature_f;
double pressure_abs, pressure_relative, altitude_delta, pressure_baseline;
float atmPressure = 100800;
float rho = 1000.0; // units: kg/m^3
float g = 9.8; // units: m/s^2
float currentPressure;
float PressureTemp;


// ***************PRESURE*****************************//
const int DevAddress = 0x76;  // 7-bit I2C address of the MS5803

// Here are the commands that can be sent to the 5803
const byte Reset = 0x1E;
const byte D1_256 = 0x40;
const byte D1_512 = 0x42;
const byte D1_1024 = 0x44;
const byte D1_2048 = 0x46;
const byte D1_4096 = 0x48;
const byte D2_256 = 0x50;
const byte D2_512 = 0x52;
const byte D2_1024 = 0x54;
const byte D2_2048 = 0x56;
const byte D2_4096 = 0x58;
const byte AdcRead = 0x00;

const byte PromBaseAddress = 0xA0;
unsigned int CalConstant[8];  // Matrix for holding calibration constants
long AdcTemperature, AdcPressure;  // Holds raw ADC data for temperature and pressure
float Temperature, Pressure, TempDifference, Offset, Sensitivity, PTemp;
float T2, Off2, Sens2;  // Offsets for second-order temperature computation
float depth = 0.0f;
float depthft = 0.0f;
byte ByteHigh, ByteMiddle, ByteLow;  // Variables for I2C reads


float depth1 = 0.0f;
float depthft1 = 0.0f;
/************************************************************************/

/**************************** TIMER**************************************/
//long t1000ms = 0;
long t1000ms = 0;
//long t3000ms = 0;
//long t4000ms = 0;
long t15000ms = 0;
long t1 = 0;

int light_cmd = 0;
boolean light_state_on = false;

void setup() {
  //put your setup code here, to run once:

  Serial.begin(9600);
  setup_pressure();
  pinMode(FLOWPIN, INPUT);
  attachInterrupt(0, rpm, RISING);

  // light
  pinMode (REDPIN, OUTPUT);
  pinMode (GREENPIN, OUTPUT);
  pinMode (BLUEPIN, OUTPUT);

  // start interuppt
  sei();
}

void loop() {
  // put your main code here, to run repeatedly:

  if (millis() - t1000ms >= 1000) {  
    calc_pressure();
    calculate_flow();
    t1000ms = millis();
  }

  if (millis() - t15000ms >= 10000) {
    //lights();
    if (Serial.available()) {
      light_cmd = Serial.read() - '0';
    }
    if (light_cmd == 1){
      light_state_on = true;
      lights();
    }
    else if (light_cmd == 2 && light_state_on == true){
      light_state_on = false;
      analogWrite(REDPIN, 0); analogWrite(GREENPIN, 0); analogWrite(BLUEPIN, 0);   
    }
    t15000ms = millis();
  }

}

void setup_pressure() {
  delay(1000);
  Wire.begin();
  delay(10);
  delay(1000);

  sendCommand(Reset);
  delay(10);
  delay(1000);

  for (byte i = 0; i < 8; i++)
  {
    sendCommand(PromBaseAddress + (2 * i));
    Wire.requestFrom(DevAddress, 2);
    while (Wire.available()) {
      ByteHigh = Wire.read();
      ByteLow = Wire.read();
    }
    CalConstant[i] = (((unsigned int)ByteHigh << 8) + ByteLow);
  }

}

void calculate_flow() {
  cli();
  pulsesAux = FLOW_PULSE;
  Calc = (pulsesAux * 60 / 7.5);
  //Calc = 0;
  sei();
  FLOW_PULSE = 0;
  
  Serial.print("flow:");
  Serial.print(Calc, DEC);
  Serial.print(":");
}

void rpm() {
  FLOW_PULSE++;
}

void lights() {
  //depthft = 4;
    //Serial.print("11:");
  if (depthft <= 1.5) {
    //Serial.print("1:");
    if (Calc <= 0) {
      //Serial.print("2");
      analogWrite(REDPIN, 0); analogWrite(GREENPIN, 255); analogWrite(BLUEPIN, 0);
    }
    if (Calc > 0) {
      analogWrite(REDPIN, 255); analogWrite(GREENPIN, 0); analogWrite(BLUEPIN, 255);
      //delay(30000);
    }
  }
  if (depthft > 1.5 && depthft <= 3) {
    if (Calc <= 0) {
      analogWrite(REDPIN, 0); analogWrite(GREENPIN, 255); analogWrite(BLUEPIN,255);
    }
    if (Calc > 0) {
      analogWrite(REDPIN, 255); analogWrite(GREENPIN, 0); analogWrite(BLUEPIN, 255);
    }
  }
  if (depthft > 3) {
    if (Calc <= 0) {
      analogWrite(REDPIN, 128); analogWrite(GREENPIN, 0); analogWrite(BLUEPIN, 255);
    }
    if (Calc > 0) {
      analogWrite(REDPIN, 255); analogWrite(GREENPIN, 0); analogWrite(BLUEPIN, 255);
    }
  }
}

void calc_pressure() {

  sendCommand(D1_4096);
  delay(10);
  sendCommand(AdcRead);
  Wire.requestFrom(DevAddress, 3);
  while (Wire.available())
  {
    ByteHigh = Wire.read();
    ByteMiddle = Wire.read();
    ByteLow = Wire.read();
  }
  AdcPressure = ((long)ByteHigh << 16) + ((long)ByteMiddle << 8) + (long)ByteLow;
  
  // dummy code for testing
  //currentPressure = (AdcPressure/10000) * 100;
  //depth1 = (currentPressure - atmPressure) / (rho * g);
  //depthft1 = depth * 3.28;
  sendCommand(D2_4096);
  delay(10);
  sendCommand(AdcRead);
  Wire.requestFrom(DevAddress, 3);
  while (Wire.available())
  {
    ByteHigh = Wire.read();
    ByteMiddle = Wire.read();
    ByteLow = Wire.read();
  }
  AdcTemperature = ((long)ByteHigh << 16) + ((long)ByteMiddle << 8) + (long)ByteLow;
  
  //Calculate the Temperature (first-order computation)
  TempDifference = (float)(AdcTemperature - ((long)CalConstant[5] << 8));
  Temperature = (TempDifference * (float)CalConstant[6]) / pow(2, 23);
  Temperature = Temperature + 2000;  // This is the temperature in hundredths of a degree C

  // Calculate the second-order offsets
  if (Temperature < 2000.0)  // Is temperature below or above 20.00 deg C ?
  {
    T2 = 3 * pow(TempDifference, 2) / pow(2, 33);
    Off2 = 1.5 * pow((Temperature - 2000.0), 2);
    Sens2 = 0.625 * pow((Temperature - 2000.0), 2);
  }
  else
  {
    T2 = (TempDifference * TempDifference) * 7 / pow(2, 37);
    Off2 = 0.0625 * pow((Temperature - 2000.0), 2);
    Sens2 = 0.0;
  }

  // Print the temperature results
  Temperature = Temperature / 100;  // Convert to degrees C

  // Calculate the pressure parameters
  Offset = (float)CalConstant[2] * pow(2, 16);
  Offset = Offset + ((float)CalConstant[4] * TempDifference / pow(2, 7));
  Sensitivity = (float)CalConstant[1] * pow(2, 15);
  Sensitivity = Sensitivity + ((float)CalConstant[3] * TempDifference / pow(2, 8));

  // Add second-order corrections
  Offset = Offset - Off2;
  Sensitivity = Sensitivity - Sens2;

  // Calculate absolute pressure in bars
  Pressure = (float)AdcPressure * Sensitivity / pow(2, 21);
  Pressure = Pressure - Offset;
  Pressure = Pressure / pow(2, 15);
  PressureTemp = Pressure / 10;  // in millibar

  depth = (PressureTemp - 1013.25) / 100.52;
  depthft = (PressureTemp - 1013.25) / 30.64;
  //if ( depthft < 0 || depthft > 4) {
    //depthft = 0.1;
  //}

  Serial.print("Depth:");
  Serial.print(depthft);
  Serial.print(":");
  
  Pressure = Pressure / 10000; // to bar
  Pressure = Pressure - 1.015;  // Convert to gauge pressure (subtract atmospheric pressure)
  //Pressure = Pressure * 14.50377;  // Convert bars to psi

//  Serial.print("Pressure:");
//  Serial.print(PressureTemp);
//  Serial.print(":");

//  Serial.print("Temperature:");
//  Serial.print(Temperature);
//  Serial.print(":");

}

void sendCommand(byte command) {
  Wire.beginTransmission(DevAddress);
  Wire.write(command);
  Wire.endTransmission();
}


void calc_pressure1() {

  sendCommand(D1_512);
  delay(10);
  sendCommand(AdcRead);
  Wire.requestFrom(DevAddress, 3);
  while (Wire.available())
  {
    ByteHigh = Wire.read();
    ByteMiddle = Wire.read();
    ByteLow = Wire.read();
  }
  AdcPressure = ((long)ByteHigh << 16) + ((long)ByteMiddle << 8) + (long)ByteLow;
  currentPressure = AdcPressure * 100;
  depth = (currentPressure - atmPressure) / (rho * g);
  depthft = depth * 3.28;
  Serial.print("Depth is:");
  Serial.println(depth);

}

