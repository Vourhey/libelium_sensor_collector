#include <Wasp4G.h>
#include <WaspPM.h>
#include <WaspSensorGas_Pro.h>
#include <WString.cpp>
#include <Ed25519.h>
#include "secrets.h"
/*
 * P&S! Possibilities for this sensor:
 *  Wiring:
 *  - SOCKET_A : CO low concentrations probe
 *  - SOCKET_B : NO probe
 *  - SOCKET_C : SO2 probe
 *  - SOCKET_D : Particle Monitor PM-X
 *  - SOCKET_E : BME200 Temperature, humidity, pressure sensor
 *  - SOCKET_F : NC
 */
 int status;
 //http://cpham.perso.univ-pau.fr/ENSEIGNEMENT/PAU-UPPA/RESA-M2/ArduinoString/ArduinoString.html
 String data,senddata ;
 char mote_ID[] = "TLT01";
 int measure;
 
 Gas CO(SOCKET_A);
 Gas NO(SOCKET_B);
 Gas SO2(SOCKET_C);
 bmeGasesSensor  bme;

// SERVER settings
///////////////////////////////////////
char host[] = "188.127.231.136";
uint16_t remote_port = 8888;
///////////////////////////////////////
uint8_t connId = Wasp4G::CONNECTION_1;
///////////////////////////////////////

uint8_t signature[64];
char hex_signature[128];
uint8_t* privateKey = signing_key;  // from "secrets.h"
uint8_t* publicKey = verifying_key; // from "secrets.h"

 void setup()
 {
 }


 void loop()
 {
        RTC.ON();
     USB.println();
     senddata = "{\"DATA\":";
     
     data = "{\"ID\":\"";
     data += mote_ID;
     data += "\",\"TIME\":\"";
     data += RTC.getTime();
     data += "\",\"BAT\":\"" ;
     data += PWR.getBatteryLevel();
     data += "\"," ;
     
   CO.ON();
   if (CO.getConc() != 0){
   data += "\"CO\":\"";
   data += CO.getConc();
   data += "\",";
   }
   CO.OFF();
   NO.ON();
   if (NO.getConc() != 0){
   data += "\"NO\":\"";
   data += NO.getConc();
   data += "\",";
   }
   NO.OFF();
   SO2.ON();  
   if (SO2.getConc() != 0){
   data += "\"SO2\":\"";
   data += SO2.getConc();
   data += "\",";
   }
   SO2.OFF();

//   bme.ON();
//   data += "\"TC\":\"";
//   data += bme.getTemperature();
//   data += "\",";
//   data += "\"HUM\":\"";
//   data += bme.getHumidity();
//   data += "\",\"PRE\":\"";
//   data += bme.getPressure();
//   data += "\",";
//   bme.OFF();
   
   // Power on the PM sensor
   status = PM.ON();
   ///////////////////////////////////////////
   // 2. Read the PM sensor
   ///////////////////////////////////////////
   if (status == 1)
   {
     // Power the fan and the laser and perform a measure of 5 seconds
     measure = PM.getPM(5000, 5000);
     // check answer
     if (measure == 1)
     {
       data += "\"pm\":{\"1.0\":\"";
       data += PM._PM1;
       data += "\",\"2.5\":\"";
       data += PM._PM2_5;
       data += "\",\"10\":\"";
       data += PM._PM10;
       data += "\"}";
     }
     else
     {
       data += "{\"pm\":\"";
       data += measure;
       data += " err\"}";
     }
   }
   else
   {
     data += "{\"pm\":\"err\"}";
   }
   
   data += "}";
  
   PM.OFF();

 senddata += data;
   senddata += ",";
   char datach[data.length()+1];
   data.toCharArray(datach, data.length()+1);
   Ed25519::sign(signature, privateKey, publicKey, datach, data.length());
     // 64 byte signature in hex (128 chars)
  for(uint8_t i = 0; i < 64; ++i)
    sprintf(hex_signature + 2*i, "%02X", signature[i]);

   senddata += "\"SIGNHEX\":\"";
   senddata += (char*)hex_signature;
   senddata += "\"}";
   senddata += "\n";
   
   USB.println((const char*)&senddata[0]);
   
  _4G.ON();
  _4G.openSocketClient(connId, Wasp4G::TCP, host, remote_port);
  _4G.send(connId, (char*)&senddata[0]);
  _4G.closeSocketClient(connId);
  _4G.OFF();
   
  PWR.deepSleep("00:00:00:10", RTC_OFFSET, RTC_ALM1_MODE1, ALL_OFF);
 }
