#---------------------------------------------------------------------------#
#  STZSOUNDNOTATIONREADER -- notation becomes a score again (MU8)           #
#---------------------------------------------------------------------------#
#
#     oRd = StzSoundNotationReaderQ()
#     oS = oRd.FromMidiFileQ("tune.mid")        # a stzSoundScore, or NULL
#     oS = oRd.FromAbcQ(cAbcText)               # the same, from ABC 2.1
#     ? oRd.Losses()                            # what the score could not keep
#     ? oRd.LastError()                         # why a file was refused
#
#     oS = StzSoundScoreFromMidiQ("tune.mid")   # one call, when the losses
#     oS = StzSoundScoreFromAbcQ(cAbcText)      # do not matter to the caller
#
# MU7 WROTE notation from a score and read nothing back; the only MIDI reader
# was the guard's own instrument. This is the other direction, and it returns
# the SAME stzSoundScore every transform already reads: a MIDI file or an ABC
# tune can be played, transcribed against, analysed for its modes, or written
# out again in another format, with no adapter.
#
# LIKE THE WRITER, THE READER COUNTS WHAT IT DROPS. A score is one tempo, notes
# and strokes with a start, a length, a pitch, an instrument and a velocity.
# What a file carries beyond that -- a tempo change, a sustain pedal, an ABC
# ornament, a lyric, a chord symbol -- is named in Losses(), never silently
# kept wrong. A file the reader cannot read honestly is REFUSED, with the
# reason in LastError(): a SMPTE-timed MIDI file, MIDI format 2, an ABC tune
# with no K: line.
#
# MIDI (Standard MIDI File, formats 0 and 1). Running status; note-on at
# velocity 0 as a note-off; system-exclusive skipped; every track merged in
# time order. PITCH IS KEY PLUS BEND, and the bend's range is read from each
# channel's RPN 0 (2 semitones until a file says otherwise), so a quarter tone
# or a slendro degree written as a bend comes back as the frequency it was. A
# bend that MOVES during a note makes it a glide to where the bend ended.
# Channel 10 is drums: General MIDI's keys become strokes (kick, snare,
# hihat; 64 dum, 63 tak, 62 ka -- the writer's own choice), and a key with no
# stroke here is dropped and counted.
# INSTRUMENTS: a program change names a GM program, and twenty instruments
# share eleven of them (an oud and a guitar are both 24). This library's
# writer puts the instrument's NAME in a text event, "stz:inst 3 oud", beside
# the program; the reader prefers that name, and otherwise takes the first
# instrument that shares the program (StzSoundGmInstrument).
#
# ABC 2.1. The header up to K: (X T M L Q K V, %%MIDI program); notes with
# accidentals ^ ^^ _ __ = and ABC's microtones ^/ _/ ^n/m; octaves ' and ,;
# lengths 2, /, /2, 3/2, //; ties -, broken rhythm > < >> <<; tuplets (3 and
# (p:q:r; chords [CEG]; rests z x, whole-bar rests Z X; the key signature
# (major, minor and the modes, and extra accidentals as in K:D ^g); bar
# accidentals, cleared at each bar line; voices by V: and [V:]; inline fields
# [K:] [L:] [M:] [Q:]; and REPEATS PLAYED OUT -- |: :| and endings |1 :|2 --
# because a score is what is performed, not what is printed.
# Beats are quarter notes, as in the writer: Q:3/8=100 is 150 quarter notes a
# minute, and a 6/8 bar is three beats.
#
# MUSICXML (MU9; score-partwise, uncompressed). Parsed by a small XML reader of
# its own -- elements, attributes, text, entities, comments, CDATA, a DOCTYPE
# -- because Ring carries none and a reader should not lean on one it cannot
# see. What is read is what SOUNDS: <pitch> with its decimal <alter> (so the
# writer's -0.5 is a quarter tone again), <duration> over <divisions>, <chord/>,
# <backup> and <forward> (voices inside one part), <tie> (the sounding tie, not
# the drawn one), <transpose> (a clarinet's written D5 is its sounding C5),
# <sound tempo> and <metronome>, <sound dynamics> and a note's dynamics,
# unpitched notes by their instrument's <midi-unpitched> key, and repeats
# PLAYED OUT: forward and backward repeats with times="n", and endings. The key
# signature is NOT needed: MusicXML writes every alteration on its note.
# REFUSED: score-timewise, a compressed .mxl (unzip it first), a text that is
# not well-formed XML, a duration before any <divisions>.

func StzSoundNotationReaderQ()
	return new stzSoundNotationReader()

func StzSoundScoreFromMusicXMLQ(pcXml)
	return StzSoundNotationReaderQ().FromMusicXMLQ(pcXml)

func StzSoundScoreFromMidiQ(pcPath)
	return StzSoundNotationReaderQ().FromMidiFileQ(pcPath)

func StzSoundScoreFromAbcQ(pcAbc)
	return StzSoundNotationReaderQ().FromAbcQ(pcAbc)

