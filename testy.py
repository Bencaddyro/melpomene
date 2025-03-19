#!/usr/bin/env python

import sys
import json
import struct
import socket
import sys


#Create a UDS socket
sock = socket.socket(socket.AF_UNIX, socket.SOCK_STREAM)

# Connect the socket to the port where the server is listening
server_address = '/home/bencaddyro/skaffen/xtension/sock'


sock.connect(server_address)
#sock.send("TODO;https://www.youtube.com/watch?v=KRhBGrZJcXY".encode())

sock.send("TODO;https://www.youtube.com/watch?v=6oXP_GCDTgA&list=OLAK5uy_kHiXT8qgSXOS_nnLJi1kDcDUXxqFc6o6M".encode())


sock.close()


