#---------------------------------------------------------------------------#
#  STZSOUNDLADDER -- a mode drawn as a ladder: one rung per degree (MU10)    #
#---------------------------------------------------------------------------#
#
#     oL = StzSoundLadderQ(:tunisian, :dhil)        # or StzSoundUniverseQ(:maqam).LadderQ()
#     ? oL.ToText()                                 # the rungs, the cents, the steps
#     oL.SaveAs("dhil.html")                        # the ladder, drawn
#     aR = oL.Rungs()                               # [ degree, name, cents, Hz, step up ]
#
# THE MAQAM LADDER is how a mode is shown when the question is not "what is the
# melody" but "where do the notes of this mode sit": each degree a rung, its
# height its pitch, the distance between two rungs the step between them. It is
# how maqam scales are taught, and it is what a staff cannot show -- on a staff a
# Rast third and a major third sit on the same line and differ by a sign; on the
# ladder the half-flat third sits visibly HALF WAY between the minor and the
# major one, because rungs are spaced by cents, not by letters.
#
# EVERYTHING DRAWN IS DECLARED. The rungs are the mode's :degrees; a degree the
# mode lowers going DOWN (:descending) is a second, dashed rung; a degree the
# sources disagree on (:variants) is shown as dotted rungs with the source named;
# the ajnas are brackets beside the rails; a degree the mode leaves out going down
# (:avoiddescending) is marked. A faint quarter-tone grid sits behind the rungs
# so the eye can see where a degree falls between the tempered semitones.
# Nothing is inferred: a mode that declares no names shows its degree numbers.

func StzSoundLadderQ(pUniverse, pMode)
	return new stzSoundLadder(pUniverse, pMode)

