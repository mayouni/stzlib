#---------------------------------------------------------------------------#
#  STZSOUNDUNIVERSE -- a musical tradition as DECLARED DATA (MU4)            #
#---------------------------------------------------------------------------#
#
#     oU = StzSoundUniverseQ(:Maqam)                   # a declaration, loaded
#     oU.Mode(:Hijaz).Tonic("D4")
#     oS = oU.PerformQ("1 2 3 4 5 4 3 2", 2)           # a stzSoundScore
#     ? oU.Check("1 2 3 4 5")                          # its movement rules
#
#     StzMusicQ().In(:Raga, :Yaman).PlayPhrase("1 2 3 4 5 4 3 2")
#
# THE PLAN'S FIVE DECLARED THINGS (section 1.3): a tuning, a pitch vocabulary
# with movement rules, a rhythmic cycle with accents, an ornament vocabulary,
# an instrument set. A universe file under base/sound/universes/ declares them
# as a Ring LIST and nothing else -- no logic -- because a tradition is not an
# algorithm and the author declares it (plan section 5). This class READS the
# declaration and renders a phrase inside it; it knows no tradition by name.
#
# THE PHRASE IS WRITTEN IN DEGREES, so one phrase means something in every
# universe: "1 2 3 4 5 4 3 2" is Do-Re-Mi in the West, Rast's first jins and
# its ghammaz, Sa-Re-Ga-Ma-Pa in Yaman, five of slendro's five keys. It is a
# stzPattern (the MU3 grammar, words as degrees): "5_" is a degree an octave
# DOWN, a degree past the mode's size wraps an octave UP ("8" is 1 above).
#
# WHAT A DECLARATION CANNOT CARRY, and says: a declared universe is what a
# tradition's theorists (or, for the oral ones, its transcribers) wrote down.
# Every file carries its sources, a confidence per part, and the line
# `:listener` -- UNPERCEIVED until a person from the tradition has heard it,
# and then their name and verdict. Plan MU4's kill criterion is that person.

func StzSoundUniverseQ(pName)
	return new stzSoundUniverse(pName)

# The declarations this library ships. A universe is added by a file in
# base/sound/universes/ with one function StzSoundUniverseData_<name>(), its
# load line in stzBase.ring, and its name here.
func StzSoundUniverses()
	return [ "western", "maqam", "tunisian", "niger", "raga", "gamelan",
	         "westafrican", "flamenco" ]

# A degree phrase: the MU3 grammar, words as degrees.
func StzSoundDegreePatternQ(pcText)
	return new stzSoundDegreePattern(pcText)

class stzSoundDegreePattern from stzPattern

	# "5" -> degree 5; "5_" -> degree 5 an octave down; "5__" two octaves
	def _Value(pcWord)
		_n_ = ""
		_down_ = 0
		for _k_ = 1 to len(pcWord)
			_c_ = pcWord[_k_]
			if isdigit(_c_) and _down_ = 0
				_n_ += _c_
			but _c_ = "_" and _n_ != ""
				_down_++
			else
				This._Refuse("'" + pcWord + "' is not a degree (1, 5, 8, 5_ for an octave down)")
				return NULL
			ok
		next
		if _n_ = "" or (0 + _n_) < 1
			This._Refuse("'" + pcWord + "' is not a degree (1, 5, 8, 5_ for an octave down)")
			return NULL
		ok
		return [ "degree", "" + (0 + _n_) + copy("_", _down_) ]

