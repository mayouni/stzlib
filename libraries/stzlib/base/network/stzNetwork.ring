/*
	Softanza base network class -- engine-backed (M-DEP3 slice 2).
	Previously loaded libcurl.ring + libuv.ring for HTTP transport
	and connection metadata. Rewired 2026-06-13 to the in-tree Zig
	engine (libraries/stzlib/engine/src/http.zig) which uses
	std.http.Client + std.crypto.tls -- HTTPS works without an
	external TLS library.

	The Ring class keeps the public surface (Timeout/IsSecure/...)
	stable so stzHttpClient and stzAppServer don't need changes;
	connection state (curl_handle, error_code) is now tracked as
	plain instance attributes instead of a curl handle.
*/

# =============================================================================
# HEX HELPERS (pure Ring -- unchanged from libcurl era)
# =============================================================================

func StzHex2Dec(cHex)
	result = 0
	for i = 1 to StzLen(cHex)
		char = cHex[i]
		if char >= "0" and char <= "9"
			digit = ascii(char) - 48
		elseif char >= "A" and char <= "F"
			digit = ascii(char) - 55
		elseif char >= "a" and char <= "f"
			digit = ascii(char) - 87
		else
			digit = 0
		ok
		result = result * 16 + digit
	next
	return result

	func hex2dec(cHex)
		return StzHex2Dec(cHex)

func StzStr2Hex(cStr)
	result = ""
	_nStr1Len_ = len(cStr)
	for _iLoopStr1_ = 1 to _nStr1Len_
		char = cStr[_iLoopStr1_]
		hex = StzDec2Hex(ascii(char))
		if StzLen(hex) = 1 hex = "0" + hex ok
		result += hex
	next
	return result

	func str2hex(cStr)
		return StzStr2Hex(cStr)

func StzDec2Hex(nNum)
	if nNum = 0 return "0" ok
	hex_chars = "0123456789ABCDEF"
	result = ""
	while nNum > 0
		result = hex_chars[nNum % 16 + 1] + result
		nNum = floor(nNum / 16)
	end
	return result

	func dec2hex(nNum)
		return StzDec2Hex(nNum)

# =============================================================================
# BASE NETWORK CLASS -- foundation for HTTP-style I/O
# =============================================================================

class stzNetwork from stzObject
	# Connection state (was curl_handle in the libcurl era).
	cLastUrl = ""             # most-recently-used URL
	nLastStatus = 0           # last HTTP status code
	last_error = ""
	error_code = 0
	timeout_seconds = 30

	def init()
		# No global init required for the engine HTTP client.

	def IsConnected()
		# Engine HTTP is request-scoped; we report "connected" iff
		# a request has run.
		return cLastUrl != ""

	def IsSecure()
		if cLastUrl = "" return False ok
		return StzLeft(cLastUrl, 8) = "https://"

	def ConnectionInfo()
		if cLastUrl = "" return [] ok
		return [
			:url = cLastUrl,
			:response_code = nLastStatus,
			:timeout_seconds = timeout_seconds
		]

	def LastError()
		return last_error

	def HasError()
		return last_error != ""

	def ClearErrors()
		last_error = ""
		error_code = 0
		return This

	def SetTimeout(nSeconds)
		timeout_seconds = nSeconds
		return This

	def Timeout()
		return timeout_seconds

	# Internal accessor used by stzHttpClient + stzAppServer to feed
	# back the most-recent request state after running an engine call.
	def _RecordRequest(cUrl, nStatus)
		cLastUrl = cUrl
		nLastStatus = nStatus
		if nStatus < 0
			last_error = StzEngineHttpLastError()
			error_code = nStatus
		ok
