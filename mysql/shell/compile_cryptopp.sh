#!/bin/bash

#https://www.cryptopp.com/wiki/Linux
#https://www.cryptopp.com/
#https://github.com/weidai11/cryptopp

TOOLS_PATH=/tmp/tools

compile_cryptopp() {
    if [ ! -d $TOOLS_PATH ]; then
        mkdir $TOOLS_PATH
    fi

    cd /tmp/tools
    wget https://www.cryptopp.com/cryptopp565.zip

    unzip -d cryptopp565 cryptopp565.zip
    cd cryptopp565
    make libcryptopp.a libcryptopp.so cryptest.exe
}

compile_cryptopp