class stzSoundUniverse

	@aU = []                # the declaration, as loaded
	@cName = ""
	@aMode = []             # the chosen mode
	@aCycle = []            # the chosen cycle
	@cTonic = ""
	@nTempo = 0
	@cMelody = ""           # the instrument the phrase is played on
	@cLastError = ""
	@nRefusals = 0
	@aNotes = []            # [ beat, degree, cents, hz, ornament ] -- what the last Perform played
	@aSonified = []         # MU7: the degrees the last SonifyQ chose
	@cSonifiedPhrase = ""
	@nSonifiedTop = 0

	def init(pName)
		_c_ = lower("" + pName)
		if ring_find(StzSoundUniverses(), _c_) = 0
			This._Refuse("no universe named '" + pName + "' -- declared: " + This._Joined(StzSoundUniverses()))
			return
		ok
		_f_ = "stzsounduniversedata_" + _c_
		@aU = call _f_()
		@cName = _c_
		# the universe's own tempo and melody first: a RHYTHM universe has no
		# mode to carry them, and the first cut left its tempo at 0, which the
		# score refused -- the West African bell then played at 120, not 360
		@nTempo = This._Get(@aU, :tempo, 90)
		@cMelody = This._Get(@aU, :melody, "piano")
		This.Mode(This._Get(@aU, :defaultmode, ""))
		This.Cycle(This._Get(@aU, :defaultcycle, ""))

	def IsUsable()
		return len(@aU) > 0

	def Name()
		return @cName

	def Title()
		return This._Get(@aU, :title, @cName)

	def Declaration()
		return @aU

	def Listener()
		return This._Get(@aU, :listener, "UNPERCEIVED")

	def Sources()
		return This._Get(@aU, :sources, [])

	def ModeNames()
		_a_ = []
		for _m_ in This._Get(@aU, :modes, [])  _a_ + This._Get(_m_, :name, "") next
		return _a_

	def CycleNames()
		_a_ = []
		for _m_ in This._Get(@aU, :cycles, [])  _a_ + This._Get(_m_, :name, "") next
		return _a_

	#-- choosing ------------------------------------------------------------

	def Mode(pName)
		_c_ = lower("" + pName)
		for _m_ in This._Get(@aU, :modes, [])
			if This._Get(_m_, :name, "") = _c_
				@aMode = _m_
				@cTonic = This._Get(_m_, :tonic, "C4")
				@cMelody = This._Get(_m_, :melody, This._Get(@aU, :melody, "piano"))
				@nTempo = This._Get(_m_, :tempo, This._Get(@aU, :tempo, 90))
				return This
			ok
		next
		if _c_ != ""
			This._Refuse("Mode: " + @cName + " declares no mode '" + pName + "' -- it has: " +
			             This._Joined(This.ModeNames()))
		ok
		return This

	def Cycle(pName)
		_c_ = lower("" + pName)
		for _m_ in This._Get(@aU, :cycles, [])
			if This._Get(_m_, :name, "") = _c_
				@aCycle = _m_
				return This
			ok
		next
		if _c_ != ""
			This._Refuse("Cycle: " + @cName + " declares no cycle '" + pName + "' -- it has: " +
			             This._Joined(This.CycleNames()))
		ok
		return This

	# The phrase ALONE: a cycle of `pnBeats` with no layers and no accents --
	# to hear a mode without its rhythm, or to measure a melody note with
	# nothing struck on top of it.
	def NoCycle(pnBeats)
		@aCycle = [ [ "name", "none" ], [ "beats", pnBeats ], [ "accents", [] ], [ "layers", [] ] ]
		return This

	def Tonic(pcNote)
		if StzNoteToHz(pcNote) = 0
			This._Refuse("Tonic: '" + pcNote + "' is not a note name")
			return This
		ok
		@cTonic = pcNote
		return This

	def Tempo(pnBpm)
		@nTempo = pnBpm
		return This

	def On(pInstrument)
		@cMelody = lower("" + pInstrument)
		return This

	def ModeName()
		return This._Get(@aMode, :name, "")

	def CycleName()
		return This._Get(@aCycle, :name, "")

	def TonicName()
		return @cTonic

	def Melody()
		return @cMelody

	def HasScale()
		return len(This._Get(@aMode, :degrees, [])) > 0

	#-- the pitch vocabulary -------------------------------------------------

	# Cents above the tonic of degree `pcDegree` ("5", "5_", "9"), reached
	# going UP (pbDown FALSE) or DOWN. -1 when the mode declares no scale.
	def CentsOf(pcDegree, pbDown)
		_aD_ = This._Get(@aMode, :degrees, [])
		_n_ = len(_aD_)
		if _n_ = 0  return -1 ok
		_d_ = 0
		_down_ = 0
		for _k_ = 1 to len(pcDegree)
			if isdigit(pcDegree[_k_])  _d_ = _d_ * 10 + (0 + pcDegree[_k_]) else _down_++ ok
		next
		_aUse_ = _aD_
		_aDesc_ = This._Get(@aMode, :descending, [])
		if pbDown and len(_aDesc_) = _n_  _aUse_ = _aDesc_ ok
		_oct_ = This._Get(@aMode, :octave, 1200)
		_up_ = floor((_d_ - 1) / _n_)
		_i_ = ((_d_ - 1) % _n_) + 1
		return _aUse_[_i_] + (_up_ - _down_) * _oct_

	def HzOf(pcDegree, pbDown)
		_c_ = This.CentsOf(pcDegree, pbDown)
		if _c_ < 0 and NOT This.HasScale()  return 0 ok
		return StzNoteToHz(@cTonic) * pow(2, _c_ / 1200)

	# The movement rules this mode declares, held against a phrase: a list
	# of what breaks them, each as text. An empty list is a phrase the
	# declaration permits -- not a phrase a musician would call right.
	def Check(pcPhrase)
		_oP_ = StzSoundDegreePatternQ(pcPhrase)
		if NOT _oP_.IsValid()  return [ _oP_.LastError() ] ok
		_aOut_ = []
		_aAvUp_ = This._Get(@aMode, :avoidascending, [])
		_aAvDn_ = This._Get(@aMode, :avoiddescending, [])
		_prev_ = 0
		for _c_ = 0 to _oP_.Period() - 1
			for _e_ in _oP_.CycleEvents(_c_)
				_ab_ = This._Absolute(_e_[4])
				_base_ = This._DegreeInOctave(_e_[4])
				if _prev_ != 0
					if _ab_ > _prev_ and ring_find(_aAvUp_, _base_) > 0
						_aOut_ + ("degree " + _base_ + " is avoided going UP in " + This.ModeName() +
						          " -- " + This._Get(@aMode, :avoidwhy, ""))
					ok
					if _ab_ < _prev_ and ring_find(_aAvDn_, _base_) > 0
						_aOut_ + ("degree " + _base_ + " is avoided going DOWN in " + This.ModeName())
					ok
				ok
				_prev_ = _ab_
			next
		next
		return _aOut_

	#-- performing a phrase ---------------------------------------------------

	# The phrase, once per cycle for `pnCycles` cycles, in this mode, over
	# this cycle, with its ornaments and accents, as a stzSoundScore. One
	# phrase cycle fills one rhythmic cycle, however many beats that has.
	def PerformQ(pcPhrase, pnCycles)
		_oS_ = StzSoundScoreQ().Tempo(@nTempo)
		@aNotes = []
		if NOT This.HasScale()
			This._Refuse(This.Title() + " declares no scale -- it is a RHYTHM (" +
			             This.CycleName() + "); a phrase needs a mode that has degrees")
			This._Rhythm(_oS_, pnCycles)
			return _oS_
		ok
		_oP_ = StzSoundDegreePatternQ(pcPhrase)
		if NOT _oP_.IsValid()
			This._Refuse(_oP_.LastError())
			return _oS_
		ok
		_B_ = This._Get(@aCycle, :beats, 4)
		_aAcc_ = This._Get(@aCycle, :accents, [])
		_aOrn_ = This._Get(@aMode, :ornaments, [])
		_pair_ = This._Get(@aMode, :pairdetunehz, 0)
		_prevAb_ = 0
		_prevHz_ = 0
		for _c_ = 0 to pnCycles - 1
			for _e_ in _oP_.CycleEvents(_c_)
				_beat_ = (_c_ + _e_[1]) * _B_
				_len_ = _e_[2] * _B_
				_ab_ = This._Absolute(_e_[4])
				_down_ = (_prevAb_ != 0 and _ab_ < _prevAb_)
				_hz_ = This.HzOf(_e_[4], _down_)
				_vel_ = 0.6
				if ring_find(_aAcc_, floor(_e_[1] * _B_ + 0.0001) + 1) > 0 and
				   fabs(_e_[1] * _B_ - floor(_e_[1] * _B_ + 0.0001)) < 0.0001
					_vel_ = 0.9
				ok
				_oS_.SetVelocity(_vel_)
				_oS_.On(@cMelody)
				_orn_ = This._OrnamentFor(_aOrn_, _prevAb_, _ab_, This._DegreeInOctave(_e_[4]))
				if _orn_ = "slide" and _prevHz_ > 0
					_oS_.GlideAt(_beat_, _prevHz_, _hz_, _len_)
				but isList(_orn_)
					# a grace: the named degree for a short moment, then the note
					_g_ = _len_ / 6
					if _g_ > 0.25  _g_ = 0.25 ok
					_gHz_ = This.HzOf(_orn_[2], FALSE)
					_oS_.NoteAt(_beat_, _gHz_, _g_)
					_oS_.NoteAt(_beat_ + _g_, _hz_, _len_ - _g_)
					_orn_ = "grace " + _orn_[2]
				else
					_oS_.NoteAt(_beat_, _hz_, _len_)
					if _orn_ = "slide"  _orn_ = "" ok
				ok
				if _pair_ > 0
					# the partner, tuned apart ON PURPOSE so the two beat
					_oS_.NoteAt(_beat_, _hz_ + _pair_, _len_)
				ok
				@aNotes + [ _beat_, _e_[4], This.CentsOf(_e_[4], _down_), _hz_, "" + _orn_ ]
				_prevAb_ = _ab_
				_prevHz_ = _hz_
			next
		next
		This._Rhythm(_oS_, pnCycles)
		_oS_.SetLength(pnCycles * _B_)
		return _oS_

	# The declared sentences of a TONAL language, drummed: the plan's MU7 row
	# (text -> drum) needs the declaration first, and it is here. Each
	# syllable is a stroke at the pitch its tone asks for -- High, Low, or a
	# Falling glide from High to Low -- lasting its declared units (a long
	# vowel takes two). The interval between High and Low is the
	# declaration's :tonepitch, which says where it came from.
	def Sentences()
		_a_ = []
		for _s_ in This._Get(@aU, :sentences, [])  _a_ + This._Get(_s_, :text, "") next
		return _a_

	def SentenceQ(pcText)
		_oS_ = StzSoundScoreQ().Tempo(@nTempo)
		_aSent_ = []
		for _s_ in This._Get(@aU, :sentences, [])
			if This._Get(_s_, :text, "") = lower("" + pcText)  _aSent_ = _s_ ok
		next
		if len(_aSent_) = 0
			This._Refuse("SentenceQ: " + @cName + " declares no sentence '" + pcText + "' -- it has: " +
			             This._Joined(This.Sentences()))
			return _oS_
		ok
		_drum_ = This._Get(@aU, :drum, "")
		_aTP_ = This._Get(@aU, :tonepitch, [])
		_h_ = This._Get(_aTP_, :h, 0)
		_lo_ = This._Get(_aTP_, :l, 0)
		_oS_.On(_drum_)
		_at_ = 0
		@aNotes = []
		for _y_ in This._Get(_aSent_, :syllables, [])
			_units_ = _y_[3] * 0.5
			switch upper(_y_[2])
			on "H"  _oS_.NoteAt(_at_, _h_, _units_)
			        @aNotes + [ _at_, _y_[1], "H", _h_, "" ]
			on "L"  _oS_.NoteAt(_at_, _lo_, _units_)
			        @aNotes + [ _at_, _y_[1], "L", _lo_, "" ]
			on "F"  _oS_.GlideAt(_at_, _h_, _lo_, _units_)
			        @aNotes + [ _at_, _y_[1], "F", _h_, "fall" ]
			other
				This._Refuse("SentenceQ: tone '" + _y_[2] + "' is not H, L or F")
			off
			_at_ += _units_
		next
		return _oS_

	#-- MU7: RENDER -- a series of numbers becomes a MELODY in this universe --
	#
	# The plan's MU7 row "data -> melody in a declared universe": sonification
	# that a listener from the tradition would hear as music, not as a meter.
	# The lowest value sits on degree 1 and the highest two octaves of the
	# mode up; one note per beat of the cycle, the cycle's own rhythm under it,
	# the mode's movement and ornaments applied as for any phrase. A series
	# with no spread is refused rather than played as one repeated note.
	def SonifyQ(paValues)
		_oS_ = StzSoundScoreQ().Tempo(@nTempo)
		_n_ = len(This._Get(@aMode, :degrees, []))
		if _n_ = 0
			This._Refuse("SonifyQ: " + This.Title() + " declares no scale -- a series needs degrees to become a melody")
			return _oS_
		ok
		if NOT isList(paValues) or len(paValues) < 2
			This._Refuse("SonifyQ: a series of two numbers or more")
			return _oS_
		ok
		_lo_ = paValues[1]
		_hi_ = paValues[1]
		for _v_ in paValues
			if NOT isNumber(_v_)
				This._Refuse("SonifyQ: every value is a number")
				return _oS_
			ok
			if _v_ < _lo_  _lo_ = _v_ ok
			if _v_ > _hi_  _hi_ = _v_ ok
		next
		if _hi_ = _lo_
			This._Refuse("SonifyQ: the series does not move -- one value would be one note, repeated")
			return _oS_
		ok
		# degrees 1 .. 2n -- two octaves of the mode -- but never past what the
		# melody instrument can play. The first cut did not ask: a series put
		# degree 14 of Rast (959 Hz) on the oud, whose top is 700, the note was
		# refused, and the melody came out one note short.
		_top_ = 2 * _n_
		_oI_ = StzSoundInstrumentQ(@cMelody)
		if _oI_.IsUsable()
			_hi_I_ = _oI_.Range()[2]
			while _top_ > 2 and This.HzOf("" + _top_, FALSE) > _hi_I_  _top_-- end
		ok
		@nSonifiedTop = _top_
		_B_ = This._Get(@aCycle, :beats, 4)
		@aSonified = []
		_cPh_ = "<"
		_k_ = 0
		for _v_ in paValues
			_d_ = 1 + floor((_v_ - _lo_) / (_hi_ - _lo_) * (_top_ - 1) + 0.5)
			@aSonified + _d_
			if _k_ % _B_ = 0
				if _k_ > 0  _cPh_ += "] " ok
				_cPh_ += "["
			else
				_cPh_ += " "
			ok
			_cPh_ += "" + _d_
			_k_++
		next
		while _k_ % _B_ != 0
			_cPh_ += " ~"
			_k_++
		end
		_cPh_ += "]>"
		@cSonifiedPhrase = _cPh_
		return This.PerformQ(_cPh_, _k_ / _B_)

	# the degrees the last SonifyQ chose, one per value
	def SonifiedDegrees()
		return @aSonified

	# the highest degree it allowed -- 2n, or fewer when the instrument is short
	def SonifiedTop()
		return @nSonifiedTop

	def SonifiedPhrase()
		return @cSonifiedPhrase

	#-- MU7 (Niger's row): TEXT -> DRUM ------------------------------------------
	#
	# Hausa is tonal: High, Low, and Falling (High then Low on one heavy
	# syllable) -- Newman (1996). In writing the tones are marked the way
	# Newman's dictionary marks them: NO mark is High, a grave (a-grave) is
	# Low, a circumflex (a-circumflex) is Falling; a doubled vowel or a macron
	# is long. Everyday Hausa writing marks NO tones at all -- so text without
	# a single mark is REFUSED: read as all-High it would be a confident lie.
	#
	# ToneSyllables returns what was read; DrumTonesQ plays it on the drum.
	# SayOnDrum is the verb the plan names, and it is GATED: text -> drum is
	# speech only if a Hausa speaker hears the sentence back, and until one has
	# (the declaration's :talkingdrum verdict), it refuses with that reason.

	def ToneSyllables(pcText)
		_aL_ = This._HausaLetters("" + pcText)
		_bMarked_ = FALSE
		for _l_ in _aL_
			if _l_[3] != "H" and _l_[2] = "v"  _bMarked_ = TRUE ok
			if _l_[5]  _bMarked_ = TRUE ok
		next
		if NOT _bMarked_
			This._Refuse("ToneSyllables: this Hausa carries no tone marks. Everyday writing leaves tone out; mark it as Newman's dictionary does -- no mark = High, a grave = Low, a circumflex = Falling")
			return []
		ok
		_aOut_ = []
		_i_ = 1
		_n_ = len(_aL_)
		while _i_ <= _n_
			if _aL_[_i_][2] = " "
				_i_++
				loop
			ok
			_syl_ = ""
			_tone_ = ""
			_units_ = 1
			# onset: consonants up to the vowel
			while This._Kind(_aL_, _i_) = "c"
				_syl_ += _aL_[_i_][1]
				_i_++
			end
			if This._Kind(_aL_, _i_) != "v"
				if _syl_ != ""  _aOut_ + [ _syl_, "H", 1 ] ok      # a stray consonant: carried, not dropped
				loop
			ok
			_syl_ += _aL_[_i_][1]
			_tone_ = _aL_[_i_][3]
			if _aL_[_i_][4]  _units_ = 2 ok
			_i_++
			# a second vowel: long (the same vowel) or a diphthong -- heavy
			if This._Kind(_aL_, _i_) = "v"
				_syl_ += _aL_[_i_][1]
				_units_ = 2
				_i_++
			ok
			# a coda: one consonant, when the next is a consonant too or the word ends
			if This._Kind(_aL_, _i_) = "c" and This._Kind(_aL_, _i_ + 1) != "v"
				_syl_ += _aL_[_i_][1]
				_i_++
			ok
			_aOut_ + [ _syl_, _tone_, _units_ ]
		end
		return _aOut_

	def DrumTonesQ(pcText)
		_oS_ = StzSoundScoreQ().Tempo(@nTempo)
		_aSy_ = This.ToneSyllables(pcText)
		if len(_aSy_) = 0  return _oS_ ok
		_drum_ = This._Get(@aU, :drum, "")
		if _drum_ = ""
			This._Refuse("DrumTonesQ: " + This.Title() + " declares no talking drum")
			return _oS_
		ok
		_aTP_ = This._Get(@aU, :tonepitch, [])
		_h_ = This._Get(_aTP_, :h, 0)
		_lo_ = This._Get(_aTP_, :l, 0)
		_oS_.On(_drum_)
		_at_ = 0
		@aNotes = []
		for _y_ in _aSy_
			_u_ = _y_[3] * 0.5
			switch _y_[2]
			on "H"  _oS_.NoteAt(_at_, _h_, _u_)
			        @aNotes + [ _at_, _y_[1], "H", _h_, "" ]
			on "L"  _oS_.NoteAt(_at_, _lo_, _u_)
			        @aNotes + [ _at_, _y_[1], "L", _lo_, "" ]
			on "F"  _oS_.GlideAt(_at_, _h_, _lo_, _u_)
			        @aNotes + [ _at_, _y_[1], "F", _h_, "fall" ]
			off
			_at_ += _u_
		next
		return _oS_

	def SayOnDrum(pcText)
		_aV_ = This._Get(@aU, :talkingdrum, [])
		_v_ = This._Get(_aV_, :verdict, "")
		if _v_ != "SPEAKS"
			This._Refuse("SayOnDrum is not available: " + This._Get(_aV_, :why, "no Hausa speaker has heard it") +
			             " (verdict: " + _v_ + ")")
			return NULL
		ok
		return This.DrumTonesQ(pcText)

	# the kind of letter i, or "" past the end -- so no loop leans on whether
	# `and` short-circuits
	def _Kind(paL, pnI)
		if pnI < 1 or pnI > len(paL)  return "" ok
		return paL[pnI][2]

	# UTF-8 Hausa -> [ letter, kind ("v", "c" or " "), tone, long, marked ]
	def _HausaLetters(pcText)
		_aL_ = []
		_k_ = 1
		_n_ = len(pcText)
		while _k_ <= _n_
			_b_ = ascii(pcText[_k_])
			if _b_ < 128
				_c_ = lower(pcText[_k_])
				if ring_find([ "a", "e", "i", "o", "u" ], _c_) > 0
					_aL_ + [ _c_, "v", "H", FALSE, FALSE ]
				but _c_ = " " or _c_ = "-" or _c_ = "," or _c_ = "."
					_aL_ + [ " ", " ", "", FALSE, FALSE ]
				else
					_aL_ + [ _c_, "c", "", FALSE, FALSE ]
				ok
				_k_++
				loop
			ok
			# two-byte UTF-8: the Latin-1 supplement and Latin Extended-A
			_b2_ = 0
			if _k_ < _n_  _b2_ = ascii(pcText[_k_ + 1]) ok
			_cp_ = (_b_ % 32) * 64 + (_b2_ % 64)
			_aV_ = [ [ 224, "a", "L", FALSE ], [ 225, "a", "H", FALSE ], [ 226, "a", "F", FALSE ],
			         [ 232, "e", "L", FALSE ], [ 233, "e", "H", FALSE ], [ 234, "e", "F", FALSE ],
			         [ 236, "i", "L", FALSE ], [ 237, "i", "H", FALSE ], [ 238, "i", "F", FALSE ],
			         [ 242, "o", "L", FALSE ], [ 243, "o", "H", FALSE ], [ 244, "o", "F", FALSE ],
			         [ 249, "u", "L", FALSE ], [ 250, "u", "H", FALSE ], [ 251, "u", "F", FALSE ],
			         [ 257, "a", "H", TRUE ], [ 275, "e", "H", TRUE ], [ 299, "i", "H", TRUE ],
			         [ 333, "o", "H", TRUE ], [ 363, "u", "H", TRUE ] ]
			_found_ = FALSE
			for _v_ in _aV_
				if _v_[1] = _cp_
					_aL_ + [ _v_[2], "v", _v_[3], _v_[4], TRUE ]
					_found_ = TRUE
					exit
				ok
			next
			if NOT _found_  _aL_ + [ "?", "c", "", FALSE, FALSE ] ok     # a hooked consonant, and the like
			_k_ += 2
		end
		return _aL_

	def ToSound(pcPhrase, pnCycles)
		return This.PerformQ(pcPhrase, pnCycles).ToSound()

	# [ beat, degree, cents, hz, ornament ] for every melody note the last
	# PerformQ placed -- what a guard, or a curious reader, holds it against.
	def PlayedNotes()
		return @aNotes

	def LastError()
		return @cLastError

	def Refusals()
		return @nRefusals

	#-- private -------------------------------------------------------------

	# the rhythmic cycle's own layers: each [ instrument, pattern ] as MU3
	# patterns over one cycle; a pattern of degrees is pitched in this mode
	def _Rhythm(poS, pnCycles)
		_nBeats_ = This._Get(@aCycle, :beats, 4)
		for _aLayer_ in This._Get(@aCycle, :layers, [])
			_inst_ = _aLayer_[1]
			_txt_ = _aLayer_[2]
			poS.On(_inst_)
			# the cycle SUPPORTS the phrase: its layers sit under the melody's
			# 0.6 / 0.9, or four colotomic strokes and a melody note landing on
			# one beat clip (the gamelan's first render peaked at 1.1)
			poS.SetVelocity(0.45)
			_bDeg_ = (len(_aLayer_) >= 3 and _aLayer_[3] = "degrees")
			if _bDeg_
				_oP_ = StzSoundDegreePatternQ(_txt_)
			else
				_oP_ = StzSoundPatternQ(_txt_)
			ok
			if NOT _oP_.IsValid()
				This._Refuse("cycle " + This.CycleName() + ": " + _oP_.LastError())
				loop
			ok
			for _c_ = 0 to pnCycles - 1
				for _e_ in _oP_.CycleEvents(_c_)
					_at_ = (_c_ + _e_[1]) * _nBeats_
					_dur_ = _e_[2] * _nBeats_
					if _bDeg_
						poS.NoteAt(_at_, This.HzOf(_e_[4], FALSE), _dur_)
					but _e_[3] = "stroke"
						poS.StrokeAt(_at_, _e_[4], _dur_)
					else
						poS.NoteAt(_at_, _e_[4], _dur_)
					ok
				next
			next
		next

	# which declared ornament applies to a note: "slide", [ "grace", degree ], or ""
	def _OrnamentFor(paOrn, pnPrevAb, pnAb, pnDeg)
		if pnPrevAb = 0  return "" ok
		for _o_ in paOrn
			_k_ = This._Get(_o_, :kind, "")
			_to_ = This._Get(_o_, :to, 0)
			_dir_ = This._Get(_o_, :when, "any")
			if _to_ != 0 and _to_ != pnDeg  loop ok
			if _dir_ = "up" and NOT (pnAb > pnPrevAb)  loop ok
			if _dir_ = "down" and NOT (pnAb < pnPrevAb)  loop ok
			if _dir_ = "step" and fabs(pnAb - pnPrevAb) != 1  loop ok
			if _k_ = "slide"  return "slide" ok
			if _k_ = "grace"  return [ "grace", "" + This._Get(_o_, :from, 1) ] ok
		next
		return ""

	# a degree word as an absolute index: "5" -> 5, "5_" -> 5 - n, "9" -> 9
	def _Absolute(pcDeg)
		_n_ = len(This._Get(@aMode, :degrees, []))
		if _n_ = 0  _n_ = 7 ok
		_d_ = 0
		_down_ = 0
		for _k_ = 1 to len(pcDeg)
			if isdigit(pcDeg[_k_])  _d_ = _d_ * 10 + (0 + pcDeg[_k_]) else _down_++ ok
		next
		return _d_ - _down_ * _n_

	def _DegreeInOctave(pcDeg)
		_n_ = len(This._Get(@aMode, :degrees, []))
		if _n_ = 0  _n_ = 7 ok
		_d_ = 0
		for _k_ = 1 to len(pcDeg)
			if isdigit(pcDeg[_k_])  _d_ = _d_ * 10 + (0 + pcDeg[_k_]) ok
		next
		return ((_d_ - 1) % _n_) + 1

	# a key of a declaration, or the default -- a missing key is not an error:
	# a rhythm-only universe has no :degrees, a mode without ornaments none
	def _Get(paL, pcKey, pDefault)
		if NOT isList(paL)  return pDefault ok
		_c_ = lower("" + pcKey)
		for _p_ in paL
			if isList(_p_) and len(_p_) = 2 and isString(_p_[1])
				if lower(_p_[1]) = _c_  return _p_[2] ok
			ok
		next
		return pDefault

	def _Refuse(pcWhy)
		@nRefusals++
		@cLastError = pcWhy

	def _Joined(paList)
		_s_ = ""
		for _i_ = 1 to len(paList)
			if _i_ > 1  _s_ += ", " ok
			_s_ += "" + paList[_i_]
		next
		return _s_
