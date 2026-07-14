# The HTTP response VALUE OBJECT (R7 re-base, 2026-07-14): handlers
# compose it fluently (Status/Header/Json/Text/Html/Send); the server
# renders it with HttpBytes() and writes those bytes through the
# reactor. Send() BUFFERS -- no socket I/O happens in this class.
#
# Attributes carry the @ scope sigil: in Ring 1.27 a BARE class-head
# attribute whose name matches an existing user GLOBAL binds the
# global instead of creating the attribute (verified 2026-07-14 --
# `oClient`/`cBody` globals were clobbered at `new`, then R12).

class stzAppResponse from stzObject
	@oClient = NULL   # legacy constructor slot (pre-reactor); unused
	@bSent = False
	@aHeaders = []
	@nStatusCode = 200
	@cStatusText = "OK"
	@cBody = ""

	def init(oClientRef)
		@oClient = oClientRef

	def Status(nCode, cText)
		@nStatusCode = nCode
		if cText != "" @cStatusText = cText ok
		return This

	def Header(cName, cValue)
		@aHeaders + [cName, cValue]
		return This

	def Headers()
		return @aHeaders

	def StatusCode()
		return @nStatusCode

	def IsSent()
		return @bSent

	def Body()
		return @cBody

	def Json(aData)
		_cJson_ = This.ObjectToJson(aData)
		This.Header("Content-Type", "application/json")
		This.Send(_cJson_)

	def Text(cText)
		This.Header("Content-Type", "text/plain")
		This.Send(cText)

	def Html(cHtml)
		This.Header("Content-Type", "text/html")
		This.Send(cHtml)

	# Buffer the body; the server transmits HttpBytes() via the reactor.
	def Send(cContent)
		if @bSent return ok
		@cBody = "" + cContent
		@bSent = True

	# Render the full HTTP/1.1 wire form (CRLF line endings,
	# Content-Length in BYTES -- Ring len() is byte-based, correct here).
	def HttpBytes()
		_cCRLF_ = char(13) + char(10)
		_cOut_ = "HTTP/1.1 " + @nStatusCode + " " + @cStatusText + _cCRLF_
		_nLen_ = len(@aHeaders)
		for _i_ = 1 to _nLen_
			_cOut_ += @aHeaders[_i_][1] + ": " + @aHeaders[_i_][2] + _cCRLF_
		next
		_cOut_ += "Content-Length: " + len(@cBody) + _cCRLF_
		_cOut_ += _cCRLF_ + @cBody
		return _cOut_

	def NotFound(cMessage)
		if cMessage = ""
			cMessage = "Not Found"
		ok
		This.Status(404, "Not Found").Text(cMessage)

	def InternalError(cMessage)
		if cMessage = ""
			cMessage = "Internal Server Error"
		ok
		This.Status(500, "Internal Server Error").Text(cMessage)

	def ObjectToJson(obj)
		# Simplified JSON serializer - full implementation needed
		if isstring(obj) return '"' + obj + '"' ok
		if isnumber(obj) return "" + obj ok
		if islist(obj)
			if len(obj) = 0 return "[]" ok

			# Check if it's an associative array (object)
			if isstring(obj[1])
				_cJson_ = "{"
				_nLen2_ = len(obj)
				for _i2_ = 1 to _nLen2_ step 2
					if _i2_ > 1 _cJson_ += "," ok
					_cJson_ += '"' + obj[_i2_] + '":' + This.ObjectToJson(obj[_i2_+1])
				next
				_cJson_ += "}"
				return _cJson_
			else
				# Regular array
				_cJson_ = "["
				_nLen3_ = len(obj)
				for _i3_ = 1 to _nLen3_
					if _i3_ > 1 _cJson_ += "," ok
					_cJson_ += This.ObjectToJson(obj[_i3_])
				next
				_cJson_ += "]"
				return _cJson_
			ok
		ok
		return '""'  # fallback
