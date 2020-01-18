#!/bin/bash

TOOL=nodemcu-tool

usage ()
{
	cat << EOH
Usage: ./install [project]

Projects:
  test1
  Simple HC-SR04 sensor example: forward/rotate movements based on range sensor data.

  test2
  Simple WebSocket example: forward/rotate/backward movements based on server commands.

  test3
  Simple PWM example: control motor pins using PWM module rather than simple GPIO.
EOH
}

upload ()
{
	for n in "$@"
	do
		echo sudo ${TOOL} upload $n.lua -n main.lua
	done

	echo sudo ${TOOL} upload ../init.lua -n init.lua
	echo sudo ${TOOL} upload settings.lua -n settings.lua
}

case "$1" in
	test1)
		upload "test1"
		;;
	test2)
		upload "test2"
		;;
	test3)
		upload "test3"
		;;
	*)
		usage	
		;;
esac
