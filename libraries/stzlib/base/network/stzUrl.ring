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
	_pH_ = StzEngineUrlParse(pcUrl)
	if _pH_ = ""
		return 0
	ok
	_nValid_ = StzEngineUrlIsValid(_pH_)
	StzEngineUrlFree(_pH_)
	return _nValid_ = 1

func StzUrlScheme(pcUrl)
	_pH_ = StzEngineUrlParse(pcUrl)
	if _pH_ = ""
		return ""
	ok
	_cResult_ = StzEngineUrlScheme(_pH_)
	StzEngineUrlFree(_pH_)
	return _cResult_

func StzUrlHost(pcUrl)
	_pH_ = StzEngineUrlParse(pcUrl)
	if _pH_ = ""
		return ""
	ok
	_cResult_ = StzEngineUrlHost(_pH_)
	StzEngineUrlFree(_pH_)
	return _cResult_

func StzUrlPort(pcUrl)
	_pH_ = StzEngineUrlParse(pcUrl)
	if _pH_ = ""
		return -1
	ok
	_nResult_ = StzEngineUrlPort(_pH_)
	StzEngineUrlFree(_pH_)
	return _nResult_

func StzUrlPath(pcUrl)
	_pH_ = StzEngineUrlParse(pcUrl)
	if _pH_ = ""
		return ""
	ok
	_cResult_ = StzEngineUrlPath(_pH_)
	StzEngineUrlFree(_pH_)
	return _cResult_

func StzUrlQuery(pcUrl)
	_pH_ = StzEngineUrlParse(pcUrl)
	if _pH_ = ""
		return ""
	ok
	_cResult_ = StzEngineUrlQuery(_pH_)
	StzEngineUrlFree(_pH_)
	return _cResult_

func StzUrlFragment(pcUrl)
	_pH_ = StzEngineUrlParse(pcUrl)
	if _pH_ = ""
		return ""
	ok
	_cResult_ = StzEngineUrlFragment(_pH_)
	StzEngineUrlFree(_pH_)
	return _cResult_

