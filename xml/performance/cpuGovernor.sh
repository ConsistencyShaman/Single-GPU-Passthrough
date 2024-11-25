#!/usr/bin/bash
#############################################################################
## __     ___	  _________                 ____  _____     ____  ____     ##
##|  \   /  /    |___   ___|        '"'    |    \\   _ \   |   \  /   |    ##
## \  \_/  /_-''-_   | |     /\     | |    |  _  \\ \ \ \  |    \/    |    ##
##  \     //  ^^  \  | |    /  \    | |    | | |  \\ \ \ \ |          |    ##
##   \   //  ______\ | |   / ^^ \   | |    | | |  / \ ""  \|   _  _   |    ##
##   /  //  /    __  | |  /  __  \  | |    | |_| /   '"'"'"|  / \/ \  |    ##
##  /  / \  \___/ /  | | /  /  \  \ | |__..|    /         /  /      \  \   ##
## /__/   \______/   '"'/__/    \__\|_____||___/         /__/        \__\  ##
#############################################################################
## FOR INTEL i9-10900KF
## DO NOT USE ON OTHER CPUS HAS IT MAY NOT WORK
## CHECK IF CPU ARCHITURE IS THE SAME
## CHECK CORES AND SIBLINGS TO PUT THEM TOGHETER WHEN ALLOCATING CPU "lscpu -e"
## NOTE:
# Has I'm using a single GPU passthrough my linux host goes in non graphical interface mode
# Like this only 2 process are active on the host, the qemu vm which takes the most resource
# The system, minimal resource...
# I don't use a reverse script to turn cpu back into "powersave" because once I go back my session
# logs off and the cpu goes back into is original state, "powersave". 
############################################################################
# SCRIPT
## Log file, for now, same folder for debug purpose
LOGS="~/Documents/Single-GPU-Passthrough/xml/performance"
DATE=$(date '+%Y-%m-%d %H:%M:%S' )
## For the best performance of allocated cores
# Change cores 0 to 6 to performance
for i in {0..6}; do
	if [ -f /sys/devices/system/cpu/cpu$i/cpufreq/scaling_governor ]; then
	  # Read cpu governor file
	  VM_GOVERNOR=$(cat /sys/devices/system/cpu/cpu$i/cpufreq/scaling_governor)
		if [ "$VM_GOVERNOR" = "powersave" ]; then
	 	  echo performance > /sys/devices/system/cpu/cpu$i/cpufreq/scaling_governor
	 	  echo "$DATE VM Core $i: Performance mode switched on" >> LOGS
		else
	 	  echo "$DATE VM Core $i Governor: $VM_GOVERNOR" >> LOGS
		fi
	else
	  echo "$DATE - ERR.. is path correct?"
	fi
done

# Change multi threads 10 to 16
for i in {10..16}; do
	if [ -f /sys/devices/system/cpu/cpu$i/cpufreq/scaling_governor ]; then
	  # Read cpu governor file
	  VM_THREADS_GOVERNOR=$(cat /sys/devices/system/cpu/cpu$i/cpufreq/scaling_governor)
		if [ "$VM_THREADS_GOVERNOR" = "powersave" ]; then
	 	  echo performance > /sys/devices/system/cpu/cpu$i/cpufreq/scaling_governor
	 	  echo "$DATE VM Thread $i: Performance mode switched on" >> LOGS
		else
	 	  echo "$DATE VM Thread $i Governor: $VM_THREADS_GOVERNOR" >> LOGS
		fi
	else
	  echo "$DATE - ERR.. is path correct?"
	fi
done


## FROM WINDOWS NOTES
## We can verify via ssh connectiong and top tool that the emulator in linux is currently maxing out the cpu performance;
## We confirm that the scaling_governor was at "powersave" mode; We've used this script to change the 7 vm cores to "performance";
## We'll change the 8 core of the cpu, the emulator core, to "performance" mode too to see if the cpu usage goes lower;

# Switch emulator core to performance
if [ -f /sys/devices/system/cpu/cpu7/cpufreq/scaling_governor ]; then
  # Read cpu governor file
  EMULATOR_GOVERNOR=$(cat /sys/devices/system/cpu/cpu7/cpufreq/scaling_governor)
    # Check file
    if [ "$EMULATOR_GOVERNOR" = "powersave" ]; then
	echo performance > /sys/devices/system/cpu/cpu7/cpufreq/scaling_governor
	echo "$DATE Emulator: Performance mode switched on" >> LOGS
    else
	echo "$DATE Emulator Governor: $EMULATOR_GOVERNOR" >> LOGS
    fi
else
	echo "$DATE - ERR... is path correct?"
fi

## Proved to be effective, cpu usage is smoother and not always above 100
## Now we keep using top from linux on our ssh connection, we pressed 1 while on top
## This allows to see each core cpu usage
## We gonna use the vm and see how this change on the cpu governor affects the performance
## CPU core 8 and 9 are still in powersave mode, they control the iothread related to disk usage
## Lets see if its worth to turn the all cpu to performance while using the vm

## We will turn all cores and threads to performance mode.
## The objective is to see if it impacts disk performance...
## Due to the fact that we using virtualized nmve and HDD has game storage. (Could be good to store games in hard nmve)
# Cores
for i in {8..9}; do
    if [ -f /sys/devices/system/cpu/cpu$i/cpufreq/scaling_governor ]; then
	# read files
	IOTHREAD_GOVERNOR=$(cat /sys/devices/system/cpu/cpu$i/cpufreq/scaling_governor)
	if [ "$IOTHREAD_GOVERNOR" = "powersave" ]; then
	  echo performance > /sys/devices/system/cpu/cpu$i/cpufreq/scaling_governor
	  echo "$DATE IOTHREAD Core $i: Performance mode switched on" >> LOGS
	else
	  echo "$DATE IOTHREAD Core $i: $IOTHREAD_GOVERNOR" >> LOGS
	fi
    else
	echo "$DATE - ERR... is path correct?"
    fi
done
# Threads
for i in {17..19}; do
    if [ -f /sys/devices/system/cpu/cpu$i/cpufreq/scaling_governor ]; then
	# read
	IOTHREAD_THREADS_GOVERNOR=$(cat /sys/devices/system/cpu/cpu$i/cpufreq/scaling_governor)
	if [ "$IOTHREAD_THREADS_GOVERNOR" = "powersave" ]; then
	  echo performance > /sys/devices/system/cpu/cpu$i/cpufreq/scaling_governor
	  echo "$DATE IOTHREAD Thread $i: Performance mode switched on" >> LOGS
	else
	  echo "$DATE IOTHREAD Thread $i: $IOTHREAD_THREAD_GOVERNOR" >> LOGS
	fi
    else
	echo "$DATE - ERR... is path correct?"
    fi
done

## With this last two loops all the cpu is turn into performance mode
## The logs lets us know which core and thread is associated with

## We checked that the cores used by the iothreads are not being used at all... 
## we may has well take one of them to the vm and the other to the host (emulator) 
## Setting all the cpu to performance is the way to go. There's no point in leaving
## a few cores in powersave, we still using this script to set the cpu to performance
