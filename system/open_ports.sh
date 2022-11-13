#!/usr/bin/env bash

# Hold ports to open in an array
# Replace 1 2 3 4 5 with the port numbers you need opened for each protocol:
declare -a tcp_ports=(1 2 3 4 5)
declare -a udp_ports=(1 2 3 4 5)

# Open the ports using the appropriate tool for your OS, as determined by
# evaluating '/etc/os-release'. There's probably a better way to do this,
# but it works for Linode's Debian and RedHat images
if [ "$(grep 'debian' /etc/os-release)" ]; then
    for i in "${tcp_ports[@]}"; do
        sudo iptables -I INPUT -p tcp --dport "${tcp_ports[$i]}" -m state --state NEW,ESTABLISHED,RELATED -j ACCEPT
    done
    for i in "${udp_ports[@]}"; do
        sudo iptables -I INPUT -p udp --dport "${udp_ports[$i]}" -m state --state NEW,ESTABLISHED,RELATED -j ACCEPT
    done

    # Persist rules through a reboot
    # You'll need to watch this part in Lish, as it uses a GUI and
    # requires user input
    sudo apt-get install iptables-persistent
elif [ "$(grep 'redhat' /etc/os-release)" ]; then
    # Open all TCP ports specified above
    for i in "${tcp_ports[@]}"; do
        sudo firewall-cmd --zone=public --add-port="${tcp_ports[$i]}/tcp" --permanent
    done

    # Open all UDP ports specified above
    for i in "${udp_ports[@]}"; do
        sudo firewall-cmd --zone=public --add-port="${udp_ports[$i]/udp" --permanent
    done

    # Reload the firewall
    sudo firewall-cmd --reload
fi
