#---------------------------------------------------------------------------#
#  STZSOUNDSTAFF -- a score drawn on the staff, as musicians write it (MU10) #
#---------------------------------------------------------------------------#
#
#     oSt = StzSoundStaffQ(oScore)
#     oSt.SetMeter(4, 4)                        # 4/4 until told otherwise
#     oSt.SaveAs("tune.html", "A Rast phrase")  # open it in any browser
#     cSvg = oSt.ToSVG("A Rast phrase")         # or the SVG alone
#     ? oSt.Losses()                            # what the drawing could not show
#     aM = oSt.Model()                          # every mark, as data
#
# WHAT A MUSICIAN CALLS THE STAFF (the stave; la portee; al-madraj). The
# Principal asked for "the graphical music notation used by musicians to write
# down their melodies" -- five lines, a clef, notes whose height is the pitch
# and whose shape is the length. MU7 WROTE that notation as text for other
# programs (ABC, MusicXML); this DRAWS it, from the same stzSoundScore.
#
# THE MODEL FIRST, THE PICTURE SECOND. The layout is computed as a list of
# marks -- each notehead with its staff step, each accidental, rest, tie, beam,
# ledger line and barline -- and only then written as SVG. A guard can hold the
# model to the rules of notation (C4 sits on the first ledger line below the
# treble staff; an accidental holds to the barline; a note that crosses a
# barline is two notes tied) without reading pixels.
#
# WHAT IS DRAWN. One staff per instrument, a treble or bass clef chosen by where
# the voice lies; the metre; notes split at barlines and tied; dotted values;
# chords (a second's heads set either side of the stem); stems that turn at the
# middle line; eighths and sixteenths BEAMED by the beat (by the dotted quarter
# in 6/8, 9/8, 12/8) and flagged when alone; rests filling every gap, a whole
# bar's rest centred; ledger lines; accidentals by the bar, including the
# QUARTER TONES this library's universes carry -- Arabic notation's half-flat (a
# flat with a stroke through it) and half-sharp (a sharp with one vertical);
# ties, across systems too; the title and the tempo; systems broken to the
# page width and justified.
#
# WHAT IS NOT (named, as the writers name theirs): no key signature -- every
# alteration is written on its note, which is how a quarter-tone melody is
# usually written anyway; drum strokes are not drawn (Losses says so); a pitch
# further than 5 cents from the nearest quarter tone is drawn at that quarter
# tone and COUNTED (slendro); no dynamics, articulations, lyrics or slurs.
# Clefs are drawn from the Unicode Musical Symbols block (Noto Music, Segoe UI
# Symbol, Apple Symbols, Bravura Text, Symbola -- whichever the viewer has);
# every other mark is drawn as a shape and needs no font.

func StzSoundStaffQ(poScore)
	return new stzSoundStaff(poScore)