# Parses a URL with the engine and gives its parts, with setters that rebuild the text; it never fetches anything.
#
# Reach for it to read or change the scheme, user information, host, port, path, query and fragment
# of one URL, or to move between a file URL and a local file path. The parse is done by the engine
# (stz_url) and is lazy: a part is read the first time it is asked. The setters change the object in
# place and rebuild Content from the parts, leaving out ports 80 and 443. It is not a fetcher
# (stzHttpClient is) and it does not split a query into pairs. A relative reference parses poorly:
# d.html has an empty path and sub/d.html is read with sub as the host. The class sits in
# network/stzUrl.ring, which neither stzlib.ring nor stzBase.ring loads, so a caller loads the file
# itself.
#
#   receiver   o1 = new stzUrl("https://bob:pw@example.com:8080/docs/guide.html?x=1&y=2#top")
#   example    ? o1.Host()
#              #--> example.com
#              ? o1.Port()
#              #--> 8080
#              ? o1.FileName()
#              #--> guide.html
#              o1.SetQuery("a=2")
#              ? o1.Content()
#              #--> https://bob:pw@example.com:8080/docs/guide.html?a=2#top
#   see        stzHttpClient, stzString
Class stzUrl from stzObject

	@cUrl = ""
	@pEngine = ""

	# Cached fields (populated lazily or on parse)
	@cScheme = ""
	@cUserName = ""
	@cPassword = ""
	@cHost = ""
	@nPort = -1
	@cPath = ""
	@cQuery = ""
	@cFragment = ""

	# Builds a URL object by parsing the text with the engine; nothing is fetched, and an empty text builds an empty object.
	#
	#   pcUrl      the URL as text, for example https://example.com:8080/a/b.html?x=1#top
	#   returns    nothing; the object is built
	#   note       text that does not parse is kept as given: IsValid answers FALSE and the parts
	#              are empty
	#   warning    the class is in network/stzUrl.ring but neither stzlib.ring nor stzBase.ring
	#              loads that file, so load it by hand before use
	#   see        SetUrl, IsValid
	def init(pcUrl)
		if isString(pcUrl) and pcUrl != ""
			@cUrl = pcUrl
			@pEngine = StzEngineUrlParse(pcUrl)
		ok

	# Returns the URL as text; when the object is empty it is rebuilt from its parts.
	#
	#   returns    a text
	#   note       Url and ToString are the same call
	#   see        SetContent, Copy, ReconstructUrl
	def Content()
		if @cUrl = "" or @cUrl = ""
			This.ReconstructUrl()
		ok
		return @cUrl

	# Replaces the URL by parsing new text; every part is read again from it.
	#
	#   pcUrl      the new URL as text
	#   returns    nothing
	#   note       it does what SetUrl does
	#   see        SetUrl, Content
	def SetContent(pcUrl)
		@cUrl = pcUrl
		This.SetUrl(pcUrl)

	def ToString()
		return This.Content()

	# Returns a new independent stzUrl built from the current text.
	#
	#   returns    a new stzUrl
	#   see        Content, Swap
	def Copy()
		return new stzUrl(This.Content())

	# Replaces the URL by parsing new text, freeing the previous parse and clearing every cached part.
	#
	#   pcUrl      the new URL as text
	#   returns    nothing
	#   note       the new text is parsed at once, so Host, Path and the others answer for it
	#   see        SetContent, Clear
	#@ aka  -- CORE URL METHODS --
	def SetUrl(pcUrl)
		if @pEngine != ""
			StzEngineUrlFree(@pEngine)
		ok
		@cUrl = pcUrl
		@pEngine = StzEngineUrlParse(pcUrl)
		# Clear cached values
		@cScheme = ""
		@cUserName = ""
		@cPassword = ""
		@cHost = ""
		@nPort = -1
		@cPath = ""
		@cQuery = ""
		@cFragment = ""

	def Url()
		return This.Content()

	# TRUE if the engine parsed the text as an absolute URL with a scheme and a host.
	#
	#   returns    TRUE or FALSE
	#   note       a relative reference such as d.html or /a/b?q=1 answers FALSE even though its
	#              path and query are read; the empty object and text such as :::: also answer FALSE
	#   see        IsEmpty, IsRelative
	def IsValid()
		if @pEngine = ""
			return 0
		ok
		return StzEngineUrlIsValid(@pEngine)

	# TRUE if no URL text is held, which is the case for a new empty object and after Clear.
	#
	#   returns    TRUE or FALSE
	#   note       it reads the held text, so an object built from garbage text is not empty
	#   see        Clear, IsValid
	def IsEmpty()
		return @cUrl = "" or @cUrl = ""

	# Forgets the URL and every part, leaving an empty object.
	#
	#   returns    nothing
	#   see        IsEmpty, SetUrl
	def Clear()
		if @pEngine != ""
			StzEngineUrlFree(@pEngine)
			@pEngine = ""
		ok
		@cUrl = ""
		@cScheme = ""
		@cUserName = ""
		@cPassword = ""
		@cHost = ""
		@nPort = -1
		@cPath = ""
		@cQuery = ""
		@cFragment = ""

	# Returns the scheme, the part before ://, as written in the URL.
	#
	#   returns    a text; empty when there is none
	#   note       the case is kept: HTTP://h/ answers HTTP, while IsHttp compares without regard to
	#              case
	#   see        Protocol, IsHttp, IsHttps
	#@ aka  -- SCHEME/PROTOCOL --
	def Scheme()
		if @cScheme = "" and @pEngine != ""
			@cScheme = StzEngineUrlScheme(@pEngine)
		ok
		if @cScheme = ""
			return ""
		ok
		return @cScheme

	def Protocol()
		return This.Scheme()

	# Sets the scheme and rebuilds the URL text from the parts.
	#
	#   pcScheme   the new scheme, for example https
	#   returns    nothing
	#   note       IsHttps and the other type checks follow at once
	#   see        Scheme, ReconstructUrl
	def SetScheme(pcScheme)
		@cScheme = pcScheme
		This.ReconstructUrl()

	# Returns the host name, without user information or port.
	#
	#   returns    a text; empty when there is none
	#   note       Domain and Server are the same call
	#   see        Domain, Server, Authority
	#@ aka  -- HOST/DOMAIN/SERVER --
	def Host()
		if @cHost = "" and @pEngine != ""
			@cHost = StzEngineUrlHost(@pEngine)
		ok
		if @cHost = ""
			return ""
		ok
		return @cHost

	def Domain()
		return This.Host()

	def Server()
		return This.Host()

	# Sets the host and rebuilds the URL text; the port, path and query are kept.
	#
	#   pcHost     the new host name
	#   returns    nothing
	#   see        Host, SetAuthority
	def SetHost(pcHost)
		@cHost = pcHost
		This.ReconstructUrl()

	# Returns the port written in the URL, or -1 when none is written.
	#
	#   returns    a number
	#   note       a URL without a port answers -1 even for http and https
	#   see        PortWithDefault, SetPort
	#@ aka  -- PORT --
	def Port()
		if @nPort = -1 and @pEngine != ""
			@nPort = StzEngineUrlPort(@pEngine)
		ok
		return @nPort

	# Returns the port of the URL, or the given number when no port is written.
	#
	#   nDefault   the number to answer when the URL has no port
	#   returns    a number
	#   note       0 counts as no port
	#   see        Port
	def PortWithDefault(nDefault)
		if This.Port() = -1 or This.Port() = 0
			return nDefault
		ok
		return @nPort

	# Sets the port and rebuilds the URL text.
	#
	#   nPort      the new port number
	#   returns    nothing
	#   note       the text drops ports 80 and 443 whatever the scheme, so SetPort(80) on https
	#              removes the port from Content
	#   see        Port, ReconstructUrl
	def SetPort(nPort)
		@nPort = nPort
		This.ReconstructUrl()

	# Returns the path, from the first slash after the host up to the query.
	#
	#   returns    a text; empty when there is none
	#   note       the engine reads a bare reference such as sub/d.html with sub as the host and
	#              /d.html as the path; d.html alone has an empty path
	#   see        Location, FileName, SetPath
	#@ aka  -- PATH/LOCATION --
	def Path()
		if @cPath = "" and @pEngine != ""
			@cPath = StzEngineUrlPath(@pEngine)
		ok
		if @cPath = ""
			return ""
		ok
		return @cPath

	def Location()
		return This.Path()

	# Sets the path and rebuilds the URL text; a missing leading slash is added.
	#
	#   pcPath     the new path
	#   returns    nothing
	#   see        Path, SetQuery
	def SetPath(pcPath)
		@cPath = pcPath
		This.ReconstructUrl()

	# Returns the last segment of the path, the part after the final slash.
	#
	#   returns    a text; empty when the path is empty
	#   note       Section(n + 1, n) is out of range; /a/b answers b and an empty path answers an
	#              empty text
	#   warning    Raises error today when the path ends with a slash, on /a/b/ and on / alike: the
	#              section call is given an end before its start
	#   see        Path
	#@ aka  -- FILENAME --
	def FileName()
		_cP_ = This.Path()
		if _cP_ = "" or _cP_ = ""
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

	# Returns the query, the text between ? and #, without the question mark.
	#
	#   returns    a text; empty when there is none
	#   see        HasQuery, SetQuery
	#@ aka  -- QUERY --
	def Query()
		if @cQuery = "" and @pEngine != ""
			@cQuery = StzEngineUrlQuery(@pEngine)
		ok
		if @cQuery = ""
			return ""
		ok
		return @cQuery

	# TRUE if the URL carries a query after a question mark.
	#
	#   returns    TRUE or FALSE
	#   see        Query
	def HasQuery()
		return This.Query() != ""

	# Sets the query and rebuilds the URL text; give it without the question mark.
	#
	#   pcQuery    the new query, for example a=2&b=3
	#   returns    nothing
	#   see        Query, SetFragment
	def SetQuery(pcQuery)
		@cQuery = pcQuery
		This.ReconstructUrl()

	# Returns the fragment, the text after #, without the hash sign.
	#
	#   returns    a text; empty when there is none
	#   see        HasFragment, SetFragment
	#@ aka  -- FRAGMENT --
	def Fragment()
		if @cFragment = "" and @pEngine != ""
			@cFragment = StzEngineUrlFragment(@pEngine)
		ok
		if @cFragment = ""
			return ""
		ok
		return @cFragment

	# TRUE if the URL carries a fragment after a hash sign.
	#
	#   returns    TRUE or FALSE
	#   see        Fragment
	def HasFragment()
		return This.Fragment() != ""

	# Sets the fragment and rebuilds the URL text; give it without the hash sign.
	#
	#   pcFragment   the new fragment, for example end
	#   returns      nothing
	#   see          Fragment, SetQuery
	def SetFragment(pcFragment)
		@cFragment = pcFragment
		This.ReconstructUrl()

	# Returns the user name written before the @ of the authority.
	#
	#   returns    a text; empty when there is none
	#   see        Password, UserInfo, SetUserName
	#@ aka  -- USER AUTHENTICATION --
	def UserName()
		if @cUserName = "" and @pEngine != ""
			@cUserName = StzEngineUrlUser(@pEngine)
		ok
		if @cUserName = ""
			return ""
		ok
		return @cUserName

	# Returns the password written after the colon in the user information.
	#
	#   returns    a text; empty when there is none
	#   note       the password stays readable in Content and Authority: do not log a URL that
	#              carries one
	#   see        UserName, UserInfo, SetPassword
	def Password()
		if @cPassword = "" and @pEngine != ""
			@cPassword = StzEngineUrlPassword(@pEngine)
		ok
		if @cPassword = ""
			return ""
		ok
		return @cPassword

	# Returns the user name and password joined by a colon, or the user name alone.
	#
	#   returns    a text; empty when neither is set
	#   see        UserName, Password, SetUserInfo
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

	# Sets the user name and rebuilds the URL text with it before the host.
	#
	#   pcUserName   the new user name
	#   returns      nothing
	#   see          UserName, SetUserInfo
	def SetUserName(pcUserName)
		@cUserName = pcUserName
		This.ReconstructUrl()

	# Sets the password and rebuilds the URL text; it shows only when a user name or password is set.
	#
	#   pcPassword   the new password
	#   returns      nothing
	#   see          Password, SetUserInfo
	def SetPassword(pcPassword)
		@cPassword = pcPassword
		This.ReconstructUrl()

	# Sets the user name and password from text of the form user:password, or only the user name when there is no colon.
	#
	#   pcUserInfo   the user information, for example zed:pp
	#   returns      nothing
	#   note         text without a colon clears an earlier password
	#   see          UserInfo, SetAuthority
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

	# Returns the user information, host and port joined as user:password@host:port, leaving out what is absent.
	#
	#   returns    a text
	#   note       it prints a port of 80 or 443 when one is set, which Content leaves out
	#   see        Host, Port, UserInfo, SetAuthority
	#@ aka  -- AUTHORITY --
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

	# Sets the user information, host and port from text such as kim:k1@host:9000 and rebuilds the URL text.
	#
	#   pcAuthority   the authority as text
	#   returns       nothing
	#   note          the parts that are given replace the old ones; the others stay
	#   warning       an authority with no user information or no port does not clear the old ones:
	#                 SetAuthority("plain.net") on a URL that had kim:k1 and port 9000 leaves
	#                 kim:k1@plain.net:9000
	#   see           Authority, SetHost
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

	# TRUE if the URL has no scheme, as /a/b or d.html.
	#
	#   returns    TRUE or FALSE
	#   see        Scheme, IsValid
	#@ aka  -- URL TYPE CHECKS --
	def IsRelative()
		return This.Scheme() = ""

	# TRUE if the scheme is file, compared without regard to case.
	#
	#   returns    TRUE or FALSE
	#   note       the same test as IsFileScheme
	#   see        IsFileScheme, ToLocalFile
	def IsLocalFile()
		return StzCaseFold(This.Scheme()) = "file"

	# TRUE if the scheme is http, compared without regard to case; https answers FALSE.
	#
	#   returns    TRUE or FALSE
	#   see        IsHttps, Scheme
	def IsHttp()
		return StzCaseFold(This.Scheme()) = "http"

	# TRUE if the scheme is https, compared without regard to case.
	#
	#   returns    TRUE or FALSE
	#   see        IsHttp, Scheme
	def IsHttps()
		return StzCaseFold(This.Scheme()) = "https"

	# TRUE if the scheme is ftp, compared without regard to case.
	#
	#   returns    TRUE or FALSE
	#   see        Scheme
	def IsFtp()
		return StzCaseFold(This.Scheme()) = "ftp"

	# TRUE if the scheme is file, compared without regard to case.
	#
	#   returns    TRUE or FALSE
	#   note       the same test as IsLocalFile
	#   see        IsLocalFile, ToLocalFile
	def IsFileScheme()
		return StzCaseFold(This.Scheme()) = "file"

	# TRUE if the given URL lies under this one, by host and path, and is longer.
	#
	#   oOtherUrl   the stzUrl to test, where anything that is not an object answers FALSE
	#   returns     TRUE or FALSE
	#   note        the scheme, port and query are not compared; http://h/a/b/ is parent of
	#               http://h/a/b/c but not of itself, and a path with no final slash also matches a
	#               longer name (/a/b matches /a/bc)
	#   see         ResolvedWith, Path
	#@ aka  -- URL RELATIONSHIPS --
	def IsParentOf(oOtherUrl)
		if isObject(oOtherUrl)
			_cMyPath_ = This.Host() + This.Path()
			_cOtherPath_ = oOtherUrl.Host() + oOtherUrl.Path()
			return StzLeft(_cOtherPath_, StzLen(_cMyPath_)) = _cMyPath_ and
				StzLen(_cOtherPath_) > StzLen(_cMyPath_)
		ok
		return 0

	# Returns a new stzUrl made of this URL with the path of the given reference put in place of its own.
	#
	#   oRelativeUrl   the stzUrl to resolve against this one
	#   returns        a new stzUrl; an empty one when the argument is not an object
	#   note           a path that does not start with a slash is joined to the base path up to its
	#                  last slash, but only when the engine gave it a path
	#   warning        resolution is right only for a reference with a leading slash (/c/d.html) or
	#                  a full URL: d.html parses with an empty path and leaves the base unchanged,
	#                  and sub/d.html is read with sub as the host so it answers
	#                  http://plain.org/d.html instead of /a/b/sub/d.html
	#   see            IsParentOf, SetPath
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

	# Returns the file path of a file URL, without the leading slash before a drive letter.
	#
	#   returns    a text; empty when the scheme is not file
	#   note       file:///C:/data/x.txt answers C:/data/x.txt and file:///tmp/x.txt answers
	#              /tmp/x.txt
	#   see        FromLocalFile, IsFileScheme
	#@ aka  -- FILE OPERATIONS --
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

	# Raises error R19 today instead of returning a file URL for the given path.
	#
	#   pcFilePath   the file path to turn into a file URL
	#   returns      a stzUrl, when it works
	#   note         the call that was meant to turn backslashes into slashes is the one that fails
	#   warning      Raises error R19 today whatever the path, on a drive path with backslashes and
	#                on /tmp/y.txt: it calls ReplaceSubstring with two arguments where that method
	#                takes a start, an end and a replacement
	#   see          ToLocalFile
	def FromLocalFile(pcFilePath)
		_oFile_ = new stzString(pcFilePath)
		_oReplacer_ = new stzStringReplacer(_oFile_)
		_oReplacer_.ReplaceSubstring("\", "/")
		_cNorm_ = _oReplacer_.Content()
		if StzLeft(_cNorm_, 1) != "/"
			_cNorm_ = "/" + _cNorm_
		ok
		return new stzUrl("file://" + _cNorm_)

	# Rebuilds the stored URL text from the scheme, user information, host, port, path, query and fragment.
	#
	#   returns    nothing; read the result with Content
	#   note       every setter calls it; ports 80, 443 and -1 are left out of the text
	#   see        Content, SetHost
	#@ aka  -- URL RECONSTRUCTION --
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

	# Exchanges the URLs of this object and the given one, in place on both.
	#
	#   oOtherUrl   the stzUrl to exchange with, where anything that is not an object does nothing
	#   returns     nothing
	#   see         Copy, SetUrl
	def Swap(oOtherUrl)
		if isObject(oOtherUrl)
			_cTemp_ = This.Content()
			This.SetUrl(oOtherUrl.Content())
			oOtherUrl.SetUrl(_cTemp_)
		ok
