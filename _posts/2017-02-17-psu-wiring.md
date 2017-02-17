---
layout: post
title:  "Wiring the Power Supply"
date:   2017-02-17 13:00:00 +0000
categories: oscar
---
This post discusses connecting a ATX PC power supply to our RAMPS 1.4 board.
To do this, we need the following things:

**Required:**

* RAMPS 1.4 controller kit.
* An ATX power supply, salvaged from a used computer.  Preferably with a hard switch built-in.
* A 24-pin ATX plug salvaged from an old computer motherboard.
* A 4-pin ATX auxiliary power plug salvaged from an old computer motherboard.
* Wires salvaged from an ATX power supply: 2 yellow wires, 2 black wires.
* 2-5 Wires with DuPont connectors salvaged from a computer chassis.
* Soldering iron and Solder
* Electrical tape or heat-shrink tube
* Multi-meter

**Optional:**

* Raspberry Pi
* Micro-USB type B port with power wires.

# Background

ATX power supplies are software controlled.
The hard switch on the back toggles the unit between off and standby, though it may be absent.
While in standby, the power supply only provides 5 volts of power at low amperage on a single pin.
This is used to power peripherals that wake the machine, such as keyboards or network cards.
When the computer wants to leave standby and enter full power, it signals the power supply to turn on by shorting the PS_ON connection to ground.
To get a power supply to reach fully power immediately when turned on, this connection must be shorted.

I'm choosing to repurpose a Raspberry Pi to control my Oscar over WiFi.
The 5 volt standby power should be in excess of the Raspberry Pi's needs, allowing the Pi to remain in continuous operation.
The RAMPS board includes a connector for the PS_ON pin which can be supported by firmware.
The Raspberry Pi and the Arduino will run from standby power when not in use, but will bring the supply to full power when preparing to print.

