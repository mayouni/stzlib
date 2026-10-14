/*
	Softanza base network class -- engine-backed (M-DEP3 slice 2).
	Previously loaded libcurl.ring + libuv.ring for HTTP transport
	and connection metadata. Rewired 2026-06-13 to the in-tree Zig
	engine (libraries/stzlib/engine/src/http.zig) which uses
	std.http.Client + std.crypto.tls -- HTTPS works without an
	external TLS library.

	The Ring class keeps the public surface (Timeout/IsSecure/...)
	stable so stzHttpClient and stzAppServer don't need changes;
	connection state (curl_handle, @error_code) is now tracked as
	plain instance attributes instead of a curl handle.
*/

# =============================================================================
# HEX HELPERS (pure Ring -- unchanged from libcurl era)
# =============================================================================

func StzHex2Dec(cHex)
	_result_ = 0
	for i = 1 to StzLen(cHex)
		_char_ = cHex[i]
		if _char_ >= "0" and _char_ <= "9"
			_digit_ = ascii(_char_) - 48
		elseif _char_ >= "A" and _char_ <= "F"
			_digit_ = ascii(_char_) - 55
		elseif _char_ >= "a" and _char_ <= "f"
			_digit_ = ascii(_char_) - 87
		else
			_digit_ = 0
		ok
		_result_ = _result_ * 16 + _digit_
	next
	return _result_

	func hex2dec(cHex)
		return StzHex2Dec(cHex)

func StzStr2Hex(cStr)
	_result_ = ""
	_nStr1Len_ = len(cStr)
	for _iLoopStr1_ = 1 to _nStr1Len_
		_char_ = cStr[_iLoopStr1_]
		_hex_ = StzDec2Hex(ascii(_char_))
		if StzLen(_hex_) = 1 _hex_ = "0" + _hex_ ok
		_result_ += _hex_
	next
	return _result_

	func str2hex(cStr)
		return StzStr2Hex(cStr)

func StzDec2Hex(_nNum_)
	if _nNum_ = 0 return "0" ok
	_hex_chars_ = "0123456789ABCDEF"
	_result_ = ""
	while _nNum_ > 0
		_result_ = _hex_chars_[_nNum_ % 16 + 1] + _result_
		_nNum_ = floor(_nNum_ / 16)
	end
	return _result_

	func dec2hex(_nNum_)
		return StzDec2Hex(_nNum_)

# =============================================================================
# BASE NETWORK CLASS -- foundation for HTTP-style I/O
# =============================================================================

# Holds the connection state shared by the library's network clients: the last request, the last error and the timeout.
#
# It is the base of stzHttpClient, stzTcpClient, stzTcpServer and stzWebSocket and keeps no socket
# itself. Its state is plain attributes: the address and status of the last recorded request, the
# last error text and code, and a timeout in seconds. The engine HTTP client is request-scoped, so
# IsConnected only says that a request has run. Subclasses override IsConnected to report an open
# socket. The class makes no request by itself.
#
#   receiver   o1 = new stzNetwork()
#   example    ? o1.Timeout()
#              #--> 30
#              o1.SetTimeout(5)
#              ? o1.Timeout()
#              #--> 5
#              ? o1.IsConnected()
#              #--> 0
#              ? o1.HasError()
#              #--> 0
#   see        stzHttpClient, stzTcpClient, stzTcpServer
class stzNetwork from stzObject
	# Connection state (was curl_handle in the libcurl era).
	@cLastUrl = ""             # most-recently-used URL
	@nLastStatus = 0           # last HTTP status code
	@last_error = ""
	@error_code = 0
	@timeout_seconds = 30

	# Builds the base state of a network object: no request yet, no error and a 30-second timeout.
	#
	#   returns    nothing; the object is built
	#   see        SetTimeout, ConnectionInfo
	def init()
	# TRUE if a request has been recorded; the engine HTTP client keeps no connection open between requests.
	#
	#   returns    TRUE or FALSE
	#   see        ConnectionInfo, IsSecure
	#@ aka  No global init required for the engine HTTP client.
	def IsConnected()
		# Engine HTTP is request-scoped; we report "connected" iff
		# a request has run.
		return @cLastUrl != ""

	# TRUE if the last recorded request used https.
	#
	#   returns    TRUE or FALSE; FALSE before any request
	#   see        IsConnected, ConnectionInfo
	def IsSecure()
		if @cLastUrl = "" return False ok
		return StzLeft(@cLastUrl, 8) = "https://"

	# Returns the last recorded request: its address, its status code and the timeout in force.
	#
	#   returns    a hash list [ :url, :response_code, :timeout_seconds ]; an empty list before any
	#              request
	#   see        IsConnected, LastError
	def ConnectionInfo()
		if @cLastUrl = "" return [] ok
		return [
			:url = @cLastUrl,
			:response_code = @nLastStatus,
			:timeout_seconds = @timeout_seconds
		]

	# Returns the text of the last error, empty when there is none.
	#
	#   returns    a text
	#   see        HasError, ClearErrors
	def LastError()
		return @last_error

	# TRUE if an error text is held.
	#
	#   returns    TRUE or FALSE
	#   see        LastError, ClearErrors
	def HasError()
		return @last_error != ""

	# Forgets the last error text and code.
	#
	#   returns    the object itself, so calls chain
	#   see        LastError
	def ClearErrors()
		@last_error = ""
		@error_code = 0
		return This

	# Sets the timeout, in seconds, that ConnectionInfo reports and requests use.
	#
	#   nSeconds   the timeout in seconds
	#   returns    the object itself, so calls chain
	#   note       the value is not checked, so a negative or non-number value is kept as given
	#   see        Timeout
	def SetTimeout(nSeconds)
		@timeout_seconds = nSeconds
		return This

	# Returns the timeout in seconds; 30 by default.
	#
	#   returns    a number
	#   see        SetTimeout
	def Timeout()
		return @timeout_seconds

	# Internal accessor used by stzHttpClient + stzAppServer to feed
	# back the most-recent request state after running an engine call.
	def _RecordRequest(cUrl, nStatus)
		@cLastUrl = cUrl
		@nLastStatus = nStatus
		if nStatus < 0
			@last_error = StzEngineHttpLastError()
			@error_code = nStatus
		ok