class stzSoundStaff

	@oS = NULL
	@nBeats = 4
	@nUnit = 4
	@nWidth = 1000
	@nSp = 10                  # one staff space, in pixels
	@aLosses = []
	@aModel = []
	@cLastError = ""

	# the engraving, computed by _Layout
	@aStaves = []              # [ instrument, clef, pieces ]
	@nBars = 0
	@nBarLen = 16              # sixteenths in a bar
	@aSystems = []             # [ first bar, last bar, x of each bar start (list), scale ]
	@aStaffY = []              # per system: [ top y of each staff ]
	@nHeight = 0
	@nLeft = 20

	def init(poScore)
		@oS = poScore

	def SetMeter(pnBeats, pnUnit)
		if NOT isNumber(pnBeats) or pnBeats < 1 or pnBeats > 32 or ring_find([ 2, 4, 8, 16 ], pnUnit) = 0
			@cLastError = "SetMeter: beats 1 to 32 over a unit of 2, 4, 8 or 16"
			return This
		ok
		@nBeats = pnBeats
		@nUnit = pnUnit
		return This

	def SetMeterQ(pnBeats, pnUnit)
		return This.SetMeter(pnBeats, pnUnit)

	def SetWidth(pnPixels)
		if isNumber(pnPixels) and pnPixels >= 400  @nWidth = pnPixels ok
		return This

	def Losses()
		return @aLosses

	def LastError()
		return @cLastError

	def Model()
		return @aModel

	def Bars()
		return @nBars

	def Systems()
		return len(@aSystems)

	def Clefs()
		_a_ = []
		for _s_ in @aStaves  _a_ + [ _s_[1], _s_[2] ] next
		return _a_

	def SaveAs(pcPath, pcTitle)
		_c_ = ""
		if lower(right(pcPath, 4)) = ".svg"
			_c_ = This.ToSVG(pcTitle)
		else
			_c_ = This.ToHTML(pcTitle)
		ok
		write(pcPath, _c_)
		return len(_c_)

	def ToHTML(pcTitle)
		_q_ = char(34)
		return "<!DOCTYPE html>" + nl + "<html lang=" + _q_ + "en" + _q_ + "><head><meta charset=" + _q_ + "utf-8" + _q_ + ">" +
		       "<title>" + This._Xml(pcTitle) + "</title>" +
		       "<style>body{margin:0;padding:16px;background:#eceae4}svg{display:block;margin:0 auto;max-width:100%;height:auto;" +
		       "background:#fff;box-shadow:0 1px 4px rgba(0,0,0,.18)}</style></head><body>" + nl +
		       This.ToSVG(pcTitle) + nl + "</body></html>" + nl

	def ToSVG(pcTitle)
		This._Layout()
		return This._Draw(pcTitle)

	#== the layout: pieces, then accidentals, then columns, then systems ========

	def _Layout()
		@aLosses = []
		@aModel = []
		@aStaves = []
		@aSystems = []
		@aStaffY = []
		@nBarLen = @nBeats * 16 / @nUnit
		_oN_ = new stzSoundNotation(@oS)
		_aV_ = _oN_._Voices()
		for _l_ in _oN_.Losses()
			if substr(_l_, "strokes") > 0
				This._Loss("strokes are not drawn on the staff (MIDI carries them)")
			else
				This._Loss(_l_)
			ok
		next
		# the end of the music, to the bar
		_end_ = 0
		for _v_ in _aV_
			for _g_ in _v_[2]
				if _g_[1] + _g_[2] > _end_  _end_ = _g_[1] + _g_[2] ok
			next
		next
		@nBars = ceil(_end_ / @nBarLen)
		if @nBars < 1  @nBars = 1 ok
		for _v_ in _aV_
			@aStaves + [ _v_[1], This._ClefOf(_v_[2]), This._Pieces(_v_[2], @nBars * @nBarLen) ]
		next
		if len(@aStaves) = 0
			@aStaves + [ "piano", "treble", This._Pieces([], @nBars * @nBarLen) ]
		ok
		for _k_ = 1 to len(@aStaves)  This._Accidentals(_k_) next

	# treble when the voice lies from middle C up, bass below it (by its median)
	def _ClefOf(paSeg)
		_a_ = []
		for _g_ in paSeg
			for _p_ in _g_[3]  _a_ + This._Diatonic(_p_) next
		next
		if len(_a_) = 0  return "treble" ok
		_a_ = sort(_a_)
		if _a_[ceil(len(_a_) / 2)] >= 28  return "treble" ok
		return "bass"

	# a spelled pitch -> its diatonic number: C4 is 28, D4 29, ... B4 34, C5 35
	def _Diatonic(paP)
		return paP[3] * 7 + substr("CDEFGAB", paP[1]) - 1

	# a voice's segments -> pieces: [ bar, pos, len, pitches, tie out, tie in, bar rest ]
	# with the rests filled, each note split at the barlines and into values a
	# musician writes (whole, dotted half, half, dotted quarter, quarter,
	# dotted eighth, eighth, sixteenth)
	def _Pieces(paSeg, pnEnd)
		_aE_ = []             # [ at, len, pitches ]
		_t_ = 0
		for _g_ in paSeg
			if _g_[1] > _t_  _aE_ + [ _t_, _g_[1] - _t_, [] ] ok
			_aE_ + [ _g_[1], _g_[2], _g_[3] ]
			_t_ = _g_[1] + _g_[2]
		next
		if pnEnd > _t_  _aE_ + [ _t_, pnEnd - _t_, [] ] ok
		_aP_ = []
		for _e_ in _aE_
			_at_ = _e_[1]
			_left_ = _e_[2]
			_bFirst_ = TRUE
			while _left_ > 0
				_bar_ = floor(_at_ / @nBarLen)
				_pos_ = _at_ % @nBarLen
				_room_ = @nBarLen - _pos_
				if len(_e_[3]) = 0 and _pos_ = 0 and _left_ >= @nBarLen
					_aP_ + [ _bar_, 0, @nBarLen, [], FALSE, FALSE, TRUE ]
					_at_ += @nBarLen
					_left_ -= @nBarLen
					loop
				ok
				_take_ = This._Value(_left_, _room_)
				_left_ -= _take_
				_aP_ + [ _bar_, _pos_, _take_, _e_[3], (_left_ > 0 and len(_e_[3]) > 0), (NOT _bFirst_ and len(_e_[3]) > 0), FALSE ]
				_bFirst_ = FALSE
				_at_ += _take_
			end
		next
		return _aP_

	def _Value(pnLeft, pnRoom)
		for _v_ in [ 16, 12, 8, 6, 4, 3, 2, 1 ]
			if _v_ <= pnLeft and _v_ <= pnRoom  return _v_ ok
		next
		return 1

	# which accidental each head SHOWS: the bar remembers, the barline forgets,
	# a tied continuation shows none; alongside each piece: [ shown or 99 ] per pitch
	def _Accidentals(pnK)
		_aP_ = @aStaves[pnK][3]
		_bar_ = -1
		_aMem_ = []
		for _i_ = 1 to len(_aP_)
			if _aP_[_i_][1] != _bar_
				_bar_ = _aP_[_i_][1]
				_aMem_ = []
			ok
			_aShow_ = []
			for _p_ in _aP_[_i_][4]
				_key_ = _p_[1] + _p_[3]
				_prev_ = 0
				for _m_ in _aMem_
					if _m_[1] = _key_  _prev_ = _m_[2] ok
				next
				_show_ = 99
				if NOT _aP_[_i_][6] and _p_[2] != _prev_  _show_ = _p_[2] ok
				_f_ = 0
				for _j_ = 1 to len(_aMem_)
					if _aMem_[_j_][1] = _key_
						_aMem_[_j_][2] = _p_[2]
						_f_ = _j_
					ok
				next
				if _f_ = 0  _aMem_ + [ _key_, _p_[2] ] ok
				_aShow_ + _show_
			next
			@aStaves[pnK][3][_i_] + _aShow_          # element 8
		next

	#== drawing ===================================================================

	def _Draw(pcTitle)
		_sp_ = @nSp
		_nSt_ = len(@aStaves)
		# the room each staff needs above its top line and below its bottom one
		_aAbove_ = []
		_aBelow_ = []
		for _st_ in @aStaves
			_hi_ = 8
			_lo_ = 0
			for _p_ in _st_[3]
				for _q_ in _p_[4]
					_s_ = This._StepOf(_q_, _st_[2])
					if _s_ > _hi_  _hi_ = _s_ ok
					if _s_ < _lo_  _lo_ = _s_ ok
				next
			next
			# the treble clef itself reaches nearly three spaces above the staff
			_aAbove_ + (((_hi_ - 8) / 2) * _sp_ + 4.0 * _sp_)
			_aBelow_ + (((0 - _lo_) / 2) * _sp_ + 3.5 * _sp_)
		next
		_aAbove_[1] += 1.5 * _sp_              # and room for the tempo over the first staff
		# the left margin: instrument names when there is more than one staff
		@nLeft = 20
		if _nSt_ > 1  @nLeft = 90 ok
		# the natural width of every bar, from its columns
		_aBarCols_ = []
		_aBarW_ = []
		for _b_ = 0 to @nBars - 1
			_aC_ = This._Columns(_b_)
			_aBarCols_ + _aC_
			_w_ = 1.2 * _sp_
			for _c_ in _aC_  _w_ += _c_[2] next
			_aBarW_ + _w_
		next
		# systems: bars while they fit, then justified (the last one only if nearly full)
		_head1_ = 4.6 * _sp_ + 3.0 * _sp_      # clef + metre, first system
		_head_ = 4.6 * _sp_                    # clef, later systems
		_right_ = @nWidth - 20
		_b_ = 1
		while _b_ <= @nBars
			_x0_ = @nLeft
			_h_ = _head_
			if len(@aSystems) = 0  _h_ = _head1_ ok
			_avail_ = _right_ - _x0_ - _h_
			_sum_ = 0
			_e_ = _b_
			while _e_ <= @nBars
				if _sum_ + _aBarW_[_e_] > _avail_ and _e_ > _b_  exit ok
				_sum_ += _aBarW_[_e_]
				_e_++
			end
			_e_--
			_scale_ = _avail_ / _sum_
			if _e_ = @nBars and _scale_ > 1.35  _scale_ = 1 ok
			_aX_ = []
			_x_ = _x0_ + _h_
			for _k_ = _b_ to _e_
				_aX_ + _x_
				_x_ += _aBarW_[_k_] * _scale_
			next
			_aX_ + _x_                                  # the end of the last bar
			@aSystems + [ _b_, _e_, _aX_, _scale_, _h_ ]
			_b_ = _e_ + 1
		end
		# vertical placement
		_y_ = 58
		if pcTitle != ""  _y_ += 30 ok
		for _si_ = 1 to len(@aSystems)
			_aY_ = []
			for _k_ = 1 to _nSt_
				_y_ += _aAbove_[_k_]
				_aY_ + _y_
				_y_ += 4 * _sp_ + _aBelow_[_k_]
			next
			@aStaffY + _aY_
			_y_ += 2 * _sp_
		next
		@nHeight = _y_ + 20

		_q_ = char(34)
		_o_ = "<svg xmlns=" + _q_ + "http://www.w3.org/2000/svg" + _q_ + " width=" + _q_ + @nWidth + _q_ + " height=" + _q_ +
		      This._F(@nHeight) + _q_ + " viewBox=" + _q_ + "0 0 " + @nWidth + " " + This._F(@nHeight) + _q_ + ">" + nl
		_o_ += "<rect width=" + _q_ + "100%" + _q_ + " height=" + _q_ + "100%" + _q_ + " fill=" + _q_ + "#ffffff" + _q_ + "/>" + nl
		_o_ += "<g fill=" + _q_ + "#111" + _q_ + " stroke=" + _q_ + "#111" + _q_ + ">" + nl
		if pcTitle != ""
			_o_ += This._Text(@nWidth / 2, 38, pcTitle, 22, "middle", "") + nl
		ok
		# the tempo, over the first staff: a small quarter note, then "= 96"
		_ty_ = @aStaffY[1][1] - _aAbove_[1] + 1.2 * _sp_
		_tx_ = @nLeft + 6
		_o_ += This._Ellipse(_tx_, _ty_, 0.42 * _sp_, 0.3 * _sp_, TRUE) +
		       This._Line(_tx_ + 0.38 * _sp_, _ty_, _tx_ + 0.38 * _sp_, _ty_ - 2.2 * _sp_, 1.1) +
		       This._Text(_tx_ + 1.1 * _sp_, _ty_ + 4, "= " + floor(@oS.TempoInBpm() + 0.5), 13, "start", "") + nl
		for _si_ = 1 to len(@aSystems)
			_o_ += This._DrawSystem(_si_, _aBarCols_)
		next
		_o_ += "</g>" + nl + "</svg>"
		return _o_

	# a bar's columns: every onset any staff has there, as [ pos, width, room for an accidental ]
	def _Columns(pnBar)
		_aPos_ = []
		for _st_ in @aStaves
			for _p_ in _st_[3]
				if _p_[1] = pnBar and ring_find(_aPos_, _p_[2]) = 0  _aPos_ + _p_[2] ok
			next
		next
		_aPos_ = sort(_aPos_)
		_aC_ = []
		for _i_ = 1 to len(_aPos_)
			_gap_ = @nBarLen - _aPos_[_i_]
			if _i_ < len(_aPos_)  _gap_ = _aPos_[_i_ + 1] - _aPos_[_i_] ok
			_w_ = @nSp * (1.7 + 1.25 * log(_gap_ + 1) / log(2))
			_acc_ = FALSE
			_dis_ = FALSE
			for _st_ in @aStaves
				for _p_ in _st_[3]
					if _p_[1] = pnBar and _p_[2] = _aPos_[_i_]
						for _a_ in _p_[8]
							if _a_ != 99  _acc_ = TRUE ok
						next
						if This._HasSecond(_p_[4], _st_[2])  _dis_ = TRUE ok
					ok
				next
			next
			if _acc_  _w_ += 1.5 * @nSp ok
			if _dis_  _w_ += 1.0 * @nSp ok
			_aC_ + [ _aPos_[_i_], _w_, _acc_ ]
		next
		return _aC_

	def _HasSecond(paPitches, pcClef)
		_aS_ = []
		for _q_ in paPitches  _aS_ + This._StepOf(_q_, pcClef) next
		_aS_ = sort(_aS_)
		for _i_ = 2 to len(_aS_)
			if _aS_[_i_] - _aS_[_i_ - 1] = 1  return TRUE ok
		next
		return FALSE

	# the staff step of a pitch: 0 is the bottom line, 8 the top one
	def _StepOf(paP, pcClef)
		if pcClef = "bass"  return This._Diatonic(paP) - 18 ok     # G2 on the bottom line
		return This._Diatonic(paP) - 30                             # E4 on the bottom line

	def _DrawSystem(pnS, paBarCols)
		_sp_ = @nSp
		_sy_ = @aSystems[pnS]
		_aX_ = _sy_[3]
		_x0_ = @nLeft
		_x1_ = _aX_[len(_aX_)]
		_o_ = ""
		_nSt_ = len(@aStaves)
		for _k_ = 1 to _nSt_
			_top_ = @aStaffY[pnS][_k_]
			for _l_ = 0 to 4  _o_ += This._Line(_x0_, _top_ + _l_ * _sp_, _x1_, _top_ + _l_ * _sp_, 1) next
			# the clef, from the font
			if @aStaves[_k_][2] = "treble"
				# calibrated by eye in Segoe UI Symbol: the curl round the G line
				_o_ += This._Glyph(_x0_ + 0.4 * _sp_, _top_ + 4.3 * _sp_, "&#x1D11E;", 6.6 * _sp_)
			else
				_o_ += This._Glyph(_x0_ + 0.5 * _sp_, _top_ + 1 * _sp_ + 1.2 * _sp_, "&#x1D122;", 4.1 * _sp_)
			ok
			@aModel + [ "clef", _k_, pnS, @aStaves[_k_][2] ]
			if pnS = 1
				_mx_ = _x0_ + 4.6 * _sp_ + 1.1 * _sp_
				_o_ += This._Text(_mx_, _top_ + 1.75 * _sp_, "" + @nBeats, 2.2 * _sp_, "middle", "bold") +
				       This._Text(_mx_, _top_ + 3.75 * _sp_, "" + @nUnit, 2.2 * _sp_, "middle", "bold")
			ok
			if pnS = 1 and _nSt_ > 1
				_o_ += This._Text(_x0_ - 8, _top_ + 2.4 * _sp_, @aStaves[_k_][1], 13, "end", "")
			ok
		next
		if _nSt_ > 1
			_ytop_ = @aStaffY[pnS][1]
			_ybot_ = @aStaffY[pnS][_nSt_] + 4 * _sp_
			_o_ += This._Line(_x0_, _ytop_, _x0_, _ybot_, 1.2) + This._Rect(_x0_ - 5, _ytop_ - 2, 3, _ybot_ - _ytop_ + 4)
		ok
		# the bars
		for _b_ = _sy_[1] to _sy_[2]
			_bx_ = _aX_[_b_ - _sy_[1] + 1]
			_ex_ = _aX_[_b_ - _sy_[1] + 2]
			_aC_ = paBarCols[_b_]
			# column x: the columns' natural widths, stretched with the bar
			_aCX_ = []
			_cx_ = _bx_ + 1.0 * _sp_ * _sy_[4]
			for _c_ in _aC_
				_px_ = _cx_
				if _c_[3]  _px_ += 1.5 * _sp_ ok
				_aCX_ + [ _c_[1], _px_ ]
				_cx_ += _c_[2] * _sy_[4]
			next
			for _k_ = 1 to _nSt_
				_o_ += This._DrawBar(_k_, pnS, _b_ - 1, _bx_, _ex_, _aCX_)
			next
			# the barline, on every staff; a final barline at the end of the music
			for _k_ = 1 to _nSt_
				_top_ = @aStaffY[pnS][_k_]
				if _b_ = @nBars
					_o_ += This._Line(_ex_ - 5, _top_, _ex_ - 5, _top_ + 4 * _sp_, 1.1) + This._Rect(_ex_ - 3, _top_, 3.2, 4 * _sp_)
				else
					_o_ += This._Line(_ex_, _top_, _ex_, _top_ + 4 * _sp_, 1.1)
				ok
				@aModel + [ "barline", _k_, pnS, _b_, _ex_ ]
			next
		next
		@aModel + [ "system", pnS, _sy_[2] - _sy_[1] + 1 ]
		return _o_

	# one bar of one staff: rests, heads, stems, beams or flags, dots, ties
	def _DrawBar(pnK, pnS, pnBar, pnX0, pnX1, paCX)
		_sp_ = @nSp
		_top_ = @aStaffY[pnS][pnK]
		_bot_ = _top_ + 4 * _sp_
		_clef_ = @aStaves[pnK][2]
		_aP_ = @aStaves[pnK][3]
		_o_ = ""
		# this bar's pieces, with their x
		_aIn_ = []
		for _i_ = 1 to len(_aP_)
			if _aP_[_i_][1] = pnBar
				_x_ = 0
				for _c_ in paCX
					if _c_[1] = _aP_[_i_][2]  _x_ = _c_[2] ok
				next
				_aIn_ + [ _i_, _x_ ]
			ok
		next
		# the beam groups: two or more eighths or shorter inside one beat, no rest between
		_grp_ = 4
		if @nUnit = 8 and @nBeats % 3 = 0  _grp_ = 6 ok
		_aGroups_ = []
		_cur_ = []
		_curBeat_ = -1
		for _it_ in _aIn_
			_p_ = _aP_[_it_[1]]
			_bShort_ = (len(_p_[4]) > 0 and _p_[3] <= 3)
			_beat_ = floor(_p_[2] / _grp_)
			if NOT _bShort_ or _beat_ != _curBeat_
				if len(_cur_) >= 2  _aGroups_ + _cur_ ok
				_cur_ = []
			ok
			if _bShort_
				_cur_ + _it_
				_curBeat_ = _beat_
			else
				_curBeat_ = -1
			ok
		next
		if len(_cur_) >= 2  _aGroups_ + _cur_ ok
		_aBeamed_ = []
		for _g_ in _aGroups_
			for _it_ in _g_  _aBeamed_ + _it_[1] next
		next
		# each piece
		for _it_ in _aIn_
			_p_ = _aP_[_it_[1]]
			_x_ = _it_[2]
			if len(_p_[4]) = 0
				_o_ += This._Rest(_p_, _x_, pnX0, pnX1, _top_, pnK, pnS, pnBar)
				loop
			ok
			_dir_ = This._StemDir(_p_[4], _clef_)
			for _g_ in _aGroups_
				for _gi_ in _g_
					if _gi_[1] = _it_[1]  _dir_ = This._GroupDir(pnK, _g_) ok
				next
			next
			_o_ += This._Heads(_p_, _x_, _top_, _clef_, _dir_, pnK, pnS, pnBar, ring_find(_aBeamed_, _it_[1]) = 0)
			_o_ += This._Tie(pnK, pnS, _it_[1], _x_, _top_, _dir_)
		next
		for _g_ in _aGroups_
			_o_ += This._Beam(_g_, _aP_, _top_, _clef_, pnK, pnS, pnBar)
		next
		return _o_

	def _StemDir(paPitches, pcClef)
		_hi_ = -99
		_lo_ = 99
		for _q_ in paPitches
			_s_ = This._StepOf(_q_, pcClef)
			if _s_ > _hi_  _hi_ = _s_ ok
			if _s_ < _lo_  _lo_ = _s_ ok
		next
		if (_hi_ - 4) > (4 - _lo_)  return "down" ok
		if (_hi_ - 4) = (4 - _lo_) and _hi_ >= 4  return "down" ok
		return "up"

	# a beam group's one stem direction: down when its heads lie, on average,
	# on or above the middle line
	def _GroupDir(pnK, paG)
		_aIdx_ = []
		for _it_ in paG  _aIdx_ + _it_[1] next
		return This._DirOfSteps(pnK, _aIdx_)

	def _DirOfSteps(pnK, paIdx)
		_clef_ = @aStaves[pnK][2]
		_sum_ = 0
		_n_ = 0
		for _i_ in paIdx
			for _q_ in @aStaves[pnK][3][_i_][4]
				_sum_ += This._StepOf(_q_, _clef_) - 4
				_n_++
			next
		next
		if _n_ > 0 and _sum_ >= 0  return "down" ok
		return "up"

	# noteheads (a second set beside the stem), ledger lines, accidentals, dots,
	# and -- when the note is not beamed -- its stem and flags
	def _Heads(paP, pnX, pnTop, pcClef, pcDir, pnK, pnS, pnBar, pbStem)
		_sp_ = @nSp
		_bot_ = pnTop + 4 * _sp_
		_len_ = paP[3]
		_bFill_ = (_len_ <= 6)
		_rx_ = 0.62 * _sp_
		_o_ = ""
		# the steps, sorted from the stem's far end
		_aH_ = []
		for _j_ = 1 to len(paP[4])
			_aH_ + [ This._StepOf(paP[4][_j_], pcClef), _j_ ]
		next
		_aH_ = sort(_aH_, 1)
		if pcDir = "down"
			_aT_ = []
			for _j_ = len(_aH_) to 1 step -1  _aT_ + _aH_[_j_] next
			_aH_ = _aT_
		ok
		_prev_ = -99
		_prevShift_ = FALSE
		_nAcc_ = 0
		for _h_ in _aH_
			_s_ = _h_[1]
			_y_ = _bot_ - _s_ * _sp_ / 2
			_shift_ = FALSE
			if fabs(_s_ - _prev_) = 1 and NOT _prevShift_  _shift_ = TRUE ok
			_hx_ = pnX
			if _shift_
				if pcDir = "up"  _hx_ = pnX + 2 * _rx_ - 1 else _hx_ = pnX - 2 * _rx_ + 1 ok
			ok
			_prev_ = _s_
			_prevShift_ = _shift_
			# ledger lines
			if _s_ <= -2
				for _l_ = -2 to _s_ step -2
					_ly_ = _bot_ - _l_ * _sp_ / 2
					_o_ += This._Line(_hx_ - 1.6 * _rx_, _ly_, _hx_ + 1.6 * _rx_, _ly_, 1.1)
					@aModel + [ "ledger", pnK, pnS, pnBar, _hx_, _ly_ ]
				next
			ok
			if _s_ >= 10
				for _l_ = 10 to _s_ step 2
					_ly_ = _bot_ - _l_ * _sp_ / 2
					_o_ += This._Line(_hx_ - 1.6 * _rx_, _ly_, _hx_ + 1.6 * _rx_, _ly_, 1.1)
					@aModel + [ "ledger", pnK, pnS, pnBar, _hx_, _ly_ ]
				next
			ok
			_o_ += This._Head(_hx_, _y_, _len_)
			_pp_ = paP[4][_h_[2]]
			@aModel + [ "head", pnK, pnS, pnBar, _hx_, _y_, _s_, _pp_[1] + _pp_[3], _pp_[2], _len_, pcDir, paP[2] ]
			# the accidental this head shows
			_show_ = paP[8][_h_[2]]
			if _show_ != 99
				_ax_ = pnX - _rx_ - 1.0 * _sp_ - _nAcc_ * 1.1 * _sp_
				_nAcc_++
				_o_ += This._Accidental(_ax_, _y_, _show_)
				@aModel + [ "acc", pnK, pnS, pnBar, _ax_, _y_, _show_ ]
			ok
			# the dot, in the space above when the head sits on a line
			if ring_find([ 12, 6, 3 ], _len_) > 0
				_dy_ = _y_
				if _s_ % 2 = 0  _dy_ = _y_ - _sp_ / 2 ok
				_dx_ = pnX + _rx_ + 0.55 * _sp_
				if _shift_ and pcDir = "up"  _dx_ += 2 * _rx_ ok
				_o_ += This._Ellipse(_dx_, _dy_, 0.17 * _sp_, 0.17 * _sp_, TRUE)
				@aModel + [ "dot", pnK, pnS, pnBar, _dx_, _dy_ ]
			ok
		next
		# the stem, and flags when not beamed
		if _len_ < 16 and pbStem
			_lo_ = 99
			_hi_ = -99
			for _h_ in _aH_
				if _h_[1] < _lo_  _lo_ = _h_[1] ok
				if _h_[1] > _hi_  _hi_ = _h_[1] ok
			next
			# an up stem rises from the lowest head past the highest; a down stem
			# falls from the highest past the lowest -- and reaches the middle line
			_mid_ = _bot_ - 2 * _sp_
			if pcDir = "up"
				_sx_ = pnX + _rx_ - 0.6
				_y1_ = _bot_ - _lo_ * _sp_ / 2
				_y2_ = _bot_ - _hi_ * _sp_ / 2 - 3.5 * _sp_
				if _y2_ > _mid_  _y2_ = _mid_ ok
			else
				_sx_ = pnX - _rx_ + 0.6
				_y1_ = _bot_ - _hi_ * _sp_ / 2
				_y2_ = _bot_ - _lo_ * _sp_ / 2 + 3.5 * _sp_
				if _y2_ < _mid_  _y2_ = _mid_ ok
			ok
			_o_ += This._Line(_sx_, _y1_, _sx_, _y2_, 1.2)
			_nf_ = 0
			if _len_ = 2 or _len_ = 3  _nf_ = 1 ok
			if _len_ = 1  _nf_ = 2 ok
			for _f_ = 1 to _nf_
				_o_ += This._Flag(_sx_, _y2_, pcDir, _f_)
			next
			if _nf_ > 0  @aModel + [ "flag", pnK, pnS, pnBar, _sx_, _nf_ ] ok
		ok
		return _o_

	def _Head(pnX, pnY, pnLen)
		_sp_ = @nSp
		_q_ = char(34)
		_t_ = "translate(" + This._F(pnX) + "," + This._F(pnY) + ") rotate(-20)"
		if pnLen <= 6
			return "<ellipse transform=" + _q_ + _t_ + _q_ + " rx=" + _q_ + This._F(0.62 * _sp_) + _q_ + " ry=" + _q_ +
			       This._F(0.44 * _sp_) + _q_ + " stroke=" + _q_ + "none" + _q_ + "/>" + nl
		ok
		if pnLen >= 16
			# a whole note: an open oval, its hole tilted the other way
			return "<ellipse transform=" + _q_ + "translate(" + This._F(pnX) + "," + This._F(pnY) + ")" + _q_ + " rx=" + _q_ +
			       This._F(0.78 * _sp_) + _q_ + " ry=" + _q_ + This._F(0.48 * _sp_) + _q_ + " stroke=" + _q_ + "none" + _q_ + "/>" +
			       "<ellipse transform=" + _q_ + "translate(" + This._F(pnX) + "," + This._F(pnY) + ") rotate(55)" + _q_ + " rx=" + _q_ +
			       This._F(0.36 * _sp_) + _q_ + " ry=" + _q_ + This._F(0.22 * _sp_) + _q_ + " fill=" + _q_ + "#fff" + _q_ +
			       " stroke=" + _q_ + "none" + _q_ + "/>" + nl
		ok
		# a half note: an open, tilted oval
		return "<ellipse transform=" + _q_ + _t_ + _q_ + " rx=" + _q_ + This._F(0.62 * _sp_) + _q_ + " ry=" + _q_ +
		       This._F(0.44 * _sp_) + _q_ + " stroke=" + _q_ + "none" + _q_ + "/>" +
		       "<ellipse transform=" + _q_ + _t_ + _q_ + " rx=" + _q_ + This._F(0.46 * _sp_) + _q_ + " ry=" + _q_ +
		       This._F(0.2 * _sp_) + _q_ + " fill=" + _q_ + "#fff" + _q_ + " stroke=" + _q_ + "none" + _q_ + "/>" + nl

	def _Flag(pnX, pnY, pcDir, pnN)
		_sp_ = @nSp
		_q_ = char(34)
		if pcDir = "up"
			_y_ = pnY + (pnN - 1) * 0.8 * _sp_
			_d_ = "M" + This._F(pnX) + "," + This._F(_y_) + " c" + This._F(0.2 * _sp_) + "," + This._F(1.2 * _sp_) + " " +
			      This._F(1.5 * _sp_) + "," + This._F(1.5 * _sp_) + " " + This._F(0.9 * _sp_) + "," + This._F(3.1 * _sp_) +
			      " c" + This._F(0.3 * _sp_) + "," + This._F(-1.3 * _sp_) + " " + This._F(-0.6 * _sp_) + "," + This._F(-1.9 * _sp_) +
			      " " + This._F(-0.9 * _sp_) + "," + This._F(-2.2 * _sp_) + " z"
		else
			_y_ = pnY - (pnN - 1) * 0.8 * _sp_
			_d_ = "M" + This._F(pnX) + "," + This._F(_y_) + " c" + This._F(0.2 * _sp_) + "," + This._F(-1.2 * _sp_) + " " +
			      This._F(1.5 * _sp_) + "," + This._F(-1.5 * _sp_) + " " + This._F(0.9 * _sp_) + "," + This._F(-3.1 * _sp_) +
			      " c" + This._F(0.3 * _sp_) + "," + This._F(1.3 * _sp_) + " " + This._F(-0.6 * _sp_) + "," + This._F(1.9 * _sp_) +
			      " " + This._F(-0.9 * _sp_) + "," + This._F(2.2 * _sp_) + " z"
		ok
		return "<path d=" + _q_ + _d_ + _q_ + " stroke=" + _q_ + "none" + _q_ + "/>" + nl

	# a beam group: stems to one straight line, a second beam for sixteenths
	def _Beam(paG, paP, pnTop, pcClef, pnK, pnS, pnBar)
		_sp_ = @nSp
		_bot_ = pnTop + 4 * _sp_
		_rx_ = 0.62 * _sp_
		_aIdx_ = []
		for _it_ in paG  _aIdx_ + _it_[1] next
		_dir_ = This._DirOfSteps(pnK, _aIdx_)
		# each note: [ stem x, root y (far head), end y wanted (near head +- 3.5) ]
		_aN_ = []
		for _it_ in paG
			_p_ = paP[_it_[1]]
			_hi_ = -99
			_lo_ = 99
			for _q_ in _p_[4]
				_s_ = This._StepOf(_q_, pcClef)
				if _s_ > _hi_  _hi_ = _s_ ok
				if _s_ < _lo_  _lo_ = _s_ ok
			next
			if _dir_ = "up"
				_aN_ + [ _it_[2] + _rx_ - 0.6, _bot_ - _lo_ * _sp_ / 2, _bot_ - _hi_ * _sp_ / 2 - 3.5 * _sp_, _p_[3] ]
			else
				_aN_ + [ _it_[2] - _rx_ + 0.6, _bot_ - _hi_ * _sp_ / 2, _bot_ - _lo_ * _sp_ / 2 + 3.5 * _sp_, _p_[3] ]
			ok
		next
		_n_ = len(_aN_)
		_xa_ = _aN_[1][1]
		_xb_ = _aN_[_n_][1]
		_ya_ = _aN_[1][3]
		_yb_ = _aN_[_n_][3]
		# a gentle slope: at most one staff space over the group
		if _yb_ - _ya_ > _sp_  _yb_ = _ya_ + _sp_ ok
		if _ya_ - _yb_ > _sp_  _yb_ = _ya_ - _sp_ ok
		# then move the whole beam so no stem is shorter than it should be
		_shift_ = 0
		for _nn_ in _aN_
			_yl_ = _ya_ + (_yb_ - _ya_) * (_nn_[1] - _xa_) / (_xb_ - _xa_ + 0.0001)
			if _dir_ = "up"
				if _yl_ - _nn_[3] > _shift_  _shift_ = _yl_ - _nn_[3] ok
			else
				if _nn_[3] - _yl_ > _shift_  _shift_ = _nn_[3] - _yl_ ok
			ok
		next
		if _dir_ = "up"
			_ya_ -= _shift_
			_yb_ -= _shift_
		else
			_ya_ += _shift_
			_yb_ += _shift_
		ok
		_th_ = 0.48 * _sp_
		_sg_ = 1
		if _dir_ = "down"  _sg_ = -1 ok
		_o_ = ""
		for _nn_ in _aN_
			_yl_ = _ya_ + (_yb_ - _ya_) * (_nn_[1] - _xa_) / (_xb_ - _xa_ + 0.0001)
			_o_ += This._Line(_nn_[1], _nn_[2], _nn_[1], _yl_, 1.2)
		next
		_o_ += This._BeamSeg(_xa_, _ya_, _xb_, _yb_, _th_ * _sg_)
		# the second beam: between neighbouring sixteenths, or a stub
		_nLv_ = 1
		_off_ = 0.75 * _sp_ * _sg_
		for _i_ = 1 to _n_
			if _aN_[_i_][4] != 1  loop ok
			_nLv_ = 2
			_bPrev_ = FALSE
			if _i_ > 1
				if _aN_[_i_ - 1][4] = 1  _bPrev_ = TRUE ok
			ok
			if _bPrev_  loop ok
			_bNext_ = FALSE
			if _i_ < _n_
				if _aN_[_i_ + 1][4] = 1  _bNext_ = TRUE ok
			ok
			_x1_ = _aN_[_i_][1]
			if _bNext_
				_j_ = _i_
				while _j_ < _n_
					if _aN_[_j_ + 1][4] != 1  exit ok
					_j_++
				end
				_x2_ = _aN_[_j_][1]
			else
				if _i_ > 1
					_x2_ = _x1_
					_x1_ = _x1_ - 1.2 * _sp_
				else
					_x2_ = _x1_ + 1.2 * _sp_
				ok
			ok
			_y1_ = _ya_ + (_yb_ - _ya_) * (_x1_ - _xa_) / (_xb_ - _xa_ + 0.0001) + _off_
			_y2_ = _ya_ + (_yb_ - _ya_) * (_x2_ - _xa_) / (_xb_ - _xa_ + 0.0001) + _off_
			_o_ += This._BeamSeg(_x1_, _y1_, _x2_, _y2_, _th_ * _sg_)
		next
		@aModel + [ "beam", pnK, pnS, pnBar, _n_, _nLv_, _dir_ ]
		return _o_

	def _BeamSeg(pnX1, pnY1, pnX2, pnY2, pnTh)
		_q_ = char(34)
		return "<polygon points=" + _q_ + This._F(pnX1 - 0.6) + "," + This._F(pnY1) + " " + This._F(pnX2 + 0.6) + "," + This._F(pnY2) + " " +
		       This._F(pnX2 + 0.6) + "," + This._F(pnY2 + pnTh) + " " + This._F(pnX1 - 0.6) + "," + This._F(pnY1 + pnTh) + _q_ +
		       " stroke=" + _q_ + "none" + _q_ + "/>" + nl

	# a tie from this piece to the next piece of the same staff
	def _Tie(pnK, pnS, pnI, pnX, pnTop, pcDir)
		_aP_ = @aStaves[pnK][3]
		_p_ = _aP_[pnI]
		if NOT _p_[5]  return "" ok
		if pnI >= len(_aP_)  return "" ok
		_sp_ = @nSp
		_bot_ = pnTop + 4 * _sp_
		_nxt_ = _aP_[pnI + 1]
		# where the next piece is drawn: its bar, its column, its system
		_ns_ = 0
		for _si_ = 1 to len(@aSystems)
			if _nxt_[1] + 1 >= @aSystems[_si_][1] and _nxt_[1] + 1 <= @aSystems[_si_][2]  _ns_ = _si_ ok
		next
		_o_ = ""
		_sg_ = 1
		if pcDir = "down"  _sg_ = -1 ok
		for _q_ in _p_[4]
			_y_ = _bot_ - This._StepOf(_q_, @aStaves[pnK][2]) * _sp_ / 2 + _sg_ * 0.7 * _sp_
			_x1_ = pnX + 0.7 * _sp_
			if _ns_ = pnS
				_x2_ = This._XOf(pnS, _nxt_[1], _nxt_[2]) - 0.7 * _sp_
				_o_ += This._Arc(_x1_, _x2_, _y_, _sg_)
				@aModel + [ "tie", pnK, pnS, _x1_, _x2_, _y_ ]
			else
				_sy_ = @aSystems[pnS]
				_x2_ = _sy_[3][len(_sy_[3])] - 2
				_o_ += This._Arc(_x1_, _x2_, _y_, _sg_)
				@aModel + [ "tie", pnK, pnS, _x1_, _x2_, _y_ ]
				if _ns_ > 0
					_top2_ = @aStaffY[_ns_][pnK]
					_y2_ = _top2_ + 4 * _sp_ - This._StepOf(_q_, @aStaves[pnK][2]) * _sp_ / 2 + _sg_ * 0.7 * _sp_
					_xs_ = @aSystems[_ns_][3][1] - 1.2 * _sp_
					_xe_ = This._XOf(_ns_, _nxt_[1], _nxt_[2]) - 0.7 * _sp_
					_o_ += This._Arc(_xs_, _xe_, _y2_, _sg_)
					@aModel + [ "tie", pnK, _ns_, _xs_, _xe_, _y2_ ]
				ok
			ok
		next
		return _o_

	# the x of a column: recomputed the way _DrawSystem places it
	def _XOf(pnS, pnBar, pnPos)
		_sy_ = @aSystems[pnS]
		_bx_ = _sy_[3][pnBar + 1 - _sy_[1] + 1]
		_aC_ = This._Columns(pnBar)
		_cx_ = _bx_ + 1.0 * @nSp * _sy_[4]
		for _c_ in _aC_
			_px_ = _cx_
			if _c_[3]  _px_ += 1.5 * @nSp ok
			if _c_[1] = pnPos  return _px_ ok
			_cx_ += _c_[2] * _sy_[4]
		next
		return _cx_

	def _Arc(pnX1, pnX2, pnY, pnSg)
		_q_ = char(34)
		_h_ = 0.55 * @nSp + (pnX2 - pnX1) * 0.04
		if _h_ > 1.4 * @nSp  _h_ = 1.4 * @nSp ok
		_mx_ = (pnX1 + pnX2) / 2
		_d_ = "M" + This._F(pnX1) + "," + This._F(pnY) + " Q" + This._F(_mx_) + "," + This._F(pnY + pnSg * _h_) + " " +
		      This._F(pnX2) + "," + This._F(pnY) + " Q" + This._F(_mx_) + "," + This._F(pnY + pnSg * (_h_ - 0.32 * @nSp)) + " " +
		      This._F(pnX1) + "," + This._F(pnY) + " z"
		return "<path d=" + _q_ + _d_ + _q_ + " stroke=" + _q_ + "none" + _q_ + "/>" + nl

	# rests are drawn as shapes: the whole hangs from the fourth line, the half
	# sits on the middle one, the quarter is a zigzag, the eighth and sixteenth a
	# slanted stem with one or two hooks
	def _Rest(paP, pnX, pnX0, pnX1, pnTop, pnK, pnS, pnBar)
		_sp_ = @nSp
		_len_ = paP[3]
		_o_ = ""
		_x_ = pnX
		if paP[7]
			_x_ = (pnX0 + pnX1) / 2
			_len_ = 16
		ok
		if _len_ = 16 or _len_ = 12 or _len_ = 8
			_y_ = pnTop + _sp_
			if _len_ != 16  _y_ = pnTop + 2 * _sp_ - 0.5 * _sp_ ok
			_o_ += This._Rect(_x_ - 0.6 * _sp_, _y_, 1.2 * _sp_, 0.5 * _sp_)
		but _len_ = 6 or _len_ = 4
			_c_ = pnTop + 2 * _sp_
			_d_ = "M" + This._F(_x_ - 0.25 * _sp_) + "," + This._F(_c_ - 1.5 * _sp_) + " L" + This._F(_x_ + 0.45 * _sp_) + "," +
			      This._F(_c_ - 0.6 * _sp_) + " L" + This._F(_x_ - 0.15 * _sp_) + "," + This._F(_c_ + 0.1 * _sp_) + " L" +
			      This._F(_x_ + 0.45 * _sp_) + "," + This._F(_c_ + 0.9 * _sp_) + " C" + This._F(_x_ - 0.2 * _sp_) + "," +
			      This._F(_c_ + 0.6 * _sp_) + " " + This._F(_x_ - 0.55 * _sp_) + "," + This._F(_c_ + 1.1 * _sp_) + " " +
			      This._F(_x_ - 0.05 * _sp_) + "," + This._F(_c_ + 1.6 * _sp_)
			_o_ += "<path d=" + char(34) + _d_ + char(34) + " fill=" + char(34) + "none" + char(34) + " stroke-width=" +
			       char(34) + This._F(0.28 * _sp_) + char(34) + " stroke-linejoin=" + char(34) + "round" + char(34) + "/>" + nl
		else
			_nh_ = 1
			if _len_ = 1  _nh_ = 2 ok
			_c_ = pnTop + 2 * _sp_
			_o_ += This._Line(_x_ + 0.5 * _sp_, _c_ - 1.0 * _sp_, _x_ - 0.1 * _sp_ - (_nh_ - 1) * 0.3 * _sp_, _c_ + 1.0 * _sp_ + (_nh_ - 1) * _sp_, 1.3)
			for _h_ = 1 to _nh_
				_hy_ = _c_ - 1.0 * _sp_ + (_h_ - 1) * _sp_
				_hx_ = _x_ + 0.5 * _sp_ - (_h_ - 1) * 0.3 * _sp_
				_o_ += This._Ellipse(_hx_ - 0.75 * _sp_, _hy_ + 0.2 * _sp_, 0.3 * _sp_, 0.3 * _sp_, TRUE)
				_o_ += "<path d=" + char(34) + "M" + This._F(_hx_ - 0.75 * _sp_) + "," + This._F(_hy_ + 0.45 * _sp_) + " Q" +
				       This._F(_hx_ - 0.2 * _sp_) + "," + This._F(_hy_ + 0.6 * _sp_) + " " + This._F(_hx_) + "," + This._F(_hy_) +
				       char(34) + " fill=" + char(34) + "none" + char(34) + " stroke-width=" + char(34) + "1.3" + char(34) + "/>" + nl
			next
		ok
		if ring_find([ 12, 6, 3 ], _len_) > 0
			_o_ += This._Ellipse(_x_ + 1.1 * _sp_, pnTop + 1.5 * _sp_, 0.17 * _sp_, 0.17 * _sp_, TRUE)
		ok
		@aModel + [ "rest", pnK, pnS, pnBar, _x_, _len_, paP[2] ]
		return _o_

	# the accidentals, drawn: sharp, flat, natural, and the quarter tones as
	# Arabic notation writes them -- a half-flat is a flat struck through, a
	# half-sharp a sharp with a single vertical
	def _Accidental(pnX, pnY, pnAlt)
		_sp_ = @nSp
		_o_ = ""
		if pnAlt = 1 or pnAlt = 0.5
			if pnAlt = 1
				_o_ += This._Line(pnX - 0.28 * _sp_, pnY - 1.3 * _sp_, pnX - 0.28 * _sp_, pnY + 1.4 * _sp_, 1.1)
				_o_ += This._Line(pnX + 0.28 * _sp_, pnY - 1.4 * _sp_, pnX + 0.28 * _sp_, pnY + 1.3 * _sp_, 1.1)
			else
				_o_ += This._Line(pnX, pnY - 1.35 * _sp_, pnX, pnY + 1.35 * _sp_, 1.1)
			ok
			_o_ += This._BeamSeg(pnX - 0.55 * _sp_, pnY - 0.3 * _sp_, pnX + 0.55 * _sp_, pnY - 0.6 * _sp_, 0.3 * _sp_)
			_o_ += This._BeamSeg(pnX - 0.55 * _sp_, pnY + 0.5 * _sp_, pnX + 0.55 * _sp_, pnY + 0.2 * _sp_, 0.3 * _sp_)
		but pnAlt = -1 or pnAlt = -0.5
			_o_ += This._Line(pnX - 0.3 * _sp_, pnY - 2.0 * _sp_, pnX - 0.3 * _sp_, pnY + 0.5 * _sp_, 1.2)
			_d_ = "M" + This._F(pnX - 0.3 * _sp_) + "," + This._F(pnY - 0.1 * _sp_) + " C" + This._F(pnX + 0.2 * _sp_) + "," +
			      This._F(pnY - 0.75 * _sp_) + " " + This._F(pnX + 0.95 * _sp_) + "," + This._F(pnY - 0.45 * _sp_) + " " +
			      This._F(pnX - 0.3 * _sp_) + "," + This._F(pnY + 0.5 * _sp_)
			_o_ += "<path d=" + char(34) + _d_ + char(34) + " fill=" + char(34) + "none" + char(34) + " stroke-width=" + char(34) + "1.5" + char(34) + "/>" + nl
			if pnAlt = -0.5
				_o_ += This._Line(pnX - 0.8 * _sp_, pnY - 0.75 * _sp_, pnX + 0.2 * _sp_, pnY - 1.35 * _sp_, 1.1)
			ok
		else
			_o_ += This._Line(pnX - 0.3 * _sp_, pnY - 1.4 * _sp_, pnX - 0.3 * _sp_, pnY + 0.55 * _sp_, 1.1)
			_o_ += This._Line(pnX + 0.3 * _sp_, pnY - 0.55 * _sp_, pnX + 0.3 * _sp_, pnY + 1.4 * _sp_, 1.1)
			_o_ += This._BeamSeg(pnX - 0.3 * _sp_, pnY - 0.25 * _sp_, pnX + 0.3 * _sp_, pnY - 0.45 * _sp_, 0.28 * _sp_)
			_o_ += This._BeamSeg(pnX - 0.3 * _sp_, pnY + 0.45 * _sp_, pnX + 0.3 * _sp_, pnY + 0.25 * _sp_, 0.28 * _sp_)
		ok
		return _o_

	#== SVG primitives ============================================================

	def _Line(pnX1, pnY1, pnX2, pnY2, pnW)
		_q_ = char(34)
		return "<line x1=" + _q_ + This._F(pnX1) + _q_ + " y1=" + _q_ + This._F(pnY1) + _q_ + " x2=" + _q_ + This._F(pnX2) + _q_ +
		       " y2=" + _q_ + This._F(pnY2) + _q_ + " stroke-width=" + _q_ + This._F(pnW) + _q_ + "/>" + nl

	def _Rect(pnX, pnY, pnW, pnH)
		_q_ = char(34)
		return "<rect x=" + _q_ + This._F(pnX) + _q_ + " y=" + _q_ + This._F(pnY) + _q_ + " width=" + _q_ + This._F(pnW) + _q_ +
		       " height=" + _q_ + This._F(pnH) + _q_ + " stroke=" + _q_ + "none" + _q_ + "/>" + nl

	def _Ellipse(pnX, pnY, pnRx, pnRy, pbFill)
		_q_ = char(34)
		_f_ = ""
		if pbFill  _f_ = " stroke=" + _q_ + "none" + _q_ ok
		return "<ellipse cx=" + _q_ + This._F(pnX) + _q_ + " cy=" + _q_ + This._F(pnY) + _q_ + " rx=" + _q_ + This._F(pnRx) + _q_ +
		       " ry=" + _q_ + This._F(pnRy) + _q_ + _f_ + "/>" + nl

	def _Text(pnX, pnY, pcText, pnSize, pcAnchor, pcWeight)
		_q_ = char(34)
		_w_ = ""
		if pcWeight != ""  _w_ = " font-weight=" + _q_ + pcWeight + _q_ ok
		return "<text x=" + _q_ + This._F(pnX) + _q_ + " y=" + _q_ + This._F(pnY) + _q_ + " font-family=" + _q_ +
		       "Georgia,'Times New Roman',serif" + _q_ + " font-size=" + _q_ + This._F(pnSize) + _q_ + " text-anchor=" + _q_ +
		       pcAnchor + _q_ + " stroke=" + _q_ + "none" + _q_ + _w_ + ">" + This._Xml(pcText) + "</text>" + nl

	def _Glyph(pnX, pnY, pcEntity, pnSize)
		_q_ = char(34)
		return "<text x=" + _q_ + This._F(pnX) + _q_ + " y=" + _q_ + This._F(pnY) + _q_ + " font-family=" + _q_ +
		       "'Noto Music','Segoe UI Symbol','Apple Symbols','Bravura Text',Symbola,serif" + _q_ + " font-size=" + _q_ +
		       This._F(pnSize) + _q_ + " stroke=" + _q_ + "none" + _q_ + ">" + pcEntity + "</text>" + nl

	# a number as SVG wants it: one decimal, whatever decimals() is set to
	def _F(pn)
		_v_ = floor(pn * 10 + 0.5)
		_s_ = ""
		if _v_ < 0
			_s_ = "-"
			_v_ = 0 - _v_
		ok
		_i_ = floor(_v_ / 10)
		_d_ = _v_ % 10
		_s_ += "" + _i_
		if _d_ != 0  _s_ += "." + _d_ ok
		# (built from integers: decimals(3) would otherwise print 12.500)
		return _s_

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

	def _Loss(pc)
		if ring_find(@aLosses, pc) = 0  @aLosses + pc ok
