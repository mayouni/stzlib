# The overlay court, at the command line (OVERLAY_GUIDE.md, step 6).
#
#   cd base/education/tools
#   ring overlay_check.ring <overlay folder> [program folder]
#
# Prints OVERLAY OK with what the overlay adds and shadows, or one line per
# finding, and exits 1 on any error so a script can stop on it.

load "../../stzBase.ring"

func main
	if len(sysargv) < 3
		? "usage: ring overlay_check.ring <overlay folder> [program folder]"
		return
	ok
	_cOv_ = sysargv[3]
	_cProg_ = "../program"
	if len(sysargv) >= 4
		_cProg_ = sysargv[4]
	ok
	_oP_ = StzProgramQ(_cProg_)
	_oOv_ = StzOverlayQ(_cOv_)
	_aF_ = _oOv_.Check(_oP_)
	if len(_aF_) = 0
		_oP_.WithOverlay(_cOv_)
		_aR_ = _oP_.OverlayReport()
		_nAdds_ = 0
		_nShadows_ = 0
		_nMerges_ = 0
		for _i_ = 1 to len(_aR_)
			if _aR_[_i_][2] = "adds"
				_nAdds_++
			but _aR_[_i_][2] = "merges"
				_nMerges_++
			else
				_nShadows_++
			ok
		next
		? "OVERLAY OK: " + _oOv_.Name() + " extends " + _oP_.Id() + ", " + len(_aR_) + " files (" +
		  _nAdds_ + " added, " + _nMerges_ + " merged into a core manifest, " + _nShadows_ + " shadowing a core file)"
		for _i_ = 1 to len(_aR_)
			? "  " + _aR_[_i_][2] + "  " + _aR_[_i_][1]
		next
	else
		? "OVERLAY REFUSED: " + len(_aF_) + " finding(s)"
		? _oOv_.CiteFindings(_oP_)
		shutdown(1)
	ok