class stzSoundNotationReader

	@aLosses = []
	@cLastError = ""
	@cTitle = ""
	@aVoicesRead = []      # [ voice id, instrument ] for the last ABC tune

	# the ABC parse: the tune's defaults, the current voice's state, the items
	@aItems = []           # [ voiceNo, kind, dur, pitches, ties, extra ]
	@aVS = []              # a voice's saved state, per voice
	@nCv = 0
	@aKey = []             # the key's alteration per letter C D E F G A B
	@nL = 0                # the unit note length, a fraction of a whole note
	@nMn = 4               # the metre, 4/4 until M: says otherwise (0 = none)
	@nMd = 4
	@aAcc = []             # [ letter+octave, alteration ] set in this bar
	@nTupLeft = 0
	@nTupF = 1
	@nBroken = 1
	@nLastIdx = 0
	@nQ = 0                # quarter notes a minute; 0 until Q: gives it
	@aDefaults = []        # the tune's header state, for a voice that begins later
	@aVDecl = []           # [ id, name, program ] from V: lines

	# the MusicXML parse
	@aX = []               # XML nodes: [ name, [ [attr, value] ], parent, [ children ], text ]
	@nMxDiv = 0            # divisions a quarter note, as the part last said
	@nMxTrans = 0          # semitones from written to sounding pitch
	@nMxVel = 0.8          # the velocity a note takes when it names none

	def init()

	def Losses()
		return @aLosses

	def LastError()
		return @cLastError

	def Title()
		return @cTitle

	def Voices()
		return @aVoicesRead

	#== MIDI ====================================================================

	def FromMidiFileQ(pcPath)
		@aLosses = []
		@cLastError = ""
		@cTitle = ""
		if NOT isString(pcPath) or NOT fexists(pcPath)
			return This._Refuse("FromMidiFileQ: no file at '" + pcPath + "'")
		ok
		return This._FromMidi(read(pcPath))

	def FromMidiBytesQ(pcBytes)
		@aLosses = []
		@cLastError = ""
		@cTitle = ""
		if NOT isString(pcBytes)  return This._Refuse("FromMidiBytesQ: the bytes of a MIDI file, as a string") ok
		return This._FromMidi(pcBytes)

	def _FromMidi(pcB)
		_n_ = len(pcB)
		if _n_ < 14
			return This._Refuse("MIDI: not a Standard MIDI File -- " + _n_ + " bytes, and a header alone is 14")
		ok
		if substr(pcB, 1, 4) != "MThd"
			return This._Refuse("MIDI: not a Standard MIDI File -- it does not begin with MThd")
		ok
		_hl_ = This._Be(pcB, 5, 4)
		_fmt_ = This._Be(pcB, 9, 2)
		_ntr_ = This._Be(pcB, 11, 2)
		_div_ = This._Be(pcB, 13, 2)
		if _fmt_ > 1
			return This._Refuse("MIDI: format " + _fmt_ + " holds independent sequences, not one piece; formats 0 and 1 are read")
		ok
		if _div_ >= 32768
			return This._Refuse("MIDI: the file counts SMPTE frames, not beats; only beat-timed files are read")
		ok
		if _div_ = 0  return This._Refuse("MIDI: a division of 0 ticks a beat") ok

		# every event of every track, keyed so that ONE sort puts them in time
		# order: tick, then track, then place in its track
		_aE_ = []          # [ key, tick, status, d1, d2, metaType, metaData ]
		_pos_ = 9 + _hl_
		_trk_ = 0
		while _pos_ + 7 <= _n_
			_id_ = substr(pcB, _pos_, 4)
			_len_ = This._Be(pcB, _pos_ + 4, 4)
			_p_ = _pos_ + 8
			_end_ = _p_ + _len_
			if _end_ > _n_ + 1
				This._Loss("MIDI: the last chunk is cut short; it is read up to the file's end")
				_end_ = _n_ + 1
			ok
			if _id_ = "MTrk"
				_trk_++
				if _trk_ > 63  return This._Refuse("MIDI: more than 63 tracks") ok
				if NOT This._MidiTrack(pcB, _p_, _end_, _trk_, _aE_)  return NULL ok
			ok
			_pos_ = _end_
		end
		if _trk_ = 0  return This._Refuse("MIDI: the file holds no track (no MTrk chunk)") ok
		if _trk_ != _ntr_
			This._Loss("MIDI: the header announces " + _ntr_ + " tracks and the file holds " + _trk_)
		ok
		_aE_ = sort(_aE_, 1)

		# the channels, as the file leaves them at each moment
		_aBend_ = list(16)
		_aRange_ = list(16)
		_aRpn_ = list(16)
		_aInst_ = list(16)
		_aNamedAt_ = list(16)
		for _c_ = 1 to 16
			_aBend_[_c_] = 8192
			_aRange_[_c_] = 2
			_aRpn_[_c_] = [ 127, 127 ]
			_aInst_[_c_] = ""
			_aNamedAt_[_c_] = -1
		next
		_cDrumInst_ = ""
		_aOn_ = []         # sounding: [ ch, key, tick, hz, vel, inst, lastHz, maxDevCents, moved, order ]
		_aOut_ = []        # [ sortKey, beat, beats, hz, inst, vel, stroke, hzEnd ]
		_nBpm_ = 0
		_nOrder_ = 0
		_nLast_ = 0
		for _e_ in _aE_
			_tick_ = _e_[2]
			if _tick_ > _nLast_  _nLast_ = _tick_ ok
			_st_ = _e_[3]
			if _st_ = 255
				if _e_[6] = 81 and len(_e_[7]) >= 3
					# microseconds a beat: 90 BPM is stored as 666667 and reads 89.99995.
					# Rounded to a thousandth -- finer than the format can mean
					_b_ = floor(60000000 / This._Be(_e_[7], 1, 3) * 1000 + 0.5) / 1000
					if _tick_ = 0
						_nBpm_ = _b_
					else
						_cur_ = _nBpm_
						if _cur_ = 0  _cur_ = 120 ok
						if fabs(_b_ - _cur_) > 0.001
							This._Loss("MIDI: the tempo changes during the piece; a score has one tempo, and keeps the first (" +
							           This._Num(_cur_) + " BPM)")
						ok
					ok
				but _e_[6] = 1 and left(_e_[7], 9) = "stz:inst "
					_aW_ = This._Words(substr(_e_[7], 10, len(_e_[7]) - 9))
					if len(_aW_) = 2
						_ch_ = number(_aW_[1])
						if StzSoundGmProgram(_aW_[2]) != 0 or _aW_[2] = "piano"
							if _ch_ = 9
								_cDrumInst_ = _aW_[2]
							but _ch_ >= 0 and _ch_ <= 15
								_aInst_[_ch_ + 1] = _aW_[2]
								_aNamedAt_[_ch_ + 1] = _tick_
							ok
						ok
					ok
				ok
				loop
			ok
			_hi_ = floor(_st_ / 16)
			_ch_ = _st_ % 16
			_c1_ = _ch_ + 1
			if _hi_ = 9 and _e_[5] > 0
				_nOrder_++
				if _ch_ = 9
					_aOn_ + [ 9, _e_[4], _tick_, 0, _e_[5], _cDrumInst_, 0, 0, FALSE, _nOrder_ ]
				else
					_hz_ = This._MidiHz(_e_[4], _aBend_[_c1_], _aRange_[_c1_])
					_inst_ = _aInst_[_c1_]
					if _inst_ = ""  _inst_ = "piano" ok
					_aOn_ + [ _ch_, _e_[4], _tick_, _hz_, _e_[5], _inst_, _hz_, 0, FALSE, _nOrder_ ]
				ok
			but _hi_ = 8 or _hi_ = 9
				for _i_ = 1 to len(_aOn_)
					if _aOn_[_i_][1] = _ch_ and _aOn_[_i_][2] = _e_[4]
						This._MidiEmit(_aOn_[_i_], _tick_, _div_, _aOut_)
						del(_aOn_, _i_)
						exit
					ok
				next
			but _hi_ = 14
				_aBend_[_c1_] = _e_[4] + 128 * _e_[5]
				if _ch_ != 9
					for _i_ = 1 to len(_aOn_)
						if _aOn_[_i_][1] = _ch_
							_hz_ = This._MidiHz(_aOn_[_i_][2], _aBend_[_c1_], _aRange_[_c1_])
							_dev_ = fabs(This._Cents(_hz_, _aOn_[_i_][4]))
							if _dev_ > _aOn_[_i_][8]  _aOn_[_i_][8] = _dev_ ok
							_aOn_[_i_][7] = _hz_
							_aOn_[_i_][9] = TRUE
						ok
					next
				ok
			but _hi_ = 11
				switch _e_[4]
				on 101  _aRpn_[_c1_][1] = _e_[5]
				on 100  _aRpn_[_c1_][2] = _e_[5]
				on 6
					if _aRpn_[_c1_][1] = 0 and _aRpn_[_c1_][2] = 0  _aRange_[_c1_] = _e_[5] ok
				on 38
					if _aRpn_[_c1_][1] = 0 and _aRpn_[_c1_][2] = 0
						_aRange_[_c1_] = floor(_aRange_[_c1_]) + _e_[5] / 100
					ok
				on 64
					if _e_[5] >= 64  This._Loss("MIDI: the sustain pedal is not kept; notes end at their note-off") ok
				on 121
					_aBend_[_c1_] = 8192
				off
			but _hi_ = 12
				if _ch_ != 9 and _aNamedAt_[_c1_] != _tick_
					_cI_ = StzSoundGmInstrument(_e_[4])
					if _cI_ = ""
						This._Loss("MIDI: GM program " + _e_[4] + " is no instrument here; it is read on the piano")
						_cI_ = "piano"
					ok
					_aInst_[_c1_] = _cI_
				ok
			ok
		next
		for _o_ in _aOn_
			This._Loss("MIDI: a note is never released; it ends where the file ends")
			This._MidiEmit(_o_, _nLast_, _div_, _aOut_)
		next
		if _nBpm_ = 0  _nBpm_ = 120 ok
		return This._ScoreOf(_aOut_, _nBpm_)

	# one track's events, appended to paE; FALSE (and LastError) on a broken track
	def _MidiTrack(pcB, pnP, pnEnd, pnTrk, paE)
		_p_ = pnP
		_tick_ = 0
		_st_ = 0
		_seq_ = 0
		while _p_ < pnEnd
			_v_ = This._VlqAt(pcB, _p_, pnEnd)
			if len(_v_) = 0
				This._Refuse("MIDI: track " + pnTrk + " ends inside a delta time")
				return FALSE
			ok
			_tick_ += _v_[1]
			_p_ = _v_[2]
			if _p_ >= pnEnd
				This._Loss("MIDI: track " + pnTrk + " ends without its end-of-track event")
				exit
			ok
			_x_ = ascii(pcB[_p_])
			if _x_ >= 128
				_st_ = _x_
				_p_++
			but _st_ = 0
				This._Refuse("MIDI: track " + pnTrk + " has a data byte with no status before it")
				return FALSE
			ok
			_seq_++
			_key_ = (_tick_ * 64 + pnTrk) * 1000000 + _seq_
			if _st_ = 255
				if _p_ >= pnEnd
					This._Refuse("MIDI: track " + pnTrk + " ends inside a meta event")
					return FALSE
				ok
				_ty_ = ascii(pcB[_p_])
				_ml_ = This._VlqAt(pcB, _p_ + 1, pnEnd)
				if len(_ml_) = 0 or _ml_[2] + _ml_[1] > pnEnd
					This._Refuse("MIDI: track " + pnTrk + " ends inside a meta event")
					return FALSE
				ok
				paE + [ _key_, _tick_, 255, 0, 0, _ty_, substr(pcB, _ml_[2], _ml_[1]) ]
				_p_ = _ml_[2] + _ml_[1]
				_st_ = 0             # a meta event cancels running status
				if _ty_ = 47  exit ok
				loop
			ok
			if _st_ = 240 or _st_ = 247
				_ml_ = This._VlqAt(pcB, _p_, pnEnd)
				if len(_ml_) = 0 or _ml_[2] + _ml_[1] > pnEnd
					This._Refuse("MIDI: track " + pnTrk + " ends inside a system-exclusive message")
					return FALSE
				ok
				This._Loss("MIDI: system-exclusive messages are skipped")
				_p_ = _ml_[2] + _ml_[1]
				_st_ = 0
				loop
			ok
			if _st_ > 240
				This._Refuse("MIDI: track " + pnTrk + " holds a real-time or system message (" + _st_ + "), which a file never should")
				return FALSE
			ok
			_hi_ = floor(_st_ / 16)
			_nd_ = 2
			if _hi_ = 12 or _hi_ = 13  _nd_ = 1 ok
			if _p_ + _nd_ > pnEnd
				This._Refuse("MIDI: track " + pnTrk + " ends inside a message")
				return FALSE
			ok
			_d2_ = 0
			if _nd_ = 2  _d2_ = ascii(pcB[_p_ + 1]) ok
			paE + [ _key_, _tick_, _st_, ascii(pcB[_p_]), _d2_, -1, "" ]
			_p_ += _nd_
		end
		return TRUE

	# a sounding note, released at pnOff: one row of the score to come
	def _MidiEmit(paOn, pnOff, pnPpq, paOut)
		_at_ = paOn[3] / pnPpq
		_ln_ = (pnOff - paOn[3]) / pnPpq
		if _ln_ <= 0
			This._Loss("MIDI: a note of no length is read as one tick long")
			_ln_ = 1 / pnPpq
		ok
		_vel_ = paOn[5] / 127
		_key_ = paOn[3] * 1000000 + paOn[10]
		if paOn[1] = 9
			_sk_ = This._GmStroke(paOn[2])
			if _sk_ = ""
				This._Loss("MIDI: General MIDI drum key " + paOn[2] + " is no stroke here; it is dropped")
				return
			ok
			_inst_ = paOn[6]
			if _inst_ = ""
				_inst_ = "drumkit"
				if ring_find([ "dum", "tak", "ka" ], _sk_) > 0  _inst_ = "darbouka" ok
			ok
			paOut + [ _key_, _at_, _ln_, 0, _inst_, _vel_, _sk_, 0 ]
			return
		ok
		_to_ = 0
		if paOn[9]
			_c_ = fabs(This._Cents(paOn[7], paOn[4]))
			if _c_ > 1  _to_ = paOn[7] ok
			if paOn[8] > _c_ + 5
				This._Loss("MIDI: a note's bend moves and comes back (vibrato, or an ornament); it is read as a glide to where the bend ends")
			ok
		ok
		paOut + [ _key_, _at_, _ln_, paOn[4], paOn[6], _vel_, "", _to_ ]

	def _MidiHz(pnKey, pnBend, pnRange)
		_semis_ = (pnBend - 8192) / 8192 * pnRange
		return 440 * pow(2, (pnKey + _semis_ - 69) / 12)

	# General MIDI's percussion keys, back to this library's strokes
	def _GmStroke(pnKey)
		switch pnKey
		on 35  return "kick"
		on 36  return "kick"
		on 37  return "snare"
		on 38  return "snare"
		on 40  return "snare"
		on 42  return "hihat"
		on 44  return "hihat"
		on 46  return "openhat"       # MU14: the open hi-hat is its own stroke now
		on 41  return "floortom"      # the toms: low and high floor, low and low-mid, hi-mid and high
		on 43  return "floortom"
		on 45  return "midtom"
		on 47  return "midtom"
		on 48  return "hightom"
		on 50  return "hightom"
		on 49  return "crash"         # MU13: crash cymbals 1 and 2
		on 57  return "crash"
		on 51  return "ride"          # ride cymbals 1 and 2
		on 59  return "ride"
		on 62  return "ka"
		on 63  return "tak"
		on 64  return "dum"
		off
		return ""

	def _Be(pcB, pnAt, pnN)
		_v_ = 0
		for _k_ = 0 to pnN - 1  _v_ = _v_ * 256 + ascii(pcB[pnAt + _k_]) next
		return _v_

	# a variable-length quantity at pnP: [ value, next position ], or [] when
	# it runs past pnEnd or past the four bytes the format allows
	def _VlqAt(pcB, pnP, pnEnd)
		_v_ = 0
		_p_ = pnP
		for _k_ = 1 to 4
			if _p_ >= pnEnd  return [] ok
			_x_ = ascii(pcB[_p_])
			_p_++
			_v_ = _v_ * 128 + (_x_ % 128)
			if _x_ < 128  return [ _v_, _p_ ] ok
		next
		return []

	#== ABC 2.1 =================================================================

	def FromAbcQ(pcAbc)
		@aLosses = []
		@cLastError = ""
		@cTitle = ""
		@aVoicesRead = []
		if NOT isString(pcAbc) or ring_trim(pcAbc) = ""
			return This._Refuse("ABC: the text is empty")
		ok
		@aItems = []
		@aVS = []
		@nCv = 0
		@aKey = [ 0, 0, 0, 0, 0, 0, 0 ]
		@nL = 0
		@nMn = 4
		@nMd = 4
		@aAcc = []
		@nTupLeft = 0
		@nTupF = 1
		@nBroken = 1
		@nLastIdx = 0
		@nQ = 0
		@aDefaults = []
		@aVDecl = []

		_aLines_ = This._Lines(pcAbc)
		_nX_ = 0
		for _k_ = 1 to len(_aLines_)
			if left(_aLines_[_k_], 2) = "X:"
				_nX_ = _k_
				exit
			ok
		next
		_bHeader_ = TRUE
		_bSawK_ = FALSE
		_from_ = 1
		if _nX_ > 0  _from_ = _nX_ ok
		for _k_ = _from_ to len(_aLines_)
			_ln_ = _aLines_[_k_]
			_tr_ = ring_trim(_ln_)
			if _tr_ = ""
				if _bHeader_  loop ok
				exit                # a blank line ends the tune
			ok
			if left(_tr_, 2) = "%%"
				This._AbcDirective(_tr_)
				loop
			ok
			if _tr_[1] = "%"  loop ok
			if This._IsField(_tr_)
				_f_ = upper(_tr_[1])
				if _tr_[1] = "w"  _f_ = "w" ok
				_val_ = ring_trim(substr(_tr_, 3, len(_tr_) - 2))
				if _f_ = "X" and _k_ > _from_
					This._Loss("ABC: the text holds more than one tune; the first is read")
					exit
				ok
				if _bHeader_
					if _f_ = "K"
						This._AbcKey(_val_)
						if @nL = 0  This._AbcDefaultL() ok
						@aDefaults = [ @aKey, @nL, @nMn, @nMd ]
						_bHeader_ = FALSE
						_bSawK_ = TRUE
					but _f_ = "V"
						This._AbcDeclareVoice(_val_)
					else
						This._AbcField(_f_, _val_)
					ok
				else
					This._AbcBodyField(_f_, _val_)
				ok
				loop
			ok
			if _bHeader_
				return This._Refuse("ABC: music before the K: line -- a tune's header ends with K:, and this one has none")
			ok
			This._AbcMusic(_ln_)
		next
		if NOT _bSawK_
			return This._Refuse("ABC: no K: line -- a tune's header ends with K:, and this one has none")
		ok
		if @nCv > 0  This._VSave() ok
		return This._AbcScore()

	#-- the header and the fields

	def _IsField(pc)
		if len(pc) < 2  return FALSE ok
		if pc[2] != ":"  return FALSE ok
		_a_ = ascii(pc[1])
		return (_a_ >= 65 and _a_ <= 90) or (_a_ >= 97 and _a_ <= 122)

	def _AbcField(pcF, pcV)
		switch pcF
		on "T"
			if @cTitle = ""  @cTitle = pcV ok
		on "M"  This._AbcMeter(pcV)
		on "L"  This._AbcUnit(pcV)
		on "Q"  This._AbcTempo(pcV)
		on "K"  This._AbcKey(pcV)
		on "P"  This._Loss("ABC: the parts order (P:) is not followed; the tune is read as it is written")
		on "w"  This._Loss("ABC: lyrics (w:, W:) are not read")
		on "W"  This._Loss("ABC: lyrics (w:, W:) are not read")
		off

	def _AbcBodyField(pcF, pcV)
		if pcF = "V"
			This._AbcSwitchVoice(pcV)
			return
		ok
		This._AbcEnsureVoice()
		This._AbcField(pcF, pcV)

	# %%MIDI program [channel] n -- the voice's (or the tune's) GM program
	def _AbcDirective(pc)
		_aW_ = This._Words(pc)
		if len(_aW_) >= 3
			if lower(_aW_[1]) = "%%midi" and lower(_aW_[2]) = "program"
				_p_ = number(_aW_[len(_aW_)])
				if @nCv > 0
					@aVS[@nCv][3] = _p_
				else
					_n_ = len(@aVDecl)
					if _n_ > 0
						@aVDecl[_n_][3] = _p_
					else
						@aVDecl + [ "", "", _p_ ]      # the tune's, for every voice
					ok
				ok
				return
			ok
		ok

	def _AbcMeter(pcV)
		_v_ = ring_trim(pcV)
		if _v_ = "C"
			@nMn = 4  @nMd = 4
			return
		ok
		if _v_ = "C|"
			@nMn = 2  @nMd = 2
			return
		ok
		if lower(_v_) = "none" or _v_ = ""
			@nMn = 0  @nMd = 0
			return
		ok
		_s_ = substr(_v_, "/")
		if _s_ = 0
			This._Loss("ABC: the metre '" + pcV + "' is not read; 4/4 is kept")
			return
		ok
		# 2+3/8: an additive metre's numerator is the sum of its parts
		_num_ = 0
		_w_ = ""
		for _j_ = 1 to _s_ - 1
			if _v_[_j_] = "+"
				_num_ += number("0" + ring_trim(_w_))
				_w_ = ""
			else
				_w_ += _v_[_j_]
			ok
		next
		_num_ += number("0" + ring_trim(_w_))
		_den_ = number(ring_trim(substr(_v_, _s_ + 1, len(_v_) - _s_)))
		if _num_ <= 0 or _den_ <= 0
			This._Loss("ABC: the metre '" + pcV + "' is not read; 4/4 is kept")
			return
		ok
		@nMn = _num_
		@nMd = _den_

	def _AbcUnit(pcV)
		_f_ = This._Fraction(pcV)
		if _f_ <= 0
			This._Loss("ABC: the unit length '" + pcV + "' is not read")
			return
		ok
		@nL = _f_

	# ABC 2.1: the default unit is 1/16 below a metre of 3/4, and 1/8 from it up
	def _AbcDefaultL()
		@nL = 1 / 8
		if @nMd > 0
			if @nMn / @nMd < 0.75  @nL = 1 / 16 ok
		ok

	# Q:1/4=96, Q:3/8=100, Q:"Allegro" 1/4=120, Q:1/4 1/8=60 -- in quarter notes a minute
	def _AbcTempo(pcV)
		_v_ = ""
		_bIn_ = FALSE
		for _k_ = 1 to len(pcV)
			if pcV[_k_] = char(34)
				_bIn_ = NOT _bIn_
				loop
			ok
			if NOT _bIn_  _v_ += pcV[_k_] ok
		next
		_v_ = ring_trim(_v_)
		if _v_ = ""  return ok
		_e_ = substr(_v_, "=")
		_q_ = 0
		if _e_ = 0
			# the old form: units of L a minute
			_u_ = @nL
			if _u_ = 0  _u_ = 1 / 8 ok
			_q_ = number(_v_) * _u_ * 4
		else
			_sum_ = 0
			for _w_ in This._Words(substr(_v_, 1, _e_ - 1))  _sum_ += This._Fraction(_w_) next
			_q_ = number(ring_trim(substr(_v_, _e_ + 1, len(_v_) - _e_))) * _sum_ * 4
		ok
		if _q_ <= 0
			This._Loss("ABC: the tempo '" + pcV + "' is not read")
			return
		ok
		if @nQ = 0
			@nQ = _q_
		but fabs(@nQ - _q_) > 0.001
			This._Loss("ABC: the tempo changes during the tune; a score has one tempo, and keeps the first (" + This._Num(@nQ) + " BPM)")
		ok

	# K: -- a tonic, a mode, and extra accidentals; the rest (clef=...) ignored
	def _AbcKey(pcV)
		_aW_ = This._Words(pcV)
		_aK_ = [ 0, 0, 0, 0, 0, 0, 0 ]
		if len(_aW_) = 0
			@aKey = _aK_
			return
		ok
		_w_ = _aW_[1]
		_i_ = 2
		if lower(_w_) = "none"
			@aKey = _aK_
			return
		ok
		if _w_ = "HP" or _w_ = "Hp"
			This._Loss("ABC: the Highland pipe key (" + _w_ + ") is read as no signature")
			@aKey = _aK_
			return
		ok
		_nFifths_ = 0
		_bTonic_ = FALSE
		_t_ = ascii(_w_[1])
		if _t_ >= 65 and _t_ <= 71
			_bTonic_ = TRUE
			_nFifths_ = This._TonicFifths(_w_[1])
			_rest_ = substr(_w_, 2, len(_w_) - 1)
			if left(_rest_, 1) = "#"
				_nFifths_ += 7
				_rest_ = substr(_rest_, 2, len(_rest_) - 1)
			but left(_rest_, 1) = "b"
				_nFifths_ -= 7
				_rest_ = substr(_rest_, 2, len(_rest_) - 1)
			ok
			if _rest_ = "" and len(_aW_) >= 2
				# "K:A min" -- the mode as its own word
				if This._ModeOffset(_aW_[2]) != 99
					_rest_ = _aW_[2]
					_i_ = 3
				ok
			ok
			if _rest_ != ""
				_off_ = This._ModeOffset(_rest_)
				if _off_ = 99
					This._Loss("ABC: the mode '" + _rest_ + "' is not known; the key is read as major")
				else
					_nFifths_ += _off_
				ok
			ok
		else
			_i_ = 1
		ok
		if _nFifths_ > 7 or _nFifths_ < -7
			This._Loss("ABC: the key '" + pcV + "' needs double sharps or flats; it is read with seven")
			if _nFifths_ > 7  _nFifths_ = 7 ok
			if _nFifths_ < -7  _nFifths_ = -7 ok
		ok
		_aSh_ = [ "F", "C", "G", "D", "A", "E", "B" ]
		_aFl_ = [ "B", "E", "A", "D", "G", "C", "F" ]
		if _nFifths_ > 0
			for _k_ = 1 to _nFifths_  _aK_[This._LetterNo(_aSh_[_k_])] = 1 next
		but _nFifths_ < 0
			for _k_ = 1 to 0 - _nFifths_  _aK_[This._LetterNo(_aFl_[_k_])] = -1 next
		ok
		# extra accidentals: K:D ^g _b =c, and "exp" for only those
		for _k_ = _i_ to len(_aW_)
			_x_ = _aW_[_k_]
			if lower(_x_) = "exp"
				_aK_ = [ 0, 0, 0, 0, 0, 0, 0 ]
				loop
			ok
			if substr(_x_, "=") > 1  loop ok           # clef=..., middle=...
			_c0_ = _x_[1]
			if (_c0_ = "^" or _c0_ = "_" or _c0_ = "=") and len(_x_) >= 2
				_aP_ = This._AbcAccidental(_x_, 1)
				if _aP_[2] > len(_x_)  loop ok
				_let_ = upper(_x_[_aP_[2]])
				_ln_ = This._LetterNo(_let_)
				if _ln_ > 0  _aK_[_ln_] = _aP_[1] ok
			ok
		next
		@aKey = _aK_

	def _TonicFifths(pcL)
		switch upper(pcL)
		on "C"  return 0
		on "G"  return 1
		on "D"  return 2
		on "A"  return 3
		on "E"  return 4
		on "B"  return 5
		on "F"  return -1
		off
		return 0

	def _ModeOffset(pc)
		_m_ = lower(left(pc, 3))
		if lower(pc) = "m"  return -3 ok
		switch _m_
		on "maj"  return 0
		on "ion"  return 0
		on "min"  return -3
		on "aeo"  return -3
		on "mix"  return -1
		on "dor"  return -2
		on "phr"  return -4
		on "lyd"  return 1
		on "loc"  return -5
		off
		return 99

	#-- voices: each keeps its own key, unit, metre, bar accidentals and tuplet

	def _AbcDeclareVoice(pcV)
		_aW_ = This._Words(pcV)
		if len(_aW_) = 0  return ok
		_id_ = _aW_[1]
		_nm_ = This._Prop(pcV, "name")
		if _nm_ = ""  _nm_ = This._Prop(pcV, "nm") ok
		for _k_ = 1 to len(@aVDecl)
			if @aVDecl[_k_][1] = _id_
				if _nm_ != ""  @aVDecl[_k_][2] = _nm_ ok
				return
			ok
		next
		@aVDecl + [ _id_, _nm_, -1 ]

	def _AbcSwitchVoice(pcV)
		_aW_ = This._Words(pcV)
		if len(_aW_) = 0  return ok
		This._AbcDeclareVoice(pcV)
		_id_ = _aW_[1]
		if @nCv > 0
			if @aVS[@nCv][1] = _id_  return ok
			This._VSave()
		ok
		for _k_ = 1 to len(@aVS)
			if @aVS[_k_][1] = _id_
				This._VLoad(_k_)
				return
			ok
		next
		This._VNew(_id_)

	# the music before any V: belongs to the first voice declared, or to "1"
	def _AbcEnsureVoice()
		if @nCv > 0  return ok
		_id_ = "1"
		for _d_ in @aVDecl
			if _d_[1] != ""
				_id_ = _d_[1]
				exit
			ok
		next
		This._VNew(_id_)

	def _VNew(pcId)
		_nm_ = ""
		_pr_ = -1
		for _d_ in @aVDecl
			if _d_[1] = ""  _pr_ = _d_[3] ok                    # the tune's %%MIDI program
		next
		for _d_ in @aVDecl
			if _d_[1] = pcId
				_nm_ = _d_[2]
				if _d_[3] >= 0  _pr_ = _d_[3] ok
			ok
		next
		@aVS + [ pcId, _nm_, _pr_, @aDefaults[1], @aDefaults[2], @aDefaults[3], @aDefaults[4], [], 0, 1, 1, 0 ]
		This._VLoad(len(@aVS))

	def _VSave()
		@aVS[@nCv][4] = @aKey
		@aVS[@nCv][5] = @nL
		@aVS[@nCv][6] = @nMn
		@aVS[@nCv][7] = @nMd
		@aVS[@nCv][8] = @aAcc
		@aVS[@nCv][9] = @nTupLeft
		@aVS[@nCv][10] = @nTupF
		@aVS[@nCv][11] = @nBroken
		@aVS[@nCv][12] = @nLastIdx

	def _VLoad(pnK)
		@nCv = pnK
		@aKey = @aVS[pnK][4]
		@nL = @aVS[pnK][5]
		@nMn = @aVS[pnK][6]
		@nMd = @aVS[pnK][7]
		@aAcc = @aVS[pnK][8]
		@nTupLeft = @aVS[pnK][9]
		@nTupF = @aVS[pnK][10]
		@nBroken = @aVS[pnK][11]
		@nLastIdx = @aVS[pnK][12]

	#-- the music

	def _AbcMusic(pcLine)
		This._AbcEnsureVoice()
		_s_ = pcLine
		_n_ = len(_s_)
		_k_ = 1
		while _k_ <= _n_
			_c_ = _s_[_k_]
			if _c_ = "%"  exit ok
			if _c_ = " " or _c_ = char(9) or _c_ = "`" or _c_ = "\" or _c_ = "$" or _c_ = "y"
				_k_++
				loop
			ok
			if _c_ = char(34)
				_e_ = This._Find(_s_, char(34), _k_ + 1)
				This._Loss("ABC: chord symbols and annotations (in quotes) are not read")
				_k_ = _e_ + 1
				loop
			ok
			if _c_ = "!" or _c_ = "+"
				_e_ = This._Find(_s_, _c_, _k_ + 1)
				This._Loss("ABC: decorations (ornaments, dynamics, articulations) are not read")
				_k_ = _e_ + 1
				loop
			ok
			if substr(".~HLMOPSTuv", _c_) > 0
				This._Loss("ABC: decorations (ornaments, dynamics, articulations) are not read")
				_k_++
				loop
			ok
			if _c_ = "{"
				_e_ = This._Find(_s_, "}", _k_ + 1)
				This._Loss("ABC: grace notes are not read")
				_k_ = _e_ + 1
				loop
			ok
			if _c_ = "("
				if _k_ < _n_ and This._IsDigit(_s_[_k_ + 1])
					_k_ = This._AbcTuplet(_s_, _k_ + 1)
				else
					_k_++                                  # a slur: phrasing, not time
				ok
				loop
			ok
			if _c_ = ")"
				_k_++
				loop
			ok
			if _c_ = "["
				if _k_ + 2 <= _n_ and _s_[_k_ + 2] = ":" and This._IsLetter(_s_[_k_ + 1])
					_e_ = This._Find(_s_, "]", _k_ + 1)
					_f_ = upper(_s_[_k_ + 1])
					_val_ = ring_trim(substr(_s_, _k_ + 3, _e_ - _k_ - 3))
					This._AbcBodyField(_f_, _val_)
					_k_ = _e_ + 1
					loop
				ok
				if _k_ < _n_ and This._IsDigit(_s_[_k_ + 1])
					_k_ = This._AbcEnding(_s_, _k_ + 1)
					loop
				ok
				if _k_ < _n_ and _s_[_k_ + 1] = "|"
					_k_ = This._AbcBar(_s_, _k_)
					loop
				ok
				_k_ = This._AbcChord(_s_, _k_ + 1)
				loop
			ok
			if _c_ = "|" or _c_ = ":"
				_k_ = This._AbcBar(_s_, _k_)
				loop
			ok
			if _c_ = ">" or _c_ = "<"
				_k_ = This._AbcBroken(_s_, _k_)
				loop
			ok
			if _c_ = "-"
				if @nLastIdx > 0
					if @aItems[@nLastIdx][2] = "n"
						for _j_ = 1 to len(@aItems[@nLastIdx][5])  @aItems[@nLastIdx][5][_j_] = TRUE next
					ok
				ok
				_k_++
				loop
			ok
			if _c_ = "z" or _c_ = "x"
				_aL_ = This._AbcLength(_s_, _k_ + 1)
				This._AbcAdd("r", @nL * _aL_[1], [], [])
				_k_ = _aL_[2]
				loop
			ok
			if _c_ = "Z" or _c_ = "X"
				_j_ = _k_ + 1
				_d_ = ""
				while _j_ <= _n_ and This._IsDigit(_s_[_j_])
					_d_ += _s_[_j_]
					_j_++
				end
				_bars_ = 1
				if _d_ != ""  _bars_ = number(_d_) ok
				_bar_ = 1
				if @nMd > 0
					_bar_ = @nMn / @nMd
				else
					This._Loss("ABC: a whole-bar rest with no metre is read as a whole note")
				ok
				@aItems + [ @nCv, "r", _bars_ * _bar_, [], [], "" ]
				@nLastIdx = len(@aItems)
				_k_ = _j_
				loop
			ok
			if _c_ = "^" or _c_ = "_" or _c_ = "=" or This._IsNoteLetter(_c_)
				_aN_ = This._AbcNote(_s_, _k_)
				if len(_aN_) = 0
					This._Loss("ABC: a symbol that is no note was skipped ('" + _c_ + "')")
					_k_++
					loop
				ok
				This._AbcAdd("n", @nL * _aN_[2], [ _aN_[1] ], [ _aN_[3] ])
				_k_ = _aN_[4]
				loop
			ok
			This._Loss("ABC: a symbol this reader does not know was skipped ('" + _c_ + "')")
			_k_++
		end

	# a note or a rest, after its tuplet and any broken rhythm pending on it
	def _AbcAdd(pcKind, pnDur, paP, paT)
		_d_ = pnDur
		if @nTupLeft > 0
			_d_ *= @nTupF
			@nTupLeft--
		ok
		if @nBroken != 1
			_d_ *= @nBroken
			@nBroken = 1
		ok
		@aItems + [ @nCv, pcKind, _d_, paP, paT, "" ]
		@nLastIdx = len(@aItems)

	# one note from pnK: [ midi, length in units, tied, next position ], or []
	def _AbcNote(pcS, pnK)
		_k_ = pnK
		_n_ = len(pcS)
		_bAlt_ = FALSE
		_alt_ = 0
		if pcS[_k_] = "^" or pcS[_k_] = "_" or pcS[_k_] = "="
			_aP_ = This._AbcAccidental(pcS, _k_)
			_alt_ = _aP_[1]
			_k_ = _aP_[2]
			_bAlt_ = TRUE
		ok
		if _k_ > _n_  return [] ok
		_c_ = pcS[_k_]
		if NOT This._IsNoteLetter(_c_)  return [] ok
		_up_ = upper(_c_)
		_oct_ = 4
		if _c_ != _up_  _oct_ = 5 ok
		_k_++
		while _k_ <= _n_
			if pcS[_k_] = "'"
				_oct_++
			but pcS[_k_] = ","
				_oct_--
			else
				exit
			ok
			_k_++
		end
		_pk_ = _up_ + _oct_
		if _bAlt_
			_f_ = 0
			for _i_ = 1 to len(@aAcc)
				if @aAcc[_i_][1] = _pk_
					@aAcc[_i_][2] = _alt_
					_f_ = _i_
				ok
			next
			if _f_ = 0  @aAcc + [ _pk_, _alt_ ] ok
		else
			_alt_ = @aKey[This._LetterNo(_up_)]
			for _a_ in @aAcc
				if _a_[1] = _pk_  _alt_ = _a_[2] ok
			next
		ok
		_aSemi_ = [ 0, 2, 4, 5, 7, 9, 11 ]
		_midi_ = 12 * (_oct_ + 1) + _aSemi_[This._LetterNo(_up_)] + _alt_
		_aL_ = This._AbcLength(pcS, _k_)
		_k_ = _aL_[2]
		_bTie_ = FALSE
		if _k_ <= _n_
			if pcS[_k_] = "-"
				_bTie_ = TRUE
				_k_++
			ok
		ok
		return [ _midi_, _aL_[1], _bTie_, _k_ ]

	# ^ ^^ _ __ = and the microtones ^/ _/ ^3/4: [ semitones, next position ]
	def _AbcAccidental(pcS, pnK)
		_k_ = pnK
		_n_ = len(pcS)
		_c_ = pcS[_k_]
		if _c_ = "="  return [ 0, _k_ + 1 ] ok
		_sign_ = 1
		if _c_ = "_"  _sign_ = -1 ok
		_cnt_ = 0
		while _k_ <= _n_ and pcS[_k_] = _c_
			_cnt_++
			_k_++
		end
		if _cnt_ = 1 and _k_ <= _n_
			if This._IsDigit(pcS[_k_]) or pcS[_k_] = "/"
				_num_ = ""
				while _k_ <= _n_ and This._IsDigit(pcS[_k_])
					_num_ += pcS[_k_]
					_k_++
				end
				_den_ = ""
				if _k_ <= _n_ and pcS[_k_] = "/"
					_k_++
					while _k_ <= _n_ and This._IsDigit(pcS[_k_])
						_den_ += pcS[_k_]
						_k_++
					end
					if _den_ = ""  _den_ = "2" ok
				else
					_den_ = "1"
				ok
				if _num_ = ""  _num_ = "1" ok
				return [ _sign_ * number(_num_) / number(_den_), _k_ ]
			ok
		ok
		return [ _sign_ * _cnt_, _k_ ]

	# 2, 3/2, /, /2, //, 3// : [ multiple of the unit, next position ]
	def _AbcLength(pcS, pnK)
		_k_ = pnK
		_n_ = len(pcS)
		_num_ = ""
		while _k_ <= _n_ and This._IsDigit(pcS[_k_])
			_num_ += pcS[_k_]
			_k_++
		end
		_v_ = 1
		if _num_ != ""  _v_ = number(_num_) ok
		if _k_ <= _n_ and pcS[_k_] = "/"
			_k_++
			_den_ = ""
			while _k_ <= _n_ and This._IsDigit(pcS[_k_])
				_den_ += pcS[_k_]
				_k_++
			end
			if _den_ != ""
				_v_ = _v_ / number(_den_)
			else
				_d_ = 2
				while _k_ <= _n_ and pcS[_k_] = "/"
					_d_ *= 2
					_k_++
				end
				_v_ = _v_ / _d_
			ok
		ok
		return [ _v_, _k_ ]

	# [CEG]2 -- the chord lasts its first note's length times its own
	def _AbcChord(pcS, pnK)
		_k_ = pnK
		_n_ = len(pcS)
		_aP_ = []
		_aT_ = []
		_first_ = 0
		while _k_ <= _n_ and pcS[_k_] != "]"
			_c_ = pcS[_k_]
			if _c_ = " "
				_k_++
				loop
			ok
			if _c_ = "!" or _c_ = "+"
				_k_ = This._Find(pcS, _c_, _k_ + 1) + 1
				This._Loss("ABC: decorations (ornaments, dynamics, articulations) are not read")
				loop
			ok
			_aN_ = This._AbcNote(pcS, _k_)
			if len(_aN_) = 0
				This._Loss("ABC: a symbol that is no note was skipped inside a chord ('" + _c_ + "')")
				_k_++
				loop
			ok
			_aP_ + _aN_[1]
			_aT_ + _aN_[3]
			if _first_ = 0  _first_ = _aN_[2] ok
			_k_ = _aN_[4]
		end
		_k_++
		_aL_ = This._AbcLength(pcS, _k_)
		_k_ = _aL_[2]
		if _k_ <= _n_
			if pcS[_k_] = "-"
				for _j_ = 1 to len(_aT_)  _aT_[_j_] = TRUE next
				_k_++
			ok
		ok
		if len(_aP_) = 0  return _k_ ok
		This._AbcAdd("n", @nL * _first_ * _aL_[1], _aP_, _aT_)
		return _k_

	# (3 (p:q:r -- the next r notes take q/p of their length
	def _AbcTuplet(pcS, pnK)
		_aF_ = [ "", "", "" ]
		_i_ = 1
		_k_ = pnK
		_n_ = len(pcS)
		while _k_ <= _n_
			if This._IsDigit(pcS[_k_])
				_aF_[_i_] += pcS[_k_]
			but pcS[_k_] = ":" and _i_ < 3
				_i_++
			else
				exit
			ok
			_k_++
		end
		_p_ = number(_aF_[1])
		if _p_ < 2  return _k_ ok
		_q_ = 0
		if _aF_[2] != ""  _q_ = number(_aF_[2]) ok
		if _q_ = 0
			switch _p_
			on 2  _q_ = 3
			on 3  _q_ = 2
			on 4  _q_ = 3
			on 6  _q_ = 2
			on 8  _q_ = 3
			other
				_q_ = 2
				if @nMn > 3 and @nMn % 3 = 0  _q_ = 3 ok    # compound time
			off
		ok
		_r_ = _p_
		if _aF_[3] != ""  _r_ = number(_aF_[3]) ok
		@nTupLeft = _r_
		@nTupF = _q_ / _p_
		return _k_

	# > < >> << : the note before and the note after share their two lengths
	def _AbcBroken(pcS, pnK)
		_c_ = pcS[pnK]
		_k_ = pnK
		_cnt_ = 0
		while _k_ <= len(pcS) and pcS[_k_] = _c_
			_cnt_++
			_k_++
		end
		_short_ = 1 / pow(2, _cnt_)
		_long_ = 2 - _short_
		if @nLastIdx = 0
			This._Loss("ABC: a broken rhythm with no note before it is ignored")
			return _k_
		ok
		if _c_ = ">"
			@aItems[@nLastIdx][3] *= _long_
			@nBroken = _short_
		else
			@aItems[@nLastIdx][3] *= _short_
			@nBroken = _long_
		ok
		return _k_

	# | || |] [| |: :| :: :|: -- and an ending straight after, as in :|2
	def _AbcBar(pcS, pnK)
		_k_ = pnK
		_n_ = len(pcS)
		_t_ = ""
		while _k_ <= _n_
			_c_ = pcS[_k_]
			if _c_ = "|" or _c_ = ":" or (_c_ = "[" and _t_ = "") or (_c_ = "]" and _t_ != "")
				_t_ += _c_
				_k_++
				if _c_ = "]"  exit ok
			else
				exit
			ok
		end
		_p1_ = substr(_t_, "|")
		_bEnd_ = FALSE
		_bStart_ = FALSE
		if _p1_ = 0
			if substr(_t_, "::") > 0
				_bEnd_ = TRUE
				_bStart_ = TRUE
			ok
		else
			if substr(left(_t_, _p1_), ":") > 0  _bEnd_ = TRUE ok
			_pl_ = 0
			for _j_ = 1 to len(_t_)
				if _t_[_j_] = "|"  _pl_ = _j_ ok
			next
			if substr(substr(_t_, _pl_, len(_t_) - _pl_ + 1), ":") > 0  _bStart_ = TRUE ok
		ok
		_bFinal_ = (substr(_t_, "||") > 0 or substr(_t_, "|]") > 0 or substr(_t_, "[|") > 0)
		@aItems + [ @nCv, "b", 0, [], [], [ _bEnd_, _bStart_, _bFinal_ ] ]
		@aAcc = []
		if _k_ <= _n_
			if This._IsDigit(pcS[_k_])  _k_ = This._AbcEnding(pcS, _k_) ok
		ok
		return _k_

	# 1  2  1,3  1-3 : which passes play what follows
	def _AbcEnding(pcS, pnK)
		_k_ = pnK
		_n_ = len(pcS)
		_aN_ = []
		_d_ = ""
		_from_ = 0
		while _k_ <= _n_
			_c_ = pcS[_k_]
			if This._IsDigit(_c_)
				_d_ += _c_
			but _c_ = ","
				if _d_ != ""  _aN_ + number(_d_) ok
				_d_ = ""
			but _c_ = "-"
				_from_ = number(_d_)
				_d_ = ""
			else
				exit
			ok
			_k_++
		end
		if _d_ != ""
			if _from_ > 0
				for _j_ = _from_ to number(_d_)  _aN_ + _j_ next
			else
				_aN_ + number(_d_)
			ok
		ok
		@aItems + [ @nCv, "e", 0, [], [], _aN_ ]
		return _k_

	#-- the performance: repeats played out, ties joined, one score

	def _AbcScore()
		_aOut_ = []          # [ sortKey, beat, beats, hz, inst, vel, stroke, hzEnd ]
		_nSeq_ = 0
		for _v_ = 1 to len(@aVS)
			_inst_ = This._AbcInstrument(@aVS[_v_][2], @aVS[_v_][3])
			@aVoicesRead + [ @aVS[_v_][1], _inst_ ]
			_aF_ = This._AbcPlayed(_v_)
			_t_ = 0
			_aOpen_ = []     # [ midi, index in _aOut_ ] tied into what comes next
			for _it_ in _aF_
				if _it_[2] = "r"
					if len(_aOpen_) > 0
						This._Loss("ABC: a tie leads to a rest; the tied note simply ends")
						_aOpen_ = []
					ok
					_t_ += _it_[3]
					loop
				ok
				_aNext_ = []
				_aUsed_ = []
				for _j_ = 1 to len(_it_[4])
					_m_ = _it_[4][_j_]
					_ix_ = 0
					for _o_ = 1 to len(_aOpen_)
						if fabs(_aOpen_[_o_][1] - _m_) < 0.001 and ring_find(_aUsed_, _o_) = 0
							_ix_ = _aOpen_[_o_][2]
							_aUsed_ + _o_
							exit
						ok
					next
					if _ix_ > 0
						_aOut_[_ix_][3] += _it_[3] * 4
					else
						_nSeq_++
						_aOut_ + [ _t_ * 4 * 1000000 + _nSeq_, _t_ * 4, _it_[3] * 4,
						           440 * pow(2, (_m_ - 69) / 12), _inst_, 0.8, "", 0 ]
						_ix_ = len(_aOut_)
					ok
					if _it_[5][_j_]  _aNext_ + [ _m_, _ix_ ] ok
				next
				if len(_aUsed_) < len(_aOpen_)
					This._Loss("ABC: a tie leads to a different note; the two are read as two notes")
				ok
				_aOpen_ = _aNext_
				_t_ += _it_[3]
			next
		next
		_q_ = @nQ
		if _q_ = 0  _q_ = 120 ok
		return This._ScoreOf(_aOut_, _q_)

	# the voice's items in the order they are PLAYED: |: :| and endings
	def _AbcPlayed(pnV)
		_aSrc_ = []
		for _it_ in @aItems
			if _it_[1] = pnV  _aSrc_ + _it_ ok
		next
		_aOut_ = []
		_i_ = 1
		_start_ = 1
		_pass_ = 1
		_bSkip_ = FALSE
		_bInEnding_ = FALSE
		_guard_ = 0
		_n_ = len(_aSrc_)
		while _i_ <= _n_
			_guard_++
			if _guard_ > 200000
				This._Loss("ABC: the repeats do not resolve; the tune is cut where they loop")
				exit
			ok
			_it_ = _aSrc_[_i_]
			if _it_[2] = "b"
				_bEnd_ = _it_[6][1]
				_bStart_ = _it_[6][2]
				_bFinal_ = _it_[6][3]
				if _bEnd_ and NOT _bSkip_
					if _pass_ = 1
						_pass_ = 2
						_i_ = _start_
						loop
					ok
					_pass_ = 1
					_bInEnding_ = FALSE
					_start_ = _i_ + 1          # the next repeat begins after this one
				ok
				if _bStart_
					_start_ = _i_ + 1
					_pass_ = 1
					_bSkip_ = FALSE
					_bInEnding_ = FALSE
				ok
				if _bFinal_ and _bInEnding_
					_pass_ = 1
					_bInEnding_ = FALSE
					_bSkip_ = FALSE
				ok
				_i_++
				loop
			ok
			if _it_[2] = "e"
				if ring_find(_it_[6], _pass_) > 0
					_bSkip_ = FALSE
					if _pass_ > 1  _bInEnding_ = TRUE ok
				else
					_bSkip_ = TRUE
				ok
				_i_++
				loop
			ok
			if NOT _bSkip_  _aOut_ + _it_ ok
			_i_++
		end
		return _aOut_

	def _AbcInstrument(pcName, pnProg)
		_nm_ = lower(ring_trim(pcName))
		if _nm_ != ""
			for _p_ in StzSoundGmTable()
				if _p_[1] = _nm_  return _nm_ ok
			next
		ok
		if pnProg >= 0
			_i_ = StzSoundGmInstrument(pnProg)
			if _i_ != ""  return _i_ ok
			This._Loss("ABC: GM program " + pnProg + " is no instrument here; the voice is read on the piano")
			return "piano"
		ok
		if _nm_ != ""
			This._Loss("ABC: a voice named '" + pcName + "' names no instrument here; it is read on the piano")
		ok
		return "piano"

	#== MusicXML (MU9) ==========================================================

	def FromMusicXMLFileQ(pcPath)
		This._MxReset()
		if NOT isString(pcPath) or NOT fexists(pcPath)
			return This._Refuse("FromMusicXMLFileQ: no file at '" + pcPath + "'")
		ok
		return This._FromMusicXML(read(pcPath))

	def FromMusicXMLQ(pcXml)
		This._MxReset()
		if NOT isString(pcXml) or ring_trim(pcXml) = ""
			return This._Refuse("MusicXML: the text is empty")
		ok
		return This._FromMusicXML(pcXml)

	def _MxReset()
		@aLosses = []
		@cLastError = ""
		@cTitle = ""
		@aVoicesRead = []
		@nQ = 0
		@aX = []

	def _FromMusicXML(pcX)
		if left(pcX, 2) = "PK"
			return This._Refuse("MusicXML: this is a compressed .mxl (a zip); unzip it and read the .musicxml inside")
		ok
		if NOT This._XmlParse(pcX)  return NULL ok
		_root_ = 0
		for _k_ = 1 to len(@aX)
			if @aX[_k_][3] = 0
				_root_ = _k_
				exit
			ok
		next
		if _root_ = 0  return This._Refuse("MusicXML: the text holds no element") ok
		_nm_ = @aX[_root_][1]
		if _nm_ = "score-timewise"
			return This._Refuse("MusicXML: score-timewise is not read; only score-partwise, the form nearly every program writes")
		ok
		if _nm_ != "score-partwise"
			return This._Refuse("MusicXML: the root is <" + _nm_ + ">, not <score-partwise>; this is not a MusicXML score")
		ok
		_w_ = This._XChild(_root_, "work")
		if _w_ > 0  @cTitle = This._XText(This._XChild(_w_, "work-title")) ok
		if @cTitle = ""  @cTitle = This._XText(This._XChild(_root_, "movement-title")) ok

		# the part list: [ id, instrument, [ [ instrument id, GM drum key ] ] ]
		_aPL_ = []
		_pl_ = This._XChild(_root_, "part-list")
		for _sp_ in This._XChildren(_pl_, "score-part")
			_aPL_ + This._MxScorePart(_sp_)
		next
		_aParts_ = This._XChildren(_root_, "part")
		if len(_aParts_) = 0  return This._Refuse("MusicXML: the score holds no <part>") ok

		# every part's measures: [ beats, items, forward, backward times, ending numbers, ending ends ]
		_aPM_ = []
		for _p_ in _aParts_
			_id_ = This._XAttr(_p_, "id")
			_info_ = [ _id_, "piano", [] ]
			for _q_ in _aPL_
				if _q_[1] = _id_  _info_ = _q_ ok
			next
			@nMxDiv = 0
			@nMxTrans = 0
			@nMxVel = 0.8
			_aM_ = []
			for _m_ in This._XChildren(_p_, "measure")
				_r_ = This._MxMeasure(_m_, _info_)
				if NOT isList(_r_)  return NULL ok
				_aM_ + _r_
			next
			_aPM_ + [ _info_, _aM_ ]
			@aVoicesRead + [ _id_, _info_[2] ]
		next
		_nMeas_ = len(_aPM_[1][2])
		for _pp_ in _aPM_
			if len(_pp_[2]) != _nMeas_
				This._Loss("MusicXML: the parts do not hold the same number of measures; each is read as far as it goes")
			ok
		next
		# one length per measure, the longest any part reached
		_aLen_ = []
		for _k_ = 1 to _nMeas_
			_l_ = 0
			for _pp_ in _aPM_
				if _k_ <= len(_pp_[2])
					if _pp_[2][_k_][1] > _l_  _l_ = _pp_[2][_k_][1] ok
				ok
			next
			_aLen_ + _l_
		next
		_aOrder_ = This._MxPlayed(_aPM_[1][2])
		_aOut_ = []
		_nSeq_ = 0
		for _pp_ in _aPM_
			_t_ = 0
			_aOpen_ = []          # [ midi, voice, index in _aOut_ ]
			for _k_ in _aOrder_
				if _k_ <= len(_pp_[2])
					for _it_ in _pp_[2][_k_][2]
						_at_ = _t_ + _it_[1]
						if _it_[4] != ""
							_nSeq_++
							_aOut_ + [ _at_ * 1000000 + _nSeq_, _at_, _it_[2], 0, This._MxDrumOf(_pp_[1][2], _it_[4]),
							           _it_[8], _it_[4], 0 ]
							loop
						ok
						_ix_ = 0
						if _it_[6]
							for _o_ = 1 to len(_aOpen_)
								if fabs(_aOpen_[_o_][1] - _it_[3]) < 0.001 and _aOpen_[_o_][2] = _it_[7]
									_ix_ = _aOpen_[_o_][3]
									del(_aOpen_, _o_)
									exit
								ok
							next
						ok
						if _ix_ > 0
							_aOut_[_ix_][3] = _at_ + _it_[2] - _aOut_[_ix_][2]
						else
							_nSeq_++
							_aOut_ + [ _at_ * 1000000 + _nSeq_, _at_, _it_[2], 440 * pow(2, (_it_[3] - 69) / 12),
							           _pp_[1][2], _it_[8], "", 0 ]
							_ix_ = len(_aOut_)
						ok
						if _it_[5]  _aOpen_ + [ _it_[3], _it_[7], _ix_ ] ok
					next
				ok
				_t_ += _aLen_[_k_]
			next
			if len(_aOpen_) > 0
				This._Loss("MusicXML: a tie starts and never stops; the note ends where it was written to")
			ok
		next
		_q_ = @nQ
		if _q_ = 0  _q_ = 120 ok
		return This._ScoreOf(_aOut_, _q_)

	# a <score-part>: its instrument, by name first, then by its GM program
	def _MxScorePart(pnSp)
		_id_ = This._XAttr(pnSp, "id")
		_aNames_ = [ This._XText(This._XChild(pnSp, "part-name")) ]
		_aUnp_ = []
		_prog_ = -1
		for _si_ in This._XChildren(pnSp, "score-instrument")
			_aNames_ + This._XText(This._XChild(_si_, "instrument-name"))
		next
		for _mi_ in This._XChildren(pnSp, "midi-instrument")
			_c_ = This._XChild(_mi_, "midi-program")
			if _c_ > 0 and _prog_ < 0  _prog_ = number(This._XText(_c_)) - 1 ok
			_u_ = This._XChild(_mi_, "midi-unpitched")
			if _u_ > 0  _aUnp_ + [ This._XAttr(_mi_, "id"), number(This._XText(_u_)) - 1 ] ok
		next
		_inst_ = ""
		for _n_ in _aNames_
			_l_ = lower(ring_trim(_n_))
			if _inst_ = "" and _l_ != ""
				for _g_ in StzSoundGmTable()
					if _g_[1] = _l_  _inst_ = _l_ ok
				next
			ok
		next
		if _inst_ = "" and _prog_ >= 0
			_inst_ = StzSoundGmInstrument(_prog_)
			if _inst_ = ""
				This._Loss("MusicXML: GM program " + (_prog_ + 1) + " (as MusicXML counts) is no instrument here; the part is read on the piano")
			ok
		ok
		if _inst_ = ""
			if ring_trim(_aNames_[1]) != "" and len(_aUnp_) = 0
				This._Loss("MusicXML: a part named '" + ring_trim(_aNames_[1]) + "' names no instrument here; it is read on the piano")
			ok
			_inst_ = "piano"
			if len(_aUnp_) > 0  _inst_ = "drumkit" ok
		ok
		return [ _id_, _inst_, _aUnp_ ]

	# a stroke's drum: the part's, when the part IS a drum; else by the stroke
	def _MxDrumOf(pcInst, pcStroke)
		if ring_find([ "darbouka", "bendir", "drumkit" ], pcInst) > 0  return pcInst ok
		if ring_find([ "dum", "tak", "ka" ], pcStroke) > 0  return "darbouka" ok
		return "drumkit"

	# one <measure>: [ beats, items, forward repeat, backward times, ending
	# numbers begun here, an ending closed here ]; an item is
	# [ start, beats, midi, stroke, tie start, tie stop, voice, velocity ]
	def _MxMeasure(pnM, paInfo)
		_aIt_ = []
		# the position is counted in WHOLE divisions and divided once: three
		# triplet thirds of 8/24 summed as beats are 3.0000000000000004, not 3
		_pB_ = 0          # beats before the last change of divisions
		_pU_ = 0          # divisions since it
		_max_ = 0
		_last_ = 0
		_bFwd_ = FALSE
		_nBack_ = 0
		_aEnd_ = []
		_bEndStop_ = FALSE
		for _c_ in @aX[pnM][4]
			_nm_ = @aX[_c_][1]
			switch _nm_
			on "attributes"
				_d_ = This._XChild(_c_, "divisions")
				if _d_ > 0
					if @nMxDiv > 0  _pB_ += _pU_ / @nMxDiv ok
					_pU_ = 0
					@nMxDiv = number(This._XText(_d_))
				ok
				_tr_ = This._XChild(_c_, "transpose")
				if _tr_ > 0
					@nMxTrans = This._Num0(This._XText(This._XChild(_tr_, "chromatic"))) +
					            12 * This._Num0(This._XText(This._XChild(_tr_, "octave-change")))
				ok
			on "note"
				if This._XChild(_c_, "grace") > 0
					This._Loss("MusicXML: grace notes are not read")
					loop
				ok
				if This._XChild(_c_, "cue") > 0  loop ok            # a cue is shown, never played
				_du_ = This._XChild(_c_, "duration")
				if _du_ = 0  loop ok
				if @nMxDiv <= 0
					This._Refuse("MusicXML: a note has a duration before any <divisions> says what a quarter note is")
					return NULL
				ok
				_units_ = number(This._XText(_du_))
				_len_ = _units_ / @nMxDiv
				_bChord_ = (This._XChild(_c_, "chord") > 0)
				_st_ = _pB_ + _pU_ / @nMxDiv
				if _bChord_  _st_ = _last_ ok
				if NOT _bChord_
					_last_ = _st_
					_pU_ += _units_
				ok
				if _st_ + _len_ > _max_  _max_ = _st_ + _len_ ok
				if This._XChild(_c_, "rest") > 0  loop ok
				_vel_ = @nMxVel
				_dy_ = This._XAttr(_c_, "dynamics")
				if _dy_ != ""  _vel_ = This._MxVelocity(number(_dy_)) ok
				_voice_ = This._XText(This._XChild(_c_, "voice"))
				if _voice_ = ""  _voice_ = "1" ok
				_bTs_ = FALSE
				_bTe_ = FALSE
				for _ti_ in This._XChildren(_c_, "tie")
					if This._XAttr(_ti_, "type") = "start"  _bTs_ = TRUE ok
					if This._XAttr(_ti_, "type") = "stop"   _bTe_ = TRUE ok
				next
				This._MxNotations(_c_)
				_pi_ = This._XChild(_c_, "pitch")
				if _pi_ > 0
					_ln_ = This._LetterNo(This._XText(This._XChild(_pi_, "step")))
					if _ln_ = 0
						This._Loss("MusicXML: a pitch with no step A to G was skipped")
						loop
					ok
					_aSemi_ = [ 0, 2, 4, 5, 7, 9, 11 ]
					_alt_ = 0
					_al_ = This._XChild(_pi_, "alter")
					if _al_ > 0  _alt_ = number(This._XText(_al_)) ok
					_oct_ = number(This._XText(This._XChild(_pi_, "octave")))
					_midi_ = 12 * (_oct_ + 1) + _aSemi_[_ln_] + _alt_ + @nMxTrans
					_aIt_ + [ _st_, _len_, _midi_, "", _bTs_, _bTe_, _voice_, _vel_ ]
					loop
				ok
				if This._XChild(_c_, "unpitched") > 0
					_key_ = -1
					_iid_ = This._XAttr(This._XChild(_c_, "instrument"), "id")
					for _u_ in paInfo[3]
						if _key_ < 0 and (_iid_ = "" or _u_[1] = _iid_)  _key_ = _u_[2] ok
					next
					_sk_ = ""
					if _key_ >= 0  _sk_ = This._GmStroke(_key_) ok
					if _sk_ = ""
						This._Loss("MusicXML: an unpitched note with no MIDI key a stroke answers to is dropped")
						loop
					ok
					_aIt_ + [ _st_, _len_, 0, _sk_, FALSE, FALSE, _voice_, _vel_ ]
				ok
			on "backup"
				_pU_ -= This._MxUnits(_c_)
			on "forward"
				_pU_ += This._MxUnits(_c_)
				if @nMxDiv > 0
					if _pB_ + _pU_ / @nMxDiv > _max_  _max_ = _pB_ + _pU_ / @nMxDiv ok
				ok
			on "direction"
				_so_ = This._XChild(_c_, "sound")
				_bT_ = FALSE
				if _so_ > 0  _bT_ = This._MxSound(_so_) ok
				if NOT _bT_
					for _dt_ in This._XChildren(_c_, "direction-type")
						_me_ = This._XChild(_dt_, "metronome")
						if _me_ > 0  This._MxMetronome(_me_) ok
					next
				ok
			on "sound"
				This._MxSound(_c_)
			on "barline"
				_rp_ = This._XChild(_c_, "repeat")
				if _rp_ > 0
					if This._XAttr(_rp_, "direction") = "forward"
						_bFwd_ = TRUE
					else
						_nBack_ = 2
						_tm_ = This._XAttr(_rp_, "times")
						if _tm_ != ""  _nBack_ = number(_tm_) ok
					ok
				ok
				_en_ = This._XChild(_c_, "ending")
				if _en_ > 0
					_ty_ = This._XAttr(_en_, "type")
					if _ty_ = "start"
						_aEnd_ = This._MxNumbers(This._XAttr(_en_, "number"))
					else
						_bEndStop_ = TRUE
					ok
				ok
			on "harmony"
				This._Loss("MusicXML: chord symbols (<harmony>) are not read")
			off
		next
		if @nMxDiv > 0
			if _pB_ + _pU_ / @nMxDiv > _max_  _max_ = _pB_ + _pU_ / @nMxDiv ok
		ok
		return [ _max_, _aIt_, _bFwd_, _nBack_, _aEnd_, _bEndStop_ ]

	def _MxUnits(pnC)
		_d_ = This._XChild(pnC, "duration")
		if _d_ = 0  return 0 ok
		return number(This._XText(_d_))

	# MusicXML's dynamics are a percentage of forte, and forte is MIDI 90
	def _MxVelocity(pnDyn)
		_v_ = pnDyn * 90 / 100 / 127
		if _v_ > 1  _v_ = 1 ok
		if _v_ < 1 / 127  _v_ = 1 / 127 ok
		return _v_

	# <sound>: tempo, dynamics, and the jumps a score does not follow. TRUE when it set a tempo
	def _MxSound(pnS)
		_bT_ = FALSE
		_t_ = This._XAttr(pnS, "tempo")
		if _t_ != ""
			This._MxTempo(number(_t_))
			_bT_ = TRUE
		ok
		_d_ = This._XAttr(pnS, "dynamics")
		if _d_ != ""  @nMxVel = This._MxVelocity(number(_d_)) ok
		for _j_ in [ "dacapo", "dalsegno", "tocoda", "fine", "segno", "coda" ]
			if This._XAttr(pnS, _j_) != ""
				This._Loss("MusicXML: jumps (da capo, dal segno, coda, fine) are not followed; the score is read as written, repeats played")
			ok
		next
		return _bT_

	# <metronome>: a beat unit (dotted or not) and a count a minute, in quarters
	def _MxMetronome(pnM)
		_u_ = This._XText(This._XChild(pnM, "beat-unit"))
		_pm_ = This._XText(This._XChild(pnM, "per-minute"))
		if _pm_ = ""  return ok
		_q_ = 1
		switch _u_
		on "whole"    _q_ = 4
		on "half"     _q_ = 2
		on "quarter"  _q_ = 1
		on "eighth"   _q_ = 0.5
		on "16th"     _q_ = 0.25
		off
		if This._XChild(pnM, "beat-unit-dot") > 0  _q_ *= 1.5 ok
		This._MxTempo(number(_pm_) * _q_)

	def _MxTempo(pnQ)
		if pnQ <= 0  return ok
		if @nQ = 0
			@nQ = pnQ
		but fabs(@nQ - pnQ) > 0.001
			This._Loss("MusicXML: the tempo changes during the score; a score has one tempo, and keeps the first (" + This._Num(@nQ) + " BPM)")
		ok

	# what a note carries that a score does not hold -- counted, once each
	def _MxNotations(pnNote)
		if This._XChild(pnNote, "lyric") > 0  This._Loss("MusicXML: lyrics are not read") ok
		_n_ = This._XChild(pnNote, "notations")
		if _n_ = 0  return ok
		for _c_ in @aX[_n_][4]
			_nm_ = @aX[_c_][1]
			if _nm_ = "glissando" or _nm_ = "slide"
				This._Loss("MusicXML: glissandos and slides are read as their starting pitch")
			but ring_find([ "ornaments", "articulations", "technical", "fermata", "arpeggiate", "dynamics" ], _nm_) > 0
				This._Loss("MusicXML: ornaments, articulations and fermatas are not read")
			ok
		next

	# "1", "1, 2", "1,2" -> [ 1, 2 ]
	def _MxNumbers(pc)
		_a_ = []
		_d_ = ""
		for _k_ = 1 to len(pc)
			if This._IsDigit(pc[_k_])
				_d_ += pc[_k_]
			else
				if _d_ != ""  _a_ + number(_d_) ok
				_d_ = ""
			ok
		next
		if _d_ != ""  _a_ + number(_d_) ok
		return _a_

	# the measures in the order they are PLAYED: forward and backward repeats
	# (times="n" honoured), endings played on their pass and skipped on others
	def _MxPlayed(paM)
		_n_ = len(paM)
		# which measures lie inside which ending
		_aIn_ = list(_n_)
		_cur_ = []
		for _k_ = 1 to _n_
			if len(paM[_k_][5]) > 0  _cur_ = paM[_k_][5] ok
			_aIn_[_k_] = _cur_
			if paM[_k_][6]  _cur_ = [] ok
		next
		_aO_ = []
		_i_ = 1
		_start_ = 1
		_pass_ = 1
		_guard_ = 0
		while _i_ <= _n_
			_guard_++
			if _guard_ > 100000
				This._Loss("MusicXML: the repeats do not resolve; the score is cut where they loop")
				exit
			ok
			if paM[_i_][3] and _i_ != _start_
				_start_ = _i_
				_pass_ = 1
			ok
			if len(_aIn_[_i_]) > 0 and ring_find(_aIn_[_i_], _pass_) = 0
				_i_++
				loop
			ok
			_aO_ + _i_
			if paM[_i_][4] > 0
				if _pass_ < paM[_i_][4]
					_pass_++
					_i_ = _start_
					loop
				ok
				_pass_ = 1
				_start_ = _i_ + 1
			but paM[_i_][6] and len(_aIn_[_i_]) > 0 and _pass_ > 1
				# the last ending, played: the repeat is over
				_pass_ = 1
				_start_ = _i_ + 1
			ok
			_i_++
		end
		return _aO_

	#-- a small XML reader: elements, attributes, text, entities; comments,
	#   processing instructions, a DOCTYPE and CDATA understood

	def _XmlParse(pcX)
		@aX = []
		_aSt_ = []
		_n_ = len(pcX)
		_k_ = 1
		_tx_ = ""
		while _k_ <= _n_
			_c_ = pcX[_k_]
			if _c_ != "<"
				_tx_ += _c_
				_k_++
				loop
			ok
			if len(_aSt_) > 0 and _tx_ != ""
				@aX[_aSt_[len(_aSt_)]][5] += This._XmlDecode(_tx_)
			ok
			_tx_ = ""
			if substr(pcX, _k_, 4) = "<!--"
				_e_ = This._FindStr(pcX, "-->", _k_ + 4)
				if _e_ = 0  return This._XmlBad("a comment never closes") ok
				_k_ = _e_ + 3
				loop
			ok
			if substr(pcX, _k_, 9) = "<![CDATA["
				_e_ = This._FindStr(pcX, "]]>", _k_ + 9)
				if _e_ = 0  return This._XmlBad("a CDATA section never closes") ok
				if len(_aSt_) > 0  @aX[_aSt_[len(_aSt_)]][5] += substr(pcX, _k_ + 9, _e_ - _k_ - 9) ok
				_k_ = _e_ + 3
				loop
			ok
			if substr(pcX, _k_, 2) = "<?"
				_e_ = This._FindStr(pcX, "?>", _k_ + 2)
				if _e_ = 0  return This._XmlBad("a processing instruction never closes") ok
				_k_ = _e_ + 2
				loop
			ok
			if substr(pcX, _k_, 2) = "<!"
				# a DOCTYPE, with an internal subset in [ ] if there is one
				_dep_ = 0
				_e_ = _k_ + 2
				while _e_ <= _n_
					if pcX[_e_] = "["  _dep_++ ok
					if pcX[_e_] = "]"  _dep_-- ok
					if pcX[_e_] = ">" and _dep_ <= 0  exit ok
					_e_++
				end
				_k_ = _e_ + 1
				loop
			ok
			# a tag: find its end, outside quoted attribute values
			_e_ = _k_ + 1
			_qc_ = ""
			while _e_ <= _n_
				_ch_ = pcX[_e_]
				if _qc_ != ""
					if _ch_ = _qc_  _qc_ = "" ok
				but _ch_ = char(34) or _ch_ = "'"
					_qc_ = _ch_
				but _ch_ = ">"
					exit
				ok
				_e_++
			end
			if _e_ > _n_  return This._XmlBad("a tag never closes") ok
			_tag_ = substr(pcX, _k_ + 1, _e_ - _k_ - 1)
			_k_ = _e_ + 1
			if left(_tag_, 1) = "/"
				_nm_ = ring_trim(substr(_tag_, 2, len(_tag_) - 1))
				if len(_aSt_) = 0  return This._XmlBad("</" + _nm_ + "> closes nothing") ok
				_top_ = _aSt_[len(_aSt_)]
				if @aX[_top_][1] != _nm_
					return This._XmlBad("</" + _nm_ + "> closes <" + @aX[_top_][1] + ">")
				ok
				del(_aSt_, len(_aSt_))
				loop
			ok
			_bSelf_ = (right(_tag_, 1) = "/")
			if _bSelf_  _tag_ = left(_tag_, len(_tag_) - 1) ok
			_aT_ = This._XmlTag(_tag_)
			_par_ = 0
			if len(_aSt_) > 0
				_par_ = _aSt_[len(_aSt_)]
			else
				for _x_ in @aX
					if _x_[3] = 0  return This._XmlBad("a second root element <" + _aT_[1] + ">") ok
				next
			ok
			@aX + [ _aT_[1], _aT_[2], _par_, [], "" ]
			_ix_ = len(@aX)
			if _par_ > 0  @aX[_par_][4] + _ix_ ok
			if NOT _bSelf_  _aSt_ + _ix_ ok
		end
		if len(_aSt_) > 0  return This._XmlBad("<" + @aX[_aSt_[len(_aSt_)]][1] + "> is never closed") ok
		if len(@aX) = 0  return This._XmlBad("there is no element at all") ok
		return TRUE

	def _XmlBad(pc)
		This._Refuse("MusicXML: not well-formed XML -- " + pc)
		return FALSE

	# "note default-x='12' dynamics=\"80\"" -> [ "note", [ [ "default-x", "12" ], ... ] ]
	def _XmlTag(pcT)
		_n_ = len(pcT)
		_k_ = 1
		_nm_ = ""
		while _k_ <= _n_ and NOT This._IsSpace(pcT[_k_])
			_nm_ += pcT[_k_]
			_k_++
		end
		_aA_ = []
		while _k_ <= _n_
			while _k_ <= _n_ and This._IsSpace(pcT[_k_])  _k_++ end
			if _k_ > _n_  exit ok
			_an_ = ""
			while _k_ <= _n_ and pcT[_k_] != "=" and NOT This._IsSpace(pcT[_k_])
				_an_ += pcT[_k_]
				_k_++
			end
			while _k_ <= _n_ and (pcT[_k_] = "=" or This._IsSpace(pcT[_k_]))  _k_++ end
			if _k_ > _n_  exit ok
			_q_ = pcT[_k_]
			_av_ = ""
			if _q_ = char(34) or _q_ = "'"
				_k_++
				while _k_ <= _n_ and pcT[_k_] != _q_
					_av_ += pcT[_k_]
					_k_++
				end
				_k_++
			ok
			_aA_ + [ _an_, This._XmlDecode(_av_) ]
		end
		return [ _nm_, _aA_ ]

	def _XmlDecode(pc)
		if substr(pc, "&") = 0  return pc ok
		_s_ = ""
		_k_ = 1
		_n_ = len(pc)
		while _k_ <= _n_
			if pc[_k_] != "&"
				_s_ += pc[_k_]
				_k_++
				loop
			ok
			_e_ = This._FindStr(pc, ";", _k_ + 1)
			if _e_ = 0
				_s_ += "&"
				_k_++
				loop
			ok
			_ent_ = substr(pc, _k_ + 1, _e_ - _k_ - 1)
			switch _ent_
			on "amp"   _s_ += "&"
			on "lt"    _s_ += "<"
			on "gt"    _s_ += ">"
			on "quot"  _s_ += char(34)
			on "apos"  _s_ += "'"
			other
				_cp_ = -1
				if left(_ent_, 2) = "#x" or left(_ent_, 2) = "#X"
					_cp_ = This._Hex(substr(_ent_, 3, len(_ent_) - 2))
				but left(_ent_, 1) = "#"
					_cp_ = number(substr(_ent_, 2, len(_ent_) - 1))
				ok
				if _cp_ >= 0
					_s_ += This._Utf8(_cp_)
				else
					_s_ += "&" + _ent_ + ";"
				ok
			off
			_k_ = _e_ + 1
		end
		return _s_

	def _Hex(pc)
		_v_ = 0
		for _k_ = 1 to len(pc)
			_d_ = substr("0123456789abcdef", lower(pc[_k_])) - 1
			if _d_ < 0  return -1 ok
			_v_ = _v_ * 16 + _d_
		next
		return _v_

	def _Utf8(pnCp)
		if pnCp < 128  return char(pnCp) ok
		if pnCp < 2048  return char(192 + floor(pnCp / 64)) + char(128 + pnCp % 64) ok
		if pnCp < 65536
			return char(224 + floor(pnCp / 4096)) + char(128 + floor(pnCp / 64) % 64) + char(128 + pnCp % 64)
		ok
		return char(240 + floor(pnCp / 262144)) + char(128 + floor(pnCp / 4096) % 64) +
		       char(128 + floor(pnCp / 64) % 64) + char(128 + pnCp % 64)

	def _XChildren(pnI, pcName)
		_a_ = []
		if pnI <= 0  return _a_ ok
		for _c_ in @aX[pnI][4]
			if @aX[_c_][1] = pcName  _a_ + _c_ ok
		next
		return _a_

	def _XChild(pnI, pcName)
		if pnI <= 0  return 0 ok
		for _c_ in @aX[pnI][4]
			if @aX[_c_][1] = pcName  return _c_ ok
		next
		return 0

	def _XText(pnI)
		if pnI <= 0  return "" ok
		return ring_trim(@aX[pnI][5])

	def _XAttr(pnI, pcName)
		if pnI <= 0  return "" ok
		for _a_ in @aX[pnI][2]
			if _a_[1] = pcName  return _a_[2] ok
		next
		return ""

	def _FindStr(pcS, pcPat, pnFrom)
		_m_ = len(pcPat)
		for _k_ = pnFrom to len(pcS) - _m_ + 1
			if substr(pcS, _k_, _m_) = pcPat  return _k_ ok
		next
		return 0

	# a number, or 0 for an element that is absent or empty
	def _Num0(pc)
		if ring_trim(pc) = ""  return 0 ok
		return number(pc)

	def _IsSpace(pc)
		return pc = " " or pc = char(9) or pc = nl or pc = char(13)

	#== both: the rows become ONE stzSoundScore =================================

	def _ScoreOf(paOut, pnBpm)
		_a_ = sort(paOut, 1)
		_oS_ = new stzSoundScore("")
		_t_ = pnBpm
		if _t_ < 20 or _t_ > 400
			This._Loss("the tempo " + This._Num(_t_) + " BPM is outside a score's 20 to 400; it is kept at the nearest")
			if _t_ < 20  _t_ = 20 ok
			if _t_ > 400  _t_ = 400 ok
		ok
		_oS_.Tempo(_t_)
		for _o_ in _a_
			_oS_.On(_o_[5])
			_v_ = _o_[6]
			if _v_ < 1 / 127  _v_ = 1 / 127 ok
			if _v_ > 1  _v_ = 1 ok
			_oS_.SetVelocity(_v_)
			if _o_[7] != ""
				_oS_.StrokeAt(_o_[2], _o_[7], _o_[3])
			but _o_[8] > 0
				_oS_.GlideAt(_o_[2], _o_[4], _o_[8], _o_[3])
			else
				_oS_.NoteAt(_o_[2], _o_[4], _o_[3])
			ok
		next
		if _oS_.Refusals() > 0
			This._Loss("the score refused " + _oS_.Refusals() + " of the notes read; the last: " + _oS_.LastError())
		ok
		return _oS_

	#== small things ============================================================

	def _Refuse(pc)
		@cLastError = pc
		return NULL

	def _Loss(pc)
		if ring_find(@aLosses, pc) = 0  @aLosses + pc ok

	def _Cents(pnA, pnB)
		if pnA <= 0 or pnB <= 0  return 0 ok
		return 1200 * log(pnA / pnB) / log(2)

	def _Num(pn)
		return "" + (floor(pn * 1000 + 0.5) / 1000)

	def _Lines(pc)
		_a_ = []
		_w_ = ""
		for _k_ = 1 to len(pc)
			_c_ = pc[_k_]
			if _c_ = nl
				_a_ + _w_
				_w_ = ""
			but _c_ != char(13)
				_w_ += _c_
			ok
		next
		if _w_ != ""  _a_ + _w_ ok
		return _a_

	def _Words(pc)
		_a_ = []
		_w_ = ""
		_bQ_ = FALSE
		for _k_ = 1 to len(pc)
			_c_ = pc[_k_]
			if _c_ = char(34)  _bQ_ = NOT _bQ_ ok
			if (_c_ = " " or _c_ = char(9)) and NOT _bQ_
				if _w_ != ""  _a_ + _w_ ok
				_w_ = ""
			else
				_w_ += _c_
			ok
		next
		if _w_ != ""  _a_ + _w_ ok
		return _a_

	# name="oud" or name=oud, from a V: line
	def _Prop(pc, pcName)
		for _w_ in This._Words(pc)
			_e_ = substr(_w_, "=")
			if _e_ > 1
				if lower(left(_w_, _e_ - 1)) = pcName
					_v_ = substr(_w_, _e_ + 1, len(_w_) - _e_)
					_q_ = char(34)
					if left(_v_, 1) = _q_  _v_ = substr(_v_, 2, len(_v_) - 1) ok
					if right(_v_, 1) = _q_  _v_ = left(_v_, len(_v_) - 1) ok
					return _v_
				ok
			ok
		next
		return ""

	def _Fraction(pc)
		_v_ = ring_trim(pc)
		_s_ = substr(_v_, "/")
		if _s_ = 0  return number(_v_) ok
		_d_ = number(substr(_v_, _s_ + 1, len(_v_) - _s_))
		if _d_ = 0  return 0 ok
		return number(substr(_v_, 1, _s_ - 1)) / _d_

	def _Find(pcS, pcC, pnFrom)
		for _k_ = pnFrom to len(pcS)
			if pcS[_k_] = pcC  return _k_ ok
		next
		return len(pcS)

	def _IsDigit(pc)
		_a_ = ascii(pc)
		return _a_ >= 48 and _a_ <= 57

	def _IsLetter(pc)
		_a_ = ascii(pc)
		return (_a_ >= 65 and _a_ <= 90) or (_a_ >= 97 and _a_ <= 122)

	def _IsNoteLetter(pc)
		return substr("ABCDEFGabcdefg", pc) > 0

	def _LetterNo(pcL)
		switch upper(pcL)
		on "C"  return 1
		on "D"  return 2
		on "E"  return 3
		on "F"  return 4
		on "G"  return 5
		on "A"  return 6
		on "B"  return 7
		off
		return 0
