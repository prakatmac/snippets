#!/usr/bin/env python2.7

import argparse
from Crypto.Cipher import AES
from Crypto.Hash import MD5
from getpass import getpass
import logging
logger = logging.getLogger(__file__)

import json

import msgpack
import oauth2 as oauth
from tweetstream import ConnectionError, AuthenticationError

from tweetstream_ext import OAuthSampleStream

def process_tweet(tweet):
	logger.info(tweet)

def stream(token, consumer, fn=process_tweet):
	with OAuthSampleStream(token, consumer) as stream:
		for tweet in stream:
			fn(tweet)
			

def decrypt_credentials(cred_file, cipher):
	cipher = AES.new(MD5.new(args.key).hexdigest(), AES.MODE_ECB)
	with open(cred_file, "r") as file:
		try:	
			raw_cred = msgpack.unpackb(cipher.decrypt(file.read()))
		except msgpack.ExtraData, exde:
			raw_cred = exde.unpacked
		logger.info(raw_cred)
	token = oauth.Token(raw_cred['AccessToken'], raw_cred['AccessSecret'])
	consumer = oauth.Consumer(raw_cred['ConsumerKey'], raw_cred['ConsumerSecret'])
	return (token, consumer)

if __name__ == '__main__':
	logging.basicConfig(level=logging.INFO)

	parser = argparse.ArgumentParser()
	parser.add_argument('-k', '--key', help='AES Decryption Key')
	parser.add_argument('credentials', help='Encrypted, MessagePack Serialized Credentials File')
	
	args = parser.parse_args()

	if args.key == None:
		args.key = getpass('AES Decryption Key: ')
	
	logger.info(args)
	token, consumer = decrypt_credentials(args.credentials, args.key)
	
	# collect forever
	reconnect_delay = 1
	while True:
		try:
			stream(token, consumer)
			reconnect_delay = 1
		except ConnectionError, ce:
			logger.warn("Disconnected. Reason: {}".format(ce.reason))
			reconnect_delay = reconnect_delay*2
			logger.warn("Attempting to reconnect after {} seconds".format(reconnect_delay))
			continue
		except AuthenticationError, ae:
			logger.warn("Disconnected. Reason: {}".format(ae.reason))
			exit(-1)