# The learner's desk, at the command line: where you are, what you
# submit, what the tutor says, and the project that earns a level.
#
#   cd base/education/tools
#   ring learn.ring <learner folder> status
#   ring learn.ring <learner folder> submit <exercise id> <your .ring file>
#   ring learn.ring <learner folder> ask <exercise id> "<your question>"
#   ring learn.ring <learner folder> project <project id>
#         (judges <learner folder>/projects/<project id>, your own folder)
#
#   options, anywhere after the folder:
#     --program <folder>     the program (default ../program)
#     --course <slug>        the course (default elementary-introduction)
#     --overlay <folder>     your institution's overlay
#     --world <name>         a teaching world: workplace, cooperative, school
#     --lang <en|fr|ar|ha>   the language the checker and the tutor answer in
#
# Exit codes: 0 done (a submission passed), 2 a submission was refused,
# 1 a wrong call or an error. Every verdict here is the checker's: it RAN
# your file in a fresh process; nobody read it. The tutor answers in your
# language, so its reply is not ASCII outside English.

load "../../stzBase.ring"

func main
	_aA_ = EduDeskArgs()
	_acRest_ = _aA_[:rest]
	if len(_acRest_) < 2
		EduDeskUsage()
		shutdown(1)
	ok
	_cLearner_ = _acRest_[1]
	_cVerb_ = StzLower(_acRest_[2])
	_cLang_ = _aA_[:lang]
	if StzFindFirst(_cVerb_, [ "status", "submit", "ask", "project" ]) = 0
		EduDeskUsage()
		shutdown(1)
	ok
	try
		_oP_ = StzProgramQ(_aA_[:program])
		if _aA_[:overlay] != ""
			_oP_.WithOverlay(_aA_[:overlay])
		ok
		if _aA_[:world] != ""
			_oP_.WithWorld(_aA_[:world])
		ok
		_oC_ = _oP_.CourseQ(_aA_[:course])
		_oL_ = StzLearnerQ(_cLearner_)

		switch _cVerb_
		on "status"
			EduDeskStatus(_oP_, _oC_, _oL_, _cLang_)

		on "submit"
			if len(_acRest_) < 4
				EduDeskUsage()
				shutdown(1)
			ok
			if NOT fexists(_acRest_[4])
				? "ERROR: no such file: " + _acRest_[4]
				shutdown(1)
			ok
			_oEx_ = _oC_.ExerciseQ(_acRest_[3])
			_oCk_ = _oL_.Submit(_oEx_, read(_acRest_[4]))
			if _oCk_.Passed()
				? "PASSED " + _oEx_.Id() + ": " + _oCk_.WhyIn(_cLang_)
			else
				? "REFUSED " + _oEx_.Id() + ": " + _oCk_.WhyIn(_cLang_)
				shutdown(2)
			ok

		on "ask"
			if len(_acRest_) < 4
				EduDeskUsage()
				shutdown(1)
			ok
			_oEx_ = _oC_.ExerciseQ(_acRest_[3])
			_oT_ = StzTutorQ(_oEx_, _cLearner_, _cLang_).WithCourseQ(_oC_)
			# the question may arrive as one quoted argument or as its words
			_cQ_ = ""
			for _k_ = 4 to len(_acRest_)
				if _k_ > 4
					_cQ_ += " "
				ok
				_cQ_ += _acRest_[_k_]
			next
			? _oT_.Ask(_cQ_)

		on "project"
			if len(_acRest_) < 3
				EduDeskUsage()
				shutdown(1)
			ok
			_oPr_ = _oP_.ProjectQ(_acRest_[3])
			_oCk_ = _oL_.SubmitProject(_oPr_)
			if _oCk_.Passed()
				? "PASSED " + _oPr_.Id() + ": the guard ran your folder and every promise was kept"
			else
				? "REFUSED " + _oPr_.Id() + ": " + _oCk_.WhyIn(_cLang_)
				shutdown(2)
			ok

		other
			EduDeskUsage()
			shutdown(1)
		off
	catch
		? "ERROR: " + cCatchError
		shutdown(1)
	done

func EduDeskUsage()
	? "usage: ring learn.ring <learner folder> status"
	? "       ring learn.ring <learner folder> submit <exercise id> <your .ring file>"
	? "       ring learn.ring <learner folder> ask <exercise id> " + '"<your question>"'
	? "       ring learn.ring <learner folder> project <project id>"
	? "options: --program <folder> --course <slug> --overlay <folder> --world <name> --lang <en|fr|ar|ha>"

# Options (--key value) anywhere after the script name; the rest in order.
func EduDeskArgs()
	_aOpt_ = [ :program = "../program", :course = "elementary-introduction", :overlay = "", :world = "", :lang = "en", :rest = [] ]
	_acKeys_ = [ "program", "course", "overlay", "world", "lang" ]
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

func EduDeskStatus(poP, poC, poL, pcLang)
	_cWorld_ = "workplace"
	if poP.HasWorld()
		_cWorld_ = poP.World()
	ok
	_cLine_ = "LEARNER " + poL.Id() + "  (" + pcLang + ", world: " + _cWorld_
	if poP.HasOverlay()
		_cLine_ += ", overlay: " + _EduLastSegment(poP.Overlay())
	ok
	? _cLine_ + ")"
	_cOn_ = poL.ChapterOn(poC)
	if _cOn_ = ""
		? "ON: every exercise of every chapter is passed"
	else
		? "ON chapter " + (0 + poC.ChapterNumber(_cOn_)) + ": " + _cOn_ + " -- " + poC.TitleOf(_cOn_, pcLang)
	ok
	_acCh_ = poC.ChapterIds()
	_acPassed_ = []
	_nAll_ = 0
	for _i_ = 1 to len(_acCh_)
		_acEx_ = poC.ExercisesOf(_acCh_[_i_])
		for _j_ = 1 to len(_acEx_)
			_nAll_++
			if poL.HasPassed(_acEx_[_j_])
				_acPassed_ + _acEx_[_j_]
			ok
		next
	next
	_cP_ = "PASSED " + len(_acPassed_) + " of " + _nAll_ + " exercises"
	if len(_acPassed_) > 0
		_cP_ += ": " + EduDeskJoin(_acPassed_)
	ok
	? _cP_
	# the levels: the earned ones, the NEXT one with what it still needs by
	# name, the later ones by count -- a list of 23 names is not a status
	_acLv_ = poP.LevelIds()
	_bNextShown_ = 0
	for _i_ = 1 to len(_acLv_)
		if poL.HasEarned(poP, poC, _acLv_[_i_])
			? "LEVEL " + _acLv_[_i_] + ": earned"
		else
			_acMiss_ = poL.MissingFor(poP, poC, _acLv_[_i_])
			if NOT _bNextShown_
				? "LEVEL " + _acLv_[_i_] + ": missing " + len(_acMiss_) + " -- " + EduDeskJoin(_acMiss_)
				_bNextShown_ = 1
			else
				? "LEVEL " + _acLv_[_i_] + ": missing " + len(_acMiss_)
			ok
		ok
	next

func EduDeskJoin(pacItems)
	_c_ = ""
	for _i_ = 1 to len(pacItems)
		if _i_ > 1
			_c_ += ", "
		ok
		_c_ += pacItems[_i_]
	next
	return _c_
