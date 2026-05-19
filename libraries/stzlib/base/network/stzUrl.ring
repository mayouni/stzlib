/*
	stzUrl - Engine-backed URL parser
	Uses Zig DLL for parsing via StzEngineUrl* functions.
*/

#-- FUNCTIONAL FORM --

func StzUrlQ(pcUrl)
	return new stzUrl(pcUrl)

func StzUrl(pcUrl)
	return new stzUrl(pcUrl)

func StzUrlIsValid(pcUrl)
	pH = StzEngineUrlParse(pcUrl)
	if pH = NULL
		return FALSE
	ok
	nValid = StzEngineUrlIsValid(pH)
	StzEngineUrlFree(pH)
	return nValid = 1

func StzUrlScheme(pcUrl)
	pH = StzEngineUrlParse(pcUrl)
	if pH = NULL
		return ""
	ok
	cResult = StzEngineUrlScheme(pH)
	StzEngineUrlFree(pH)
	return cResult

func StzUrlHost(pcUrl)
	pH = StzEngineUrlParse(pcUrl)
	if pH = NULL
		return ""
	ok
	cResult = StzEngineUrlHost(pH)
	StzEngineUrlFree(pH)
	return cResult

func StzUrlPort(pcUrl)
	pH = StzEngineUrlParse(pcUrl)
	if pH = NULL
		return -1
	ok
	nResult = StzEngineUrlPort(pH)
	StzEngineUrlFree(pH)
	return nResult

func StzUrlPath(pcUrl)
	pH = StzEngineUrlParse(pcUrl)
	if pH = NULL
		return ""
	ok
	cResult = StzEngineUrlPath(pH)
	StzEngineUrlFree(pH)
	return cResult

func StzUrlQuery(pcUrl)
	pH = StzEngineUrlParse(pcUrl)
	if pH = NULL
		return ""
	ok
	cResult = StzEngineUrlQuery(pH)
	StzEngineUrlFree(pH)
	return cResult

func StzUrlFragment(pcUrl)
	pH = StzEngineUrlParse(pcUrl)
	if pH = NULL
		return ""
	ok
	cResult = StzEngineUrlFragment(pH)
	StzEngineUrlFree(pH)
	return cResult

