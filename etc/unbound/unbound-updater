#!/bin/bash
    # https://www.wilderssecurity.com/threads/adblocking-with-unbound.406346/page-2
    #
    # A bash script to update domain blocklist for Unbound
    # This will download the blocklists hosted by Steven Black
    # and DNScrypt.info then combine the lists and remove duplicates
    # To reduce false postives, anudeepND's hosted whitelist will
    # be use to sanatize the blocklist

    # You can also manually add domains to the blacklist or whitelist
    # by adding them in blacklist.txt or whitelist.txt in /etc/unbound
    # CREDITS
    # Steven Black https://github.com/StevenBlack/hosts
    # DNScrypt.info https://github.com/DNSCrypt/dnscrypt-proxy/wiki/Public-blacklists
    # anudeepND https://github.com/anudeepND/whitelist

    # Check for sudo
if [[ "${UID}" -ne 0 ]];
then
  echo 'Please use "sudo" to run this script.' >&2
  exit 1
fi
    
    wget -q https://raw.githubusercontent.com/StevenBlack/hosts/master/hosts
    
    if [[ $? -ne 0 ]]; then
        echo 'Steven Black blacklist failed to download, please check network connection' >&2
        exit 1;
    fi
    
    wget -q https://download.dnscrypt.info/blacklists/domains/mybase.txt
    
    if [[ $? -ne 0 ]]; then
        echo 'DNScrypt blacklist failed to download, please check network connection' >&2
        exit 1;
    fi
    
    wget -q https://raw.githubusercontent.com/anudeepND/whitelist/master/domains/whitelist.txt
    
    if [[ $? -ne 0 ]]; then
        echo 'anudeepND whitelist failed to download, please check network connection' >&2
        exit 1;
    fi

    cat hosts | grep '^0\.0\.0\.0' | awk '{print $2}' > block
    sed '/#/d; /*/d; /^$/d; /^\./d' mybase.txt > mybase
    touch -a /etc/unbound/blacklist.txt
    cat block mybase /etc/unbound/blacklist.txt | sort -u > merged
    touch -a /etc/unbound/whitelist.txt
    cat whitelist.txt /etc/unbound/whitelist.txt | sort -u > whitelist
    comm -23 merged whitelist > merged_corrected
    
    # Change "/etc/unbound/unbound-blocked.conf" to match the include setting in unbound.conf file
    awk '{print "local-zone: \""$1"\" always_nxdomain"}' merged_corrected > /etc/unbound/unbound-blocked.conf

    # Attempting to load updated blocklist to unbound
    echo 'Loading updated blocklist to Unbound...'
    echo
    unbound-control dump_cache > unbound.dump
    if [[ $? -ne 0 ]]; then
        echo 'Unable to load blocklist to unbound. You will need to restart unbound manually to load the updated blocklist!' >&2
        logger "Unbound domain blocklist updated at $(date), manual restart required"
        exit 1;
    fi
    unbound-control reload
    cat unbound.dump | unbound-control load_cache

    # Log update
    logger "Unbound domain blocklist updated at $(date)"

    echo
    echo 'Unbound domain blocklist updated and loaded!'
    exit 0
