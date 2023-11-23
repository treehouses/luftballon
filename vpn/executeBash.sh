#!/bin/bash
manageConfigPath=$(pwd)
source $manageConfigPath/../dependencies/createDirectories.sh

createDirectories
getServerDirectory
getClientDirectory