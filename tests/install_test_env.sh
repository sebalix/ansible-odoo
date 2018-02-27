#!/bin/bash
HERE=$(dirname $(readlink -m $0))
VENV=/opt/ansible-venv
GET_PIP_URL="https://bootstrap.pypa.io/get-pip.py"
# Install system dependencies
apt-get update -qq
if [[ "$PYTHON_VERSION" == '3' ]]; then
    apt-get install -qq python-virtualenv python3-apt python3-pip python3-dev python3-psycopg2
else
    apt-get install -qq python-virtualenv python-apt python-pip python-dev python-psycopg2
fi
apt-get install -qq lsb-release wget ca-certificates
# Install Ansible in a virtual Python environment
if [[ "$PYTHON_VERSION" == '3' ]]; then
    virtualenv $VENV --python=python3
else
    virtualenv $VENV
fi
wget $GET_PIP_URL -O $VENV/get-pip.py
$VENV/bin/python $VENV/get-pip.py
$VENV/bin/pip install "ansible>=$ANSIBLE_VERSION"
# Install PostgreSQL
apt-get install -qq postgresql postgresql-contrib
