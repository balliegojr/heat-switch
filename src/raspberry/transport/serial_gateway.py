import serial

port = None
def init(port_name='/dev/ttyUSB0'):
    global port
    port = serial.Serial(port_name)


def read():
    if not port:
        raise Exception('Not initialized')

    content = port.readline()
    if content:
        return content.decode("utf-8")

    return None


def write(payload):
    if not port:
        raise Exception('Not initialized')

    port.write(payload.encode())