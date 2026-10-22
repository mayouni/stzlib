# The HTTP response VALUE OBJECT (R7 re-base, 2026-07-14): handlers
# compose it fluently (Status/Header/Json/Text/Html/Send); the server
# renders it with HttpBytes() and writes those bytes through the
# reactor. Send() BUFFERS -- no socket I/O happens in this class.
#
# Attributes carry the @ scope sigil: in Ring 1.27 a BARE class-head
# attribute whose name matches an existing user GLOBAL binds the
# global instead of creating the attribute (verified 2026-07-14 --
# `oClient`/`cBody` globals were clobbered at `new`, then R12).

# Holds one HTTP response that a handler fills and the server renders to bytes; it does no socket work itself.
#
# Status, Header, Text, Html and Json compose it. Send buffers the body once and marks it sent;
# HttpBytes renders the HTTP/1.1 wire form with CRLF line endings and a Content-Length counted in
# bytes. Json uses a simple serializer in which a flat [ key, value, ... ] list is an object; see
# its warning for the shapes it gets wrong.
#
#   receiver   o1 = new stzAppResponse("")
#   example    o1.Status(201, "Created")
#              o1.Json([ "id", 7, "name", "Ana" ])
#              ? o1.Body()
#              #--> {"id":7,"name":"Ana"}
#              ? o1.StatusCode()
#              #--> 201
#   see        stzAppRequest, stzAppRouter, stzAppServer
class stzAppResponse from stzObject
	@oClient = ""   # legacy constructor slot (pre-reactor); unused
	@bSent = 0
	@aHeaders = []
	@nStatusCode = 200
	@cStatusText = "OK"
	@cBody = ""

	# Builds an empty response with status 200 OK and no headers, ready to be filled and sent.
	#
	#   oClientRef   a legacy slot from before the reactor, kept and never used
	#   returns      nothing; the object is built
	#   see          Status, Send
	def init(oClientRef)
		@oClient = oClientRef

	# Sets the status code and, when text is given, the reason phrase that HttpBytes writes.
	#
	#   nCode      the status code, such as 404
	#   cText      the reason phrase
	#   returns    the response itself, so calls chain
	#   warning    an empty cText keeps the previous phrase, so Status(202, "") after Status(201,
	#              "Created") reads 202 Created
	#   see        StatusCode, NotFound
	def Status(nCode, cText)
		@nStatusCode = nCode
		if cText != "" @cStatusText = cText ok
		return This

	# Adds a header to the response; the same name added twice is written twice, never replaced.
	#
	#   cName      the header name
	#   cValue     the header value
	#   returns    the response itself, so calls chain
	#   see        Headers, Text
	def Header(cName, cValue)
		@aHeaders + [cName, cValue]
		return This

	# Returns the headers added so far as a list of [ name, value ] pairs, in order.
	#
	#   returns    a list of [ text, text ] pairs
	#   see        Header
	def Headers()
		return @aHeaders

	# Returns the status code, 200 until Status changes it.
	#
	#   returns    a number
	#   see        Status
	def StatusCode()
		return @nStatusCode

	# TRUE if a body has been buffered by Send, Text, Html or Json.
	#
	#   returns    1 or 0, numbers
	#   see        Send, Body
	def IsSent()
		return @bSent

	# Returns the buffered body, an empty text before anything is sent.
	#
	#   returns    a text
	#   see        Send, HttpBytes
	def Body()
		return @cBody

	# Serializes a value to JSON, adds the application/json content type and buffers it as the body.
	#
	#   aData      the value: a flat list [ key, value, key, value ] becomes an object, any other
	#              list an array
	#   returns    nothing
	#   note       build the object as a flat list and the output is what a client expects
	#   warning    a Ring hash list of pairs such as [ :a = 1 ] becomes an array of one-pair
	#              objects, not an object; a list of two texts becomes an object; a list of an odd
	#              number of texts raises R2; an object inside the data becomes ""
	#   note       texts and keys are written through the engine's JSON string writer, so a
	#              quote, a backslash or a control character inside one stays a valid document
	#   see        ObjectToJson, Text, Send
	def Json(aData)
		_cJson_ = This.ObjectToJson(aData)
		This.Header("Content-Type", "application/json")
		This.Send(_cJson_)

	# Adds the text/plain content type and buffers the text as the body.
	#
	#   cText      the text to send
	#   returns    nothing
	#   see        Html, Json, Send
	def Text(cText)
		This.Header("Content-Type", "text/plain")
		This.Send(cText)

	# Adds the text/html content type and buffers the markup as the body.
	#
	#   cHtml      the HTML text to send
	#   returns    nothing
	#   see        Text, Json, Send
	def Html(cHtml)
		This.Header("Content-Type", "text/html")
		This.Send(cHtml)

	# Buffers the body and marks the response sent; nothing is written to a socket, and a second call changes nothing.
	#
	#   cContent   the body, a text or a number, kept as text
	#   returns    nothing
	#   note       the server writes HttpBytes through the reactor
	#   warning    once sent, the body can not be replaced, though Status and Header still change
	#              the object
	#   see        HttpBytes, IsSent
	#@ aka  Buffer the body; the server transmits HttpBytes() via the reactor.
	def Send(cContent)
		if @bSent return ok
		@cBody = "" + cContent
		@bSent = 1

	# Renders the whole HTTP/1.1 response: status line, headers, a Content-Length counted in bytes, a blank line, then the body, all with CRLF.
	#
	#   returns    a text
	#   note       a text with an accented e counts 2 bytes in Content-Length
	#   see        Send, Status
	#@ aka  Render the full HTTP/1.1 wire form (CRLF line endings, Content-Length in BYTES -- Ring len() is byte-based, correct here).
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

	# Sets status 404 and sends the message as plain text, Not Found when the message is empty.
	#
	#   cMessage   the text of the page, or an empty text for the default
	#   returns    nothing
	#   see        InternalError, Status
	def NotFound(cMessage)
		if cMessage = ""
			cMessage = "Not Found"
		ok
		This.Status(404, "Not Found").Text(cMessage)

	# Sets status 500 and sends the message as plain text, Internal Server Error when the message is empty.
	#
	#   cMessage   the text of the page, or an empty text for the default
	#   returns    nothing
	#   see        NotFound, Status
	def InternalError(cMessage)
		if cMessage = ""
			cMessage = "Internal Server Error"
		ok
		This.Status(500, "Internal Server Error").Text(cMessage)

	# Returns the JSON text of a text, a number or a list; this is the simple serializer behind Json.
	#
	#   obj        the value to serialize
	#   returns    a text such as {"id":7}
	#   note       numbers keep the library's own formatting, so 3.5 reads 3.50
	#   warning    the same limits as Json: a list that starts with a text is read as key and value
	#              pairs and an object becomes ""; a text is written through StzJsonString
	#   see        Json
	def ObjectToJson(obj)
		# a text is the engine's JSON string literal, quotes included (RX1)
		if isstring(obj) return StzJsonString(obj) ok
		if isnumber(obj) return "" + obj ok
		if islist(obj)
			if len(obj) = 0 return "[]" ok

			# Check if it's an associative array (object)
			if isstring(obj[1])
				_cJson_ = "{"
				_nLen2_ = len(obj)
				for _i2_ = 1 to _nLen2_ step 2
					if _i2_ > 1 _cJson_ += "," ok
					_cJson_ += StzJsonString(obj[_i2_]) + ':' + This.ObjectToJson(obj[_i2_+1])
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
