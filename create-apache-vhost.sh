#!/bin/bash

# checking for root
if (( ! $(id -u) == 0)); then
    echo "Please run this script as root"
    exit
fi

# geting the document root
echo -n "Please type document root: "
read root

# creating a folder if it doesn't exist'
if [[ ! -d "${root}" ]]; then
    mkdir -p $root && echo "New folder created: $root"
fi

# asking for more folders to create
echo -n "You want to create more folders like logs, ssl? (y/n): "
read additional_folder_consent

# checking for the answer
# if answer is yes, then we will create those folders
if [[ "${additional_folder_consent}" == "y" ]]; then
    echo $additional_folder_consent
fi