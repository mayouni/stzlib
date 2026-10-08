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

	# Builds a skill from the structure file and the per-language text files that share its id in one folder.
	#
	#   pcFolder   the folder that holds the skill files, with or without a trailing slash
	#   pcId       the skill's id, such as cr-01, matched without regard to case
	#   returns    nothing; the object is built
	#   note       the text files are read once, here: a language file added later is not seen by
	#              this object
	#   warning    raises an error naming the id and the folder when the folder has no file
	#              <id>.zknw
	#   see        StzSkillQ, Languages
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

	# Returns the skill's id in lower case, as it names its files.
	#
	#   returns    a text, such as cr-01
	#   see        Family, Title
	def Id()
		return @cId

	# Returns the family the skill belongs to, as declared in its structure file.
	#
	#   returns    a text such as craft; an empty text when no family is declared
	#   see        Anchors, Study
	def Family()
		_ac_ = _EduObjects(@aFacts, @cId, "family")
		if len(_ac_) = 0
			return ""
		ok
		return _ac_[1]

	# Returns the names of the study material that teaches the skill.
	#
	#   returns    a list of text; [ ] when none is declared
	#   see        Anchors, Evidence
	def Study()
		return _EduObjects(@aFacts, @cId, "study")

	# Returns the names of the workplace worlds that anchor the skill's examples.
	#
	#   returns    a list of text, such as school and cooperative; [ ] when none is declared
	#   see        Family, Study
	def Anchors()
		return _EduObjects(@aFacts, @cId, "anchor")

	# Returns what the skill's structure file says proves one level: an exercise for foundation, a project for practitioner and expert.
	#
	#   pcLevel    foundation, practitioner or expert, matched without regard to case
	#   returns    a text such as elementary-introduction/ex-15-01 or project-s3; an empty text for
	#              an unknown level or a level with no evidence
	#   warning    the evidence is a claim about a guard; this call does not check that the exercise
	#              or project exists
	#   see        Level, Study
	#@ aka  "foundation" | "practitioner" | "expert"
	def Evidence(pcLevel)
		_ac_ = _EduObjects(@aFacts, @cId, StzLower(pcLevel) + "-evidence")
		if len(_ac_) = 0
			return ""
		ok
		return _ac_[1]

	# Returns the language codes in which the skill has a text file.
	#
	#   returns    a list of text, in the order the folder lists the files, such as ar, en, fr, ha;
	#              [ ] when the skill has no text file
	#   see        MissingIn, IsCompleteIn
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

	# Returns the skill's title in one language, without its CR-01 style id prefix.
	#
	#   pcLang     the language code, matched without regard to case
	#   returns    a text
	#   warning    raises an error naming the skill and the language when the skill has no text file
	#              in that language
	#   see        Question, Level, Languages
	def Title(pcLang)
		return This._Text(pcLang)[:title]

	# Returns the guiding question of the skill in one language.
	#
	#   pcLang     the language code, matched without regard to case
	#   returns    a text
	#   warning    raises an error naming the skill and the language when the skill has no text file
	#              in that language
	#   see        Title, Level
	def Question(pcLang)
		return This._Text(pcLang)[:question]

	# Returns what a learner can do at one level of the skill, in one language.
	#
	#   pcLang     the language code, matched without regard to case
	#   pcLevel    foundation, practitioner or expert, matched without regard to case
	#   returns    a text; an empty text when the level is unknown or the text file leaves it empty
	#   warning    raises an error naming the skill and the language when the skill has no text file
	#              in that language
	#   see        Question, Evidence
	def Level(pcLang, pcLevel)
		return This._Text(pcLang)[StzLower(pcLevel)]

	# Returns the languages, among those given, in which the skill has no text file or has a text with an empty field.
	#
	#   pacLangs   the language codes to test, in lower case
	#   returns    a list of the codes given, in the order given; [ ] when the skill is complete in
	#              all of them
	#   warning    the codes are compared as written: "EN" is reported missing although en exists,
	#              while Title and Level accept "EN"; the translated texts (fr, ar, ha) are drafts,
	#              0 of 35 units reviewed by a person
	#   see        IsCompleteIn, Languages
	#@ aka  The languages, among those asked, in which the text is missing or has an empty field -- [] means complete.
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

	# TRUE if the skill has a text with a title, a question and all three levels in every language given.
	#
	#   pacLangs   the language codes to test, in lower case
	#   returns    TRUE or FALSE; TRUE for an empty list
	#   warning    same case rule as MissingIn: pass lower-case codes
	#   see        MissingIn, Languages
	def IsCompleteIn(pacLangs)
		return len(This.MissingIn(pacLangs)) = 0
