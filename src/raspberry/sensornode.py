import paho.mqtt.client as mqtt
import serial
import random
import os
import time
import sys
from uuid import getnode as get_mac
from peewee import SqliteDatabase, Model, DoesNotExist, JOIN, \
    PrimaryKeyField, FloatField, CharField, BooleanField

if True:
    import transport.serial_gateway as comm
else:
    import transport.radio as comm

broker_address="iot.eclipse.org"
topic_base = "viper"
node_id = None

_db_name = os.path.dirname(os.path.realpath(__file__)) + '/sensornode-1.0.db'
db = SqliteDatabase(_db_name)


class NodeId(Model):
    class Meta:
        database = db

    id = PrimaryKeyField()
    node_id = CharField(null=False, unique=True, max_length=100)
    node_type = CharField(null=False, max_length=50)

class SensorConfig(Model):
    class Meta:
        database = db

    id = PrimaryKeyField()
    node_id = CharField(null=False, unique=True, max_length=100)
    op_mode = CharField(null=False, max_length=1, default='A')
    relay_status = BooleanField(null=False, default=False)
    lower_boundary = FloatField(null=False, default=26.0)
    upper_boundary = FloatField(null=False, default=32.0)

def init():
    db.create_tables([NodeId, SensorConfig], safe=True)

def generate_node_id():
    return get_mac()

def get_node_id():
    try:
        node = NodeId.get(NodeId.node_type == 'node')
    except DoesNotExist:
        node = NodeId.create(
            node_id=generate_node_id(), node_type='node')
        
    return node.node_id

def generate_sensor_uid():
    return 'C' + ''.join([str(random.randint(0,9)) for n in range(6)]);

def create_sensor_info(uid):
    node_id = NodeId.create(
        node_id=uid, node_type='sensor')

    config = SensorConfig.create(node_id=uid, op_mode='A')

def set_sensor_options(uid, op_mode, relay_status=False, lower_boundary=26.0, upper_boundary=32.0):
    try:
        config = SensorConfig.get(SensorConfig.node_id == uid)
    except DoesNotExist:
        config = SensorConfig.create(node_id=uid, op_mode='A')

    config.op_mode = op_mode
    config.relay_status = relay_status
    config.lower_boundary = lower_boundary
    config.upper_boundary = upper_boundary

    config.save()
    
        

def process_content(content):
    if "DEBUG: " in content:
        return

    if ':' in content:
        uid, command, value = content.split(':')
    else:
        command = content

    if 'I' in command:
        _sensor_uid = generate_sensor_uid()
        payload = ('0000000:SI' + _sensor_uid)
        comm.write(payload)
        client.publish(f"{topic_base}/node/{node_id}/sensor/{uid}/id", f"id:{_sensor_uid};op_mode:A;lower:28.0;upper:32.0;status:0")
        create_sensor_info(_sensor_uid)
    elif 'G' in command:
        send_sensor_info(uid)
    elif command == 't':
        client.publish(f"{topic_base}/node/{node_id}/sensor/{uid}/temperature", value)
    elif command == 'r':
        client.publish(f"{topic_base}/node/{node_id}/sensor/{uid}/relay", value)


def on_message(client, userdata, message):
    topic_content = message.topic.split('/')
    if len(topic_content) == 6:
        _,_,_,_,sensor_id,topic = topic_content
        value = str(message.payload.decode("utf-8"))
        if topic == "mode":
            if value == "override relay on":
                comm.write(f"{sensor_id}:SMO1")
                set_sensor_options(sensor_id, 'O', relay_status=True)
            elif value == "override relay off":
                comm.write(f"{sensor_id}:SMO0")
                set_sensor_options(sensor_id, 'O', relay_status=False)
            elif value == "report":
                comm.write(f"{sensor_id}:SMR")
                set_sensor_options(sensor_id, 'R', relay_status=False)
            elif "automatic" in value:
                _, upper, lower = value.split(' ')
                f_upper = str(float(upper)).zfill(5)
                f_lower = str(float(lower)).zfill(5)

                comm.write(f"{sensor_id}:SMA:{f_upper}:{f_lower}")
                set_sensor_options(sensor_id, 'A', relay_status=False, lower_boundary=float(f_lower), upper_boundary=float(f_upper))

def send_sensor_info(uid):
    try:
        config = SensorConfig.get(SensorConfig.node_id == uid)
    except DoesNotExist:
        config = SensorConfig.create(node_id=uid, op_mode='A')

    time.sleep(1/10)

    if config.op_mode == 'O' and config.relay_status:
        comm.write(f"{uid}:SMO1")
    elif config.op_mode == 'O' and not config.relay_status:
        comm.write(f"{uid}:SMO0")
    elif config.op_mode == 'R':
        comm.write(f"{uid}:SMR")
    elif config.op_mode == 'A':
        f_upper = str(float(config.upper_boundary)).zfill(5)
        f_lower = str(float(config.lower_boundary)).zfill(5)

        comm.write(f"{uid}:SMA:{f_upper}:{f_lower}")

if __name__ == '__main__':
    init()

    node_id = get_node_id()

    if '--id' in sys.argv:
        print(node_id)
        exit()


    client = mqtt.Client("P1") #create new instance
    client.connect(broker_address) #connect to broker
    client.loop_start() #start the loop
    client.subscribe(f"{topic_base}/node/{node_id}/set/#")
    client.on_message=on_message #attach function to callback

    comm.init()

    while True:
        _content = comm.read()

        if _content:
            process_content(_content.replace('\\r\\n', ''))
            
                
