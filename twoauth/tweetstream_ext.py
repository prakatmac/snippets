import time
from platform import python_version_tuple
from tweetstream.streamclasses import BaseStream
from tweetstream import AuthenticationError, ConnectionError, USER_AGENT
import oauth2 as oauth
import urllib
import urllib2

from urllib2_ext import VerifiedHTTPSHandler, VerifiedHTTPSConnection

class OAuthStream(BaseStream):
	def __init__(self, token, consumer, 
					catchup=None, raw=False, timeout=None, url=None):
		super(OAuthStream, self).__init__('disabled', 'disabled',
			catchup=None, url=None)		
		self._token = token
		self._consumer = consumer
		self._timeout = timeout
	
	def _init_conn(self):
		"""Open the connection to the twitter server"""
		headers = {'User-Agent': self.user_agent}
		postdata = self._get_post_data() or {}
		if self._catchup_count:
			postdata["count"] = self._catchup_count
		
		poststring = urllib.urlencode(postdata) if postdata else None
		handler = VerifiedHTTPSHandler()
		oreq = oauth.Request(method="GET", url=self.url, parameters=postdata)
		oreq.sign_request(oauth.SignatureMethod_HMAC_SHA1(), self._consumer, self._token)
		req = urllib2.Request(oreq.to_url(), headers=headers)

		opener = urllib2.build_opener(handler)

		# If connecting fails, convert to ReconnectExponentiallyError so
		# clients can implement appropriate backoff.
		try:
			self._conn = opener.open(req, timeout=self._timeout)
		except urllib2.HTTPError, x:
			if x.code == 401:
				raise AuthenticationError("Access denied")
			elif x.code == 404:
				raise ReconnectExponentiallyError("%s: %s" % (self.url, x))
			else:
				raise ReconnectExponentiallyError(str(x))
		except urllib2.URLError, x:
			raise ReconnectExponentiallyError(str(x))

		self._socket = self._conn.fp._sock
		self.connected = True
		if not self.starttime:
			self.starttime = time.time()
		if not self._rate_ts:
			self._rate_ts = time.time()

	def _get_post_data(self):
		params = {
			'oauth_version': "1.0",
			'oauth_nonce': oauth.generate_nonce(),
			'oauth_timestamp': int(time.time()),
			'oauth_token': self._token.key,
			'oauth_consumer_key': self._consumer.key
		}
		return params

class OAuthSampleStream(OAuthStream):
	url = "https://stream.twitter.com/1.1/statuses/sample.json"