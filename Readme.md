# Readme
PixPilot is a nice telemetry screen (and maybe a GCS replacement?) for Taranis Radios running OpenTX >=2.2.
It works with PX4 (Pixhawk, Fixhawk, AUAV-X2, PixRacer etc.) flight controllers once my [relevant pull request](https://github.com/PX4/Firmware/pull/4361) has been tested and fully implemented, and requires a FrSky X-Receiver (SPort).

Support for Arducopter will be added once they have implemented [the relevant PR](https://github.com/ArduPilot/ardupilot/issues/1587).

Thanks to ilihack, SockEye, Richardoe, Schicksie, lichtl, ben_&Jace25, Clooney82&fnoopdogg for their previous work.

## Changelog:

**STILL HEAVLILY WIP**

This will make use of [my new implementation of the frsky sport telemetry driver in PX4](https://github.com/PX4/Firmware/pull/4361), as well as https://github.com/opentx/opentx/pull/3326 and https://github.com/opentx/opentx/pull/3426 which makes passing through of any kind of 4 byte data via the sensor addresses 0x5000 - 0x50ff to lua (downstream), as well as pushing packets upstream via lua possible.


## Flight controller S-port Setup (X-Receiver)
1. Buy a RS232 TTL level converter (not need to be a FrSky, a cheaper one like the MAX3232CSE also works fine & is better to solder) 
2. Buy the FrSky SPC cable - but its only one normal diode, you could solder the diode directly to the RS 232 TTL converter like https://goo.gl/y9XCq8 instead
3. Make sure you have everything wired up like this (but connect the cable to Serial 4/5 instead): ![Wiring for X-Type Receivers](http://ardupilot.org/copter/_images/Telemetry_FrSky_Pixhawk-SPORT.jpg)
4. To start the `frsky_telemetry driver` on the Pixhawk SERIAL5 on startup, create a file called `/etc/extras.txt` on your SD card with the following contents:

 ```
# Start FrSky telemetry on SERIAL4 (ttyS6, designated "SERIAL4/5" on the case)
frsky_telemetry start -d /dev/ttyS6
```

**If you have an older FMUv1 board, change `/dev/ttyS6` to `/dev/ttyS2`**


## Taranis Setup OpenTX 2.2.0 or newer
1. Make sure you have LUA-Scripting enabled in companion
2. Download the scripts folder from here and copy to the SD card root
3. Optional: Edit with a txt Editor the Downloaded Script to Change the Setup to you own Wishes
3. Start your Taranis, go into your desired Model Settings by short pressing the Menu button
4. Navigate to the last Page by long pressing the page button
5. Delete all Sensors
6. Discovery new Sensors
7. There will be a lot of sensors listed depending on your receiver (d8r, d4r, x8r etc.)
8. Recommend is to check if the sensors Name correct. 
9. Set PixPilot as Telemetry screen.


### Using:
Push in the Normal Taranis Screen Long the Page Button to see the PX4Pilot Telemetry screens.
If you want to reset PX4Pilot because you have a new Home Position or reset you Battery Consume or what else Push long (Menu) in the PixPilot Screen.

##Useful links
1. https://github.com/PX4/Firmware/pull/4349
2. http://copter.ardupilot.com/wiki/common-optional-hardware/common-telemetry-landingpage/common-frsky-telemetry/
3. https://github.com/opentx/opentx/pull/3326
4. https://github.com/ArduPilot/ardupilot/issues/1587

##PixPilot Script Download
https://github.com/thedevleon/PixPilot/archive/master.zip
