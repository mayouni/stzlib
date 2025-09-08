class stzAppResponse
	oClient = NULL
	bSent = False
	aHeaders = []
	nStatusCode = 200
	cStatusText = "OK"

	def init(oClientRef)
		oClient = oClientRef

	def Status(nCode, cText)
		nStatusCode = nCode
		if cText != "" cStatusText = cText ok
		return This

	def Header(cName, cValue)
		aHeaders + [cName, cValue]
		return This

	def Json(aData)
		cJson = This.ObjectToJson(aData)
		This.Header("Content-Type", "application/json")
		This.Send(cJson)

	def Text(cText)
		This.Header("Content-Type", "text/plain")
		This.Send(cText)

	def Html(cHtml)
		This.Header("Content-Type", "text/html")
		This.Send(cHtml)

	def Send(cContent)
		if bSent return ok
		
		cResponse = "HTTP/1.1 " + nStatusCode + " " + cStatusText + nl
		
		# Add headers
		This.Header("Content-Length", len(cContent))
		for aHeader in aHeaders
			cResponse += aHeader[1] + ": " + aHeader[2] + nl
		next
		
		cResponse += nl + cContent
		
		# Send via TCP server (need reference to server)
		# oTcpServer.SendTo(oClient, cResponse)
		bSent = True

	def NotFound(cMessag)
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
				cJson = "{"
				for i = 1 to len(obj) step 2
					if i > 1 cJson += "," ok
					cJson += '"' + obj[i] + '":' + This.ObjectToJson(obj[i+1])
				next
				cJson += "}"
				return cJson
			else
				# Regular array
				cJson = "["
				for i = 1 to len(obj)
					if i > 1 cJson += "," ok
					cJson += This.ObjectToJson(obj[i])
				next
				cJson += "]"
				return cJson
			ok
		ok
		return '""'  # fallback
