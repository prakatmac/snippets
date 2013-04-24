#!/usr/bin/env python2.7

import urllib2
from urllib import urlencode

import argparse
import json

from ext.urllib2_ext import VerifiedHTTPSHandler

GZIP_HEADER = {'Accept-Encoding': 'gzip'}

class StreamRequest(urllib2.Request):
	endpoint = ""
	def __init__(self):
		urllib2.Request.__init__(self, self.endpoint)
	
	def h(self, headers):
		for key, value in headers.iteritems():
			self.add_header(key, value)
		return self
		
	def d(self, query_params):
		self.add_data(urlencode(query_params))
		return self
		
class SampleStreamRequest(StreamRequest):
	endpoint = 'https://stream.twitter.com/1.1/statuses/sample.json'
	
class FilterStreamRequest(StreamRequest):
	endpoint = 'https://stream.twitter.com/1.1/statuses/filter.json'

class TwitterStream(object):
	def __init__(self, req):
		self.req = req
		self.conn = False
	
	def __iter__(self):
		# try:
		self.conn = urllib2.build_opener(VerifiedHTTPSHandler()).open(self.req)
		while True:
			# this should read through the end of the json dict
			msg = json.load(self.conn)
			yield msg
		# except InterruptedException:
		# 	pass
		# finally:
		# 	self.conn.close()			
		
if __name__ == '__main__':
	parser = argparse.ArgumentParser()
	parser.add_argument('input', help='JSON serialized header file')
	args = parser.parse_args()
	
	with open(args.input, 'r') as file:
		auth_header = json.load(file)
	
	s = TwitterStream(SampleStreamRequest().h(auth_header))
	print s.req.headers
	for tweet in s:
		print tweet