/*
	stzUrl - Pure Ring URL parser
*/

#-- FUNCTIONAL FORM --

func StzUrlQ(pcUrl)
	return new stzUrl(pcUrl)

func StzUrl(pcUrl)
	return new stzUrl(pcUrl)

Class stzUrl from stzObject

	@cUrl = ""

	@cScheme = ""
	@cUserName = ""
	@cPassword = ""
	@cHost = ""
	@nPort = -1
	@cPath = ""
	@cQuery = ""
	@cFragment = ""

	def init(pcUrl)
		if isString(pcUrl)
			@cUrl = pcUrl
			_ParseUrl(pcUrl)
		ok

	def Content()
		if @cUrl = "" or @cUrl = NULL
			This.ReconstructUrl()
		ok
		return @cUrl

	def SetContent(pcUrl)
		@cUrl = pcUrl
		This.SetUrl(pcUrl)

	def ToString()
		return This.Content()

	def Copy()
		return new stzUrl(This.Content())

	#-- CORE URL METHODS --

	def SetUrl(pcUrl)
		@cUrl = pcUrl
		_ParseUrl(pcUrl)

	def Url()
		return This.Content()

	def IsValid()
		return @cScheme != "" and @cHost != ""

	def IsEmpty()
		return @cUrl = "" or @cUrl = NULL

	def Clear()
		@cUrl = ""
		@cScheme = ""
		@cUserName = ""
		@cPassword = ""
		@cHost = ""
		@nPort = -1
		@cPath = ""
		@cQuery = ""
		@cFragment = ""

	#-- SCHEME/PROTOCOL --

	def Scheme()
		return @cScheme

	def Protocol()
		return This.Scheme()

	def SetScheme(pcScheme)
		@cScheme = pcScheme
		This.ReconstructUrl()

	#-- HOST/DOMAIN/SERVER --

	def Host()
		return @cHost

	def Domain()
		return This.Host()

	def Server()
		return This.Host()

	def SetHost(pcHost)
		@cHost = pcHost
		This.ReconstructUrl()

	#-- PORT --

	def Port()
		return @nPort

	def PortWithDefault(nDefault)
		if @nPort = -1
			return nDefault
		ok
		return @nPort

	def SetPort(nPort)
		@nPort = nPort
		This.ReconstructUrl()

	#-- PATH/LOCATION --

	def Path()
		return @cPath

	def Location()
		return This.Path()

	def SetPath(pcPath)
		@cPath = pcPath
		This.ReconstructUrl()

	#-- FILENAME --

	def FileName()
		cP = @cPath
		if cP = "" or cP = NULL
			return ""
		ok
		nPos = 0
		for i = len(cP) to 1 step -1
			if cP[i] = "/"
				nPos = i
				exit
			ok
		next
		if nPos > 0
			return substr(cP, nPos + 1)
		ok
		return cP

	#-- QUERY --

	def Query()
		return @cQuery

	def HasQuery()
		return @cQuery != "" and @cQuery != NULL

	def SetQuery(pcQuery)
		@cQuery = pcQuery
		This.ReconstructUrl()

	#-- FRAGMENT --

	def Fragment()
		return @cFragment

	def HasFragment()
		return @cFragment != "" and @cFragment != NULL

	def SetFragment(pcFragment)
		@cFragment = pcFragment
		This.ReconstructUrl()

	#-- USER AUTHENTICATION --

	def UserName()
		return @cUserName

	def Password()
		return @cPassword

	def UserInfo()
		if @cUserName = "" and @cPassword = ""
			return ""
		ok
		if @cPassword != ""
			return @cUserName + ":" + @cPassword
		ok
		return @cUserName

	def SetUserName(pcUserName)
		@cUserName = pcUserName
		This.ReconstructUrl()

	def SetPassword(pcPassword)
		@cPassword = pcPassword
		This.ReconstructUrl()

	def SetUserInfo(pcUserInfo)
		nColon = substr(pcUserInfo, ":")
		if nColon > 0
			@cUserName = left(pcUserInfo, nColon - 1)
			@cPassword = substr(pcUserInfo, nColon + 1)
		else
			@cUserName = pcUserInfo
			@cPassword = ""
		ok
		This.ReconstructUrl()

	#-- AUTHORITY --

	def Authority()
		cAuth = ""
		cUI = This.UserInfo()
		if cUI != ""
			cAuth += cUI + "@"
		ok
		cAuth += @cHost
		if @nPort != -1
			cAuth += ":" + string(@nPort)
		ok
		return cAuth

	def SetAuthority(pcAuthority)
		cWork = pcAuthority
		nAt = substr(cWork, "@")
		if nAt > 0
			This.SetUserInfo(left(cWork, nAt - 1))
			cWork = substr(cWork, nAt + 1)
		ok
		nColon = substr(cWork, ":")
		if nColon > 0
			@cHost = left(cWork, nColon - 1)
			@nPort = number(substr(cWork, nColon + 1))
		else
			@cHost = cWork
		ok
		This.ReconstructUrl()

	#-- URL TYPE CHECKS --

	def IsRelative()
		return @cScheme = "" or @cScheme = NULL

	def IsLocalFile()
		return lower(@cScheme) = "file"

	def IsHttp()
		return lower(@cScheme) = "http"

	def IsHttps()
		return lower(@cScheme) = "https"

	def IsFtp()
		return lower(@cScheme) = "ftp"

	def IsFileScheme()
		return lower(@cScheme) = "file"

	#-- URL RELATIONSHIPS --

	def IsParentOf(oOtherUrl)
		if isObject(oOtherUrl)
			cMyPath = @cHost + @cPath
			cOtherPath = oOtherUrl.Host() + oOtherUrl.Path()
			return left(cOtherPath, len(cMyPath)) = cMyPath and
				len(cOtherPath) > len(cMyPath)
		ok
		return FALSE

	def ResolvedWith(oRelativeUrl)
		if isObject(oRelativeUrl)
			cRelPath = oRelativeUrl.Path()
			if left(cRelPath, 1) = "/"
				oResult = new stzUrl(This.Content())
				oResult.SetPath(cRelPath)
				return oResult
			else
				cBasePath = @cPath
				nSlash = 0
				for i = len(cBasePath) to 1 step -1
					if cBasePath[i] = "/"
						nSlash = i
						exit
					ok
				next
				if nSlash > 0
					cNewPath = left(cBasePath, nSlash) + cRelPath
				else
					cNewPath = "/" + cRelPath
				ok
				oResult = new stzUrl(This.Content())
				oResult.SetPath(cNewPath)
				return oResult
			ok
		ok
		return new stzUrl("")

	#-- FILE OPERATIONS --

	def ToLocalFile()
		if lower(@cScheme) = "file"
			cP = @cPath
			if substr(cP, 1, 1) = "/" and len(cP) > 2 and cP[3] = ":"
				return substr(cP, 2)
			ok
			return cP
		ok
		return ""

	def FromLocalFile(pcFilePath)
		cNorm = substr(pcFilePath, "\", "/")
		if left(cNorm, 1) != "/"
			cNorm = "/" + cNorm
		ok
		return new stzUrl("file://" + cNorm)

	#-- URL RECONSTRUCTION --

	def ReconstructUrl()
		cUrl = ""

		if @cScheme != "" and @cScheme != NULL
			cUrl = @cScheme + "://"
		ok

		if (@cUserName != "" and @cUserName != NULL) or (@cPassword != "" and @cPassword != NULL)
			if @cUserName != "" and @cUserName != NULL
				cUrl += @cUserName
			ok
			if @cPassword != "" and @cPassword != NULL
				cUrl += ":" + @cPassword
			ok
			cUrl += "@"
		ok

		if @cHost != "" and @cHost != NULL
			cUrl += @cHost
		ok

		if @nPort != -1 and @nPort != 80 and @nPort != 443
			cUrl += ":" + string(@nPort)
		ok

		if @cPath != "" and @cPath != NULL
			if left(@cPath, 1) != "/"
				cUrl += "/"
			ok
			cUrl += @cPath
		ok

		if @cQuery != "" and @cQuery != NULL
			cUrl += "?" + @cQuery
		ok

		if @cFragment != "" and @cFragment != NULL
			cUrl += "#" + @cFragment
		ok

		@cUrl = cUrl

	def Swap(oOtherUrl)
		if isObject(oOtherUrl)
			cTemp = This.Content()
			This.SetUrl(oOtherUrl.Content())
			oOtherUrl.SetUrl(cTemp)
		ok

	#-- PRIVATE PARSER --

	private

	def _ParseUrl(cUrl)
		if cUrl = "" or cUrl = NULL
			return
		ok

		cWork = cUrl

		# Extract fragment
		nHash = substr(cWork, "#")
		if nHash > 0
			@cFragment = substr(cWork, nHash + 1)
			cWork = left(cWork, nHash - 1)
		ok

		# Extract query
		nQ = substr(cWork, "?")
		if nQ > 0
			@cQuery = substr(cWork, nQ + 1)
			cWork = left(cWork, nQ - 1)
		ok

		# Extract scheme
		nScheme = substr(cWork, "://")
		if nScheme > 0
			@cScheme = left(cWork, nScheme - 1)
			cWork = substr(cWork, nScheme + 3)
		ok

		# Extract userinfo
		nAt = substr(cWork, "@")
		if nAt > 0
			cUserInfo = left(cWork, nAt - 1)
			cWork = substr(cWork, nAt + 1)
			nColon = substr(cUserInfo, ":")
			if nColon > 0
				@cUserName = left(cUserInfo, nColon - 1)
				@cPassword = substr(cUserInfo, nColon + 1)
			else
				@cUserName = cUserInfo
			ok
		ok

		# Extract host and port from path
		nSlash = substr(cWork, "/")
		if nSlash > 0
			cHostPort = left(cWork, nSlash - 1)
			@cPath = substr(cWork, nSlash)
		else
			cHostPort = cWork
			@cPath = ""
		ok

		# Split host:port
		nColon = substr(cHostPort, ":")
		if nColon > 0
			@cHost = left(cHostPort, nColon - 1)
			@nPort = number(substr(cHostPort, nColon + 1))
		else
			@cHost = cHostPort
		ok
