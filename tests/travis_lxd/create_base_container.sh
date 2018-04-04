#!/bin/bash
HERE=$(dirname $(readlink -m $0))
ODOO_VERSIONS=($ODOO_VERSIONS)
ODOO_INSTALL_TYPES=($ODOO_INSTALL_TYPES)
CT_DIR="/var/lib/lxd/containers/$1"
# Spawn a LXD container
lxc init ${IMAGE} $1 -c security.privileged=true
lxc config set $1 raw.lxc "lxc.aa_allow_incomplete=1"
if [[ "$IMAGE" == 'images:debian/jessie' ]]; then
    $HERE/fix_debian_jessie.sh $1;
fi
# Start the container...
lxc start $1 && sleep 4 && lxc list
# Configure the container
lxc config set $1 environment.ANSIBLE_VERSION $ANSIBLE_VERSION
# Copy the project files into the container
cp -av $HERE/../.. $CT_DIR/rootfs/opt/ansible-odoo
# Install the test environment
lxc exec $1 -- sh -c "/opt/ansible-odoo/tests/install_test_env.sh" || exit 1
# Stop the container
lxc stop $1
# Copy the container into multiple flavors
for odoo_version in "${ODOO_VERSIONS[@]}"
do
    for odoo_install_type in "${ODOO_INSTALL_TYPES[@]}"
    do
        version=$(echo $odoo_version | cut -d. -f1)
        CT_NAME="$1-$version-$odoo_install_type"
        echo -e "\nCopy $1 container to $CT_NAME..."
        lxc copy $1 $CT_NAME && sleep 4 && lxc list || exit 1
    done
done
