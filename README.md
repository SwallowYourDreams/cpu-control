# cpu-control
A bash script to further facilitate the use of cpufrequtils on Debian-based Linux to throttle cpu clock speeds. May be adapted for other distros.

## Disclaimer
This program is free software. It comes without any warranty, to the extent permitted by applicable law. You can redistribute it and/or modify it under the terms of the Do What The rainbows You Want To Public License, Version 2, as published by Sam Hocevar. See http://sam.zoy.org/wtfpl/COPYING for more details.

Tested on Linux Mint 19 x64 Cinnamon.

## Dependencies
This script requires the following packages to run:
* cpufrequtils
* notify-osd
* sed

If you run installer.sh, everything will be set up for you.

## Installation

After downloading/cloning, run `installer.sh` and follow its instructions, which will
    * make sure all dependencies are fulfilled
    * copy the script to /usr/local/bin
    * offer to exempt cpufreq-set from requiring a superuser password by making an entry to sudoers.d (this is strongly recommended if you're planning to tie cpu-control to keyboard shortcuts)
    * offer to create a system-wide alias for running the script

## How to use it
### From the command line
The -d option lets you use the default arguments _minx, min, med_ and _max_, whose clock speeds are calculated based on the clock speed range of your cpu:

`cpu-control -d minx` # extreme minimum, lowest possible clock speed

`cpu-control -d min` # minimal, relatively low clock speed 

`cpu-control -d med` # medium, average clock speed

`cpu-control -d max` # maximum clock speed

The -s option lets you set a specific clock speed in MHz:

`cpu-control -s 1500` # will limit cpu clock speed to 1500 MHz

The -i option will display the current clock speed limit and the actual clock speed of all cpu cores:

`cpu-control -i`

### Via keyboard shortcuts
If your desktop environment allows you to create custom keyboard shortcuts, this is the most comfortable way to call the script. This method will only work if you have granted superuser permissions to cpufreq-set during installation. Just link the aforementioned commands (see section "From the command line") to custom keyboard shortcuts. This will make changing cpu clock speeds a breeze.
