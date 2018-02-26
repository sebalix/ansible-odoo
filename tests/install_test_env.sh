#!/bin/bash
HERE=$(dirname $(readlink -m $0))
VENV=/opt/ansible-venv
GET_PIP_URL="https://bootstrap.pypa.io/get-pip.py"
# Install system dependencies
apt-get update -qq
apt-get install -qq python-virtualenv python3-apt python3-psycopg2 python3-pip python3-dev lsb-release wget ca-certificates
# Install Ansible in a virtual Python environment
virtualenv $VENV --python=/usr/bin/python3
wget $GET_PIP_URL -O $VENV/get-pip.py
$VENV/bin/python3 $VENV/get-pip.py
$VENV/bin/pip3 install "ansible>=$ANSIBLE_VERSION"
# Install PostgreSQL
apt-get install -qq postgresql postgresql-contrib
