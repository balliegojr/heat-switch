#include <SPI.h>
#include <nRF24L01.h>
#include <RF24.h>

#include <EEPROM.h>

const int debug = 1;

const int uid_address = 0;
const uint64_t w_pipe = 0x0606060606;
const uint64_t r_pipe = 0x0707070707;

char uid[] = "0000000";
char op_mode = 'A';

const int temperatureSensorPin = 0; 
const int powerRelayPin = 10;

float upperCelciusLimit = 32.0;
float lowerCelciusLimit = 28.0;

int powerRelayStatus = LOW;
int override_relay = LOW;
int current_loop = 0;

RF24 radio(7, 8); // CE, CSN

void setup()
{
  Serial.begin(9600);

  analogReference(INTERNAL);

  pinMode(powerRelayPin, OUTPUT);
  digitalWrite(powerRelayPin, powerRelayStatus);

  if (EEPROM.read(0) == 'C')
    for (int i = 0; i<7; i++) {
      uid[i] = EEPROM.read(i);
    }
  

  radio.begin();
  radio.openReadingPipe(0, r_pipe);
  radio.openWritingPipe(w_pipe);
  radio.setPALevel(RF24_PA_MIN);
  
  radio.startListening();

  if (EEPROM.read(0) == 'C')
    initialize_config();
}

void initialize_config() {
  char command[3];
  strcpy(command, "G:_");
  send_radio(command);
}

void send_radio(char text[]) {
  if (strcmp(uid, "0000000") == 0){
    return;
  }

  if (debug == 1)
    Serial.println("Sending radio message");
  

  char package[32];
  strcpy(package, uid);
  strcat(package, ":");
  strcat(package, text);

  if (debug == 1)
    Serial.println(package);

  radio.stopListening();
  radio.write(package, 32, 0);
  radio.startListening();
}

void requestId() {
  if (debug == 1)
    Serial.println("Requesting Id");
    
  radio.stopListening();
  char request[] = "I";

  radio.write(&request, 1, 0);

  radio.startListening();
  
}

void set_info(char* info) {
  info++;
  
  switch (info[0]) {
    case 'I':
        for (int i=0; i<7; i++ ) {
            uid[i] = info[i+1];
        }

        EEPROM.put(uid_address, uid);
        initialize_config();
        break;
    case 'M':
        info++;
        op_mode = info[0];
        switch (op_mode) {
            case 'A': {
                info += 2;

                char str_upper[] = "000.0";
                char str_lower[] = "000.0";

                for (int i = 0; i < 5; ++i)
                {
                    str_upper[i] = info[i];
                    str_lower[i] = info[i+6];
                }

                upperCelciusLimit = atof(str_upper);
                lowerCelciusLimit = atof(str_lower);
                
                break;
            }
            case 'O':
                info++;
                //set override:
                if (info[0] == '1') {
                  override_relay = HIGH;
                } else {
                  override_relay = LOW;
                }

                break;
            case 'R':
                override_relay = LOW;
                override_mode();
                break;
            }

        break;
  }
}

void override_mode() {
  if (override_relay != powerRelayStatus){
    powerRelayStatus = override_relay;
    digitalWrite(powerRelayPin, powerRelayStatus);
    char status_str[4];
    if (powerRelayStatus == HIGH) {
      strcpy(status_str, "r:on");
      send_radio(status_str);
    } else {
      strcpy(status_str, "r:off");
      send_radio(status_str);
    }
  }
}

void report_mode() {
  if (current_loop % 20 != 0){
    return;
  }
  
  int temperatureC = read_temp();

  char text[32];
  sprintf(text, "t:%d", temperatureC);
  send_radio(text);
}

int read_temp() {
  int reading = analogRead(temperatureSensorPin);
  return reading / 9.31; // using 1.1v reference
  // return (5.0 * reading * 100.0) / 1024;
  
}

void automatic_mode() {
  if (current_loop % 20 != 0){
    return;
  }
  
  int temperatureC = read_temp();
 
  int newRelayStatus = powerRelayStatus;
  if (temperatureC >= upperCelciusLimit){
    newRelayStatus = LOW;
  } else if (temperatureC <= lowerCelciusLimit){
    newRelayStatus = HIGH; 
  }

  if (newRelayStatus != powerRelayStatus){
    powerRelayStatus = newRelayStatus;
    digitalWrite(powerRelayPin, powerRelayStatus);
    char status_str[4];
    if (powerRelayStatus == HIGH) {
      strcpy(status_str, "r:on");
      send_radio(status_str);
    } else {
      strcpy(status_str, "r:off");
      send_radio(status_str);
    }
 } 

 char text[32];
 sprintf(text, "t:%d", temperatureC);
 send_radio(text);
}

void process_radio_message(char* message) {
    if (debug == 1) {
      Serial.println("Received radio message: ");
      Serial.println(message);
    }
      
    for (int i=0; i < 7; i++){
        if (uid[i] != message[i]){
          return;
        }
    }

    char* command = message + 8;
    if (command[0] == 'S') {
        set_info(command);
    }
}
 
void loop()
{
  if (strcmp(uid, "0000000") == 0) {
    requestId();  
  }

  while (radio.available()) {
    if (debug==1){
      Serial.println("radio available");
    }
    char radio_info[32];
    radio.read(&radio_info, 32);
    
    process_radio_message(radio_info);
  }
  
  switch (op_mode) {
    case 'O':
      override_mode();
      break;
    case 'A':
      automatic_mode();
      break;
    case 'R':
      report_mode();    
      break;
  }

  current_loop++;
  if (current_loop == 100000){
    current_loop = 0;
  }
  delay(100);                                     
}
