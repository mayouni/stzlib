# The reviewer's sheet: everything a native speaker needs to read to sign
# off one translation, in ONE markdown file, and the exact line to record
# the sign-off. A translation is a draft until someone who speaks the
# language has read it; the reader page says so until a line is recorded.
#
#   cd base/education/tools
#   ring review_sheet.ring <out.md> --lang <fr|ar|ha> [options]
#
#   options:
#     --program <folder>    the program (default ../program)
#     --overlay <folder>    an institution's overlay laid on
#
# Prints the coverage (units reviewed of units in all) and what it wrote.
# Exit 1 on a wrong call: no language, the source language (English is
# the original, nothing to review), or a language with no edition at all.

load "../../stzBase.ring"

func main
	_aA_ = EduSheetArgs()
	if len(_aA_[:rest]) < 1 or _aA_[:lang] = ""
		EduSheetUsage()
		shutdown(1)
	ok
	_cOut_ = _aA_[:rest][1]
	_cLang_ = StzLower(_aA_[:lang])
	try
		_oP_ = StzProgramQ(_aA_[:program])
		if _aA_[:overlay] != ""
			_oP_.WithOverlay(_aA_[:overlay])
		ok
		if _cLang_ = _oP_.SourceLanguage()
			? "ERROR: '" + _cLang_ + "' is the source edition; there is nothing to review in it"
			shutdown(1)
		ok
		_acUnits_ = _oP_.ReviewUnits(_cLang_)
		if len(_acUnits_) <= 2
			? "ERROR: no edition in '" + _cLang_ + "' (the program speaks " + @@(_oP_.Languages()) + ")"
			shutdown(1)
		ok
		_cText_ = EduSheetBuild(_oP_, _cLang_, _acUnits_)
		write(_cOut_, _cText_)
		_aC_ = _oP_.ReviewCoverage(_cLang_)
		? "REVIEW SHEET " + _cLang_ + ": " + _aC_[1] + " of " + _aC_[2] + " units reviewed"
		? "WROTE " + _cOut_ + " (" + len(_acUnits_) + " units)"
		_acUnk_ = _oP_.UnknownReviews(_cLang_)
		if len(_acUnk_) > 0
			? "WARNING: review facts naming no unit: " + @@(_acUnk_)
		ok
	catch
		? "ERROR: " + cCatchError
		shutdown(1)
	done

func EduSheetUsage()
	? "usage: ring review_sheet.ring <out.md> --lang <fr|ar|ha> [--program <folder>] [--overlay <folder>]"

func EduSheetArgs()
	_aOpt_ = [ :program = "../program", :overlay = "", :lang = "", :rest = [] ]
	_acKeys_ = [ "program", "overlay", "lang" ]
	_i_ = 3
	_nA_ = len(sysargv)
	while _i_ <= _nA_
		_c_ = sysargv[_i_]
		_bOpt_ = 0
		if StzLeft(_c_, 2) = "--" and _i_ < _nA_
			_cKey_ = StzLower(StzRight(_c_, StzLen(_c_) - 2))
			if StzFindFirst(_cKey_, _acKeys_) > 0
				_aOpt_[_cKey_] = sysargv[_i_ + 1]
				_bOpt_ = 1
				_i_ += 2
			ok
		ok
		if NOT _bOpt_
			_aOpt_[:rest] + _c_
			_i_++
		ok
	end
	return _aOpt_

func EduSheetLangName(pcLang)
	if pcLang = "fr"
		return "Fran" + char(195) + char(167) + "ais"
	ok
	if pcLang = "ar"
		return StzChar(1575) + StzChar(1604) + StzChar(1593) + StzChar(1585) + StzChar(1576) + StzChar(1610) + StzChar(1577)
	ok
	if pcLang = "ha"
		return "Hausa"
	ok
	return pcLang

