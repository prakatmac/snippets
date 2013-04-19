#!/usr/bin/python
"""
authorize - Twitter OAuth2 API Tools

This module facilitates Twitter API authentication and authorization using its
OAuth2 API which is relatively new (enabled 3/11/2013 as far as I know and only
for application-only authorization).
"""

import argparse
import base64
from urllib import quote_plus as quote
import urllib2
import json

from urllib2_ext import VerifiedHTTPSHandler

ENDPOINT = 'https://api.twitter.com/oauth2/token'

def build_credentials(key, secret):
    return base64.b64encode(quote(key) + ":" + quote(secret))

def build_request(credentials):
    return urllib2.Request(ENDPOINT, u'grant_type=client_credentials',
        {'Content-Type': 'application/x-www-form-urlencoded;charset=UTF-8',
         'Authorization': 'Basic ' + credentials })

def authorize(key, secret):
    """
    Given a consumer key and consumer secret, return a dict representing the
    HTTP Authorization header containing valid Bearer credentials for use in
    subsequent API requests.
    """
    req = build_request(build_credentials(key, secret))
    try:
        resp = urllib2.build_opener(VerifiedHTTPSHandler()).open(req)
        out = json.load(resp)
        resp.close()
        return {'Authorization': 'Bearer ' + out[u'access_token']}
    except Exception as e:
        print(e)

if __name__ == '__main__':
    parser = argparse.ArgumentParser()
    parser.add_argument('-k', '--key', help='Consumer Key')
    parser.add_argument('-s', '--secret', help='Consumer Secret')
    parser.add_argument('-o', '--output', help='Save JSON serialized header')
    
    args = parser.parse_args()

    if args.key == None:
        args.key = raw_input('Consumer Key: ')
    if args.secret == None:
        args.secret = raw_input('Consumer Secret: ')
    
    if args.output == None:
        print(json.dumps(authorize(args.key, args.secret)))
    else:
        with open(args.output, 'w') as file:
            json.dump(authorize(args.key, args.secret), file)
        
    