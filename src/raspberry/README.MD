This is the code to control the Raspberry gateway

### Install dependencies
```
pip install -r requirements.txt
```

Install spidev

```
wget https://github.com/Gadgetoid/py-spidev/archive/master.zip  
unzip master.zip  
rm master.zip  
cd py-spidev-master  
sudo python3 setup.py install # python3  
```

### Execution

To get the controller identification pass --id in the command line

```
./sensornode.py --id
```

### Serial vs Radio
The default operation mode is through serial communication, it is necessary to pass --radio to use the radio module  
NOTICE: the radio communication was not tested.

### TODO:
- Improve parameters, accept serial port name from parameters
- Test radio communication directly 