# HEAT SWITCH #

This is a project created for the IOT course that I'm atteding to  
The ideia of the project, is to watch and control the temperature of a controlled environment for pets. With this project, it is possible to control several environments at the same time.

## Setup ##

![alt text](https://github.com/balliegojr/heat-switch/blob/master/heat-switch-nrf_bb.jpg "Fritizzing project")

### Arduino Nano ###
- LM35 (Reading temperature)
- nRF24L01 (Radio communication with Raspberry)
- Relay Module (control the heating system)
- [Optional] Power source module

The Arduino nano is responsible for reading the temperature and turn the heating on and off. In the schematics, it has a power source module, so you don't need to use a battery for it.

#### Behavior ####
It is possible to set the arduino to 3 different operation modes:
- Automatic: Read and report temperatures, if it is above a given threshold (default to 30 degress celcius), it turns off the Relay, if it is bellow a given threshold (default to 28 degress celcius), it turns the relay on  
- Report: In this mode, it will only report the temperature at a default interval (10 seconds)  
- Override: In this mode, it is possible to manually overrid the relay to on or off


### Raspberry ###
- nRF24L01 (Radio communication with Arduino nodes)

The Raspberry is gateway between the server and the sensor nodes. It communicates through radio with arduino nodes and through MQTT with the server.
There are two possible setups, use the radio module directly into GPIO pins or connect the radio module to an arduino and use serial communication with any computer.


## Server ##

The server is an application written in Elixir and PhoenixFramework, the user can register his nodes from the website  
- https://elixir-lang.org
- http://phoenixframework.org
- [hulaaki MQTT client](https://github.com/suvash/hulaaki)