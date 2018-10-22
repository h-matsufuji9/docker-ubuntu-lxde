#!/bin/bash -e

USER_ID=$(id -u)
GROUP_ID=$(id -g)
USER=${USER:-${DEFAULT_USER}}
GROUP=${GROUP:-${USER}}
PASSWD=${PASSWD:-${DEFAULT_PASSWD}}

# Add group
echo "GROUP_ID: $GROUP_ID"
if [[ $GROUP_ID != "0" && ! $(getent group $GROUP) ]]; then
    groupadd -g $GROUP_ID $GROUP
fi

# Add user
echo "USER_ID: $USER_ID"
if [[ $USER_ID != "0" && ! $(getent passwd $USER) ]]; then
    export HOME=/home/$USER
    useradd -d ${HOME} -m -s /bin/bash -u $USER_ID -g $GROUP_ID $USER
fi

# Revert permissions
sudo chmod u-s /usr/sbin/useradd
sudo chmod u-s /usr/sbin/groupadd

if [[ $1 == "xrdp" ]]; then
    # Set login user name
    USER=$(whoami)
    echo "USER: $USER"

    # Set login password
    echo "PASSWD: $PASSWD"
    echo ${USER}:${PASSWD} | sudo chpasswd

    [ ! -e ${HOME}/.xsession ] && cp /etc/skel/.xsession ${HOME}/.xsession

    echo "#############################"

    # Run XRDP server with tail in the foreground
    exec sudo bash -c "/etc/init.d/xrdp start && tail -F /var/log/xrdp.log"
fi

exec "$@"