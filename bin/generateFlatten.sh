#!/bin/bash

mkdir solbin/ &>/dev/null
mkdir solbin/flatten/ &>/dev/null
rm -rf solbin/flatten/"$1Flatten.sol" &>/dev/null

yarn run truffle-flattener contracts/"$1".sol >>solbin/flatten/"$1Flatten".sol

echo "export solbin/flatten/$1Flatten.sol"
