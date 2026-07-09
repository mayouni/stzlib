/*
	Softanza base network class -- engine-backed (M-DEP3 slice 2).
	Previously loaded libcurl.ring + libuv.ring for HTTP transport
	and connection metadata. Rewired 2026-06-13 to the in-tree Zig
	engine (libraries/stzlib/engine/src/http.zig) which uses
	std.http.Client + std.crypto.tls -- HTTPS works without an
	external TLS library.

	The Ring class keeps the public surface (Timeout/IsSecure/...)
	stable so stzHttpClient and stzAppServer don't need changes;
	connection state (curl_handle, _error_code_) is now tracked as
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

class stzNetwork from stzObject
	# Connection state (was curl_handle in the libcurl era).
	_cLastUrl_ = ""             # most-recently-used URL
	_nLastStatus_ = 0           # last HTTP status code
	_last_error_ = ""
	_error_code_ = 0
	_timeout_seconds_ = 30

	def init()
		# No global init required for the engine HTTP client.

	def IsConnected()
		# Engine HTTP is request-scoped; we report "connected" iff
		# a request has run.
		return _cLastUrl_ != ""

	def IsSecure()
		if _cLastUrl_ = "" return False ok
		return StzLeft(_cLastUrl_, 8) = "https://"

	def ConnectionInfo()
		if _cLastUrl_ = "" return [] ok
		return [
			:url = _cLastUrl_,
			:response_code = _nLastStatus_,
			:timeout_seconds = _timeout_seconds_
		]

	def LastError()
		return _last_error_

	def HasError()
		return _last_error_ != ""

	def ClearErrors()
		_last_error_ = ""
		_error_code_ = 0
		return This

	def SetTimeout(nSeconds)
		_timeout_seconds_ = nSeconds
		return This

	def Timeout()
		return _timeout_seconds_

	# Internal accessor used by stzHttpClient + stzAppServer to feed
	# back the most-recent request state after running an engine call.
	def _RecordRequest(cUrl, nStatus)
		_cLastUrl_ = cUrl
		_nLastStatus_ = nStatus
		if nStatus < 0
			_last_error_ = StzEngineHttpLastError()
			_error_code_ = nStatus
		ok
