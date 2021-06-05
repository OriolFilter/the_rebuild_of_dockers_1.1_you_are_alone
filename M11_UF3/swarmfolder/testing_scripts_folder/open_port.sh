#!/usr/bin/env bash

port=$1 # Gets a port from the argv and opens it in loop in the background
while true; do
  nc -l $port # Listens to given port
done