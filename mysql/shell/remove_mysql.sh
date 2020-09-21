#!/bin/bash

sudo apt-get --purge remove mysql-server
sudo apt-get --purge remove mysql-client
sudo apt-get --purge remove mysql-common
apt-get autoremove
apt-get autoclean
