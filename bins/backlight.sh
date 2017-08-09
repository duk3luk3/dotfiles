#!/bin/bash

echo $(($(cat /sys/class/backlight/intel_backlight/brightness) $1)) | sudo tee /sys/class/backlight/intel_backlight/brightness
