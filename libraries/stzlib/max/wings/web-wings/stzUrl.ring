func StzUrlQ(pUrl)
	return new stzUrl(pUrl)

Class stzUrl from stzObject

	@oQUrl

	def init(pUrl)
		
		if isString(pUrl)
			@oQUrl = new QUrl(pUrl)

		but isObject(pUrl) and ring_classname(pUrl) = "qurl"
			@oQUrl = pUrl

		else
			StzRaise("Can't create the stzUrl object! you must provide a string or a QUrl object.")
		ok

	def Copy()
		oResult = new stzUrl(This.Url())
		return oResult

	  #------------------#
	 #   URL CONTENT    #
	#------------------#


	def Url() #TODO // Ask Mahmoud to QUrl.toString() in RingQt

		cResult = ""
		
		# Add scheme
		cScheme = @oQUrl.scheme()
		if len(cScheme) > 0
			cResult += cScheme + "://"
		ok
		
		# Add user info if present
		cUserInfo = @oQUrl.userInfo(0)
		if len(cUserInfo) > 0
			cResult += cUserInfo + "@"
		ok
		
		# Add host
		cHost = @oQUrl.host(0)
		cResult += cHost
		
		# Add port if not default
		nPort = @oQUrl.port(-1)
		if nPort != -1 and nPort != 80 and nPort != 443
			cResult += ":" + nPort
		ok
		
		# Add path
		cPath = @oQUrl.path(0)
		cResult += cPath
		
		# Add query
		cQuery = @oQUrl.query(0)
		if len(cQuery) > 0
			cResult += "?" + cQuery
		ok
		
		# Add fragment
		cFragment = @oQUrl.fragment(0)
		if len(cFragment) > 0
			cResult += "#" + cFragment
		ok
		
		return cResult

		def Content()
			return Url()

	def SetUrl(pcUrl)
		@oQUrl.setUrl(pcUrl, 0)

	def QUrlObject()
		return @oQUrl

	  #------------------#
	 #   URL PARTS      #
	#------------------#

	def Scheme()
		return @oQUrl.scheme()

	def SetScheme(pcScheme)
		@oQUrl.setScheme(pcScheme)

	def Authority()
		return @oQUrl.authority(0)

	def SetAuthority(pcAuthority)
		@oQUrl.setAuthority(pcAuthority, 0)

	def Host()
		return @oQUrl.host(0)

	def SetHost(pcHost)
		@oQUrl.setHost(pcHost, 0)

	def Port()
		return @oQUrl.port(-1)

	def SetPort(nPort)
		@oQUrl.setPort(nPort)

	def Path()
		return @oQUrl.path(0)

	def SetPath(pcPath)
		@oQUrl.setPath(pcPath, 0)

	def Query()
		return @oQUrl.query(0)

	def SetQuery(pcQuery)
		@oQUrl.setQuery(pcQuery, 0)

	def Fragment()
		return @oQUrl.fragment(0)

	def SetFragment(pcFragment)
		@oQUrl.setFragment(pcFragment, 0)

	def FileName()
		return @oQUrl.fileName(0)

	def UserName()
		return @oQUrl.userName(0)

	def SetUserName(pcUserName)
		@oQUrl.setUserName(pcUserName, 0)

	def Password()
		return @oQUrl.password(0)

	def SetPassword(pcPassword)
		@oQUrl.setPassword(pcPassword, 0)

	def UserInfo()
		return @oQUrl.userInfo(0)

	def SetUserInfo(pcUserInfo)
		@oQUrl.setUserInfo(pcUserInfo, 0)

	  #------------------#
	 #   URL CHECKING   #
	#------------------#

	def IsEmpty()
		return @oQUrl.isEmpty()

	def IsValid()
		return @oQUrl.isValid()

	def IsRelative()
		return @oQUrl.isRelative()

	def IsAbsolute()
		return not This.IsRelative()

	def IsLocalFile()
		return @oQUrl.isLocalFile()

	def HasFragment()
		return @oQUrl.hasFragment()

	def HasQuery()
		return @oQUrl.hasQuery()

	def IsParentOf(oOtherUrl)
		if isObject(oOtherUrl) and ring_classname(oOtherUrl) = "stzurl"
			return @oQUrl.isParentOf(oOtherUrl.QUrlObject())
		ok
		return FALSE

	  #------------------#
	 #   URL OPERATIONS #
	#------------------#

	def Clear()
		@oQUrl.clear()

	def ResolvedWith(oOtherUrl)
		if isObject(oOtherUrl) and ring_classname(oOtherUrl) = "stzurl"
			oResolvedUrl = @oQUrl.resolved(oOtherUrl.QUrlObject())
			return new stzUrl(oResolvedUrl)
		ok
		return This.Copy()

	def ToLocalFile()
		return @oQUrl.toLocalFile()

	def Error()
		return @oQUrl.errorString()

		def ErrorString()
			return This.Error()

	def Swap(oOtherUrl)
		if isObject(oOtherUrl) and ring_classname(oOtherUrl) = "stzurl"
			@oQUrl.swap(oOtherUrl.QUrlObject())
		ok

	  #------------------#
	 #   STATIC METHODS #
	#------------------#

	def FromLocalFile(pcFilePath)
		oQUrl = @oQUrl.fromLocalFile(pcFilePath)
		return new stzUrl(oQUrl)

	  #------------------#
	 #   ALTERNATIVE    #
	 #   NAMING         #
	#------------------#

	def Uri()
		return This.Url()

	def SetUri(pcUri)
		This.SetUrl(pcUri)

	def IsUri()
		return This.IsValid()

	def ClearUri()
		This.Clear()

	def GetScheme()
		return This.Scheme()

	def GetAuthority()
		return This.Authority()

	def GetHost()
		return This.Host()

	def GetPort()
		return This.Port()

	def GetPath()
		return This.Path()

	def GetQuery()
		return This.Query()

	def GetFragment()
		return This.Fragment()

	def GetFileName()
		return This.FileName()

	def GetUserName()
		return This.UserName()

	def GetPassword()
		return This.Password()

	def GetUserInfo()
		return This.UserInfo()

	  #------------------#
	 #   SEMANTICS      #
	#------------------#

	def Protocol()
		return This.Scheme()

	def SetProtocol(pcProtocol)
		This.SetScheme(pcProtocol)

	def Domain()
		return This.Host()

	def SetDomain(pcDomain)
		This.SetHost(pcDomain)

	def Server()
		return This.Host()

	def SetServer(pcServer)
		This.SetHost(pcServer)

	def Location()
		return This.Path()

	def SetLocation(pcLocation)
		This.SetPath(pcLocation)

	def Parameters()
		return This.Query()

	def SetParameters(pcParameters)
		This.SetQuery(pcParameters)

	def Anchor()
		return This.Fragment()

	def SetAnchor(pcAnchor)
		This.SetFragment(pcAnchor)

	def IsFile()
		return This.IsLocalFile()

	def HasParameters()
		return This.HasQuery()

	def HasAnchor()
		return This.HasFragment()

	def ResolveWith(oOtherUrl)
		return This.ResolvedWith(oOtherUrl)

	def IsValidUrl()
		return This.IsValid()

	def IsEmptyUrl()
		return This.IsEmpty()

	def IsRelativeUrl()
		return This.IsRelative()

	def IsAbsoluteUrl()
		return This.IsAbsolute()

	def LocalFilePath()
		return This.ToLocalFile()

	def LastError()
		return This.ErrorString()

	def IsHttps()
		return (This.Scheme() = "https")

	def IsHttp()
		return (This.Scheme() = "http")

	def IsFtp()
		return (This.Scheme() = "ftp")

	def IsFileScheme()
		return (This.Scheme() = "file")
