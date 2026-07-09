#--------------------------------------------------------------#
#       SOFTANZA LIBRARY (V0.9) - STZSTRINGVISUALIZER          #
#   An accelerative library for Ring applications, and more!   #
#--------------------------------------------------------------#
#                                                              #
#   Description  : String visualizer -- Show(), VizFind(),     #
#                  Boxed(), and visual rendering operations.   #
#                  Wraps stzString via composition.            #
#                  For aliases, use stzStringVisualizerXT.     #
#   Version      : V0.9 (2026)                                 #
#   Author       : Mansour Ayouni (kalidianow@gmail.com)       #
#                                                              #
#--------------------------------------------------------------#


class stzStringVisualizer from stzObject

	@oString

	def init(pStrOrStzStrObj)
		if isString(pStrOrStzStrObj)
			@oString = new stzString(pStrOrStzStrObj)
		but isObject(pStrOrStzStrObj)
			@oString = pStrOrStzStrObj
		else
			StzRaise("Can't create stzStringVisualizer! Parameter must be a string or stzString object.")
		ok

	def Content()
		return @oString.Content()

	def NumberOfChars()
		return @oString.NumberOfChars()

	def IsEmpty()
		return @oString.IsEmpty()

	  #===============================#
	 #     SHOW                      #
	#===============================#

	def Show()
		? @oString.Content()

	def ShowShort()
		_nLen_ = @oString.NumberOfChars()
		if _nLen_ <= 50
			? @oString.Content()
		else
			? @oString.Section(1, 47) + "..."
		ok

	def ShowNL()
		? @oString.Content() + NL

	  #===============================#
	 #     VIZFIND                   #
	#===============================#

	def VizFindCharCS(_c_, pCaseSensitive)
		if NOT ( isString(_c_) and StzLen(_c_) = 1 )
			return ""
		ok

		_cResult_ = @@( @oString.Content() )
		_oFinder_ = new stzStringFinder(@oString)
		_anPos_ = _oFinder_.FindCS(_c_, pCaseSensitive)

		_nChars_ = @oString.NumberOfChars()

		_cViz_ = " "
		for i = 1 to _nChars_
			if StzFindFirst(_anPos_, i) > 0
				_cViz_ += "^"
			else
				_cViz_ += "-"
			ok
		next

		return _cResult_ + NL + _cViz_

	def VizFindChar(_c_)
		return This.VizFindCharCS(_c_, 1)

	def VizFindCS(pcSubStr, pCaseSensitive)
		_cResult_ = @@( @oString.Content() )
		_oFinder_ = new stzStringFinder(@oString)
		_anPos_ = _oFinder_.FindCS(pcSubStr, pCaseSensitive)

		_nSubLen_ = StzLen(pcSubStr)
		_nChars_ = @oString.NumberOfChars()

		_cViz_ = " "
		for i = 1 to _nChars_
			_bMarked_ = 0
			_nPosLen_ = len(_anPos_)
			for j = 1 to _nPosLen_
				if i >= _anPos_[j] and i < _anPos_[j] + _nSubLen_
					_bMarked_ = 1
					exit
				ok
			next

			if _bMarked_
				_cViz_ += "^"
			else
				_cViz_ += "-"
			ok
		next

		return _cResult_ + NL + _cViz_

	def VizFind(pcSubStr)
		return This.VizFindCS(pcSubStr, 1)

	  #===============================#
	 #     BOXED                     #
	#===============================#

	def Boxed()
		return This.BoxedXT([ :Line = :Thin, :AllCorners = :Round ])

	def BoxedXT(paOptions)
		_cContent_ = @oString.Content()
		_nLen_ = @oString.NumberOfChars()

		_cCorner_ = "+"
		_cHLine_ = "-"
		_cVLine_ = "|"

		if isList(paOptions)
			_nOptLen_ = len(paOptions)
			for i = 1 to _nOptLen_
				if isList(paOptions[i])
					if len(paOptions[i]) = 2
						if paOptions[i][1] = :AllCorners
							if paOptions[i][2] = :Round
								_cCorner_ = "."
							ok
						ok
						if paOptions[i][1] = :Line
							if paOptions[i][2] = :Dashed
								_cHLine_ = "-"
								_cVLine_ = ":"
							ok
						ok
					ok
				ok
			next
		ok

		_cTop_ = _cCorner_ + ""
		for i = 1 to _nLen_ + 2
			_cTop_ += _cHLine_
		next
		_cTop_ += _cCorner_

		_cMid_ = _cVLine_ + " " + _cContent_ + " " + _cVLine_
		_cBot_ = _cCorner_ + ""
		for i = 1 to _nLen_ + 2
			_cBot_ += _cHLine_
		next
		_cBot_ += _cCorner_

		return _cTop_ + NL + _cMid_ + NL + _cBot_

	def BoxedRounded()
		return This.BoxedXT([ :Line = :Thin, :AllCorners = :Round ])

	  #===============================#
	 #     CHARS BOXED               #
	#===============================#

	def EachCharBoxed()
		_acResult_ = []
		_cContent_ = @oString.Content()
		_nLen_ = @oString.NumberOfChars()

		for i = 1 to _nLen_
			_c_ = @oString.NthChar(i)
			_oViz_ = new stzStringVisualizer(_c_)
			_acResult_ + _oViz_.Boxed()
		next

		return _acResult_

	  #===============================#
	 #     STRINGIFICATION           #
	#===============================#

	def Stringify()
		return @@(@oString.Content())

	  #===============================#
	 #     HIGHLIGHTED               #
	#===============================#

	def HighlightCS(pcSubStr, pcMarker, pCaseSensitive)
		_cContent_ = @oString.Content()
		_cResult_ = @ReplaceCS(_cContent_, pcSubStr, pcMarker + pcSubStr + pcMarker, pCaseSensitive)
		return _cResult_

	def Highlight(pcSubStr, pcMarker)
		return This.HighlightCS(pcSubStr, pcMarker, 1)
