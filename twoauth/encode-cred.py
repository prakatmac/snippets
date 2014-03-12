#!/usr/bin/env python2.7

from Crypto.Cipher import AES
from Crypto.Hash import MD5
import json
import argparse
from getpass import getpass

import msgpack

if __name__ == '__main__':
	parser = argparse.ArgumentParser()
	parser.add_argument('input', help='Input JSON Credentials')
	parser.add_argument('output', help='Output Encrypted Credentials')
	parser.add_argument('-k', '--key', help='AES Encryption Key')
	
	args = parser.parse_args()

	if args.key == None:
		args.key = getpass('AES Encryption Key: ')
	cipher = AES.new(MD5.new(args.key).hexdigest(), AES.MODE_ECB)

	with open(args.input, "r") as infile:
		data = msgpack.packb(json.load(infile))
		data = data + '\x00'*(16 - len(data)%16)
		enc_data = cipher.encrypt(data)
		with open(args.output, "w") as outfile:
			outfile.write(enc_data)
