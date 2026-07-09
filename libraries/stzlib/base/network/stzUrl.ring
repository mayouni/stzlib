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
	_nValid_ = StzEngineUrlIsValid(pH)
	StzEngineUrlFree(pH)
	return _nValid_ = 1

func StzUrlScheme(pcUrl)
	pH = StzEngineUrlParse(pcUrl)
	if pH = NULL
		return ""
	ok
	_cResult_ = StzEngineUrlScheme(pH)
	StzEngineUrlFree(pH)
	return _cResult_

func StzUrlHost(pcUrl)
	pH = StzEngineUrlParse(pcUrl)
	if pH = NULL
		return ""
	ok
	_cResult_ = StzEngineUrlHost(pH)
	StzEngineUrlFree(pH)
	return _cResult_

func StzUrlPort(pcUrl)
	pH = StzEngineUrlParse(pcUrl)
	if pH = NULL
		return -1
	ok
	_nResult_ = StzEngineUrlPort(pH)
	StzEngineUrlFree(pH)
	return _nResult_

func StzUrlPath(pcUrl)
	pH = StzEngineUrlParse(pcUrl)
	if pH = NULL
		return ""
	ok
	_cResult_ = StzEngineUrlPath(pH)
	StzEngineUrlFree(pH)
	return _cResult_

func StzUrlQuery(pcUrl)
	pH = StzEngineUrlParse(pcUrl)
	if pH = NULL
		return ""
	ok
	_cResult_ = StzEngineUrlQuery(pH)
	StzEngineUrlFree(pH)
	return _cResult_

