# Libelium Sensor Collector

The agent listens to a TCP socket, receives data and transfers it to Robonomics Network as a [Result](https://wiki.robonomics.network/agent_development/market_messages/#result) message.

Check out the [DApp](https://dapp.robonomics.network/#/sensors/airalab/QmbQT8cj9TJKfYVaidfShnrEX1g14yTC9bdG1XbcRX73wY/0xFfd95814A77884AfF78B7e6eAFCEbB81c3C2D765/) to see data

The sensor set includes:

* CO low concentrations probe
* NO probe
* SO2 probe
* Particle Monitor PM-X
* BME200 Temperature, humidity, pressure sensor

## Build

To build the agent's code run:

```
nix build -f release.nix
source result/setup.bash
```

To upload the [firmware](firmware/waspmote_ide) use [Waspmote IDE](http://www.libelium.com/products/waspmote/)

## Launch

By default the agent is deployed to `188.127.231.136` machine and listens to `8888` port

```
roslaunch libelium_sensor_collector agent.launch [ip:=<IP>] [port:=<PORT>]
```