class stzSoundLadder

	@oU = NULL
	@aMode = []
	@cLastError = ""
	@nPx = 0.55                 # pixels a cent

	def init(pUniverse, pMode)
		@oU = StzSoundUniverseQ(pUniverse)
		if NOT @oU.IsUsable()
			@cLastError = @oU.LastError()
			return
		ok
		if "" + pMode != ""  @oU.Mode(pMode) ok
		for _m_ in This._Get(@oU.Declaration(), :modes, [])
			if This._Get(_m_, :name, "") = @oU.ModeName()  @aMode = _m_ ok
		next
		if len(This._Get(@aMode, :degrees, [])) = 0
			@cLastError = "a ladder needs a mode with degrees: " + @oU.Name() + " / '" + pMode + "' declares none"
		ok

	def Tonic(pcNote)
		@oU.Tonic(pcNote)
		return This

	def IsUsable()
		return @cLastError = ""

	def LastError()
		return @cLastError

	def ModeName()
		return @oU.ModeName()

	def TonicName()
		return @oU.TonicName()

	# [ degree, name, cents, Hz, step to the next rung ] -- the octave included
	def Rungs()
		return This._RungsOf(This._Get(@aMode, :degrees, []))

	# the same for the descending form, or [] when the mode declares none that differs
	def DescendingRungs()
		_aD_ = This._Get(@aMode, :descending, [])
		if len(_aD_) = 0  return [] ok
		if This._Same(_aD_, This._Get(@aMode, :degrees, []))  return [] ok
		return This._RungsOf(_aD_)

	def Steps()
		_a_ = []
		for _r_ in This.Rungs()
			if _r_[5] > 0  _a_ + _r_[5] ok
		next
		return _a_

	# [ name, lowest cents, highest cents, the jins's own cents above the tonic ]
	def Ajnas()
		_aD_ = This._Get(@aMode, :degrees, [])
		_a_ = []
		for _j_ in This._Get(@aMode, :ajnas, [])
			_aC_ = []
			# a jins's cents are counted from its own first degree -- unless they
			# begin below zero, in which case the declaration counted them from
			# the tonic (tunisian.ring's "rast (below the tonic, on G)")
			_base_ = 0
			if len(_j_[3]) > 0
				if _j_[3][1] >= 0 and _j_[2] >= 1 and _j_[2] <= len(_aD_)  _base_ = _aD_[_j_[2]] ok
			ok
			for _c_ in _j_[3]  _aC_ + (_base_ + _c_) next
			_a_ + [ _j_[1], This._Min(_aC_), This._Max(_aC_), _aC_ ]
		next
		return _a_

	def ToText()
		_t_ = This._Get(@aMode, :name, "") + " (" + @oU.Name() + ") -- tonic " + @oU.TonicName() + ", " +
		      This._Fmt(StzNoteToHz(@oU.TonicName()), 2) + " Hz" + nl
		_t_ += " deg  " + This._Pad("name", 18) + This._PadL("cents", 7) + This._PadL("Hz", 10) + "    step" + nl
		_aR_ = This.Rungs()
		for _i_ = len(_aR_) to 1 step -1
			_r_ = _aR_[_i_]
			_t_ += This._PadL("" + _r_[1], 4) + "  " + This._Pad(_r_[2], 18) + This._PadL("" + _r_[3], 7) +
			       This._PadL(This._Fmt(_r_[4], 2), 10) + nl
			if _i_ > 1
				_s_ = _aR_[_i_ - 1][5]
				_t_ += copy(" ", 45) + This._PadL("" + _s_, 4) + "  " + This._Tone(_s_) + nl
			ok
		next
		_aDn_ = This.DescendingRungs()
		if len(_aDn_) > 0
			_t_ += " descending, where it differs:" + nl
			_aUp_ = This.Rungs()
			for _k_ = 1 to len(_aDn_)
				if _aDn_[_k_][3] != _aUp_[_k_][3]
					_t_ += "   degree " + _k_ + ": " + _aUp_[_k_][3] + " going up, " + _aDn_[_k_][3] + " coming down" + nl
				ok
			next
		ok
		for _j_ in This.Ajnas()
			_t_ += " jins " + _j_[1] + ": " + _j_[2] + " to " + _j_[3] + " cents" + nl
		next
		return _t_

	def SaveAs(pcPath)
		_c_ = ""
		if lower(right(pcPath, 4)) = ".svg"
			_c_ = This.ToSVG()
		else
			_c_ = This.ToHTML()
		ok
		write(pcPath, _c_)
		return len(_c_)

	def ToHTML()
		_q_ = char(34)
		return "<!DOCTYPE html>" + nl + "<html lang=" + _q_ + "en" + _q_ + "><head><meta charset=" + _q_ + "utf-8" + _q_ + ">" +
		       "<title>" + This._Xml(This._Title()) + "</title>" +
		       "<style>body{margin:0;padding:16px;background:#eceae4}svg{display:block;margin:0 auto;max-width:100%;height:auto;" +
		       "background:#fff;box-shadow:0 1px 4px rgba(0,0,0,.18)}</style></head><body>" + nl +
		       This.ToSVG() + nl + "</body></html>" + nl

	def ToSVG()
		_q_ = char(34)
		_aR_ = This.Rungs()
		_aJ_ = This.Ajnas()
		_aDn_ = This.DescendingRungs()
		_lo_ = 0
		for _j_ in _aJ_
			if _j_[2] < _lo_  _lo_ = _j_[2] ok
		next
		_hi_ = _aR_[len(_aR_)][3]
		_top_ = 96
		_W_ = 780
		_H_ = _top_ + (_hi_ - _lo_) * @nPx + 120 + 17 * This._NoteLines()
		_ink_ = "#1a1a1a"
		_grid_ = "#e3ded2"
		_warm_ = "#8a5a2b"
		_cool_ = "#2b5c8a"
		_x1_ = 300                                     # the rails
		_x2_ = 380
		_o_ = "<svg xmlns=" + _q_ + "http://www.w3.org/2000/svg" + _q_ + " width=" + _q_ + _W_ + _q_ + " height=" + _q_ +
		      This._F(_H_) + _q_ + " viewBox=" + _q_ + "0 0 " + _W_ + " " + This._F(_H_) + _q_ + ">" + nl
		_o_ += "<rect width=" + _q_ + "100%" + _q_ + " height=" + _q_ + "100%" + _q_ + " fill=" + _q_ + "#ffffff" + _q_ + "/>" + nl
		_o_ += This._T(_W_ / 2, 40, This._Title(), 22, "middle", _ink_, "")
		_o_ += This._T(_W_ / 2, 64, "tonic " + @oU.TonicName() + " (" + This._Fmt(StzNoteToHz(@oU.TonicName()), 2) +
		                " Hz) -- rungs spaced by cents, " + This._Fmt(@nPx * 100, 0) + " px a semitone", 13, "middle", "#666", "")
		# the quarter-tone grid
		_c_ = floor(_lo_ / 50) * 50
		while _c_ <= _hi_
			_y_ = This._Y(_c_, _top_, _hi_)
			_w_ = 0.6
			if _c_ % 100 = 0  _w_ = 1.1 ok
			_o_ += This._L(_x1_ - 14, _y_, _x2_ + 14, _y_, _w_, _grid_, "")
			_c_ += 50
		end
		# the rails
		_o_ += This._L(_x1_, This._Y(_hi_, _top_, _hi_) - 18, _x1_, This._Y(_lo_, _top_, _hi_) + 18, 3, _ink_, "")
		_o_ += This._L(_x2_, This._Y(_hi_, _top_, _hi_) - 18, _x2_, This._Y(_lo_, _top_, _hi_) + 18, 3, _ink_, "")
		# below the tonic: the ajnas that reach there get their own faint rungs
		for _j_ in _aJ_
			for _cc_ in _j_[4]
				if _cc_ < 0
					_y_ = This._Y(_cc_, _top_, _hi_)
					_o_ += This._L(_x1_, _y_, _x2_, _y_, 2, "#9a9a9a", "")
					_o_ += This._T(_x2_ + 12, _y_ + 4, "" + _cc_ + " ¢", 12, "start", "#9a9a9a", "")
				ok
			next
		next
		# the rungs, their names, cents and Hz; the step to the next rung
		_aAvoid_ = This._Get(@aMode, :avoiddescending, [])
		for _i_ = 1 to len(_aR_)
			_r_ = _aR_[_i_]
			_y_ = This._Y(_r_[3], _top_, _hi_)
			_w_ = 4
			if _i_ = 1 or _i_ = len(_aR_)  _w_ = 6 ok
			_o_ += This._L(_x1_, _y_, _x2_, _y_, _w_, _ink_, "")
			_o_ += This._T(_x1_ - 22, _y_ + 5, _r_[2], 15, "end", _ink_, "")
			_o_ += This._T(_x1_ - 22, _y_ + 20, "degree " + _r_[1], 11, "end", "#777", "")
			_o_ += This._T(_x2_ + 12, _y_ + 5, "" + _r_[3] + " ¢", 14, "start", _ink_, "bold")
			_o_ += This._T(_x2_ + 12, _y_ + 19, This._Fmt(_r_[4], 1) + " Hz", 11, "start", "#777", "")
			if ring_find(_aAvoid_, _r_[1]) > 0
				_o_ += This._T(_x1_ - 22, _y_ + 33, "left out going down", 11, "end", _cool_, "italic")
			ok
			if _i_ < len(_aR_)
				_yn_ = This._Y(_aR_[_i_ + 1][3], _top_, _hi_)
				_xm_ = _x2_ + 110
				_o_ += This._L(_xm_, _y_ - 3, _xm_, _yn_ + 3, 1, "#999", "")
				_o_ += This._L(_xm_ - 4, _y_ - 3, _xm_ + 4, _y_ - 3, 1, "#999", "")
				_o_ += This._L(_xm_ - 4, _yn_ + 3, _xm_ + 4, _yn_ + 3, 1, "#999", "")
				_o_ += This._T(_xm_ + 8, (_y_ + _yn_) / 2 + 4, "" + _r_[5] + " ¢  " + This._Tone(_r_[5]), 12, "start", "#444", "")
			ok
		next
		# the descending form, where it differs: a dashed rung
		_aLeg_ = []
		for _k_ = 1 to len(_aDn_)
			if _aDn_[_k_][3] != _aR_[_k_][3]
				_y_ = This._Y(_aDn_[_k_][3], _top_, _hi_)
				_o_ += This._L(_x1_, _y_, _x2_, _y_, 3, _cool_, "6,4")
				_o_ += This._T(_x1_ - 22, _y_ + 5, "coming down: " + _aDn_[_k_][3] + " ¢", 12, "end", _cool_, "")
				_aLeg_ + [ _cool_, "dashed: the degree as the mode descends" ]
			ok
		next
		# the variants the sources give: dotted rungs
		_nv_ = 0
		for _v_ in This._Get(@aMode, :variants, [])
			_nv_++
			for _cc_ in _v_[2]
				if _cc_ != _aR_[_v_[1]][3]
					_y_ = This._Y(_cc_, _top_, _hi_)
					_o_ += This._L(_x1_ + 4, _y_, _x2_ - 4, _y_, 2, _warm_, "2,3")
					_o_ += This._T(_x1_ - 22, _y_ + 4, "variant " + _cc_ + " ¢ [" + _nv_ + "]", 11, "end", _warm_, "")
				ok
			next
		next
		# the ajnas: brackets, side by side
		_xj_ = _x2_ + 250
		for _j_ in _aJ_
			_ya_ = This._Y(_j_[3], _top_, _hi_)
			_yb_ = This._Y(_j_[2], _top_, _hi_)
			_o_ += This._L(_xj_, _ya_, _xj_, _yb_, 2.5, _warm_, "")
			_o_ += This._L(_xj_ - 7, _ya_, _xj_, _ya_, 2.5, _warm_, "")
			_o_ += This._L(_xj_ - 7, _yb_, _xj_, _yb_, 2.5, _warm_, "")
			_o_ += "<text transform=" + _q_ + "translate(" + This._F(_xj_ + 14) + "," + This._F((_ya_ + _yb_) / 2) + ") rotate(90)" + _q_ +
			       " font-family=" + _q_ + "Georgia,serif" + _q_ + " font-size=" + _q_ + "12" + _q_ + " fill=" + _q_ + _warm_ + _q_ +
			       " text-anchor=" + _q_ + "middle" + _q_ + ">" + This._Xml(_j_[1]) + "</text>" + nl
			_xj_ += 30
		next
		# what the declaration says about itself
		_yb_ = This._Y(_lo_, _top_, _hi_) + 50
		_n_ = 0
		for _v_ in This._Get(@aMode, :variants, [])
			_n_++
			for _ln_ in This._Wrap("[" + _n_ + "] degree " + _v_[1] + ": " + _v_[3], 105)
				_o_ += This._T(40, _yb_, _ln_, 12, "start", _warm_, "")
				_yb_ += 17
			next
		next
		for _lg_ in _aLeg_
			_o_ += This._T(40, _yb_, _lg_[2], 12, "start", _lg_[1], "")
			_yb_ += 17
			exit
		next
		_why_ = This._Get(@aMode, :why, "")
		if _why_ != ""
			for _ln_ in This._Wrap("why: " + _why_, 105)
				_o_ += This._T(40, _yb_, _ln_, 12, "start", "#555", "")
				_yb_ += 17
			next
		ok
		_cf_ = This._Get(@aMode, :confidence, "")
		if _cf_ != ""
			for _ln_ in This._Wrap("confidence: " + _cf_, 105)
				_o_ += This._T(40, _yb_, _ln_, 12, "start", "#555", "")
				_yb_ += 17
			next
		ok
		return _o_ + "</svg>"

	#-- inside --------------------------------------------------------------

	def _Title()
		return This._Get(@aMode, :name, "") + " -- " + @oU.Title()

	def _RungsOf(paD)
		_aN_ = This._Get(@aMode, :names, [])
		_oct_ = This._Get(@aMode, :octave, 1200)
		_hz0_ = StzNoteToHz(@oU.TonicName())
		_a_ = []
		_n_ = len(paD)
		for _i_ = 1 to _n_
			_nm_ = "" + _i_
			if _i_ <= len(_aN_)  _nm_ = _aN_[_i_] ok
			_next_ = _oct_
			if _i_ < _n_  _next_ = paD[_i_ + 1] ok
			_a_ + [ _i_, _nm_, paD[_i_], _hz0_ * pow(2, paD[_i_] / 1200), _next_ - paD[_i_] ]
		next
		_nm_ = "1"
		if len(_aN_) > 0  _nm_ = _aN_[1] ok
		_a_ + [ _n_ + 1, _nm_ + " (octave)", _oct_, _hz0_ * pow(2, _oct_ / 1200), 0 ]
		return _a_

	# the lines the notes under the ladder will take
	def _NoteLines()
		_n_ = 1
		for _v_ in This._Get(@aMode, :variants, [])  _n_ += len(This._Wrap(_v_[3], 100)) next
		_n_ += len(This._Wrap(This._Get(@aMode, :why, ""), 100))
		_n_ += len(This._Wrap(This._Get(@aMode, :confidence, ""), 100))
		return _n_

	# words to lines of at most pnW characters
	def _Wrap(pc, pnW)
		_a_ = []
		_l_ = ""
		_w_ = ""
		_s_ = pc + " "
		for _k_ = 1 to len(_s_)
			if _s_[_k_] = " "
				if len(_l_) + len(_w_) + 1 > pnW and _l_ != ""
					_a_ + _l_
					_l_ = _w_
				else
					if _l_ = ""  _l_ = _w_ else _l_ += " " + _w_ ok
				ok
				_w_ = ""
			else
				_w_ += _s_[_k_]
			ok
		next
		if _l_ != ""  _a_ + _l_ ok
		return _a_

	def _Same(paA, paB)
		if len(paA) != len(paB)  return FALSE ok
		for _i_ = 1 to len(paA)
			if paA[_i_] != paB[_i_]  return FALSE ok
		next
		return TRUE

	# 150 -> "3/4 tone"; a step off the quarter-tone grid has no such name
	def _Tone(pnC)
		if pnC % 50 != 0  return "" ok
		_q_ = pnC / 50
		_w_ = floor(_q_ / 4)
		_r_ = _q_ % 4
		_s_ = ""
		if _w_ > 0  _s_ = "" + _w_ ok
		if _r_ = 1  _s_ += " 1/4" ok
		if _r_ = 2  _s_ += " 1/2" ok
		if _r_ = 3  _s_ += " 3/4" ok
		_s_ = ring_trim(_s_)
		if _q_ = 4  return "(1 tone)" ok
		return "(" + _s_ + " tone)"

	def _Y(pnCents, pnTop, pnHi)
		return pnTop + 30 + (pnHi - pnCents) * @nPx

	def _L(pnX1, pnY1, pnX2, pnY2, pnW, pcColour, pcDash)
		_q_ = char(34)
		_d_ = ""
		if pcDash != ""  _d_ = " stroke-dasharray=" + _q_ + pcDash + _q_ ok
		return "<line x1=" + _q_ + This._F(pnX1) + _q_ + " y1=" + _q_ + This._F(pnY1) + _q_ + " x2=" + _q_ + This._F(pnX2) + _q_ +
		       " y2=" + _q_ + This._F(pnY2) + _q_ + " stroke=" + _q_ + pcColour + _q_ + " stroke-width=" + _q_ + This._F(pnW) + _q_ +
		       _d_ + "/>" + nl

	def _T(pnX, pnY, pcText, pnSize, pcAnchor, pcColour, pcStyle)
		_q_ = char(34)
		_s_ = ""
		if pcStyle = "bold"  _s_ = " font-weight=" + _q_ + "bold" + _q_ ok
		if pcStyle = "italic"  _s_ = " font-style=" + _q_ + "italic" + _q_ ok
		return "<text x=" + _q_ + This._F(pnX) + _q_ + " y=" + _q_ + This._F(pnY) + _q_ + " font-family=" + _q_ +
		       "Georgia,'Times New Roman',serif" + _q_ + " font-size=" + _q_ + pnSize + _q_ + " fill=" + _q_ + pcColour + _q_ +
		       " text-anchor=" + _q_ + pcAnchor + _q_ + _s_ + ">" + This._Xml(pcText) + "</text>" + nl

	def _F(pn)
		_v_ = floor(pn * 10 + 0.5)
		_s_ = ""
		if _v_ < 0
			_s_ = "-"
			_v_ = 0 - _v_
		ok
		_s_ += "" + floor(_v_ / 10)
		if _v_ % 10 != 0  _s_ += "." + (_v_ % 10) ok
		return _s_

	# a number with n decimals, built from integers so decimals() cannot change it
	def _Fmt(pn, pnD)
		_m_ = pow(10, pnD)
		_v_ = floor(pn * _m_ + 0.5)
		_s_ = "" + floor(_v_ / _m_)
		if pnD > 0
			_f_ = "" + (_v_ % _m_)
			while len(_f_) < pnD  _f_ = "0" + _f_ end
			_s_ += "." + _f_
		ok
		return _s_

	def _Pad(pc, pnW)
		_s_ = "" + pc
		while len(_s_) < pnW  _s_ += " " end
		return _s_

	def _PadL(pc, pnW)
		_s_ = "" + pc
		while len(_s_) < pnW  _s_ = " " + _s_ end
		return _s_

	def _Min(paA)
		_m_ = 999999
		for _x_ in paA
			if _x_ < _m_  _m_ = _x_ ok
		next
		return _m_

	def _Max(paA)
		_m_ = -999999
		for _x_ in paA
			if _x_ > _m_  _m_ = _x_ ok
		next
		return _m_

	def _Get(paList, pcKey, pDefault)
		if NOT isList(paList)  return pDefault ok
		for _p_ in paList
			if isList(_p_) and len(_p_) = 2
				if isString(_p_[1]) and lower(_p_[1]) = lower(pcKey)  return _p_[2] ok
			ok
		next
		return pDefault

	def _Xml(pc)
		_s_ = ""
		for _k_ = 1 to len(pc)
			_ch_ = pc[_k_]
			if _ch_ = "&"
				_s_ += "&amp;"
			but _ch_ = "<"
				_s_ += "&lt;"
			but _ch_ = ">"
				_s_ += "&gt;"
			else
				_s_ += _ch_
			ok
		next
		return _s_