Class stzUrl from stzObject

	@cUrl = ""
	@pEngine = NULL

	# Cached fields (populated lazily or on parse)
	@cScheme = NULL
	@cUserName = NULL
	@cPassword = NULL
	@cHost = NULL
	@nPort = -1
	@cPath = NULL
	@cQuery = NULL
	@cFragment = NULL

	def init(pcUrl)
		if isString(pcUrl) and pcUrl != ""
			@cUrl = pcUrl
			@pEngine = StzEngineUrlParse(pcUrl)
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
		if @pEngine != NULL
			StzEngineUrlFree(@pEngine)
		ok
		@cUrl = pcUrl
		@pEngine = StzEngineUrlParse(pcUrl)
		# Clear cached values
		@cScheme = NULL
		@cUserName = NULL
		@cPassword = NULL
		@cHost = NULL
		@nPort = -1
		@cPath = NULL
		@cQuery = NULL
		@cFragment = NULL

	def Url()
		return This.Content()

	def IsValid()
		if @pEngine = NULL
			return 0
		ok
		return StzEngineUrlIsValid(@pEngine)

	def IsEmpty()
		return @cUrl = "" or @cUrl = NULL

	def Clear()
		if @pEngine != NULL
			StzEngineUrlFree(@pEngine)
			@pEngine = NULL
		ok
		@cUrl = ""
		@cScheme = NULL
		@cUserName = NULL
		@cPassword = NULL
		@cHost = NULL
		@nPort = -1
		@cPath = NULL
		@cQuery = NULL
		@cFragment = NULL

	#-- SCHEME/PROTOCOL --

	def Scheme()
		if @cScheme = NULL and @pEngine != NULL
			@cScheme = StzEngineUrlScheme(@pEngine)
		ok
		if @cScheme = NULL
			return ""
		ok
		return @cScheme

	def Protocol()
		return This.Scheme()

	def SetScheme(pcScheme)
		@cScheme = pcScheme
		This.ReconstructUrl()

	#-- HOST/DOMAIN/SERVER --

	def Host()
		if @cHost = NULL and @pEngine != NULL
			@cHost = StzEngineUrlHost(@pEngine)
		ok
		if @cHost = NULL
			return ""
		ok
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
		if @nPort = -1 and @pEngine != NULL
			@nPort = StzEngineUrlPort(@pEngine)
		ok
		return @nPort

	def PortWithDefault(nDefault)
		if This.Port() = -1 or This.Port() = 0
			return nDefault
		ok
		return @nPort

	def SetPort(nPort)
		@nPort = nPort
		This.ReconstructUrl()

	#-- PATH/LOCATION --

	def Path()
		if @cPath = NULL and @pEngine != NULL
			@cPath = StzEngineUrlPath(@pEngine)
		ok
		if @cPath = NULL
			return ""
		ok
		return @cPath

	def Location()
		return This.Path()

	def SetPath(pcPath)
		@cPath = pcPath
		This.ReconstructUrl()

	#-- FILENAME --

	def FileName()
		cP = This.Path()
		if cP = "" or cP = NULL
			return ""
		ok
		nPos = 0
		oPath = new stzString(cP)
		acChars = oPath.Chars()
		nLen = len(acChars)
		for i = nLen to 1 step -1
			if acChars[i] = "/"
				nPos = i
				exit
			ok
		next
		if nPos > 0
			return oPath.Section(nPos + 1, nLen)
		ok
		return cP

	#-- QUERY --

	def Query()
		if @cQuery = NULL and @pEngine != NULL
			@cQuery = StzEngineUrlQuery(@pEngine)
		ok
		if @cQuery = NULL
			return ""
		ok
		return @cQuery

	def HasQuery()
		return This.Query() != ""

	def SetQuery(pcQuery)
		@cQuery = pcQuery
		This.ReconstructUrl()

	#-- FRAGMENT --

	def Fragment()
		if @cFragment = NULL and @pEngine != NULL
			@cFragment = StzEngineUrlFragment(@pEngine)
		ok
		if @cFragment = NULL
			return ""
		ok
		return @cFragment

	def HasFragment()
		return This.Fragment() != ""

	def SetFragment(pcFragment)
		@cFragment = pcFragment
		This.ReconstructUrl()

	#-- USER AUTHENTICATION --

	def UserName()
		if @cUserName = NULL and @pEngine != NULL
			@cUserName = StzEngineUrlUser(@pEngine)
		ok
		if @cUserName = NULL
			return ""
		ok
		return @cUserName

	def Password()
		if @cPassword = NULL and @pEngine != NULL
			@cPassword = StzEngineUrlPassword(@pEngine)
		ok
		if @cPassword = NULL
			return ""
		ok
		return @cPassword

	def UserInfo()
		cUser = This.UserName()
		cPass = This.Password()
		if cUser = "" and cPass = ""
			return ""
		ok
		if cPass != ""
			return cUser + ":" + cPass
		ok
		return cUser

	def SetUserName(pcUserName)
		@cUserName = pcUserName
		This.ReconstructUrl()

	def SetPassword(pcPassword)
		@cPassword = pcPassword
		This.ReconstructUrl()

	def SetUserInfo(pcUserInfo)
		oInfo = new stzString(pcUserInfo)
		oFinder = new stzStringFinder(oInfo)
		nColon = oFinder.IndexOf(":")
		if nColon > 0
			@cUserName = oInfo.Section(1, nColon - 1)
			@cPassword = oInfo.Section(nColon + 1, oInfo.NumberOfChars())
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
		cAuth += This.Host()
		nP = This.Port()
		if nP != -1 and nP != 0
			cAuth += ":" + string(nP)
		ok
		return cAuth

	def SetAuthority(pcAuthority)
		oAuth = new stzString(pcAuthority)
		oFinder = new stzStringFinder(oAuth)

		nAt = oFinder.IndexOf("@")
		cWork = pcAuthority
		if nAt > 0
			This.SetUserInfo(oAuth.Section(1, nAt - 1))
			cWork = oAuth.Section(nAt + 1, oAuth.NumberOfChars())
		ok

		oWork = new stzString(cWork)
		oFinder2 = new stzStringFinder(oWork)
		nColon = oFinder2.IndexOf(":")
		if nColon > 0
			@cHost = oWork.Section(1, nColon - 1)
			@nPort = 0 + oWork.Section(nColon + 1, oWork.NumberOfChars())
		else
			@cHost = cWork
		ok
		This.ReconstructUrl()

	#-- URL TYPE CHECKS --

	def IsRelative()
		return This.Scheme() = ""

	def IsLocalFile()
		return StzCaseFold(This.Scheme()) = "file"

	def IsHttp()
		return StzCaseFold(This.Scheme()) = "http"

	def IsHttps()
		return StzCaseFold(This.Scheme()) = "https"

	def IsFtp()
		return StzCaseFold(This.Scheme()) = "ftp"

	def IsFileScheme()
		return StzCaseFold(This.Scheme()) = "file"

	#-- URL RELATIONSHIPS --

	def IsParentOf(oOtherUrl)
		if isObject(oOtherUrl)
			cMyPath = This.Host() + This.Path()
			cOtherPath = oOtherUrl.Host() + oOtherUrl.Path()
			return StzLeft(cOtherPath, StzLen(cMyPath)) = cMyPath and
				StzLen(cOtherPath) > StzLen(cMyPath)
		ok
		return 0

	def ResolvedWith(oRelativeUrl)
		if isObject(oRelativeUrl)
			cRelPath = oRelativeUrl.Path()
			if StzLeft(cRelPath, 1) = "/"
				oResult = new stzUrl(This.Content())
				oResult.SetPath(cRelPath)
				return oResult
			else
				cBasePath = This.Path()
				nSlash = 0
				oBase = new stzString(cBasePath)
				acChars = oBase.Chars()
				nBLen = len(acChars)
				for i = nBLen to 1 step -1
					if acChars[i] = "/"
						nSlash = i
						exit
					ok
				next
				if nSlash > 0
					cNewPath = oBase.Section(1, nSlash) + cRelPath
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
		if StzCaseFold(This.Scheme()) = "file"
			cP = This.Path()
			oP = new stzString(cP)
			if StzLeft(cP, 1) = "/" and oP.NumberOfChars() > 2
				acChars = oP.Chars()
				if acChars[3] = ":"
					return oP.Section(2, oP.NumberOfChars())
				ok
			ok
			return cP
		ok
		return ""

	def FromLocalFile(pcFilePath)
		oFile = new stzString(pcFilePath)
		oReplacer = new stzStringReplacer(oFile)
		oReplacer.ReplaceSubstring("\", "/")
		cNorm = oReplacer.Content()
		if StzLeft(cNorm, 1) != "/"
			cNorm = "/" + cNorm
		ok
		return new stzUrl("file://" + cNorm)

	#-- URL RECONSTRUCTION --

	def ReconstructUrl()
		cUrl = ""

		cSch = This.Scheme()
		if cSch != ""
			cUrl = cSch + "://"
		ok

		cUser = This.UserName()
		cPass = This.Password()
		if cUser != "" or cPass != ""
			if cUser != ""
				cUrl += cUser
			ok
			if cPass != ""
				cUrl += ":" + cPass
			ok
			cUrl += "@"
		ok

		cH = This.Host()
		if cH != ""
			cUrl += cH
		ok

		nP = This.Port()
		if nP != -1 and nP != 0 and nP != 80 and nP != 443
			cUrl += ":" + string(nP)
		ok

		cPth = This.Path()
		if cPth != ""
			if StzLeft(cPth, 1) != "/"
				cUrl += "/"
			ok
			cUrl += cPth
		ok

		cQ = This.Query()
		if cQ != ""
			cUrl += "?" + cQ
		ok

		cFr = This.Fragment()
		if cFr != ""
			cUrl += "#" + cFr
		ok

		@cUrl = cUrl

	def Swap(oOtherUrl)
		if isObject(oOtherUrl)
			cTemp = This.Content()
			This.SetUrl(oOtherUrl.Content())
			oOtherUrl.SetUrl(cTemp)
		ok
