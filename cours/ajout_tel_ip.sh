#!/bin/bash

if [ -z "$1" ]; then
  echo "Usage: $0 <argument>"
  exit 1
fi
echo "
[$1]
Usename = $1 
Secret = bonjour 
Host = dynamic 
Type = friend 
Context = local 
" >> /etc/asterisk/sip.conf
