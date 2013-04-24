#!/usr/bin/env python2.7

import argparse
from Crypto.Cipher import AES
from Crypto.Hash import MD5
from getpass import getpass

import logging
logger = logging.getLogger(__file__)
logging.basicConfig(level=logging.INFO)

import json

import zmq
import msgpack
import oauth2 as oauth
from tweetstream import ConnectionError, AuthenticationError

from ext.tweetstream_ext import OAuthSampleStream

def process_tweet(tweet, stream=None):
	logger.debug(tweet)
	PUBLISHER.send(msgpack.packb(tweet))

def stream(token, consumer, fn=process_tweet):
	with OAuthSampleStream(token, consumer) as stream:
		for tweet in stream:
			fn(tweet, stream)
			
def setup_logger(logfile=None):
	formatter = logging.Formatter('%(asctime)s - %(name)s - %(levelname)s - %(message)s')
	ch = logging.StreamHandler()
	ch.setLevel(logging.WARN)
	ch.setFormatter(formatter)
	if logfile is not None:
		fh = logging.FileHandler(logfile)
		fh.setLevel(logging.INFO)
		fh.setFormatter(formatter)

def setup_zmq_publisher(address="tcp://*:9000"):
	context = zmq.Context()
	globals()['PUBLISHER'] = context.socket(zmq.PUB)
	PUBLISHER.bind(address)

def decrypt_credentials(cred_file, cipher):
	cipher = AES.new(MD5.new(args.key).hexdigest(), AES.MODE_ECB)
	with open(cred_file, "r") as file:
		try:	
			raw_cred = msgpack.unpackb(cipher.decrypt(file.read()))
		except msgpack.ExtraData, exde:
			raw_cred = exde.unpacked
		logger.debug(raw_cred)
	token = oauth.Token(raw_cred['AccessToken'], raw_cred['AccessSecret'])
	consumer = oauth.Consumer(raw_cred['ConsumerKey'], raw_cred['ConsumerSecret'])
	return (token, consumer)

if __name__ == '__main__':
	parser = argparse.ArgumentParser()
	parser.add_argument('-k', '--key', help='AES Decryption Key')
	parser.add_argument('-l', '--log', help='Log output to file', default=None)
	parser.add_argument('credentials', help='Encrypted, MessagePack Serialized Credentials File')
	parser.add_argument('-a', '--address', help='TCP/IPC address to bind', default="tcp://*:9000")
	
	args = parser.parse_args()

	setup_logger(args.log)
	setup_zmq_publisher(args.address)
	
	if args.key == None:
		args.key = getpass('AES Decryption Key: ')
	
	logger.debug(args)
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
			logger.error("Disconnected. Reason: {}".format(ae.reason))
			exit(-1)