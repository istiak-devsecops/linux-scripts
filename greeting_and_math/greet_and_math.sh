#!/bin/bash

CURRENT_TIME=$(date +"%T")
USERNAME=$(whoami)
read -p "Enter a number: " NUMBER

RESULT=$((NUMBER + 10))

echo "Hello! [$USERNAME], the data is [$CURRENT_TIME]. If we add 10 to your number we get [$RESULT]."
