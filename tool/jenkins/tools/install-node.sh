#!/bin/bash

node_version=v14.18.0

wget https://nodejs.org/dist/$node_version/node-$node_version-linux-x64.tar.xz
tar -Jxf node-$node_version-linux-x64.tar.xz
rm node-$node_version-linux-x64.tar.xz

chmod -R +x ./node-$node_version-linux-x64/bin/