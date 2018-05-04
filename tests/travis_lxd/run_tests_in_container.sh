#!/bin/bash
HERE=$(dirname $(readlink -m $0))
ODOO_VERSIONS=($ODOO_VERSIONS)
ODOO_INSTALL_TYPES=($ODOO_INSTALL_TYPES)
TESTS_RC=()
for odoo_version in "${ODOO_VERSIONS[@]}"
do
    for odoo_install_type in "${ODOO_INSTALL_TYPES[@]}"
    do
        version=$(echo $odoo_version | cut -d. -f1)
        CT_NAME="$1-$version-$odoo_install_type"
        echo -e "\n"
        echo -e "###########################################################"
        echo -e "# $CT_NAME"
        echo -e "###########################################################\n"
        # Copy the container...
        echo -e "\nCopy $1 container to $CT_NAME..."
        lxc copy $1 $CT_NAME && sleep 4 && lxc list || exit 1
        # Start the container...
        echo -e "\nStart the $CT_NAME container..."
        lxc start $CT_NAME && sleep 4 && lxc list
        # Configure the container
        echo -e "\nConfigure the $CT_NAME container..."
        lxc config set $CT_NAME environment.ODOO_VERSION $odoo_version
        lxc config set $CT_NAME environment.ODOO_INSTALL_TYPE $odoo_install_type
        # Run the tests...
        echo -e "\nRun tests in$CT_NAME container..."
        lxc exec $CT_NAME -- sh -c "/opt/ansible-odoo/tests/run.sh"
        TESTS_RC+=( $? )
        # Stop the container...
        echo -e "\nStop the $CT_NAME container..."
        lxc stop $CT_NAME
        # Delete the container...
        echo -e "\nDelete the $CT_NAME container (free disk space)..."
        lxc delete $CT_NAME
        df -h
    done
done

for rc in "${TESTS_RC[@]}"
do
    if [ "$rc" != "0" ]; then
        echo -e "\nTests failed, check the logs above."
        exit 1
    fi
done