func EduSheetBuild(poP, pcLang, pacUnits)
	_aC_ = poP.ReviewCoverage(pcLang)
	_c_ = "# Review sheet - " + EduSheetLangName(pcLang) + " (" + pcLang + ") - " + poP.Id() + char(10) + char(10)
	_c_ += "Coverage when this sheet was made: **" + _aC_[1] + " of " + _aC_[2] + " units reviewed** by a native speaker." + char(10) + char(10)
	_c_ += "## What you are asked to do" + char(10) + char(10)
	_c_ += "Read the units below, in this language, as a learner would meet them. Judge the **wording**: is it natural, " +
	       "correct, respectful, at the right level for the reader, and are the technical words the ones people use? " +
	       "Correct anything that is not." + char(10) + char(10)
	_c_ += "- Do **not** change the code inside the fenced blocks, nor any line starting with `#-->`: they are checked by running them, " +
	       "and a change there breaks a guard. A sentence **inside a string** in a cell (for example a natural-language request) is a " +
	       "question for the plane that owns it: mark it in your corrections and leave it." + char(10)
	_c_ += "- Send corrections as the corrected text of the file named at each unit, or as a list of `was -> now` pairs. " +
	       "You do not need to know Softanza or Git." + char(10)
	_c_ += "- The English edition is the original: to compare, ask for the English page " +
	       "(`ring build_reader.ring en.html --langs en`)." + char(10) + char(10)
	_c_ += "## When you have finished a unit, how it is recorded" + char(10) + char(10)
	_c_ += "One line per unit, in a file `program/reviews/" + pcLang + ".zknw` (create it with the first line):" + char(10) + char(10)
	_c_ += "    knowledge " + '"reviews-' + pcLang + '"' + char(10) + char(10) + "    facts" + char(10)
	_c_ += "        <your-name-or-handle> | reviewed | <unit>" + char(10) + char(10)
	_c_ += "`<unit>` is the name in the heading of each unit below. Use a name or handle without spaces (`aminu`, `zainab-m`); " +
	       "it is shown on the page beside the unit, and is yours to choose. Until a unit has such a line, the page says " +
	       "*draft translation*." + char(10) + char(10)
	_c_ += "---" + char(10) + char(10)
	_nU_ = len(pacUnits)
	for _i_ = 1 to _nU_
		_c_ += EduSheetUnit(poP, pcLang, pacUnits[_i_])
	next
	return _c_

