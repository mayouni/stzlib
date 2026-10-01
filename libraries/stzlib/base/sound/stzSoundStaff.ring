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
# THE KEY SIGNATURE (MU11). SetKey("auto") -- the default -- reads it from the
# music: the circle-of-fifths key that leaves the fewest accidentals, and then,
# as Arabic notation does, every letter whose quarter-tone alteration is the
# one it usually carries joins the signature -- so Rast is written with E and B
# half-flat in the key, and Bayati with B flat and E half-flat. SetKey("Bb"),
# SetKey("F#m"), SetKey(-3) or SetKey("none") set it; SetKeyOfMode(:maqam,
# :hijaz) takes it from a declared mode (D: B flat, E flat, F sharp). THE KEY
# ALSO SPELLS: with one flat in the key the note between A and B is B flat,
# not A sharp, and an accidental is drawn only where a note leaves the key.
#
# THE PERCUSSION STAFF (MU11). Drum strokes are drawn on their own staff, under
# the pitched ones, with the neutral clef: the drum kit on five lines (kick in
# the bottom space, snare in the third, the hihat above the staff with an x
# head); a hand drum -- darbouka, bendir -- on ONE line, as its rhythms are
# written: dum under the line, tak over it, ka over it with an x head, and the
# syllables D T K beneath, the way a darbouka player reads them.
#
# KEY CHANGES (MU12). KeyChangeAt(beat, key) and KeyChangeOfModeAt(beat,
# universe, mode) change the key at a barline (a beat inside a bar is moved to
# the next barline, and counted); with the key read from the music and no
# change asked for, the piece is cut into SECTIONS by the key each part fits --
# a change only where it saves more accidentals than it costs (a penalty of 4).
# A change is drawn as engravers draw it: a double barline, naturals cancelling
# what the old key had and the new one has not, then the new signature; at the
# head of a system the new key, and a COURTESY signature at the end of the
# system before. Each bar remembers, and spells in, the key in force there.
#
# THE TWO-VOICE KIT (MU12). On the drum kit's staff the hands and the feet are
# two voices, as drum parts are written: hihat and snare with stems UP, the kick
# with stems DOWN, each voice with its own rhythm and its own rests (raised for
# the hands, lowered for the feet). A kit with only hands, or only feet, stays
# one voice.
#
# WHAT IS NOT (named, as the writers name theirs): a pitch further than 5 cents from the nearest quarter tone is drawn at
# that quarter tone and COUNTED (slendro); no dynamics, articulations, lyrics or
# slurs.
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

	# the key signature (MU11)
	@cKey = "auto"             # "auto", "none", "fifths", or "mode"
	@nKeyFifths = 0            # what SetKey asked for, when it named a key
	@aSig = [ 0, 0, 0, 0, 0, 0, 0 ]      # the alteration each letter C D E F G A B carries
	@aSigOrder = []            # [ letter, alteration ] in the order they are drawn
	@nFifths = 0               # the circle-of-fifths part of the signature
	@cKeyName = ""
	@aModeSig = []             # what SetKeyOfMode read from the declaration
	@cModeName = ""

	# key changes (MU12)
	@aKeyReq = []              # [ beat, sig, fifths, name ] asked by KeyChangeAt
	@bKeyChanges = TRUE        # find changes when the key is read from the music
	@aKeys = []                # [ from bar (0-based), sig, fifths, order, name ]

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

	# "auto" (read from the music), "none", a key ("D", "Bb", "F#m", "Ddor"),
	# or a number of fifths: 2 is two sharps, -3 three flats
	def SetKey(pKey)
		if isNumber(pKey)
			if pKey < -7 or pKey > 7
				@cLastError = "SetKey: a number of fifths is -7 (seven flats) to 7 (seven sharps)"
				return This
			ok
			@cKey = "fifths"
			@nKeyFifths = pKey
			return This
		ok
		_c_ = lower(ring_trim("" + pKey))
		if _c_ = "auto" or _c_ = "none"
			@cKey = _c_
			return This
		ok
		_f_ = This._FifthsOfName("" + pKey)
		if _f_ = 99
			@cLastError = "SetKey: '" + pKey + "' is not a key -- a tonic and a mode (D, Bb, F#m, Ddor), a number of fifths, auto or none"
			return This
		ok
		@cKey = "fifths"
		@nKeyFifths = _f_
		return This

	def SetKeyQ(pKey)
		return This.SetKey(pKey)

	# the signature a DECLARED mode implies: its degrees spelled on consecutive
	# letters from the tonic -- quarter tones included, as Arabic notation writes them
	def SetKeyOfMode(pUniverse, pMode)
		_r_ = This._SigOfMode(pUniverse, pMode, "SetKeyOfMode")
		if len(_r_) = 0  return This ok
		@aModeSig = _r_[1]
		@cModeName = _r_[2]
		@cKey = "mode"
		return This

	# [ signature, "universe / mode" ], or [] with LastError
	def _SigOfMode(pUniverse, pMode, pcWho)
		_oU_ = StzSoundUniverseQ(pUniverse)
		if NOT _oU_.IsUsable()
			@cLastError = pcWho + ": " + _oU_.LastError()
			return []
		ok
		if "" + pMode != ""  _oU_.Mode(pMode) ok
		_aD_ = []
		for _m_ in This._GetKV(_oU_.Declaration(), "modes", [])
			if This._GetKV(_m_, "name", "") = _oU_.ModeName()  _aD_ = This._GetKV(_m_, "degrees", []) ok
		next
		if len(_aD_) != 7
			@cLastError = pcWho + ": a key signature needs a mode of seven degrees; " + _oU_.Name() + " / " +
			              _oU_.ModeName() + " has " + len(_aD_)
			return []
		ok
		_oN_ = new stzSoundNotation("")
		_aT_ = _oN_._Spell(StzNoteToHz(_oU_.TonicName()))
		_m0_ = This._Midi(_aT_)
		_l0_ = substr("CDEFGAB", _aT_[1])
		_aSig_ = [ 0, 0, 0, 0, 0, 0, 0 ]
		_aSemi_ = [ 0, 2, 4, 5, 7, 9, 11 ]
		for _i_ = 1 to 7
			_l_ = ((_l0_ - 1 + _i_ - 1) % 7) + 1
			_m_ = _m0_ + _aD_[_i_] / 100
			_o_ = floor((_m_ - _aSemi_[_l_]) / 12 + 0.5) - 1
			_a_ = _m_ - (12 * (_o_ + 1) + _aSemi_[_l_])
			_a_ = floor(_a_ * 2 + 0.5) / 2
			if fabs(_a_) > 1
				@cLastError = pcWho + ": degree " + _i_ + " is " + _a_ + " semitones from its letter; no signature writes that"
				return []
			ok
			_aSig_[_l_] = _a_
		next
		return [ _aSig_, _oU_.Name() + " / " + _oU_.ModeName() ]

	# MU12: the key changes at the barline at (or after) `pnBeat`
	def KeyChangeAt(pnBeat, pKey)
		if NOT isNumber(pnBeat) or pnBeat < 0
			@cLastError = "KeyChangeAt: a beat is 0 or later"
			return This
		ok
		_f_ = 0
		_bNone_ = FALSE
		if isNumber(pKey)
			if pKey < -7 or pKey > 7
				@cLastError = "KeyChangeAt: a number of fifths is -7 to 7"
				return This
			ok
			_f_ = pKey
		but lower(ring_trim("" + pKey)) = "none"
			_bNone_ = TRUE
		else
			_f_ = This._FifthsOfName("" + pKey)
			if _f_ = 99
				@cLastError = "KeyChangeAt: '" + pKey + "' is not a key -- a tonic and a mode (D, Bb, F#m, Ddor), a number of fifths, or none"
				return This
			ok
		ok
		if _bNone_
			@aKeyReq + [ pnBeat, [ 0, 0, 0, 0, 0, 0, 0 ], 0, "no key signature" ]
		else
			@aKeyReq + [ pnBeat, This._SigOfFifths(_f_), _f_, This._FifthsText(_f_) ]
		ok
		return This

	def KeyChangeAtQ(pnBeat, pKey)
		return This.KeyChangeAt(pnBeat, pKey)

	def KeyChangeOfModeAt(pnBeat, pUniverse, pMode)
		if NOT isNumber(pnBeat) or pnBeat < 0
			@cLastError = "KeyChangeOfModeAt: a beat is 0 or later"
			return This
		ok
		_r_ = This._SigOfMode(pUniverse, pMode, "KeyChangeOfModeAt")
		if len(_r_) = 0  return This ok
		@aKeyReq + [ pnBeat, _r_[1], 0, "from the mode " + _r_[2] + ": " + This._SigTextOf(This._SigOrderOf(_r_[1])) ]
		return This

	def KeyChangeOfModeAtQ(pnBeat, pUniverse, pMode)
		return This.KeyChangeOfModeAt(pnBeat, pUniverse, pMode)

	# find key changes when the key is read from the music (TRUE, the default)
	def SetKeyChanges(pbFind)
		@bKeyChanges = pbFind
		return This

	# [ bar (from 1), the key's name ] for every change after the first key -- after ToSVG
	def KeyChanges()
		_a_ = []
		for _i_ = 2 to len(@aKeys)  _a_ + [ @aKeys[_i_][1] + 1, @aKeys[_i_][5] ] next
		return _a_

	def SetKeyOfModeQ(pUniverse, pMode)
		return This.SetKeyOfMode(pUniverse, pMode)

	# the signature drawn: [ letter, alteration ] in drawing order -- after ToSVG
	def Key()
		return @aSigOrder

	def KeyName()
		return @cKeyName

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
		for _s_ in @aStaves
			if _s_[5] = 0  _a_ + [ _s_[1], _s_[2] ] ok          # a second voice draws no staff of its own
		next
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
			# MU11: strokes are drawn now, on a percussion staff
			if substr(_l_, "strokes") = 0  This._Loss(_l_) ok
		next
		_aDr_ = This._Strokes()
		# the end of the music, to the bar
		_end_ = 0
		for _v_ in _aV_
			for _g_ in _v_[2]
				if _g_[1] + _g_[2] > _end_  _end_ = _g_[1] + _g_[2] ok
			next
		next
		for _v_ in _aDr_
			for _g_ in _v_[2]
				if _g_[1] + _g_[2] > _end_  _end_ = _g_[1] + _g_[2] ok
			next
		next
		@nBars = ceil(_end_ / @nBarLen)
		if @nBars < 1  @nBars = 1 ok
		# the key, then every pitch spelled IN it
		This._ResolveKey(_aV_)
		# each pitch spelled in the key in force where it begins
		for _vi_ = 1 to len(_aV_)
			for _gi_ = 1 to len(_aV_[_vi_][2])
				_aK_ = This._KeyAt(floor(_aV_[_vi_][2][_gi_][1] / @nBarLen))
				for _pi_ = 1 to len(_aV_[_vi_][2][_gi_][3])
					_aV_[_vi_][2][_gi_][3][_pi_] = This._RespellIn(_aV_[_vi_][2][_gi_][3][_pi_], _aK_[2], _aK_[3])
				next
			next
		next
		# a staff entry: [ instrument, clef, pieces, voice ("" | "up" | "down"), the entry it shares a staff with ]
		for _v_ in _aV_
			@aStaves + [ _v_[1], This._ClefOf(_v_[2]), This._Pieces(_v_[2], @nBars * @nBarLen), "", 0 ]
		next
		# the percussion staves, under the pitched ones; the kit's hands and feet as two voices
		# the hands (and every one-voice drum) first, so the feet find their staff
		_aDr2_ = []
		for _v_ in _aDr_
			if _v_[3] != "down"  _aDr2_ + _v_ ok
		next
		for _v_ in _aDr_
			if _v_[3] = "down"  _aDr2_ + _v_ ok
		next
		for _v_ in _aDr2_
			_cl_ = "perc1"
			if _v_[1] = "drumkit"  _cl_ = "perc5" ok
			if _v_[3] = "down"
				_host_ = 0
				for _k_ = 1 to len(@aStaves)
					if @aStaves[_k_][1] = _v_[1] and @aStaves[_k_][4] = "up"  _host_ = _k_ ok
				next
				if _host_ > 0
					@aStaves + [ _v_[1], _cl_, This._Pieces(_v_[2], @nBars * @nBarLen), "down", _host_ ]
				else
					@aStaves + [ _v_[1], _cl_, This._Pieces(_v_[2], @nBars * @nBarLen), "", 0 ]
				ok
			else
				_role_ = ""
				for _w_ in _aDr_
					if _w_[1] = _v_[1] and _w_[3] = "down"  _role_ = "up" ok
				next
				@aStaves + [ _v_[1], _cl_, This._Pieces(_v_[2], @nBars * @nBarLen), _role_, 0 ]
			ok
		next
		if len(@aStaves) = 0
			@aStaves + [ "piano", "treble", This._Pieces([], @nBars * @nBarLen), "", 0 ]
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
		if This._IsPerc(@aStaves[pnK][2])
			for _i_ = 1 to len(_aP_)
				_aShow_ = []
				for _p_ in _aP_[_i_][4]  _aShow_ + 99 next
				@aStaves[pnK][3][_i_] + _aShow_
			next
			return
		ok
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
				_prev_ = This._KeyAt(_bar_)[2][substr("CDEFGAB", _p_[1])]   # the bar's key, until the bar says otherwise
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
		# a second voice shares its host's staff: the host makes room for both
		for _k_ = 1 to _nSt_
			_h_ = @aStaves[_k_][5]
			if _h_ > 0
				if _aBelow_[_k_] > _aBelow_[_h_]  _aBelow_[_h_] = _aBelow_[_k_] ok
				if _aAbove_[_k_] > _aAbove_[_h_]  _aAbove_[_h_] = _aAbove_[_k_] ok
			ok
		next
		_aAbove_[1] += 1.5 * _sp_              # and room for the tempo over the first staff
		# the left margin: instrument names when there is more than one staff
		@nLeft = 20
		if len(This.Clefs()) > 1  @nLeft = 90 ok
		# the natural width of every bar, from its columns
		_aBarCols_ = []
		_aBarW_ = []
		for _b_ = 0 to @nBars - 1
			_aC_ = This._Columns(_b_)
			_aBarCols_ + _aC_
			_w_ = 1.2 * _sp_ + This._ChangeW(_b_)         # MU12: room for a key change at its head
			for _c_ in _aC_  _w_ += _c_[2] next
			_aBarW_ + _w_
		next
		# systems: bars while they fit, then justified (the last one only if nearly full)
		_right_ = @nWidth - 20
		_b_ = 1
		while _b_ <= @nBars
			_x0_ = @nLeft
			# the head: the clef, the key IN FORCE at this system's first bar, the metre once
			_h_ = 4.6 * _sp_ + This._KeyW(This._KeyAt(_b_ - 1)[4])
			if len(@aSystems) = 0  _h_ += 3.0 * _sp_ ok
			_avail_ = _right_ - _x0_ - _h_
			_sum_ = 0
			_e_ = _b_
			while _e_ <= @nBars
				# a system that ends just before a key change carries a courtesy key
				if _sum_ + _aBarW_[_e_] + This._CourtesyW(_e_) > _avail_ and _e_ > _b_  exit ok
				_sum_ += _aBarW_[_e_]
				_e_++
			end
			_e_--
			_cw_ = This._CourtesyW(_e_)
			_scale_ = (_avail_ - _cw_) / _sum_
			if _e_ = @nBars and _scale_ > 1.35  _scale_ = 1 ok
			_aX_ = []
			_x_ = _x0_ + _h_
			for _k_ = _b_ to _e_
				_aX_ + _x_
				_x_ += _aBarW_[_k_] * _scale_
			next
			_aX_ + _x_                                  # the end of the last bar
			@aSystems + [ _b_, _e_, _aX_, _scale_, _h_, _cw_ ]
			_b_ = _e_ + 1
		end
		# vertical placement
		_y_ = 58
		if pcTitle != ""  _y_ += 30 ok
		for _si_ = 1 to len(@aSystems)
			_aY_ = []
			for _k_ = 1 to _nSt_
				if @aStaves[_k_][5] > 0
					_aY_ + _aY_[@aStaves[_k_][5]]          # a second voice: its host's staff
					loop
				ok
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
		if pcClef = "perc5"                                         # the kit, on five lines
			switch paP[1]
			on "kick"   return 1
			on "dum"    return 1
			on "hihat"  return 9
			on "ka"     return 9
			off
			return 5
		ok
		if pcClef = "perc1"                                         # a hand drum, on one line
			if paP[1] = "dum" or paP[1] = "kick"  return 3 ok
			return 5
		ok
		if pcClef = "bass"  return This._Diatonic(paP) - 18 ok     # G2 on the bottom line
		return This._Diatonic(paP) - 30                             # E4 on the bottom line

	def _DrawSystem(pnS, paBarCols)
		_sp_ = @nSp
		_sy_ = @aSystems[pnS]
		_aX_ = _sy_[3]
		_x0_ = @nLeft
		_x1_ = _aX_[len(_aX_)] + _sy_[6]
		_o_ = ""
		_nSt_ = len(@aStaves)
		_aKey_ = This._KeyAt(_sy_[1] - 1)
		_kw_ = This._KeyW(_aKey_[4])
		_nLast_ = 0
		for _k_ = 1 to _nSt_
			if @aStaves[_k_][5] > 0  loop ok              # a second voice draws no staff
			_nLast_ = _k_
			_top_ = @aStaffY[pnS][_k_]
			_clef_ = @aStaves[_k_][2]
			_no_ = This._StaffNo(_k_)
			if _clef_ = "perc1"
				_o_ += This._Line(_x0_, _top_ + 2 * _sp_, _x1_, _top_ + 2 * _sp_, 1)
				@aModel + [ "lines", _no_, pnS, 1 ]
			else
				for _l_ = 0 to 4  _o_ += This._Line(_x0_, _top_ + _l_ * _sp_, _x1_, _top_ + _l_ * _sp_, 1) next
				@aModel + [ "lines", _no_, pnS, 5 ]
			ok
			# the clef: G and F from the font; the neutral clef drawn
			if _clef_ = "treble"
				# calibrated by eye in Segoe UI Symbol: the curl round the G line
				_o_ += This._Glyph(_x0_ + 0.4 * _sp_, _top_ + 4.3 * _sp_, "&#x1D11E;", 6.6 * _sp_)
			but _clef_ = "bass"
				_o_ += This._Glyph(_x0_ + 0.5 * _sp_, _top_ + 1 * _sp_ + 1.2 * _sp_, "&#x1D122;", 4.1 * _sp_)
			else
				_o_ += This._Rect(_x0_ + 1.2 * _sp_, _top_ + 1 * _sp_, 0.4 * _sp_, 2 * _sp_) +
				       This._Rect(_x0_ + 2.0 * _sp_, _top_ + 1 * _sp_, 0.4 * _sp_, 2 * _sp_)
			ok
			@aModel + [ "clef", _no_, pnS, _clef_ ]
			# the key in force at this system's first bar, on every pitched staff
			if NOT This._IsPerc(_clef_)
				_kx_ = _x0_ + 4.6 * _sp_ + 0.2 * _sp_
				for _ka_ in _aKey_[4]
					_ks_ = This._SigStep(_ka_[1], _ka_[2], _clef_)
					_o_ += This._Accidental(_kx_ + 0.5 * _sp_, _top_ + 4 * _sp_ - _ks_ * _sp_ / 2, _ka_[2])
					@aModel + [ "keysig", _no_, pnS, _ka_[1], _ka_[2], _kx_, _ks_, _sy_[1] ]
					_kx_ += 1.25 * _sp_
				next
			ok
			if pnS = 1
				_mx_ = _x0_ + 4.6 * _sp_ + _kw_ + 1.1 * _sp_
				_o_ += This._Text(_mx_, _top_ + 1.75 * _sp_, "" + @nBeats, 2.2 * _sp_, "middle", "bold") +
				       This._Text(_mx_, _top_ + 3.75 * _sp_, "" + @nUnit, 2.2 * _sp_, "middle", "bold")
			ok
			if pnS = 1 and len(This.Clefs()) > 1
				_o_ += This._Text(_x0_ - 8, _top_ + 2.4 * _sp_, @aStaves[_k_][1], 13, "end", "")
			ok
		next
		if len(This.Clefs()) > 1
			_ytop_ = @aStaffY[pnS][1]
			_ybot_ = @aStaffY[pnS][_nLast_] + 4 * _sp_
			_o_ += This._Line(_x0_, _ytop_, _x0_, _ybot_, 1.2) + This._Rect(_x0_ - 5, _ytop_ - 2, 3, _ybot_ - _ytop_ + 4)
		ok
		# the bars
		for _b_ = _sy_[1] to _sy_[2]
			_bx_ = _aX_[_b_ - _sy_[1] + 1]
			_ex_ = _aX_[_b_ - _sy_[1] + 2]
			_aC_ = paBarCols[_b_]
			# a key change inside the system: naturals, then the new key, at the bar's head
			if _b_ > _sy_[1] and This._ChangeW(_b_ - 1) > 0
				_o_ += This._DrawKeyChange(pnS, _b_, _bx_ + 0.5 * _sp_, "keychange")
			ok
			# column x: the columns' natural widths, stretched with the bar
			_aCX_ = []
			_cx_ = This._ColStart(pnS, _b_ - 1, _bx_)
			for _c_ in _aC_
				_px_ = _cx_
				if _c_[3]  _px_ += 1.5 * _sp_ ok
				_aCX_ + [ _c_[1], _px_ ]
				_cx_ += _c_[2] * _sy_[4]
			next
			for _k_ = 1 to _nSt_
				_o_ += This._DrawBar(_k_, pnS, _b_ - 1, _bx_, _ex_, _aCX_)
			next
			# the barline, on every staff: double before a key change, final at the end
			_bDbl_ = (_b_ < @nBars and This._ChangeW(_b_) > 0)
			for _k_ = 1 to _nSt_
				if @aStaves[_k_][5] > 0  loop ok
				_top_ = @aStaffY[pnS][_k_]
				_bt_ = _top_
				_bh_ = 4 * _sp_
				if @aStaves[_k_][2] = "perc1"
					_bt_ = _top_ + _sp_            # a one-line staff's barline spans a space either side
					_bh_ = 2 * _sp_
				ok
				if _b_ = @nBars
					_o_ += This._Line(_ex_ - 5, _bt_, _ex_ - 5, _bt_ + _bh_, 1.1) + This._Rect(_ex_ - 3, _bt_, 3.2, _bh_)
				but _bDbl_
					_o_ += This._Line(_ex_ - 3.5, _bt_, _ex_ - 3.5, _bt_ + _bh_, 1.1) + This._Line(_ex_, _bt_, _ex_, _bt_ + _bh_, 1.1)
					@aModel + [ "dblbar", This._StaffNo(_k_), pnS, _b_, _ex_ ]
				else
					_o_ += This._Line(_ex_, _bt_, _ex_, _bt_ + _bh_, 1.1)
				ok
				@aModel + [ "barline", This._StaffNo(_k_), pnS, _b_, _ex_ ]
			next
		next
		# the courtesy key, after the last barline, when the next system changes key
		if _sy_[6] > 0
			_o_ += This._DrawKeyChange(pnS, _sy_[2] + 1, _aX_[len(_aX_)] + 0.6 * _sp_, "keycourtesy")
		ok
		@aModel + [ "system", pnS, _sy_[2] - _sy_[1] + 1 ]
		return _o_

	# the naturals cancelling what the old key had and the new one has not, then
	# the new key, on every pitched staff, from x -- for bar `pnBar1` (from 1)
	def _DrawKeyChange(pnS, pnBar1, pnX, pcKind)
		_sp_ = @nSp
		_aOld_ = This._KeyAt(pnBar1 - 2)
		_aNew_ = This._KeyAt(pnBar1 - 1)
		_aNat_ = This._Cancels(_aOld_[2], _aNew_[2])
		_o_ = ""
		for _k_ = 1 to len(@aStaves)
			if @aStaves[_k_][5] > 0 or This._IsPerc(@aStaves[_k_][2])  loop ok
			_top_ = @aStaffY[pnS][_k_]
			_clef_ = @aStaves[_k_][2]
			_kx_ = pnX
			for _n_ in _aNat_
				_ks_ = This._SigStep(_n_[1], _n_[2], _clef_)
				_o_ += This._Accidental(_kx_ + 0.5 * _sp_, _top_ + 4 * _sp_ - _ks_ * _sp_ / 2, 0)
				@aModel + [ pcKind + "nat", This._StaffNo(_k_), pnS, _n_[1], _kx_, _ks_, pnBar1 ]
				_kx_ += 1.25 * _sp_
			next
			for _ka_ in _aNew_[4]
				_ks_ = This._SigStep(_ka_[1], _ka_[2], _clef_)
				_o_ += This._Accidental(_kx_ + 0.5 * _sp_, _top_ + 4 * _sp_ - _ks_ * _sp_ / 2, _ka_[2])
				_kind_ = "keysig"                       # a courtesy key is not the bar's key
				if pcKind = "keycourtesy"  _kind_ = "keycourtesysig" ok
				@aModel + [ _kind_, This._StaffNo(_k_), pnS, _ka_[1], _ka_[2], _kx_, _ks_, pnBar1 ]
				_kx_ += 1.25 * _sp_
			next
			@aModel + [ pcKind, This._StaffNo(_k_), pnS, pnBar1, len(_aNat_), len(_aNew_[4]) ]
		next
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
			if @aStaves[pnK][4] != ""  _dir_ = @aStaves[pnK][4] ok    # the kit's hands up, its feet down
			_o_ += This._Heads(_p_, _x_, _top_, _clef_, _dir_, pnK, pnS, pnBar, ring_find(_aBeamed_, _it_[1]) = 0)
			_o_ += This._Tie(pnK, pnS, _it_[1], _x_, _top_, _dir_)
		next
		for _g_ in _aGroups_
			_o_ += This._Beam(_g_, _aP_, _top_, _clef_, pnK, pnS, pnBar)
		next
		return _o_

	def _StemDir(paPitches, pcClef)
		if This._IsPerc(pcClef)  return "up" ok
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
		if @aStaves[pnK][4] != ""  return @aStaves[pnK][4] ok
		_clef_ = @aStaves[pnK][2]
		if This._IsPerc(_clef_)  return "up" ok
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
			# ledger lines (a percussion staff has none)
			if _s_ <= -2 and NOT This._IsPerc(pcClef)
				for _l_ = -2 to _s_ step -2
					_ly_ = _bot_ - _l_ * _sp_ / 2
					_o_ += This._Line(_hx_ - 1.6 * _rx_, _ly_, _hx_ + 1.6 * _rx_, _ly_, 1.1)
					@aModel + [ "ledger", This._StaffNo(pnK), pnS, pnBar, _hx_, _ly_ ]
				next
			ok
			if _s_ >= 10
				for _l_ = 10 to _s_ step 2
					_ly_ = _bot_ - _l_ * _sp_ / 2
					_o_ += This._Line(_hx_ - 1.6 * _rx_, _ly_, _hx_ + 1.6 * _rx_, _ly_, 1.1)
					@aModel + [ "ledger", This._StaffNo(pnK), pnS, pnBar, _hx_, _ly_ ]
				next
			ok
			_pp_ = paP[4][_h_[2]]
			if This._IsPerc(pcClef)
				_bX_ = (_pp_[1] = "hihat" or _pp_[1] = "ka")
				if _bX_
					_o_ += This._XHead(_hx_, _y_)
				else
					_o_ += This._Head(_hx_, _y_, _len_)
				ok
				@aModel + [ "head", This._StaffNo(pnK), pnS, pnBar, _hx_, _y_, _s_, _pp_[1], 0, _len_, pcDir, paP[2] ]
				@aModel + [ "stroke", This._StaffNo(pnK), pnS, pnBar, _hx_, _pp_[1], _s_, _bX_, @aStaves[pnK][4] ]
				if pcClef = "perc1"
					_o_ += This._Text(_hx_, pnTop + 5.6 * _sp_, This._Syllable(_pp_[1]), 1.2 * _sp_, "middle", "")
				ok
			else
				_o_ += This._Head(_hx_, _y_, _len_)
				@aModel + [ "head", This._StaffNo(pnK), pnS, pnBar, _hx_, _y_, _s_, _pp_[1] + _pp_[3], _pp_[2], _len_, pcDir, paP[2] ]
			ok
			# the accidental this head shows
			_show_ = paP[8][_h_[2]]
			if _show_ != 99
				_ax_ = pnX - _rx_ - 1.0 * _sp_ - _nAcc_ * 1.1 * _sp_
				_nAcc_++
				_o_ += This._Accidental(_ax_, _y_, _show_)
				@aModel + [ "acc", This._StaffNo(pnK), pnS, pnBar, _ax_, _y_, _show_ ]
			ok
			# the dot, in the space above when the head sits on a line
			if ring_find([ 12, 6, 3 ], _len_) > 0
				_dy_ = _y_
				if _s_ % 2 = 0  _dy_ = _y_ - _sp_ / 2 ok
				_dx_ = pnX + _rx_ + 0.55 * _sp_
				if _shift_ and pcDir = "up"  _dx_ += 2 * _rx_ ok
				_o_ += This._Ellipse(_dx_, _dy_, 0.17 * _sp_, 0.17 * _sp_, TRUE)
				@aModel + [ "dot", This._StaffNo(pnK), pnS, pnBar, _dx_, _dy_ ]
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
			if _nf_ > 0  @aModel + [ "flag", This._StaffNo(pnK), pnS, pnBar, _sx_, _nf_ ] ok
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
		@aModel + [ "beam", This._StaffNo(pnK), pnS, pnBar, _n_, _nLv_, _dir_ ]
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
				@aModel + [ "tie", This._StaffNo(pnK), pnS, _x1_, _x2_, _y_ ]
			else
				_sy_ = @aSystems[pnS]
				_x2_ = _sy_[3][len(_sy_[3])] - 2
				_o_ += This._Arc(_x1_, _x2_, _y_, _sg_)
				@aModel + [ "tie", This._StaffNo(pnK), pnS, _x1_, _x2_, _y_ ]
				if _ns_ > 0
					_top2_ = @aStaffY[_ns_][pnK]
					_y2_ = _top2_ + 4 * _sp_ - This._StepOf(_q_, @aStaves[pnK][2]) * _sp_ / 2 + _sg_ * 0.7 * _sp_
					_xs_ = @aSystems[_ns_][3][1] - 1.2 * _sp_
					_xe_ = This._XOf(_ns_, _nxt_[1], _nxt_[2]) - 0.7 * _sp_
					_o_ += This._Arc(_xs_, _xe_, _y2_, _sg_)
					@aModel + [ "tie", This._StaffNo(pnK), _ns_, _xs_, _xe_, _y2_ ]
				ok
			ok
		next
		return _o_

	# the x of a column: recomputed the way _DrawSystem places it
	def _XOf(pnS, pnBar, pnPos)
		_sy_ = @aSystems[pnS]
		_bx_ = _sy_[3][pnBar + 1 - _sy_[1] + 1]
		_aC_ = This._Columns(pnBar)
		_cx_ = This._ColStart(pnS, pnBar, _bx_)
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
		# a voice's rests move out of the other's way: the hands' up, the feet's down
		if @aStaves[pnK][4] = "up"  pnTop -= 1.5 * _sp_ ok
		if @aStaves[pnK][4] = "down"  pnTop += 2.0 * _sp_ ok
		_len_ = paP[3]
		_o_ = ""
		_x_ = pnX
		if paP[7]
			_x_ = (pnX0 + pnX1) / 2
			_len_ = 16
		ok
		if _len_ = 16 or _len_ = 12 or _len_ = 8
			_y_ = pnTop + _sp_
			if @aStaves[pnK][2] = "perc1" and _len_ = 16  _y_ = pnTop + 2 * _sp_ ok
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
		@aModel + [ "rest", This._StaffNo(pnK), pnS, pnBar, _x_, _len_, paP[2], @aStaves[pnK][4] ]
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

	#== the key signature (MU11) ==================================================

	# MU12: the first key (as MU11 read it), then the keys bar by bar -- asked
	# for by KeyChangeAt, or found in the music
	def _ResolveKey(paV)
		# with changes asked for, the opening key is read from the music BEFORE the
		# first of them -- not from passages that belong to a later key
		_aV1_ = paV
		if len(@aKeyReq) > 0
			_first_ = 999999
			for _q_ in @aKeyReq
				_b_ = ceil(floor(_q_[1] * 4 + 0.5) / @nBarLen)
				if _b_ < _first_  _first_ = _b_ ok
			next
			if _first_ > 0
				_aV1_ = []
				for _v_ in paV
					_aG_ = []
					for _g_ in _v_[2]
						if _g_[1] < _first_ * @nBarLen  _aG_ + _g_ ok
					next
					_aV1_ + [ _v_[1], _aG_ ]
				next
			ok
		ok
		This._ResolveFirstKey(_aV1_)
		@aKeys = [ [ 0, @aSig, @nFifths, @aSigOrder, @cKeyName ] ]
		if len(@aKeyReq) > 0
			_aR_ = []
			for _q_ in @aKeyReq  _aR_ + [ _q_[1] * 1000 + len(_aR_), _q_ ] next
			_aR_ = sort(_aR_, 1)
			for _x_ in _aR_
				_q_ = _x_[2]
				_s16_ = floor(_q_[1] * 4 + 0.5)
				_bar_ = ceil(_s16_ / @nBarLen)
				if _s16_ % @nBarLen != 0
					This._Loss("a key change at beat " + _q_[1] + " falls inside bar " + (_bar_) + "; it is written at the next barline")
				ok
				if _bar_ >= @nBars  loop ok
				_aE_ = [ _bar_, _q_[2], _q_[3], This._SigOrderOf(_q_[2]), _q_[4] ]
				if _bar_ = 0
					@aKeys[1] = _aE_
					@aSig = _q_[2]
					@nFifths = _q_[3]
					@aSigOrder = _aE_[4]
					@cKeyName = _q_[4]
				else
					@aKeys + _aE_
				ok
			next
			This._PruneKeys()
			return
		ok
		if @cKey = "auto" and @bKeyChanges  This._DetectKeyChanges(paV) ok

	# the keys bar by bar, by the fewest accidentals plus a penalty for each change
	def _DetectKeyChanges(paV)
		_nB_ = @nBars
		if _nB_ < 2  return ok
		_aF_ = [ 0, 1, -1, 2, -2, 3, -3, 4, -4, 5, -5, 6, -6, 7, -7 ]
		_aPcs_ = []
		_aSigs_ = []
		for _f_ in _aF_
			_aPcs_ + This._PcsOfFifths(_f_)
			_aSigs_ + This._SigOfFifths(_f_)
		next
		# each bar's cost in each key: its semitone notes outside the key
		_aCost_ = list(_nB_)
		for _b_ = 1 to _nB_
			_aRow_ = list(15)
			for _i_ = 1 to 15  _aRow_[_i_] = 0 next
			_aCost_[_b_] = _aRow_
		next
		for _v_ in paV
			for _g_ in _v_[2]
				_b_ = floor(_g_[1] / @nBarLen) + 1
				if _b_ > _nB_  loop ok
				for _p_ in _g_[3]
					_m_ = This._Midi(_p_)
					if fabs(_m_ - floor(_m_ + 0.5)) > 0.01
						# a quarter tone: a key that alters its letter by a semitone cannot
						# also carry it -- the note would need its sign (Rast's B half-flat
						# against B flat major)
						_ql_ = substr("CDEFGAB", This._RespellIn(_p_, [ 0, 0, 0, 0, 0, 0, 0 ], 0)[1])
						for _i_ = 1 to 15
							if _aSigs_[_i_][_ql_] != 0  _aCost_[_b_][_i_] = _aCost_[_b_][_i_] + 1 ok
						next
						loop
					ok
					_pc_ = floor(_m_ + 0.5) % 12
					for _i_ = 1 to 15
						if ring_find(_aPcs_[_i_], _pc_) = 0  _aCost_[_b_][_i_] = _aCost_[_b_][_i_] + 1 ok
					next
				next
			next
		next
		# the cheapest path through the keys: a change costs four accidentals
		_nPen_ = 4
		_aDp_ = list(_nB_)
		_aBk_ = list(_nB_)
		_aRow_ = list(15)
		for _i_ = 1 to 15  _aRow_[_i_] = _aCost_[1][_i_] + fabs(_aF_[_i_]) * 0.01 next
		_aDp_[1] = _aRow_
		_aBk_[1] = list(15)
		for _b_ = 2 to _nB_
			_aRow_ = list(15)
			_aBack_ = list(15)
			for _i_ = 1 to 15
				_best_ = _aDp_[_b_ - 1][_i_]
				_from_ = _i_
				for _j_ = 1 to 15
					if _aDp_[_b_ - 1][_j_] + _nPen_ < _best_
						_best_ = _aDp_[_b_ - 1][_j_] + _nPen_
						_from_ = _j_
					ok
				next
				_aRow_[_i_] = _best_ + _aCost_[_b_][_i_]
				_aBack_[_i_] = _from_
			next
			_aDp_[_b_] = _aRow_
			_aBk_[_b_] = _aBack_
		next
		_cur_ = 1
		for _i_ = 2 to 15
			if _aDp_[_nB_][_i_] < _aDp_[_nB_][_cur_]  _cur_ = _i_ ok
		next
		_aPath_ = list(_nB_)
		for _b_ = _nB_ to 1 step -1
			_aPath_[_b_] = _cur_
			if _b_ > 1  _cur_ = _aBk_[_b_][_cur_] ok
		next
		# sections: a run of bars in one key
		_aSec_ = []
		for _b_ = 1 to _nB_
			_n_ = len(_aSec_)
			if _n_ = 0
				_aSec_ + [ _b_ - 1, _b_ - 1, _aF_[_aPath_[_b_]] ]
			but _aSec_[_n_][3] = _aF_[_aPath_[_b_]]
				_aSec_[_n_][2] = _b_ - 1
			else
				_aSec_ + [ _b_ - 1, _b_ - 1, _aF_[_aPath_[_b_]] ]
			ok
		next
		if len(_aSec_) < 2  return ok
		# each section's key: its fifths, and its own quarter tones by count
		@aKeys = []
		for _sc_ in _aSec_
			_aSig_ = This._SigOfFifths(_sc_[3])
			_aCnt_ = []
			for _v_ in paV
				for _g_ in _v_[2]
					_b_ = floor(_g_[1] / @nBarLen)
					if _b_ < _sc_[1] or _b_ > _sc_[2]  loop ok
					for _p_ in _g_[3]
						_r_ = This._RespellIn(_p_, _aSig_, _sc_[3])
						_f2_ = 0
						for _i_ = 1 to len(_aCnt_)
							if _aCnt_[_i_][1] = _r_[1] and _aCnt_[_i_][2] = _r_[2]
								_aCnt_[_i_][3] = _aCnt_[_i_][3] + 1
								_f2_ = 1
							ok
						next
						if _f2_ = 0  _aCnt_ + [ _r_[1], _r_[2], 1 ] ok
					next
				next
			next
			for _l_ = 1 to 7
				_cl_ = substr("CDEFGAB", _l_, 1)
				_tot_ = 0
				_qa_ = 0
				_qn_ = 0
				for _c_ in _aCnt_
					if _c_[1] = _cl_
						_tot_ += _c_[3]
						if fabs(_c_[2]) = 0.5 and _c_[3] > _qn_
							_qn_ = _c_[3]
							_qa_ = _c_[2]
						ok
					ok
				next
				if _qn_ * 2 > _tot_  _aSig_[_l_] = _qa_ ok
			next
			_aOrd_ = This._SigOrderOf(_aSig_)
			_nm_ = This._FifthsText(_sc_[3])
			_aQ_ = []
			for _ka_ in _aOrd_
				if fabs(_ka_[2]) = 0.5  _aQ_ + _ka_ ok
			next
			if len(_aQ_) > 0
				_t_ = ""
				for _ka_ in _aQ_
					if _t_ != ""  _t_ += ", " ok
					_t_ += _ka_[1] + " " + This._AltName(_ka_[2])
				next
				_nm_ += ", with " + _t_ + " in the key (as Arabic notation writes it)"
			ok
			@aKeys + [ _sc_[1], _aSig_, _sc_[3], _aOrd_, _nm_ ]
		next
		@aSig = @aKeys[1][2]
		@nFifths = @aKeys[1][3]
		@aSigOrder = @aKeys[1][4]
		@cKeyName = @aKeys[1][5]
		This._PruneKeys()

	# a "change" to the key already in force is no change
	def _PruneKeys()
		_a_ = [ @aKeys[1] ]
		for _i_ = 2 to len(@aKeys)
			if NOT This._SameSig(@aKeys[_i_][2], _a_[len(_a_)][2])  _a_ + @aKeys[_i_] ok
		next
		@aKeys = _a_

	def _SameSig(paA, paB)
		for _i_ = 1 to 7
			if paA[_i_] != paB[_i_]  return FALSE ok
		next
		return TRUE

	# the key in force in bar `pnBar` (from 0)
	def _KeyAt(pnBar)
		_r_ = @aKeys[1]
		for _k_ in @aKeys
			if _k_[1] <= pnBar  _r_ = _k_ ok
		next
		return _r_

	# the letters the old key altered and the new one does not: naturals
	def _Cancels(paOld, paNew)
		_a_ = []
		for _l_ = 1 to 7
			if paOld[_l_] != 0 and paNew[_l_] = 0  _a_ + [ substr("CDEFGAB", _l_, 1), paOld[_l_] ] ok
		next
		# drawn where the old accidentals stood, in their order
		_aO_ = This._SigOrderOf(paOld)
		_r_ = []
		for _o_ in _aO_
			for _x_ in _a_
				if _x_[1] = _o_[1]  _r_ + _x_ ok
			next
		next
		return _r_

	def _KeyW(paOrder)
		if len(paOrder) = 0  return 0 ok
		return len(paOrder) * 1.25 * @nSp + 0.6 * @nSp

	# the room a key change takes at the head of bar `pnBar` (from 0): naturals + new key
	def _ChangeW(pnBar)
		if pnBar <= 0 or pnBar >= @nBars  return 0 ok
		_bCh_ = FALSE
		for _i_ = 2 to len(@aKeys)
			if @aKeys[_i_][1] = pnBar  _bCh_ = TRUE ok
		next
		if NOT _bCh_  return 0 ok
		_n_ = len(This._Cancels(This._KeyAt(pnBar - 1)[2], This._KeyAt(pnBar)[2])) + len(This._KeyAt(pnBar)[4])
		return _n_ * 1.25 * @nSp + 1.2 * @nSp

	# a system ending at bar `pnE` (from 1) before a change carries a courtesy key
	def _CourtesyW(pnE)
		if pnE >= @nBars  return 0 ok
		_w_ = This._ChangeW(pnE)
		if _w_ = 0  return 0 ok
		return _w_ + 0.4 * @nSp

	# where a bar's first column may start: after its key change, when one is drawn there
	def _ColStart(pnS, pnBar, pnBx)
		_sy_ = @aSystems[pnS]
		_lead_ = 1.0 * @nSp
		if pnBar + 1 > _sy_[1]  _lead_ += This._ChangeW(pnBar) ok
		return pnBx + _lead_ * _sy_[4]

	# a staff entry's number as drawn: a second voice is its host's staff
	def _StaffNo(pnK)
		_k_ = pnK
		if @aStaves[pnK][5] > 0  _k_ = @aStaves[pnK][5] ok
		_n_ = 0
		for _i_ = 1 to _k_
			if @aStaves[_i_][5] = 0  _n_++ ok
		next
		return _n_

	def _SigOrderOf(paSig)
		_a_ = []
		for _i_ = 1 to 7
			_l_ = substr("BEADGCF", _i_, 1)
			_x_ = paSig[substr("CDEFGAB", _l_)]
			if _x_ < 0  _a_ + [ _l_, _x_ ] ok
		next
		for _i_ = 1 to 7
			_l_ = substr("FCGDAEB", _i_, 1)
			_x_ = paSig[substr("CDEFGAB", _l_)]
			if _x_ > 0  _a_ + [ _l_, _x_ ] ok
		next
		return _a_

	def _SigTextOf(paOrder)
		if len(paOrder) = 0  return "no sharps or flats" ok
		_t_ = ""
		for _ka_ in paOrder
			if _t_ != ""  _t_ += ", " ok
			_t_ += _ka_[1] + " " + This._AltName(_ka_[2])
		next
		return _t_

	def _ResolveFirstKey(paV)
		@aSig = [ 0, 0, 0, 0, 0, 0, 0 ]
		@nFifths = 0
		@cKeyName = "no key signature"
		if @cKey = "none"
			This._SigOrder()
			return
		ok
		if @cKey = "mode"
			@aSig = @aModeSig
			This._SigOrder()
			@cKeyName = "from the mode " + @cModeName + ": " + This._SigText()
			return
		ok
		if @cKey = "fifths"
			@nFifths = @nKeyFifths
			@aSig = This._SigOfFifths(@nFifths)
			This._SigOrder()
			@cKeyName = This._FifthsText(@nFifths)
			return
		ok
		# auto: the circle-of-fifths key leaving the fewest accidentals ...
		_aPc_ = []
		_aQl_ = []                    # the letters quarter tones sit on (MU12)
		for _v_ in paV
			for _g_ in _v_[2]
				for _p_ in _g_[3]
					_m_ = This._Midi(_p_)
					if fabs(_m_ - floor(_m_ + 0.5)) < 0.01
						_aPc_ + (floor(_m_ + 0.5) % 12)
					else
						_aQl_ + substr("CDEFGAB", This._RespellIn(_p_, [ 0, 0, 0, 0, 0, 0, 0 ], 0)[1])
					ok
				next
			next
		next
		_best_ = 0
		_bestCost_ = 999999
		for _f_ in [ 0, 1, -1, 2, -2, 3, -3, 4, -4, 5, -5, 6, -6, 7, -7 ]
			_aIn_ = This._PcsOfFifths(_f_)
			_aSf_ = This._SigOfFifths(_f_)
			_c_ = 0
			for _pc_ in _aPc_
				if ring_find(_aIn_, _pc_) = 0  _c_++ ok
			next
			for _ql_ in _aQl_
				if _aSf_[_ql_] != 0  _c_++ ok
			next
			if _c_ < _bestCost_
				_bestCost_ = _c_
				_best_ = _f_
			ok
		next
		@nFifths = _best_
		@aSig = This._SigOfFifths(_best_)
		# ... then, as Arabic notation writes it, a letter whose quarter tone is the
		# alteration it usually carries takes that quarter tone into the key
		_aCnt_ = []                   # [ letter, alteration, count ]
		for _v_ in paV
			for _g_ in _v_[2]
				for _p_ in _g_[3]
					_r_ = This._Respell(_p_)
					_f2_ = 0
					for _i_ = 1 to len(_aCnt_)
						if _aCnt_[_i_][1] = _r_[1] and _aCnt_[_i_][2] = _r_[2]
							_aCnt_[_i_][3] = _aCnt_[_i_][3] + 1
							_f2_ = 1
						ok
					next
					if _f2_ = 0  _aCnt_ + [ _r_[1], _r_[2], 1 ] ok
				next
			next
		next
		for _l_ = 1 to 7
			_cl_ = substr("CDEFGAB", _l_, 1)
			_tot_ = 0
			_qa_ = 0
			_qn_ = 0
			for _c_ in _aCnt_
				if _c_[1] = _cl_
					_tot_ += _c_[3]
					if fabs(_c_[2]) = 0.5 and _c_[3] > _qn_
						_qn_ = _c_[3]
						_qa_ = _c_[2]
					ok
				ok
			next
			if _qn_ * 2 > _tot_  @aSig[_l_] = _qa_ ok
		next
		This._SigOrder()
		@cKeyName = This._FifthsText(@nFifths)
		_aQ_ = []
		for _ka_ in @aSigOrder
			if fabs(_ka_[2]) = 0.5  _aQ_ + _ka_ ok
		next
		if len(_aQ_) > 0
			_t_ = ""
			for _ka_ in _aQ_
				if _t_ != ""  _t_ += ", " ok
				_t_ += _ka_[1] + " " + This._AltName(_ka_[2])
			next
			@cKeyName += ", with " + _t_ + " in the key (as Arabic notation writes it)"
		ok

	# the pitch classes of the major scale with `pnF` fifths
	def _PcsOfFifths(pnF)
		_t_ = ((pnF * 7) % 12 + 12) % 12
		_a_ = []
		for _d_ in [ 0, 2, 4, 5, 7, 9, 11 ]  _a_ + ((_t_ + _d_) % 12) next
		return _a_

	def _SigOfFifths(pnF)
		_a_ = [ 0, 0, 0, 0, 0, 0, 0 ]
		if pnF > 0
			for _i_ = 1 to pnF  _a_[substr("CDEFGAB", substr("FCGDAEB", _i_, 1))] = 1 next
		but pnF < 0
			for _i_ = 1 to 0 - pnF  _a_[substr("CDEFGAB", substr("BEADGCF", _i_, 1))] = -1 next
		ok
		return _a_

	# flats and half-flats first, in the order of flats; then the sharps, in theirs
	def _SigOrder()
		@aSigOrder = []
		for _i_ = 1 to 7
			_l_ = substr("BEADGCF", _i_, 1)
			_a_ = @aSig[substr("CDEFGAB", _l_)]
			if _a_ < 0  @aSigOrder + [ _l_, _a_ ] ok
		next
		for _i_ = 1 to 7
			_l_ = substr("FCGDAEB", _i_, 1)
			_a_ = @aSig[substr("CDEFGAB", _l_)]
			if _a_ > 0  @aSigOrder + [ _l_, _a_ ] ok
		next

	# where a signature accidental sits: the places the tradition fixed for
	# each letter (sharps high, flats in their zigzag), two octaves lower in bass
	def _SigStep(pcLetter, pnAlt, pcClef)
		_aS_ = [ [ "F", 38 ], [ "C", 35 ], [ "G", 39 ], [ "D", 36 ], [ "A", 33 ], [ "E", 37 ], [ "B", 34 ] ]
		_aF_ = [ [ "B", 34 ], [ "E", 37 ], [ "A", 33 ], [ "D", 36 ], [ "G", 32 ], [ "C", 35 ], [ "F", 31 ] ]
		_aU_ = _aS_
		if pnAlt < 0  _aU_ = _aF_ ok
		_d_ = 34
		for _x_ in _aU_
			if _x_[1] = pcLetter  _d_ = _x_[2] ok
		next
		if pcClef = "bass"  return _d_ - 14 - 18 ok
		return _d_ - 30

	# a pitch spelled IN the key: the letter whose alteration the key already
	# gives it costs nothing; otherwise the smallest alteration, sharps in a sharp
	# key and flats in a flat one, and a quarter tone above its letter rather
	# than below the next (the writers' spelling)
	def _Respell(paP)
		return This._RespellIn(paP, @aSig, @nFifths)

	def _RespellIn(paP, paSig, pnFifths)
		_m_ = This._Midi(paP)
		_aSemi_ = [ 0, 2, 4, 5, 7, 9, 11 ]
		_best_ = paP
		_bestCost_ = 999
		for _l_ = 1 to 7
			_o_ = floor((_m_ - _aSemi_[_l_]) / 12 + 0.5) - 1
			_a_ = _m_ - (12 * (_o_ + 1) + _aSemi_[_l_])
			_a_ = floor(_a_ * 2 + 0.5) / 2
			if fabs(_a_) > 1  loop ok
			_c_ = 1 + fabs(_a_)
			if fabs(_a_ - paSig[_l_]) < 0.01  _c_ = 0 ok
			if _c_ > 0
				if _a_ = -0.5  _c_ += 0.2 ok
				if _a_ = -1 and pnFifths >= 0  _c_ += 0.1 ok
				if _a_ = 1 and pnFifths < 0  _c_ += 0.1 ok
			ok
			if _c_ < _bestCost_
				_bestCost_ = _c_
				_best_ = [ substr("CDEFGAB", _l_, 1), _a_, _o_, paP[4] ]
			ok
		next
		return _best_

	def _Midi(paP)
		_aSemi_ = [ 0, 2, 4, 5, 7, 9, 11 ]
		return 12 * (paP[3] + 1) + _aSemi_[substr("CDEFGAB", paP[1])] + paP[2]

	# "D", "Bb", "F#m", "Ddor", "A min" -> fifths; 99 when it is no key
	def _FifthsOfName(pc)
		_s_ = ring_trim(pc)
		if len(_s_) = 0  return 99 ok
		_t_ = upper(_s_[1])
		_aT_ = [ [ "C", 0 ], [ "G", 1 ], [ "D", 2 ], [ "A", 3 ], [ "E", 4 ], [ "B", 5 ], [ "F", -1 ] ]
		_f_ = 99
		for _x_ in _aT_
			if _x_[1] = _t_  _f_ = _x_[2] ok
		next
		if _f_ = 99  return 99 ok
		_r_ = substr(_s_, 2, len(_s_) - 1)
		if left(_r_, 1) = "#"
			_f_ += 7
			_r_ = substr(_r_, 2, len(_r_) - 1)
		but left(_r_, 1) = "b"
			_f_ -= 7
			_r_ = substr(_r_, 2, len(_r_) - 1)
		ok
		_r_ = lower(ring_trim(_r_))
		_aM_ = [ [ "", 0 ], [ "maj", 0 ], [ "major", 0 ], [ "ion", 0 ], [ "m", -3 ], [ "min", -3 ], [ "minor", -3 ],
		         [ "aeo", -3 ], [ "dor", -2 ], [ "phr", -4 ], [ "lyd", 1 ], [ "mix", -1 ], [ "loc", -5 ] ]
		_off_ = 99
		for _x_ in _aM_
			if _x_[1] = _r_  _off_ = _x_[2] ok
		next
		if _off_ = 99  return 99 ok
		_f_ += _off_
		if _f_ < -7 or _f_ > 7  return 99 ok
		return _f_

	def _FifthsText(pnF)
		_aN_ = [ "Cb", "Gb", "Db", "Ab", "Eb", "Bb", "F", "C", "G", "D", "A", "E", "B", "F#", "C#" ]
		_n_ = _aN_[pnF + 8] + " major"
		if pnF = 0  return _n_ + " (no sharps or flats)" ok
		if pnF = 1  return _n_ + " (1 sharp)" ok
		if pnF = -1  return _n_ + " (1 flat)" ok
		if pnF > 0  return _n_ + " (" + pnF + " sharps)" ok
		return _n_ + " (" + (0 - pnF) + " flats)"

	def _SigText()
		if len(@aSigOrder) = 0  return "no sharps or flats" ok
		_t_ = ""
		for _ka_ in @aSigOrder
			if _t_ != ""  _t_ += ", " ok
			_t_ += _ka_[1] + " " + This._AltName(_ka_[2])
		next
		return _t_

	def _AltName(pnA)
		if pnA = 1  return "sharp" ok
		if pnA = -1  return "flat" ok
		if pnA = 0.5  return "half-sharp" ok
		if pnA = -0.5  return "half-flat" ok
		return "natural"

	#== the percussion staff (MU11) ===============================================

	def _IsPerc(pcClef)
		return left(pcClef, 4) = "perc"

	# every stroke, by its drum: [ instrument, segments [ at16, len16, [ [stroke,0,0,0] ] ] ]
	def _Strokes()
		_aRaw_ = []                   # [ instrument, [ [ at, len, stroke ] ] ]
		for _e_ in @oS.Events()
			if _e_[3] > 0 or _e_[6] = ""  loop ok
			_inst_ = _e_[4]
			if _inst_ = ""  _inst_ = "drumkit" ok
			_sk_ = _e_[6]
			if _sk_ = "hat"  _sk_ = "hihat" ok
			_at_ = floor(_e_[1] * 4 + 0.5)
			_ln_ = floor(_e_[2] * 4 + 0.5)
			if _ln_ < 1  _ln_ = 1 ok
			# MU12: on the kit the feet (kick) are a voice of their own, stems down
			_role_ = ""
			if _inst_ = "drumkit"
				_role_ = "up"
				if _sk_ = "kick" or _sk_ = "dum"  _role_ = "down" ok
			ok
			_vi_ = 0
			for _k_ = 1 to len(_aRaw_)
				if _aRaw_[_k_][1] = _inst_ and _aRaw_[_k_][3] = _role_  _vi_ = _k_ ok
			next
			if _vi_ = 0
				_aRaw_ + [ _inst_, [], _role_ ]
				_vi_ = len(_aRaw_)
			ok
			_aRaw_[_vi_][2] + [ _at_ * 1000 + len(_aRaw_[_vi_][2]), _at_, _ln_, _sk_ ]
		next
		_aOut_ = []
		for _r_ in _aRaw_
			_aS_ = sort(_r_[2], 1)
			_aSeg_ = []
			for _x_ in _aS_
				_n_ = len(_aSeg_)
				if _n_ > 0
					if _aSeg_[_n_][1] = _x_[2]
						# strokes struck together are one chord, as long as the shortest
						_bHas_ = FALSE
						for _q_ in _aSeg_[_n_][3]
							if _q_[1] = _x_[4]  _bHas_ = TRUE ok
						next
						if NOT _bHas_  _aSeg_[_n_][3] + [ _x_[4], 0, 0, 0 ] ok
						if _x_[3] < _aSeg_[_n_][2]  _aSeg_[_n_][2] = _x_[3] ok
						loop
					ok
					if _aSeg_[_n_][1] + _aSeg_[_n_][2] > _x_[2]
						_aSeg_[_n_][2] = _x_[2] - _aSeg_[_n_][1]    # a stroke rings until the next
					ok
				ok
				_aSeg_ + [ _x_[2], _x_[3], [ [ _x_[4], 0, 0, 0 ] ] ]
			next
			_aOut_ + [ _r_[1], _aSeg_, _r_[3] ]
		next
		return _aOut_

	def _Syllable(pcStroke)
		switch pcStroke
		on "dum"    return "D"
		on "tak"    return "T"
		on "ka"     return "K"
		on "kick"   return "B"
		on "snare"  return "S"
		on "hihat"  return "H"
		off
		return "?"

	def _XHead(pnX, pnY)
		_r_ = 0.5 * @nSp
		return This._Line(pnX - _r_, pnY - _r_, pnX + _r_, pnY + _r_, 1.6) + This._Line(pnX - _r_, pnY + _r_, pnX + _r_, pnY - _r_, 1.6)

	def _GetKV(paList, pcKey, pDefault)
		if NOT isList(paList)  return pDefault ok
		for _p_ in paList
			if isList(_p_) and len(_p_) = 2
				if isString(_p_[1]) and lower(_p_[1]) = lower(pcKey)  return _p_[2] ok
			ok
		next
		return pDefault

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
