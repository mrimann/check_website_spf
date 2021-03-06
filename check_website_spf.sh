#!/usr/bin/env bash

# check_website_spf.sh
#
# Copyright 2019-2020 by Mario Rimann <mario@rimann.org>
# Licensed under the permissive MIT license, see LICENSE.md
#
# Development of this script was partially sponsored by my
# employer internezzo, see http://www.internezzo.ch
#
# If this script helps you to make your work easier, please consider
# to give feedback or do something good, see https://rimann.org/support

usage() {
	cat - >&2 << _EOT_
Usage: $0 -z <zone> -a <ip address> -f <fqdn>

	-m
		optional: if this option is set, it's mandatory for the zone to have an
		SPF policy, not having one in this situation leads to a WARNING
	-z <zone>
		specify zone to check
	-a <ip-address>
		specify the webserver's IP address
	-f <fqdn>
		specify the webserver's fully-qualified domain name (FQDN)
_EOT_
	exit 255
}

# Parse the input options
while getopts ":mz:a:f:" opt; do
  case $opt in
    m)
      force=1
      ;;
    z)
      zone=$OPTARG
      ;;
    a)
      ip=$OPTARG
      ;;
    f)
      fqdn=$OPTARG
      ;;
    h)
      usage ;;
  esac
done


# Check if dig is available at all - fail hard if not
pathToDig=$( which dig )
if [[ ! -e $pathToDig ]]; then
	echo "No executable of dig found, cannot proceed without dig. Sorry!"
	exit 1
fi

# TODO: Find a way to properly test it locally on the Mac...
# Check if PySFP available at all - fail hard if not
pathToPySPF="/usr/lib/python3/dist-packages/spf.py"
if [[ ! -e $pathToPySPF ]]; then
	echo "Cannot find PySPF at $pathToPySPF, well I need it. Giving up. Sorry!"
	exit 1
fi

# Check if we got a zone to validate - fail hard if not
if [[ -z $zone ]]; then
	echo "Missing zone to test - please provide a zone via the -z parameter."
	echo
	usage
	exit 3
fi

# Check if we got an IP address to check against the SPF record - fail hard if not
if [[ -z $ip ]]; then
	echo "Missing IP address to test - please provide the address via the -a parameter."
	echo
	usage
	exit 3
fi

# Check if we got an FQDN to check against the SPF record - fail hard if not
if [[ -z $fqdn ]]; then
	echo "Missing server's FQDN to test - please provide this value via the -f parameter."
	echo
	usage
	exit 3
fi


# Check if there's a TXT record at all that qualifies for SPF
checkTxtRecord=$( dig TXT $zone +short | grep spf )
if [ -z "$checkTxtRecord" ]; then
		if [[ $force -eq 0 ]]; then
			echo "OK: Domain $zone has no SPF policy right now."
			exit 0
		else
			echo "WARNING: Domain $zone has no SPF policy right now, but one is required for this domain!"
			exit 1
		fi
fi

# Execute the check against PySPF
pySpfResult=$( python3 /usr/lib/python3/dist-packages/spf.py ${ip} no-reply@${zone} ${fqdn})

# do that against the local docker container (work-around for MacOS based DEV environment, ...)
#pySpfResult=$( docker run docker-spf:bionic python3 /usr/lib/python3/dist-packages/spf.py ${ip} no-reply@${zone} ${fqdn})

# determine if we need to alert
checkResultStatus=$( echo $pySpfResult | grep "result" | grep "pass" )
if [ -z "$checkResultStatus" ]; then
	echo -e "WARNING: SPF policy for domain $zone looks fishy.\nCurrent policy: $checkTxtRecord\nPySPF result was: $pySpfResult"
	exit 1
else
	echo -e "OK: SPF policy for domain $zone seems to be valid.\nCurrent policy: $checkTxtRecord\nPySPF result was: $pySpfResult"
	exit 0
fi