If you are interested in adding a network interface and power control to your printer, a Raspberry Pi Zero is only $5 or less, working USB WiFi adaptors are about $5 - $10, and USB OTG cables are $3 or [you can wire your own](http://makezine.com/projects/usb-otg-cable/).
Alternatively, a Raspberry Pi 3 with built-in WiFi is $35.

The Arduino power control circuitry can handle both a 9-12 volt input or 5-volt input via USB.
The RAMPS shield is configured to provide 12-volt power if no USB port is plugged in.
This is generally a good idea, but it creates a slight problem if you want to use the Arduino to control a power supply.
When the Arduino is off, the PS_ON pin will float.
This causes the power supply to rapidly turn on and off which eventually damages the supply.
To prevent this, the Arduino must be on when the power supply is in standby.
However, the only inputs are already taken: the 12-volt is connected and we can't hook something up to USB without making that port unavailable to other electronics.
We could power the Arduino directly by connecting the 5-volt standby to VCC.
Unfortunately, the power control circuitry is not designed to handle the RAMPS 12-volt connection and a 5-volt connection to VCC simultaneously.
The recommended solution from the RAMPS developers is to remove the diode that completes the 12-volt connection to the Arduino.

Fortunately, this problem won't arise when using a Raspberry Pi because the USB port powering the Arduino is connected to standby power via the Raspberry Pi.
Both devices will remain on when the power supply is in standby mode, making this configuration ideal.
Just remember not to unplug the Arduino from the Raspberry Pi while the Pi is on.
You can still remove the diode and connect standby power to VCC if you want to make the system more robust.

Please visit the [RAMPS 1.4 page](http://reprap.org/wiki/RAMPS_1.4) for more information about configuring RAMPS.

# ATX Pin-out

![Image of ATX pin-out](/images/{{ page.date | date: "%Y-%m-%d" }}/atx-24-pin-labeled.svg)
![Image of ATX 4-pin auxiliary pin-out](/images/{{ page.date | date: "%Y-%m-%d" }}/atx-4-pin-opt-labeled.svg)

This diagram illustrates the pin-out of an ATX 20(+4)-pin connector as well as the ATX 4-pin auxiliary power connector.
While it is possible to use only an ATX 24-pin connector for all connections, many salvaged power supplies will still have the old 20-pin connector.
Therefore, I recommend using the ATX 4-pin auxiliary connector for both 12-volt lines and using the ATX connector for all 5-volt connections.

# Exposing 12-volt and 5-volt

The first step is to connect the 4-pin ATX auxiliary power plug to the RAMPS power terminals.
Keep the color coordination and solder those salvaged yellow cables into the 12-volt pins and black into ground pins.
Strip the ends of these 4 cables, but don't install them into the RAMPS board yet.

Oscar won't be using any 5-volt hardware, but it's a good idea to include it if we decide to expand.
Grab a salvaged wire with a DuPont connector and solder it to any 5-volt terminal on the 24-pin connector where a red wire would plug in.

It's a good idea to use your multi-meter to test all of these connections for continuity before continuing.

# Exposing PS_ON, VSB, and 2 GND connectors

I prefer modular configurations to static ones, especially when building a device that might change
Rather than solder these connections directly, I recommend that you expose these pins with DuPont connectors and then plug them in any configuration you desire.

While 2 GND connections aren't strictly necessary, I have found it useful for debugging.
Your Raspberry Pi will need one GND connection for standby power.
To test the power supply in this configuration, you will need to be able to short PS_ON manually.
This is easier when a second GND connector is available.

As usual, test all connections for continuity.

# Testing the power supply

You should test your power supply before connecting it to your devices.
Plug your power supply into your connectors and set your multi-meter to detect 5-12 volts.
An ATX power supply should not require a load to produce stable voltages.

BE CAREFUL!  You do not want to short any of the power connections, especially 5-volt and 12-volt lines.
You may want to make a tube of electrical tape around the 12-volt lines to ensure they do not unintentionally short.

Pick a GND connection and affix your ground (black) probe to it.
Start by testing standby power (purple) for 5 volts by touching it with the live (red) probe.
Repeat this process for your 12-volt and 5-volt connections.
Next, use your multi-meter to test the voltage on PS_ON (green).
PS_ON should produce 5 volts and the power supply fan should kick on momentarily.
If the power supply turns on, jumper that connection manually and continue testing the 12-volt and 5-volt connections.
These should now be supplying 12-volt and 5-volt power.

If anything goes wrong, unplug everything and test your work for continuity.
If that still seems good, you can test the power supply directly by using your multi-meter probes on its connector end.
18-gauge solid wire can be used to bridge PS_ON to GND directly in the device, but you should be extremely careful when doing this.

# Connecting 12-volt and 5-volt power


Insert the 12-volt wires and ground wires from the auxiliary connector into the bottom set of screw-down terminals on the RAMPS board.
The yellow 12-volt wires go in the positive (+) terminals and the black ground connectors go in the negative (-) terminals.
Optionally, slip the 5-volt DuPont connector onto the RAMPS board where it says 5V, just above PS_ON and VIN.

# Logic Configuration 1: Always-on

![Raspberry Pi and RAMPS connection](/images/{{ page.date | date: "%Y-%m-%d" }}/psu-on-wiring.svg)

This configuration causes the power supply immediately reach full power when plugged in or turned on.
To do this, make a male-to-male jumper cable, or use one you already have, and short PS_ON to GND.
The Arduino will receive power from one of the 12-volt connectors.
You may optionally connect the 5-volt connector to the RAMPS board if you have any 5-volt devices connected.

# Logic Configuration 2: Raspberry Pi

![Raspberry Pi and RAMPS connection](/images/{{ page.date | date: "%Y-%m-%d" }}/psu-pi-wiring.svg)

This configuration connects a Raspberry Pi to the Arduino.
Both devices are powered from standby power: the Raspberry Pi directly and the Arduino from the Raspberry Pi.
It is essential that the Raspberry Pi remain connected to the Arduino or the power supply may be damaged.

Solder the VCC and GND pins of a Micro USB connector to some male header pins.
Connect your VSB (purple) lead to VCC (red) and join the supply GND (black) to USB GND (black) to power your raspberry pi.
Connect the PS_ON (green) connector to the PS_ON pin of the RAMPS board.
Again, you may optionally connect the 5-volt connector to the RAMPS board if you have any 5-volt devices connected.

# Logic Configuration 3: Stand-alone

![Stand-alone RAMPS connection](/images/{{ page.date | date: "%Y-%m-%d" }}/psu-standalone-wiring.svg)

This is the most complex configuration as it requires removing a diode from the RAMPS board.
I do not recommend using this configuration, but you have the option if you are adventurous.
Remember not to connect a PC to the RAMPS Arduino when in this configuration.
You *will need* an SD card reader or other storage connection. 

The diode labelled D1 on the RAMPS board allows the Arduino to receive power from a 12-volt connection if it is not powered by USB.
To safely control the power supply, the Arduino must have standby power when this 12-volt connection is not on.
Removing D1 allows will prevent the Arduino from receiving power through its on-board regulator.
This allows us to connect 5-volt standby power to VCC, which is exposed on the RAMPS board.
However, the Arduino **must not** receive USB power or 12-volt power while receiving standby power.

To do this, desolder diode D1 from your RAMPS board and store it somewhere safe.
Plug the VSB (purple) lead into the VCC pin on the RAMPS board to power the Arduino and stepper controllers.
As before, connect the PS_ON (green) connector to the PS_ON pin of the RAMPS board.
Because you are very likely to have a 5-volt SD card reader, connect a 5-volt connector to the RAMPS board.

It is not recommended to connect a USB cable in this configuration because you have bypassed the Arduino power regulator.
You may be able to get away with it, but it is possible to damage your Arduino.
Further modifications to the Arduino itself are recommended, please visit the [RAMPS 1.4 page](http://reprap.org/wiki/RAMPS_1.4) for more information.
