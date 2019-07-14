#!/bin/bash

#This program is free software. It comes without any warranty, to
#the extent permitted by applicable law. You can redistribute it
#and/or modify it under the terms of the Do What The Fuck You Want
#To Public License, Version 2, as published by Sam Hocevar. See
#http://sam.zoy.org/wtfpl/COPYING for more details.

# SETTINGS
declare -r DEPENDENCIES=(cpufrequtils sed notify-osd)
script="cpu-control.sh"
installto="/usr/local/bin"
sudoersfile="/etc/sudoers.d/cpufreq-set"
aliasfile="/home/$USER/.bash_aliases"

# Handle options and arguments
while getopts ":v" o; do
    case "${o}" in
        v)
            verbose="true"
            ;;
        *)
			
            ;;
    esac
done
shift $((OPTIND-1))

# Dependency checking
if [ "$verbose" == "true" ] ; then
	echo "Checking for missing dependencies."
fi
# Iterate over required packages and install them if necessary
for package in ${DEPENDENCIES[@]}; do
	dpkg -s "$package" > /dev/null
	# If dependency is unfulfilled...
	if [ ! $? == 0 ] ; then
		if [ "$verbose" == "true" ] ; then
			echo "Package $package could not be found on your system. The script will try to install it."
		fi
		# ...install it
		sudo apt install "$package"
		# If installation failed, show error and abort istaller
		if [ ! $? == 0 ] ; then
			echo "Failed to install required packages. Installation aborted."
			exit 1
		fi
	fi
done
if [ "$verbose" == "true" ] ; then
	echo "All dependencies are fulfilled."
fi

# Add cpufreq-set to sudoers.d
# TODO
echo "Do you wish to grant cpufreq-set superuser permissions without entering a superuser password? This is recommended so you do not have to type in your superuser password every time you change clock speed. Do you wish to proceed? [y/n]"
read input
if [ "$input" == "y" ] ; then 
	cpufreqset="$( which cpufreq-set )"
	if [ -z cpufreqset ] ; then
		echo "Failed to find cpufreq-set on your system. Could not write entry to /etc/sudoers.d"
	else
		sudo touch "$sudoersfile"
		echo "$USER	ALL=(ALL)	NOPASSWD: $cpufreqset" | sudo EDITOR="tee -a" visudo -f "$sudoersfile"
	fi
else
	echo "Proceeding without superuser permissions. If you want to change this later, you must manually make an entry to /etc/sudoers.d, or run this installer again."
fi

# Make script executable and copy it to $installto directory
chmod +x "./$script"
sudo install "./$script" "$installto/$script"

# Add alias
echo "Do you wish to set an alias for cpu-control? [y/n]"
read input
if [ "$input" == "y" ]; then
	echo "Please enter an alias for cpu-control: "
	read input
	if [ ! -z input ] ; then
		echo "alias $input='$installto/$script'" >> "$aliasfile"
		source "$aliasfile"
	fi
fi

# Logoff prompt
echo "Installation complete. On some systems, it may be necessary to log off and back on for the changes to the superuser permissions to take effect."
