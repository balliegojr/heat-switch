import RPi.GPIO as GPIO
from lib_nrf24.lib_nrf24 import NRF24
import time
import spidev

radio = None

def init():
    global radio
    GPIO.setmode(GPIO.BCM)

    reading_pipe = 0x0606060606
    writing_pipe = 0x0707070707

    radio = NRF24(GPIO, spidev.SpiDev())
    radio.begin(0, 17)
    radio.setPayloadSize(32)
    radio.setChannel(0x60)

    radio.setDataRate(NRF24.BR_2MBPS)
    radio.setPALevel(NRF24.PA_MIN)
    radio.setAutoAck(True)
    radio.enableDynamicPayloads()
    radio.enableAckPayload()

    radio.openReadingPipe(0, reading_pipe)
    radio.openWritingPipe(writing_pipe)
    radio.printDetails()

    radio.startListening()


def read():
    if not radio:
        raise Exception("Not initialized")

    if radio.available(0):
        receivedMessage = []
        radio.read(receivedMessage, radio.getDynamicPayloadSize())

        string = ""
        for n in receivedMessage:
            # Decode into standard unicode set
            if (n >= 32 and n <= 126):
                string += chr(n)

        return string

    return None


def write(payload):
    if not radio:
        raise Exception("Not initialized")

    radio.stopListening()

    message = list(payload)
    radio.write(message)

    radio.startListening()
