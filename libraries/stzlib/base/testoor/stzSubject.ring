# Testoor -- the SUBJECT: what a tour tests, handed to it by the runner.
# Phase P1b of SOFTANZA_TESTOOR_ROADMAP.md, the seam refinement needs.
#
# A tour used to hard-code the file it loads, so it could only ever test the one
# program it was written beside. To test a REFINED copy of that program -- the
# rendering of a proposed change, written to a rehearsal path -- the same tour
# must take its subject from the runner: `--testoor-subject PATH` is appended to
# the child's argv when the runner is given a subject (TESTOOR_PROTOCOL.md
# section 2), and the tour reads it back with TestoorSubject().
#
# A subject written in refinement form carries tags such as
#   $nVat = <R:PARAM name="vat" value="0.22" min="0" max="0.9">
# which are not yet a program. TestoorResolveRefinements() turns each tag into
# the value it carries, so the source can be run:  eval(read(TestoorSubject())).
# It reads the value of the tag as the refinement library renders it (Rendered()
# keeps the tags, with the current value in each).

# the subject the runner handed this tour, or ""
func TestoorSubject()
	_n_ = len(sysargv)
	for _i_ = 1 to _n_ - 1
		if sysargv[_i_] = "--testoor-subject"
			return sysargv[_i_ + 1]
		ok
	next
	return ""

# every <R:KIND ... value="V" ...> in a source replaced by V
func TestoorResolveRefinements(pcSource)
	_c_ = "" + pcSource
	_cOut_ = ""
	while 1
		_nAt_ = substr(_c_, "<R:")
		if _nAt_ = 0  exit  ok
		_cOut_ += substr(_c_, 1, _nAt_ - 1)
		_cRest_ = substr(_c_, _nAt_, len(_c_) - _nAt_ + 1)
		_nEnd_ = substr(_cRest_, ">")
		if _nEnd_ = 0
			_cOut_ += _cRest_
			_c_ = ""
			exit
		ok
		_cOut_ += _TestoorTagValue(substr(_cRest_, 1, _nEnd_))
		_c_ = substr(_cRest_, _nEnd_ + 1, len(_cRest_) - _nEnd_)
	end
	return _cOut_ + _c_

func _TestoorTagValue(pcTag)
	_n_ = substr(pcTag, 'value="')
	if _n_ = 0  return ""  ok
	_cRest_ = substr(pcTag, _n_ + 7, len(pcTag) - _n_ - 6)
	_m_ = substr(_cRest_, '"')
	if _m_ = 0  return ""  ok
	return substr(_cRest_, 1, _m_ - 1)
