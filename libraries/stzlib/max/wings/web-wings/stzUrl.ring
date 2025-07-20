/*
	stzUrl - A Softanzified wrapper for QUrl in RingQt
	Part of the web-wings module in the MAX layer of Softanza library
*/


#-- FUNCTIONAL FORM --

func StzUrlQ(pcUrl)
	return new stzUrl(pcUrl)

func StzUrl(pcUrl)
	return new stzUrl(pcUrl)

Class stzUrl from stzObject

	@oQUrl
	@cUrl = ""

	def init(pcUrl)
		if isString(pcUrl)
			@cUrl = pcUrl
			@oQUrl = new QUrl(pcUrl)
		else
			@cUrl = ""
			@oQUrl = new QUrl("")
		ok

	def Content()
		# Use internal reconstruction only
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
		oResult = new stzUrl("")
		oResult.SetUrl(This.Content())
		return oResult

	#-- CORE URL METHODS --

	def SetUrl(pcUrl)
		@cUrl = pcUrl
		@oQUrl.setUrl(pcUrl, 0) # 0 = TolerantMode
	
	def SetUrlWithMode(pcUrl, nMode)
		@cUrl = pcUrl
		@oQUrl.setUrl(pcUrl, nMode)
	
	def Url()
		return This.Content()

	def IsValid()
		return @oQUrl.isValid()
	
	def IsEmpty()
		return (@cUrl = "" or @cUrl = NULL) and @oQUrl.isEmpty()
	
	def Error()
		return @oQUrl.errorString()
	
	def ErrorString()
		return This.Error()

	def Clear()
		@cUrl = ""
		@oQUrl.clear()

	#-- SCHEME/PROTOCOL --

	def Scheme()
		return @oQUrl.scheme()
	
	def Protocol()
		return This.Scheme()
	
	def SetScheme(pcScheme)
		@oQUrl.setScheme(pcScheme)
		This.ReconstructUrl()

	#-- HOST/DOMAIN/SERVER --

	def Host()
		return @oQUrl.host(0) # 0 = FullyDecoded
	
	def HostWithMode(nMode)
		return @oQUrl.host(nMode)
	
	def Domain()
		return This.Host()
	
	def Server()
		return This.Host()
	
	def SetHost(pcHost)
		@oQUrl.setHost(pcHost, 0)
		This.ReconstructUrl()
	
	def SetHostWithMode(pcHost, nMode)
		@oQUrl.setHost(pcHost, nMode)
		This.ReconstructUrl()

	#-- PORT --

	def Port()
		return @oQUrl.port(-1) # -1 = default port if not specified
	
	def PortWithDefault(nDefault)
		return @oQUrl.port(nDefault)
	
	def SetPort(nPort)
		@oQUrl.setPort(nPort)
		This.ReconstructUrl()

	#-- PATH/LOCATION --

	def Path()
		return @oQUrl.path(0) # 0 = FullyDecoded
	
	def PathWithMode(nMode)
		return @oQUrl.path(nMode)
	
	def Location()
		return This.Path()
	
	def SetPath(pcPath)
		@oQUrl.setPath(pcPath, 0)
		This.ReconstructUrl()
	
	def SetPathWithMode(pcPath, nMode)
		@oQUrl.setPath(pcPath, nMode)
		This.ReconstructUrl()

	#-- FILENAME --

	def FileName()
		return @oQUrl.fileName(0) # 0 = FullyDecoded
	
	def FileNameWithMode(nMode)
		return @oQUrl.fileName(nMode)

	#-- QUERY --

	def Query()
		return @oQUrl.query(0) # 0 = FullyDecoded
	
	def QueryWithMode(nMode)
		return @oQUrl.query(nMode)
	
	def HasQuery()
		return @oQUrl.hasQuery()
	
	def SetQuery(pcQuery)
		@oQUrl.setQuery(pcQuery, 0)
		This.ReconstructUrl()
	
	def SetQueryWithMode(pcQuery, nMode)
		@oQUrl.setQuery(pcQuery, nMode)
		This.ReconstructUrl()

	#-- FRAGMENT --

	def Fragment()
		return @oQUrl.fragment(0) # 0 = FullyDecoded
	
	def FragmentWithMode(nMode)
		return @oQUrl.fragment(nMode)
	
	def HasFragment()
		return @oQUrl.hasFragment()
	
	def SetFragment(pcFragment)
		@oQUrl.setFragment(pcFragment, 0)
		This.ReconstructUrl()
	
	def SetFragmentWithMode(pcFragment, nMode)
		@oQUrl.setFragment(pcFragment, nMode)
		This.ReconstructUrl()

	#-- USER AUTHENTICATION --

	def UserName()
		return @oQUrl.userName(0) # 0 = FullyDecoded
	
	def UserNameWithMode(nMode)
		return @oQUrl.userName(nMode)
	
	def Password()
		return @oQUrl.password(0) # 0 = FullyDecoded
	
	def PasswordWithMode(nMode)
		return @oQUrl.password(nMode)

	def UserInfo()
		return @oQUrl.userInfo(0) # 0 = FullyDecoded
	
	def UserInfoWithMode(nMode)
		return @oQUrl.userInfo(nMode)
	
	def SetUserName(pcUserName)
		@oQUrl.setUserName(pcUserName, 0)
		This.ReconstructUrl()
	
	def SetUserNameWithMode(pcUserName, nMode)
		@oQUrl.setUserName(pcUserName, nMode)
		This.ReconstructUrl()
	
	def SetPassword(pcPassword)
		@oQUrl.setPassword(pcPassword, 0)
		This.ReconstructUrl()
	
	def SetPasswordWithMode(pcPassword, nMode)
		@oQUrl.setPassword(pcPassword, nMode)
		This.ReconstructUrl()
	
	def SetUserInfo(pcUserInfo)
		@oQUrl.setUserInfo(pcUserInfo, 0)
		This.ReconstructUrl()
	
	def SetUserInfoWithMode(pcUserInfo, nMode)
		@oQUrl.setUserInfo(pcUserInfo, nMode)
		This.ReconstructUrl()

	#-- AUTHORITY --

	def Authority()
		return @oQUrl.authority(0) # 0 = FullyDecoded
	
	def AuthorityWithMode(nMode)
		return @oQUrl.authority(nMode)
	
	def SetAuthority(pcAuthority)
		@oQUrl.setAuthority(pcAuthority, 0)
		This.ReconstructUrl()
	
	def SetAuthorityWithMode(pcAuthority, nMode)
		@oQUrl.setAuthority(pcAuthority, nMode)
		This.ReconstructUrl()

	#-- URL TYPE CHECKS --

	def IsRelative()
		return @oQUrl.isRelative()
	
	def IsLocalFile()
		return @oQUrl.isLocalFile()
	
	def IsHttp()
		return lower(This.Scheme()) = "http"
	
	def IsHttps()
		return lower(This.Scheme()) = "https"
	
	def IsFtp()
		return lower(This.Scheme()) = "ftp"
	
	def IsFileScheme()
		return lower(This.Scheme()) = "file"

	#-- URL RELATIONSHIPS --

	def IsParentOf(oOtherUrl)
		if @isObject(oOtherUrl) and ring_classname(oOtherUrl) = "stzurl"
			return @oQUrl.isParentOf(oOtherUrl.QUrlObject())
		ok
		return FALSE
	
	def ResolvedWith(oRelativeUrl)
		if @isObject(oRelativeUrl) and ring_classname(oRelativeUrl) = "stzurl"
			oResolved = @oQUrl.resolved(oRelativeUrl.QUrlObject())
			oResult = new stzUrl("")
			oResult.SetQUrlObject(oResolved)
			# We need to reconstruct the URL string for the resolved object
			oResult.ReconstructUrl()
			return oResult
		ok
		return new stzUrl("")

	#-- FILE OPERATIONS --

	def ToLocalFile()
		return @oQUrl.toLocalFile()
	
	def FromLocalFile(pcFilePath)
		oFileUrl = @oQUrl.fromLocalFile(pcFilePath)
		oResult = new stzUrl("")
		oResult.SetQUrlObject(oFileUrl)
		# Reconstruct URL for file URL
		oResult.ReconstructUrl()
		return oResult

	#-- URL RECONSTRUCTION --

	def ReconstructUrl()
		cUrl = ""
		
		# Add scheme
		cScheme = This.Scheme()
		if cScheme != NULL and cScheme != ""
			cUrl = cScheme + "://"
		ok
		
		# Add user info
		cUserName = This.UserName()
		cPassword = This.Password()
		if (cUserName != NULL and cUserName != "") or (cPassword != NULL and cPassword != "")
			if cUserName != NULL and cUserName != ""
				cUrl += cUserName
			ok
			if cPassword != NULL and cPassword != ""
				cUrl += ":" + cPassword
			ok
			cUrl += "@"
		ok
		
		# Add host
		cHost = This.Host()
		if cHost != NULL and cHost != ""
			cUrl += cHost
		ok
		
		# Add port (only if not default)
		nPort = This.Port()
		if nPort != -1 and nPort != 80 and nPort != 443
			cUrl += ":" + string(nPort)
		ok
		
		# Add path
		cPath = This.Path()
		if cPath != NULL and cPath != ""
			if not substr(cPath, 1, 1) = "/"
				cUrl += "/"
			ok
			cUrl += cPath
		ok
		
		# Add query
		cQuery = This.Query()
		if cQuery != NULL and cQuery != ""
			cUrl += "?" + cQuery
		ok
		
		# Add fragment
		cFragment = This.Fragment()
		if cFragment != NULL and cFragment != ""
			cUrl += "#" + cFragment
		ok
		
		@cUrl = cUrl

	#-- INTERNAL METHODS --

	def QUrlObject()
		return @oQUrl
	
	def SetQUrlObject(oQUrl)
		@oQUrl = oQUrl
		# When setting a new QUrl object, we should reconstruct our URL string
		This.ReconstructUrl()

	def Swap(oOtherUrl)
		if @isObject(oOtherUrl) and ring_classname(oOtherUrl) = "stzurl"
			@oQUrl.swap(oOtherUrl.QUrlObject())
			# After swapping, both objects need URL reconstruction
			This.ReconstructUrl()
			oOtherUrl.ReconstructUrl()
		ok
