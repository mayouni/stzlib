#--------------------------------------------------------------#
#        SOFTANZA LIBRARY (V0.9) - STZSKILL                    #
#   An accelerative library for Ring applications, and more!   #
#--------------------------------------------------------------#
#                                                              #
#   Description  : A SKILL is a guiding question with three    #
#                  levels, each backed by evidence; a LEVEL of #
#                  the program is earned by a project that     #
#                  passes its guards. The course's CURRICULUM  #
#                  says which chapter trains which skill.      #
#   Version      : V0.9 (2026)                                 #
#   Author       : Mansour Ayouni (kalidianow@gmail.com)       #
#                                                              #
#--------------------------------------------------------------#
#
# On disk, a skill is two things (charter 4, plan B):
#   skills/<id>.zknw        structure: family, evidence, study, anchors
#   skills/<id>.<lang>.md   text: a title line, then question: /
#                           foundation: / practitioner: / expert:
# The keys of the text file are machine words and stay English in every
# language; only the text after them is translated. A skill with no text
# in one of the program's languages is INCOMPLETE, and a guard says which
# language is missing (law 7).
#
# Evidence names what proves a level: `course/exercise` for foundation,
# and a project id for practitioner and expert. Evidence is a CLAIM about
# a guard; whether the guard exists is checked, never assumed.

func StzSkillQ(pcFolder, pcId)
	return new stzSkill(pcFolder, pcId)

class stzSkill from stzObject

	@cFolder = ""
	@cId = ""
	@aFacts = []
	@aText = []     # [ [ lang, [ :title, :question, :foundation, :practitioner, :expert ] ] ]

	def init(pcFolder, pcId)
		@cFolder = _EduNoSlash(pcFolder)
		@cId = StzLower(pcId)
		_cF_ = @cFolder + "/" + @cId + ".zknw"
		if NOT fexists(_cF_)
			StzRaise("No skill '" + @cId + "' under " + @cFolder + ".")
		ok
		@aFacts = _EduFactsOf(_cF_)
		_acFiles_ = StzEngineDirListFiles(@cFolder)
		_nL_ = len(_acFiles_)
		for _i_ = 1 to _nL_
			_cN_ = _acFiles_[_i_]
			if StzLeft(_cN_, StzLen(@cId) + 1) = @cId + "." and StzRight(_cN_, 3) = ".md"
				_cLang_ = StzMid(_cN_, StzLen(@cId) + 2, StzLen(_cN_) - StzLen(@cId) - 4)
				@aText + [ _cLang_, This._ParseText(read(@cFolder + "/" + _cN_)) ]
			ok
		next

	def _ParseText(pcText)
		_aT_ = [ :title = "", :question = "", :foundation = "", :practitioner = "", :expert = "" ]
		_acL_ = StzSplit(StzReplace(pcText, char(13), ""), char(10))
		_nL_ = len(_acL_)
		for _i_ = 1 to _nL_
			_c_ = ring_trim(_acL_[_i_])
			if StzLeft(_c_, 2) = "# "
				_nDot_ = StzFindFirst(" · ", _c_)
				if _nDot_ > 0
					_aT_[:title] = ring_trim(StzRight(_c_, StzLen(_c_) - _nDot_ - 2))
				else
					_aT_[:title] = ring_trim(StzRight(_c_, StzLen(_c_) - 2))
				ok
			else
				_acKeys_ = [ "question", "foundation", "practitioner", "expert" ]
				for _k_ = 1 to 4
					_cK_ = _acKeys_[_k_] + ":"
					if StzLeft(_c_, StzLen(_cK_)) = _cK_
						_aT_[_acKeys_[_k_]] = ring_trim(StzRight(_c_, StzLen(_c_) - StzLen(_cK_)))
					ok
				next
			ok
		next
		return _aT_

	def Id()
		return @cId

	def Family()
		_ac_ = _EduObjects(@aFacts, @cId, "family")
		if len(_ac_) = 0
			return ""
		ok
		return _ac_[1]

	def Study()
		return _EduObjects(@aFacts, @cId, "study")

	def Anchors()
		return _EduObjects(@aFacts, @cId, "anchor")

	# "foundation" | "practitioner" | "expert"
	def Evidence(pcLevel)
		_ac_ = _EduObjects(@aFacts, @cId, StzLower(pcLevel) + "-evidence")
		if len(_ac_) = 0
			return ""
		ok
		return _ac_[1]

	def Languages()
		_ac_ = []
		_nL_ = len(@aText)
		for _i_ = 1 to _nL_
			_ac_ + @aText[_i_][1]
		next
		return _ac_

	def _Text(pcLang)
		_nL_ = len(@aText)
		for _i_ = 1 to _nL_
			if @aText[_i_][1] = StzLower(pcLang)
				return @aText[_i_][2]
			ok
		next
		StzRaise("Skill '" + @cId + "' has no text in '" + pcLang + "'.")

	def Title(pcLang)
		return This._Text(pcLang)[:title]

	def Question(pcLang)
		return This._Text(pcLang)[:question]

	def Level(pcLang, pcLevel)
		return This._Text(pcLang)[StzLower(pcLevel)]

	# The languages, among those asked, in which the text is missing or
	# has an empty field -- [] means complete.
	def MissingIn(pacLangs)
		_acRes_ = []
		_nL_ = len(pacLangs)
		for _i_ = 1 to _nL_
			_cLang_ = pacLangs[_i_]
			_bOk_ = 0
			_nT_ = len(@aText)
			for _j_ = 1 to _nT_
				if @aText[_j_][1] = _cLang_
					_aT_ = @aText[_j_][2]
					if _aT_[:title] != "" and _aT_[:question] != "" and _aT_[:foundation] != "" and
					   _aT_[:practitioner] != "" and _aT_[:expert] != ""
						_bOk_ = 1
					ok
				ok
			next
			if NOT _bOk_
				_acRes_ + _cLang_
			ok
		next
		return _acRes_

	def IsCompleteIn(pacLangs)
		return len(This.MissingIn(pacLangs)) = 0
