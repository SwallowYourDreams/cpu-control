#!/bin/bash

#This program is free software. It comes without any warranty, to
#the extent permitted by applicable law. You can redistribute it
#and/or modify it under the terms of the Do What The Fuck You Want
#To Public License, Version 2, as published by Sam Hocevar. See
#http://sam.zoy.org/wtfpl/COPYING for more details.

# SETTINGS: You may want to change these values according to your preferences and system.
declare -r CPUFREQDIR="/sys/devices/system/cpu/cpufreq"
declare -r UNIT="MHz" #unit used to measure cpu clock speed. Default: MHz.
declare -r DIVISOR=1000 #number by which all cpu clock speeds (in Hz) are divided. Needs to be set according to the unit chosen. Default: 1000
declare -r SEPARATOR="." #character used to separate the thousands in large numbers. Default: comma (,)
debugging="false"

# INTERNAL VARIABLES: These values should normally remain untouched.
clockmin=$(( $(cat "$CPUFREQDIR/policy0/scaling_min_freq") / $DIVISOR )) #the minimum clock speed for this cpu
clockmax=$(( $(cat "$CPUFREQDIR/policy0/scaling_max_freq") / $DIVISOR )) #the maximum clock speed for this cpu
cores=($(ls -d "$CPUFREQDIR"/policy*)) #the absolute paths to the cpufreq policy directories; *not* the number of cores, although it may be derived from this array
# If for some reason no cores can be found, abort script
if [ "${#cores[@]}" -lt 1 ] ; then
	msg="No CPU found. Please check your cpufrequtils installation."
	userfeedback "${icons[error]}" "Error" "$msg"
fi
minx=$(cat "$CPUFREQDIR/policy0/cpuinfo_min_freq") #clock speed: extreme minimum
max=$(cat "$CPUFREQDIR/policy0/cpuinfo_max_freq") #clock speed: maximum
diff=$(($max - $minx)) #clock speed range between extreme minimum and maximum
min=$(($minx + $(($diff/3)))) #clock speed: minimum
med=$(($minx + $(($diff/3))*2 )) #clock speed: medium
# Icons for notify-send
declare -A icons
icons[info]="info"
icons[settings]="settings"
icons[error]="error"
#icons[error]="/usr/share/icons/Mint-Y/status/48/dialog-error.png"
# Output to cli for testing purposes
if [ "$debugging" == "true" ] ; then
	echo "Minx: $minx"
	echo "Min: $min"
	echo "Med: $med"
	echo "Max: $max"
fi

# FUNCTIONS
# Sets cpu clock speed to a user-defined value
function setclock {
	if [ "$1" -gt "$max" ] || [ "$1" -lt "$minx" ] ; then
		msg="Invalid clock speed: $(($1 / $DIVISOR)) $UNIT.\nYour CPU clock speeds may range from $(( $minx / $DIVISOR )) to $(( $max / $DIVISOR )) $UNIT."
		userfeedback "${icons[error]}" "Error" "$msg"
		exit 1
	else
		clockspeed=$(( $1 / $DIVISOR ))
		# Debugging
		if [ "$debugging" == "true" ] ; then
			echo "Clockspeed: $clockspeed $UNIT"
		fi
		for((i=0; i < ${#cores[@]}; i++)); do
			if [ "$debugging" == "true" ] ; then
				echo "Setting CPU #$1 ; $clockspeeds$UNIT"
			fi
			sudo cpufreq-set -c $i -u "$clockspeed$UNIT"
		done
		msg="Clock speed is now limited to $(formatnumber $clockspeed) $UNIT."
		userfeedback "${icons[settings]}" "CPU" "$msg"
		exit 0
	fi
}
# Shows the current clock speed for all cpu cores
function showinfo {
	# Get actual current clock speeds of all cpus
	for(( i=0 ; i < ${#cores[@]} ; i++ )); do
		core=${cores[$i]}
		clockspeed=$(( $(cat "$core/scaling_cur_freq") / $DIVISOR ))
		clockspeed=$(formatnumber $clockspeed)
		clockspeeds+="Core $(($i +1)):   $(formatnumber $clockspeed) MHz\n"
	done
	# Output
	msg="Clock speed is between $clockmin and $clockmax $UNIT.\n\n$clockspeeds"
	userfeedback "${icons[info]}" "CPU" "$msg"
	exit 0
}

# Gives feedback to the user in the form of cli output and pop-up messages
function userfeedback {
	notify-send -i "$1" "$2" "$3"
	printf "$msg\n"
}
# Formats large numbers so that the thousands will be marked by a delimiter (e.g. "1,000" instead of "1000")
function formatnumber {
	echo $1 | sed ':a;s/\B[0-9]\{3\}\>/'"$SEPARATOR"'&/;ta'
}

# Displays syntax instructions for options and arguments
function usage {
	usage="$(basename $0) [-i] [-d minx|min|med|max] [-s clockspeed*]\n*in MHz\n"
	msg="Incorrect use of options or arguments."
	userfeedback "${icons[error]}" "Error" "$msg"
	printf "$usage"
	exit 1
}

# OPTIONS
# If no options are passed, display syntax instructions
if [ -z $1 ] ; then
	usage
fi
# option and argument handling
while getopts "id:s:" o; do
	case "${o}" in
		i)
			showinfo
		;;
		d)
			d=${OPTARG}
			case "$d" in
				minx)
					setclock $minx
				;;
				min)
					setclock $min
				;;
				med)
					setclock $med
				;;
				max)
					setclock $max
				;;
				*)
					usage
				;;
			esac
		;;
		s)
			s=${OPTARG}
			setclock $(($s * $DIVISOR))
		;;
		h)
			usage
		;;
		*)
			usage
		;;
	esac
done
shift $((OPTIND-1))