func EduSheetUnit(poP, pcLang, pcUnit)
	_cMark_ = "[ ]"
	if poP.IsReviewed(pcLang, pcUnit)
		_cMark_ = "[reviewed by " + EduSheetJoin(poP.ReviewersOf(pcLang, pcUnit)) + "]"
	ok
	if StzLeft(pcUnit, 8) = "chapter:"
		_cRest_ = StzRight(pcUnit, StzLen(pcUnit) - 8)
		_nDot_ = StzFindFirst(".", _cRest_)
		_cSlug_ = StzLeft(_cRest_, _nDot_ - 1)
		_cId_ = StzRight(_cRest_, StzLen(_cRest_) - _nDot_)
		_oC_ = poP.CourseQ(_cSlug_)
		_cF_ = _oC_.ChapterFile(_cId_, pcLang)
		_c_ = "## " + pcUnit + " " + _cMark_ + char(10) + char(10) + "File: `" + _cF_ + "`" + char(10) + char(10)
		_c_ += EduSheetDemote(StzReplace(read(_cF_), char(13), "")) + char(10)
		_acEx_ = _oC_.ExercisesOf(_cId_)
		for _k_ = 1 to len(_acEx_)
			_oEx_ = _oC_.ExerciseQ(_acEx_[_k_])
			if _oEx_.HasTaskIn(pcLang)
				_c_ += "### Exercise " + _acEx_[_k_] + char(10) + char(10) + _oEx_.Task(pcLang) + char(10) + char(10)
			else
				_c_ += "### Exercise " + _acEx_[_k_] + char(10) + char(10) + "(no task in " + pcLang + ")" + char(10) + char(10)
			ok
		next
		return _c_ + "---" + char(10) + char(10)
	ok
	if StzLeft(pcUnit, 6) = "world:"
		_cW_ = StzRight(pcUnit, StzLen(pcUnit) - 6)
		_cF_ = poP.WorldPageFile(_cW_, pcLang)
		_c_ = "## " + pcUnit + " " + _cMark_ + char(10) + char(10) + "File: `" + _cF_ + "`" + char(10) + char(10)
		return _c_ + EduSheetDemote(StzReplace(read(_cF_), char(13), "")) + char(10) + "---" + char(10) + char(10)
	ok
	if pcUnit = "skills"
		_c_ = "## skills " + _cMark_ + char(10) + char(10) + "The twenty-five skills: a guiding question and what a learner can do at each level." + char(10) + char(10)
		_acS_ = poP.SkillIds()
		for _k_ = 1 to len(_acS_)
			_oS_ = poP.SkillQ(_acS_[_k_])
			_c_ += "### " + _acS_[_k_] + " - " + _oS_.Title(pcLang) + char(10) + char(10)
			_c_ += "- question: " + _oS_.Question(pcLang) + char(10)
			_c_ += "- foundation: " + _oS_.Level(pcLang, "foundation") + char(10)
			_c_ += "- practitioner: " + _oS_.Level(pcLang, "practitioner") + char(10)
			_c_ += "- expert: " + _oS_.Level(pcLang, "expert") + char(10) + char(10)
		next
		return _c_ + "---" + char(10) + char(10)
	ok
	_c_ = "## tutor " + _cMark_ + char(10) + char(10) +
	      "What the tutor says and the checker prints, and the questions an exercise asks about its steps. " +
	      "`%1` is filled with the learner's own text." + char(10) + char(10)
	_aT_ = _EduTemplates()
	for _k_ = 1 to len(_aT_)
		if _aT_[_k_][2] = pcLang
			_c_ += "### " + _aT_[_k_][1] + char(10) + char(10) + "- original (en): " + EduSheetEnglish(_aT_, _aT_[_k_][1]) + char(10) +
			       "- " + pcLang + ": " + _aT_[_k_][3] + char(10) + char(10)
		ok
	next
	_acC_ = poP.Courses()
	for _k_ = 1 to len(_acC_)
		_cDir_ = poP.FolderFor("courses/" + _acC_[_k_] + "/exercises")
		if _cDir_ = ""
			loop
		ok
		_acEx_ = StzEngineDirListDirs(_cDir_)
		for _j_ = 1 to len(_acEx_)
			_cG_ = _cDir_ + "/" + _acEx_[_j_] + "/gaps." + pcLang + ".md"
			if fexists(_cG_)
				_c_ += "### questions of exercise " + _acEx_[_j_] + char(10) + char(10) + StzReplace(read(_cG_), char(13), "") + char(10) + char(10)
			ok
		next
	next
	return _c_ + "---" + char(10) + char(10)

# The chapter text as it is, headings demoted one level so the sheet's own
# structure stays the outline (a chapter's "# Title" becomes "### Title").
func EduSheetDemote(pcText)
	_acL_ = StzSplit(pcText, char(10))
	_c_ = ""
	_bIn_ = 0
	for _i_ = 1 to len(_acL_)
		_l_ = _acL_[_i_]
		if StzLeft(ring_trim(_l_), 3) = "```"
			_bIn_ = NOT _bIn_
		ok
		if NOT _bIn_ and StzLeft(_l_, 1) = "#" and StzLeft(ring_trim(_l_), 3) != "```"
			_l_ = "##" + _l_
		ok
		_c_ += _l_ + char(10)
	next
	return _c_

func EduSheetEnglish(paTemplates, pcKey)
	for _i_ = 1 to len(paTemplates)
		if paTemplates[_i_][1] = pcKey and paTemplates[_i_][2] = "en"
			return paTemplates[_i_][3]
		ok
	next
	return ""

func EduSheetJoin(pacItems)
	_c_ = ""
	for _i_ = 1 to len(pacItems)
		if _i_ > 1
			_c_ += ", "
		ok
		_c_ += pacItems[_i_]
	next
	return _c_