func StzUrlFragment(pcUrl)
	pH = StzEngineUrlParse(pcUrl)
	if pH = NULL
		return ""
	ok
	_cResult_ = StzEngineUrlFragment(pH)
	StzEngineUrlFree(pH)
	return _cResult_

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
		_cP_ = This.Path()
		if _cP_ = "" or _cP_ = NULL
			return ""
		ok
		_nPos_ = 0
		_oPath_ = new stzString(_cP_)
		_acChars_ = _oPath_.Chars()
		_nLen_ = len(_acChars_)
		for i = _nLen_ to 1 step -1
			if _acChars_[i] = "/"
				_nPos_ = i
				exit
			ok
		next
		if _nPos_ > 0
			return _oPath_.Section(_nPos_ + 1, _nLen_)
		ok
		return _cP_

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
		_cUser_ = This.UserName()
		_cPass_ = This.Password()
		if _cUser_ = "" and _cPass_ = ""
			return ""
		ok
		if _cPass_ != ""
			return _cUser_ + ":" + _cPass_
		ok
		return _cUser_

	def SetUserName(pcUserName)
		@cUserName = pcUserName
		This.ReconstructUrl()

	def SetPassword(pcPassword)
		@cPassword = pcPassword
		This.ReconstructUrl()

	def SetUserInfo(pcUserInfo)
		_oInfo_ = new stzString(pcUserInfo)
		_oFinder_ = new stzStringFinder(_oInfo_)
		_nColon_ = _oFinder_.IndexOf(":")
		if _nColon_ > 0
			@cUserName = _oInfo_.Section(1, _nColon_ - 1)
			@cPassword = _oInfo_.Section(_nColon_ + 1, _oInfo_.NumberOfChars())
		else
			@cUserName = pcUserInfo
			@cPassword = ""
		ok
		This.ReconstructUrl()

	#-- AUTHORITY --

	def Authority()
		_cAuth_ = ""
		_cUI_ = This.UserInfo()
		if _cUI_ != ""
			_cAuth_ += _cUI_ + "@"
		ok
		_cAuth_ += This.Host()
		_nP_ = This.Port()
		if _nP_ != -1 and _nP_ != 0
			_cAuth_ += ":" + string(_nP_)
		ok
		return _cAuth_

	def SetAuthority(pcAuthority)
		_oAuth_ = new stzString(pcAuthority)
		_oFinder_ = new stzStringFinder(_oAuth_)

		_nAt_ = _oFinder_.IndexOf("@")
		_cWork_ = pcAuthority
		if _nAt_ > 0
			This.SetUserInfo(_oAuth_.Section(1, _nAt_ - 1))
			_cWork_ = _oAuth_.Section(_nAt_ + 1, _oAuth_.NumberOfChars())
		ok

		_oWork_ = new stzString(_cWork_)
		_oFinder2_ = new stzStringFinder(_oWork_)
		_nColon_ = _oFinder2_.IndexOf(":")
		if _nColon_ > 0
			@cHost = _oWork_.Section(1, _nColon_ - 1)
			@nPort = 0 + _oWork_.Section(_nColon_ + 1, _oWork_.NumberOfChars())
		else
			@cHost = _cWork_
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
			_cMyPath_ = This.Host() + This.Path()
			_cOtherPath_ = oOtherUrl.Host() + oOtherUrl.Path()
			return StzLeft(_cOtherPath_, StzLen(_cMyPath_)) = _cMyPath_ and
				StzLen(_cOtherPath_) > StzLen(_cMyPath_)
		ok
		return 0

	def ResolvedWith(oRelativeUrl)
		if isObject(oRelativeUrl)
			_cRelPath_ = oRelativeUrl.Path()
			if StzLeft(_cRelPath_, 1) = "/"
				_oResult_ = new stzUrl(This.Content())
				_oResult_.SetPath(_cRelPath_)
				return _oResult_
			else
				_cBasePath_ = This.Path()
				_nSlash_ = 0
				_oBase_ = new stzString(_cBasePath_)
				_acChars_ = _oBase_.Chars()
				_nBLen_ = len(_acChars_)
				for i = _nBLen_ to 1 step -1
					if _acChars_[i] = "/"
						_nSlash_ = i
						exit
					ok
				next
				if _nSlash_ > 0
					_cNewPath_ = _oBase_.Section(1, _nSlash_) + _cRelPath_
				else
					_cNewPath_ = "/" + _cRelPath_
				ok
				_oResult_ = new stzUrl(This.Content())
				_oResult_.SetPath(_cNewPath_)
				return _oResult_
			ok
		ok
		return new stzUrl("")

	#-- FILE OPERATIONS --

	def ToLocalFile()
		if StzCaseFold(This.Scheme()) = "file"
			_cP_ = This.Path()
			_oP_ = new stzString(_cP_)
			if StzLeft(_cP_, 1) = "/" and _oP_.NumberOfChars() > 2
				_acChars_ = _oP_.Chars()
				if _acChars_[3] = ":"
					return _oP_.Section(2, _oP_.NumberOfChars())
				ok
			ok
			return _cP_
		ok
		return ""

	def FromLocalFile(pcFilePath)
		_oFile_ = new stzString(pcFilePath)
		_oReplacer_ = new stzStringReplacer(_oFile_)
		_oReplacer_.ReplaceSubstring("\", "/")
		_cNorm_ = _oReplacer_.Content()
		if StzLeft(_cNorm_, 1) != "/"
			_cNorm_ = "/" + _cNorm_
		ok
		return new stzUrl("file://" + _cNorm_)

	#-- URL RECONSTRUCTION --

	def ReconstructUrl()
		_cUrl_ = ""

		_cSch_ = This.Scheme()
		if _cSch_ != ""
			_cUrl_ = _cSch_ + "://"
		ok

		_cUser_ = This.UserName()
		_cPass_ = This.Password()
		if _cUser_ != "" or _cPass_ != ""
			if _cUser_ != ""
				_cUrl_ += _cUser_
			ok
			if _cPass_ != ""
				_cUrl_ += ":" + _cPass_
			ok
			_cUrl_ += "@"
		ok

		_cH_ = This.Host()
		if _cH_ != ""
			_cUrl_ += _cH_
		ok

		_nP_ = This.Port()
		if _nP_ != -1 and _nP_ != 0 and _nP_ != 80 and _nP_ != 443
			_cUrl_ += ":" + string(_nP_)
		ok

		_cPth_ = This.Path()
		if _cPth_ != ""
			if StzLeft(_cPth_, 1) != "/"
				_cUrl_ += "/"
			ok
			_cUrl_ += _cPth_
		ok

		_cQ_ = This.Query()
		if _cQ_ != ""
			_cUrl_ += "?" + _cQ_
		ok

		_cFr_ = This.Fragment()
		if _cFr_ != ""
			_cUrl_ += "#" + _cFr_
		ok

		@cUrl = _cUrl_

	def Swap(oOtherUrl)
		if isObject(oOtherUrl)
			_cTemp_ = This.Content()
			This.SetUrl(oOtherUrl.Content())
			oOtherUrl.SetUrl(_cTemp_)
		ok
