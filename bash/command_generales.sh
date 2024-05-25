#!/bin/bash

# desactive l interface graphique et la veille automatique
sudo systemctl mask sleep.target suspend.target hibernate.target hybrid-sleep.target
sudo systemctl set-default multi-user