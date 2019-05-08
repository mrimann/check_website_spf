#!/usr/bin/env bash

# check_website_spf.sh
#
# Copyright 2019 by Mario Rimann <mario@rimann.org>
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
while getopts ":z:a:f:" opt; do
  case $opt in
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
#pathToPySPF="/usr/lib/python3/dist-packages/spf.py"
#if [[ ! -e $pathToPySPF ]]; then
#	echo "Cannot find PySPF at $pathToPySPF, well I need it. Giving up. Sorry!"
#	exit 1
#fi

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
	echo "OK: Domain $zone has no SPF policy right now."
	exit 0
fi

# Execute the check against PySPF
pySpfResult=$( docker run docker-spf:bionic python3 /usr/lib/python3/dist-packages/spf.py ${ip} no-reply@${zone} ${fqdn})

# determine if we need to alert
checkResultStatus=$( echo $pySpfResult | grep "result" | grep "pass" )
if [ -z "$checkResultStatus" ]; then
	echo "WARNING: SPF policy for domain $zone looks fishy. PySPF result was: $pySpfResult"
	exit 1
else
	echo "OK: SPF policy for domain $zone seem to be valid. PySPF result was: $pySpfResult"
	exit 0

fi
