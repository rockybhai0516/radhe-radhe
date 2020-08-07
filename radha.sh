#!/bin/bash
# radha.sh
# find hidden urls from the javascript files for a website
# Usage: # radha.sh https://www.google.de
# (c) @r0bre 2020
# contact: mail [at] mrr4431@gmail.com
#set -euo pipefail
###############################radha.sh######################################

if [ ! -d 'curl' ]; then
	mkdir curl
fi
 
if [ ! -d 'output' ]; then 
	mkdir output
fi

banner(){
echo "	               _ _                          _ _             "
echo "	 _ __ __ _  __| | |__   ___   _ __ __ _  __| | |__   ___    "
echo "	| '__/ _  |/ _  | '_ \ / _ \ | '__/ _  |/ _  | '_ \ / _ \   "
echo "	| | | (_| | (_| | | | |  __/ | | | (_| | (_| | | | |  __/   "
echo "	|_|  \__,_|\__,_|_| |_|\___| |_|  \__,_|\__,_|_| |_|\___|   "
echo "	                                               by rocky     "
}

trap ctrl_c INT

ctrl_c(){
    echo "interrupt detected, doing cleanup and exiting.."
    do_cleanup
    exit 
}

do_cleanup(){
		rm -fr curl 
		rm -fr alive.txt
		rm -fr urls.txt
}

usage(){
    echo "Usage: ./radha.sh  [Target URL]"
}

if [ $# -eq 0 ] || [ "$1" = "-h" ]
	then
	banner
   	usage
    exit
fi

if [ $# -eq 1 ]
then
    banner
fi

domain=$1
html=$curl/out.html

echo "[*] gathering all subdomains"
curl -s https://certspotter.com/api/v0/certs\?domain\=$domain | jq '.[].dns_names[]' | sed 's/\"//g' | sed 's/\*\.//g' | sort -u | grep $domain | httprobe -c 70 |  grep https > alive.txt

echo "[*] getting js files"
cat host | httprobe -c 70 | waybackurls | grep https | grep .js | cut -d '?' -f1 | sort -u | xargs -n1 -I{} curl {} > curl/out.html

echo "[*] getting hidden urls from the js file"
cat curl/out.html | grep -Eo "(http|https)://[a-zA-Z0-9./?=_-]*" | sort -u | tee /output/$domain_hidden_url

echo"[*] getting the rest api admin disclosure "
cat curl/out.html | grep -Eo "(http|https)://[a-zAA-Z0-9./?=_-]*" | sort -u | grep "wp-json/wp/v1/users" | grep "wp-json/wp/v2/users" | tee output/$domain_restapi

do_cleanup

