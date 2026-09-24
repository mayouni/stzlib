# Builds the reader page: every chapter you ask for, in every language you
# ask for, RUN side by side and observed, then the world pages, then one
# HTML file. Nothing on the page is an output: the page says so on every
# cell, and the build is red if any cell raised or any promise was not kept.
#
#   cd base/education/tools
#   ring build_reader.ring <out.html> [options]
#
#   options:
#     --program <folder>       the program (default ../program)
#     --course <slug>          the course (default elementary-introduction)
#     --overlay <folder>       an institution's overlay laid on
#     --world <name>           a teaching world for the chapters (workplace, cooperative, school)
#     --langs en,fr,ar,ha      the editions to build (default: all the program teaches in)
#     --chapters all|1-3|1,4   which chapters (default all)
#     --worlds all|none|a,b    which world pages (default all that have one)
#
# A scoped build PRINTS what it skipped, by name. Exit 1 on a wrong call, a
# missing edition, or a red cell; the file is still written so you can look.

load "../../stzBase.ring"

func main
	_aA_ = EduBuildArgs()
	if len(_aA_[:rest]) < 1
		EduBuildUsage()
		shutdown(1)
	ok
	_cOut_ = _aA_[:rest][1]
	_bRed_ = 0
	try
		_oP_ = StzProgramQ(_aA_[:program])
		if _aA_[:overlay] != ""
			_oP_.WithOverlay(_aA_[:overlay])
		ok
		if _aA_[:world] != ""
			_oP_.WithWorld(_aA_[:world])
		ok
		_oC_ = _oP_.CourseQ(_aA_[:course])
		_acLangs_ = _oP_.Languages()
		if _aA_[:langs] != ""
			_acLangs_ = StzSplit(_aA_[:langs], ",")
		ok
		_acAll_ = _oC_.ChapterIds()
		_acPick_ = EduBuildPick(_aA_[:chapters], _acAll_)
		_acWAll_ = _oP_.WorldsWithPages()
		_acWPick_ = EduBuildPick(_aA_[:worlds], _acWAll_)
		_oRd_ = new stzEduReader(_oC_)
		? "BUILD " + _oC_.Slug() + " in " + EduBuildJoin(_acLangs_) + ": " + len(_acPick_) + " of " + len(_acAll_) +
		  " chapters, " + len(_acWPick_) + " of " + len(_acWAll_) + " world pages"
		for _i_ = 1 to len(_acPick_)
			_cId_ = _acPick_[_i_]
			_aCh_ = _oC_.RunChapterInQ(_cId_, _acLangs_)
			_cLine_ = "  chapter " + (0 + _oC_.ChapterNumber(_cId_)) + " " + _cId_ + ":"
			for _j_ = 1 to len(_aCh_)
				_oRd_.AddChapter(_aCh_[_j_])
				if _aCh_[_j_].AllCellsRan() and _aCh_[_j_].AllPromisesKept()
					_cLine_ += " " + _acLangs_[_j_]
				else
					_cLine_ += " " + _acLangs_[_j_] + "=RED"
					_bRed_ = 1
				ok
			next
			? _cLine_
		next
		for _i_ = 1 to len(_acWPick_)
			_cW_ = _acWPick_[_i_]
			_aCh_ = _oP_.RunWorldPageInQ(_cW_, _acLangs_)
			_cLine_ = "  world " + _cW_ + ":"
			for _j_ = 1 to len(_aCh_)
				_oRd_.AddWorldPage(_aCh_[_j_])
				if _aCh_[_j_].AllCellsRan() and _aCh_[_j_].AllPromisesKept()
					_cLine_ += " " + _acLangs_[_j_]
				else
					_cLine_ += " " + _acLangs_[_j_] + "=RED"
					_bRed_ = 1
				ok
			next
			? _cLine_
		next
		_oRd_.WriteTo(_cOut_)
		? "WROTE " + _cOut_
		_acSk_ = EduBuildLeftOut(_acAll_, _acPick_)
		if len(_acSk_) > 0
			? "SKIPPED chapters: " + EduBuildJoin(_acSk_)
		ok
		_acSk_ = EduBuildLeftOut(_acWAll_, _acWPick_)
		if len(_acSk_) > 0
			? "SKIPPED worlds: " + EduBuildJoin(_acSk_)
		ok
	catch
		? "ERROR: " + cCatchError
		shutdown(1)
	done
	if _bRed_
		? "RED: a cell raised or a promise was not kept; the page is written but not fit to publish"
		shutdown(1)
	ok

func EduBuildUsage()
	? "usage: ring build_reader.ring <out.html> [--program <folder>] [--course <slug>] [--overlay <folder>]"
	? "                              [--world <name>] [--langs en,fr] [--chapters all|1-3|1,4] [--worlds all|none|a,b]"

func EduBuildArgs()
	_aOpt_ = [ :program = "../program", :course = "elementary-introduction", :overlay = "", :world = "",
		:langs = "", :chapters = "all", :worlds = "all", :rest = [] ]
	_acKeys_ = [ "program", "course", "overlay", "world", "langs", "chapters", "worlds" ]
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

# "all", "none", "1-3", "1,4" (by rank) or "a,b" (by id) against a list of ids.
func EduBuildPick(pcSpec, pacAll)
	_c_ = StzLower(ring_trim(pcSpec))
	if _c_ = "all" or _c_ = ""
		return pacAll
	ok
	_acRes_ = []
	if _c_ = "none"
		return _acRes_
	ok
	_acParts_ = StzSplit(_c_, ",")
	for _i_ = 1 to len(_acParts_)
		_p_ = ring_trim(_acParts_[_i_])
		if EduBuildIsNumber(_p_)
			_n_ = 0 + _p_
			if _n_ >= 1 and _n_ <= len(pacAll)
				_acRes_ + pacAll[_n_]
			ok
		but StzFindFirst("-", _p_) > 0 and EduBuildIsNumber(StzReplace(_p_, "-", ""))
			_acLo_ = StzSplit(_p_, "-")
			for _n_ = (0 + _acLo_[1]) to (0 + _acLo_[2])
				if _n_ >= 1 and _n_ <= len(pacAll)
					_acRes_ + pacAll[_n_]
				ok
			next
		but StzFindFirst(_p_, pacAll) > 0
			_acRes_ + _p_
		ok
	next
	return _acRes_

# Ring's isdigit() judges ONE character; "12" is not a digit to it.
func EduBuildIsNumber(pcText)
	if pcText = ""
		return 0
	ok
	for _i_ = 1 to len(pcText)
		if NOT isdigit(pcText[_i_])
			return 0
		ok
	next
	return 1

func EduBuildLeftOut(pacAll, pacPick)
	_acRes_ = []
	for _i_ = 1 to len(pacAll)
		if StzFindFirst(pacAll[_i_], pacPick) = 0
			_acRes_ + pacAll[_i_]
		ok
	next
	return _acRes_

func EduBuildJoin(pacItems)
	_c_ = ""
	for _i_ = 1 to len(pacItems)
		if _i_ > 1
			_c_ += ", "
		ok
		_c_ += pacItems[_i_]
	next
	return _c_
