#include <SPI.h>
#include <nRF24L01.h>
#include <RF24.h>

const int temperatureSensorPin = 0; 
const int powerRelayPin = 10;

const float upperCelciusLimit = 32.0;
const float lowerCelciusLimit = 28.0;

int powerRelayStatus = LOW;

RF24 radio(7, 8); // CE, CSN
const uint64_t r_pipe = 0x0606060606;
const uint64_t w_pipe = 0x0707070707;

void setup()
{
  Serial.begin(9600);
  
  radio.begin();
  radio.openReadingPipe(0, r_pipe);
  radio.openWritingPipe(w_pipe);
  radio.setPALevel(RF24_PA_MIN);
  radio.startListening();
  
  Serial.println("DEBUG: Board available");
}
 
void loop()
{
 if (radio.available()){
  char radio_info[32];
  radio.read(&radio_info, 32);

  Serial.println(radio_info);
  Serial.flush();
 }

 if (Serial.available()){
  
  char serial_info[32];
  Serial.readBytes(serial_info, 32);
  
  radio.stopListening();
  radio.write(serial_info, 32);
  radio.startListening();
 }

 delay(20);
}
