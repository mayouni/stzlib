#---------------------------------------------------------------------------#
#  STZSOUNDNOTATION -- a score becomes notation and a MIDI file (MU7)        #
#---------------------------------------------------------------------------#
#
#     oN = StzSoundNotationQ(oScore)
#     ? oN.ToABC("Rast study")                  # ABC 2.1 text
#     write("rast.musicxml", oN.ToMusicXML("Rast study"))
#     oN.ToMidiFile("rast.mid")                 # Standard MIDI File, type 1
#     ? oN.Losses()                             # what a format could not carry
#
# THE PLAN'S MU7 ROW "Score -> notation (ABC out, MusicXML out) and -> MIDI
# file". Notation is a RENDERING of the score (plan 1.2), never its source:
# each format below is written from the same stzSoundScore, and each says
# what it LOST, because a declared universe carries intonation no Western
# format was built for.
#
# QUARTER TONES are written in each format's own terms: ABC 2.1's "^/" and
# "_/", MusicXML's decimal <alter>-0.5</alter>. A pitch further than 5 cents
# from the nearest quarter tone -- slendro, a just-intoned Yaman -- is written
# at that quarter tone and COUNTED in Losses.
# MIDI has no quarter tones at all, so every pitched note carries a PITCH BEND
# on its own channel (channels rotate; the bend range is set to +-12 semitones
# so a kalangu's glide fits), and a glide is a ramp of bends. A note needing
# a channel when all fifteen are sounding is counted in Losses.
# STROKES go to MIDI's drum channel (General MIDI numbers); ABC and MusicXML
# here write pitched parts only, and say so in Losses.
#
# DURATIONS are rounded to a sixteenth of a beat's quarter (ABC L:1/16, and
# MusicXML divisions 4); a rounding larger than a hundredth of a beat is a loss.

func StzSoundNotationQ(poScore)
	return new stzSoundNotation(poScore)

# General MIDI programs (0-based), and what GM cannot name honestly
func StzSoundGmTable()
	return [ [ "piano", 0 ], [ "guitar", 24 ], [ "harp", 46 ], [ "bell", 14 ], [ "epiano", 4 ],
	         [ "brass", 61 ], [ "flute", 73 ], [ "oud", 24 ], [ "koto", 107 ], [ "kora", 46 ],
	         [ "metallophone", 11 ], [ "mezwed", 109 ], [ "zokra", 111 ], [ "kakaki", 56 ],
	         [ "sarewa", 73 ], [ "imzad", 110 ], [ "kalangu", 116 ], [ "darbouka", 116 ],
	         [ "bendir", 116 ], [ "drumkit", 116 ] ]

func StzSoundGmProgram(pcInst)
	for _p_ in StzSoundGmTable()
		if _p_[1] = pcInst  return _p_[2] ok
	next
	return 0

# MU8: a GM program back to an instrument -- the FIRST of this table's names
# that shares it ("" when none does). Twenty instruments on eleven programs,
# so the program alone cannot tell an oud from a guitar: the writer names the
# instrument in a text event beside each program change, and the reader
# prefers that name when there is one.
func StzSoundGmInstrument(pnProg)
	for _p_ in StzSoundGmTable()
		if _p_[2] = pnProg  return _p_[1] ok
	next
	return ""

class stzSoundNotation

	@oS = NULL
	@aLosses = []

	def init(poScore)
		@oS = poScore

	def Losses()
		return @aLosses

	#-- ABC 2.1 ---------------------------------------------------------------

	def ToABC(pcTitle)
		@aLosses = []
		_aV_ = This._Voices()
		_c_ = "X:1" + nl + "T:" + pcTitle + nl + "M:4/4" + nl + "L:1/16" + nl +
		      "Q:1/4=" + floor(@oS.TempoInBpm() + 0.5) + nl + "K:C" + nl
		_n_ = 0
		for _v_ in _aV_
			_n_++
			_c_ += "V:" + _n_ + " name=" + char(34) + _v_[1] + char(34) + nl
		next
		_n_ = 0
		for _v_ in _aV_
			_n_++
			_c_ += "[V:" + _n_ + "] " + This._AbcLine(_v_[2]) + nl
		next
		return _c_

	def _AbcLine(paSeg)
		_s_ = ""
		_t_ = 0
		_aAcc_ = []       # [ letterWithOctave, alter ] set in the current bar
		for _g_ in paSeg
			if _g_[1] > _t_
				_s_ += This._AbcSplit("z", _t_, _g_[1] - _t_, _aAcc_)
				_t_ = _g_[1]
			ok
			_tok_ = ""
			if len(_g_[3]) > 1  _tok_ += "[" ok
			for _p_ in _g_[3]
				_tok_ += This._AbcPitch(_p_, _aAcc_)
			next
			if len(_g_[3]) > 1  _tok_ += "]" ok
			_s_ += This._AbcSplit(_tok_, _t_, _g_[2], _aAcc_)
			_t_ += _g_[2]
		next
		# a voice that ends ON a barline closes that bar; it wrote "| |]", an
		# empty bar (seen when MU8 read a tune back)
		if right(_s_, 2) = "| "  return left(_s_, len(_s_) - 2) + "|]" ok
		return _s_ + " |]"

	# a token of `pnLen` sixteenths from `pnAt`, split and tied at barlines
	def _AbcSplit(pcTok, pnAt, pnLen, paAcc)
		_s_ = ""
		_at_ = pnAt
		_left_ = pnLen
		while _left_ > 0
			_room_ = 16 - (_at_ % 16)
			_take_ = _left_
			if _take_ > _room_  _take_ = _room_ ok
			_s_ += pcTok
			if _take_ != 1  _s_ += "" + _take_ ok
			_left_ -= _take_
			_at_ += _take_
			if _left_ > 0 and pcTok != "z"  _s_ += "-" ok
			_s_ += " "
			if _at_ % 16 = 0
				_s_ += "| "
				# a new bar clears the accidentals -- and nothing else remembers them
				_n_ = len(paAcc)
				for _k_ = _n_ to 1 step -1  del(paAcc, _k_) next
			ok
		end
		return _s_

	def _AbcPitch(paSp, paAcc)
		_step_ = paSp[1]
		_alt_ = paSp[2]
		_oct_ = paSp[3]
		_letter_ = _step_
		if _oct_ >= 5
			_letter_ = lower(_step_) + copy("'", _oct_ - 5)
		else
			_letter_ = _step_ + copy(",", 4 - _oct_)
		ok
		_prev_ = NULL
		for _a_ in paAcc
			if _a_[1] = _letter_  _prev_ = _a_[2] ok
		next
		_acc_ = ""
		if _alt_ = 1
			_acc_ = "^"
		but _alt_ = -1
			_acc_ = "_"
		but _alt_ = 0.5
			_acc_ = "^/"
		but _alt_ = -0.5
			_acc_ = "_/"
		else
			if NOT isNull(_prev_) and _prev_ != 0  _acc_ = "=" ok
		ok
		if _alt_ != 0 or NOT isNull(_prev_)
			paAcc + [ _letter_, _alt_ ]
		ok
		return _acc_ + _letter_

	#-- MusicXML (partwise) -----------------------------------------------------

	def ToMusicXML(pcTitle)
		@aLosses = []
		_aV_ = This._Voices()
		_q_ = char(34)
		_x_ = "<?xml version=" + _q_ + "1.0" + _q_ + " encoding=" + _q_ + "UTF-8" + _q_ + "?>" + nl +
		      "<score-partwise version=" + _q_ + "4.0" + _q_ + ">" + nl +
		      "  <work><work-title>" + This._Xml(pcTitle) + "</work-title></work>" + nl + "  <part-list>" + nl
		_n_ = 0
		for _v_ in _aV_
			_n_++
			_x_ += "    <score-part id=" + _q_ + "P" + _n_ + _q_ + "><part-name>" + This._Xml(_v_[1]) +
			       "</part-name></score-part>" + nl
		next
		_x_ += "  </part-list>" + nl
		_n_ = 0
		for _v_ in _aV_
			_n_++
			_x_ += "  <part id=" + _q_ + "P" + _n_ + _q_ + ">" + nl + This._XmlMeasures(_v_[2]) + "  </part>" + nl
		next
		return _x_ + "</score-partwise>" + nl

	def _XmlMeasures(paSeg)
		# the voice as a list of [ at, len, pitches or [] for a rest ], rests filled
		_aAll_ = []
		_t_ = 0
		for _g_ in paSeg
			if _g_[1] > _t_  _aAll_ + [ _t_, _g_[1] - _t_, [] ] ok
			_aAll_ + _g_
			_t_ = _g_[1] + _g_[2]
		next
		if _t_ % 16 != 0  _aAll_ + [ _t_, 16 - (_t_ % 16), [] ] ok
		_x_ = ""
		_bar_ = -1
		for _g_ in _aAll_
			_at_ = _g_[1]
			_left_ = _g_[2]
			_bFirst_ = TRUE
			while _left_ > 0
				_b_ = floor(_at_ / 16)
				if _b_ != _bar_
					if _bar_ >= 0  _x_ += "    </measure>" + nl ok
					_bar_ = _b_
					_x_ += "    <measure number=" + char(34) + (_b_ + 1) + char(34) + ">" + nl
					if _b_ = 0
						_x_ += "      <attributes><divisions>4</divisions><time><beats>4</beats>" +
						       "<beat-type>4</beat-type></time><clef><sign>G</sign><line>2</line></clef></attributes>" + nl +
						       "      <sound tempo=" + char(34) + floor(@oS.TempoInBpm() + 0.5) + char(34) + "/>" + nl
					ok
				ok
				_room_ = 16 - (_at_ % 16)
				_take_ = This._XmlPiece(_left_, _room_)
				_last_ = (_take_ = _left_)
				_x_ += This._XmlNote(_g_[3], _take_, NOT _bFirst_, NOT _last_)
				_bFirst_ = FALSE
				_left_ -= _take_
				_at_ += _take_
			end
		next
		if _bar_ >= 0  _x_ += "    </measure>" + nl ok
		return _x_

	# the largest note value that fits both what is left and the bar's room
	def _XmlPiece(pnLeft, pnRoom)
		for _v_ in [ 16, 12, 8, 6, 4, 3, 2, 1 ]
			if _v_ <= pnLeft and _v_ <= pnRoom  return _v_ ok
		next
		return 1

	def _XmlNote(paP, pnDur, pbTieStop, pbTieStart)
		_aType_ = [ [ 16, "whole", 0 ], [ 12, "half", 1 ], [ 8, "half", 0 ], [ 6, "quarter", 1 ],
		            [ 4, "quarter", 0 ], [ 3, "eighth", 1 ], [ 2, "eighth", 0 ], [ 1, "16th", 0 ] ]
		_ty_ = "16th"
		_dot_ = 0
		for _a_ in _aType_
			if _a_[1] = pnDur
				_ty_ = _a_[2]
				_dot_ = _a_[3]
			ok
		next
		_x_ = ""
		if len(paP) = 0
			return "      <note><rest/><duration>" + pnDur + "</duration><type>" + _ty_ + "</type>" +
			       copy("<dot/>", _dot_) + "</note>" + nl
		ok
		_k_ = 0
		for _p_ in paP
			_k_++
			_x_ += "      <note>"
			if _k_ > 1  _x_ += "<chord/>" ok
			_x_ += "<pitch><step>" + _p_[1] + "</step>"
			if _p_[2] != 0  _x_ += "<alter>" + This._AlterText(_p_[2]) + "</alter>" ok
			_x_ += "<octave>" + _p_[3] + "</octave></pitch><duration>" + pnDur + "</duration>"
			if pbTieStop  _x_ += "<tie type=" + char(34) + "stop" + char(34) + "/>" ok
			if pbTieStart  _x_ += "<tie type=" + char(34) + "start" + char(34) + "/>" ok
			_x_ += "<type>" + _ty_ + "</type>" + copy("<dot/>", _dot_)
			if pbTieStop or pbTieStart
				_x_ += "<notations>"
				if pbTieStop  _x_ += "<tied type=" + char(34) + "stop" + char(34) + "/>" ok
				if pbTieStart  _x_ += "<tied type=" + char(34) + "start" + char(34) + "/>" ok
				_x_ += "</notations>"
			ok
			_x_ += "</note>" + nl
		next
		return _x_

	# -1, -0.5, 0.5, 1 written as those, whatever decimals() is set to (the
	# first cut printed -0.500 -- valid, and not what anyone reads as a quarter tone)
	def _AlterText(pn)
		if pn = -1    return "-1" ok
		if pn = -0.5  return "-0.5" ok
		if pn = 0.5   return "0.5" ok
		if pn = 1     return "1" ok
		return "0"

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

	#-- MIDI (Standard MIDI File, type 1) ---------------------------------------

	def ToMidiFile(pcPath)
		_b_ = This.ToMidiBytes()
		write(pcPath, _b_)
		return len(_b_)

	def ToMidiBytes()
		@aLosses = []
		_ppq_ = 480
		_aEv_ = @oS.Events()
		# track 0: tempo and metre
		_us_ = floor(60000000 / @oS.TempoInBpm() + 0.5)
		_t0_ = This._Vlq(0) + char(255) + char(81) + char(3) + This._Be(_us_, 3) +
		       This._Vlq(0) + char(255) + char(88) + char(4) + char(4) + char(2) + char(24) + char(8) +
		       This._Vlq(0) + char(255) + char(47) + char(0)
		# track 1: pitched notes, a channel each, bent onto their pitch
		_aPool_ = [ 0, 1, 2, 3, 4, 5, 6, 7, 8, 10, 11, 12, 13, 14, 15 ]
		_aBusy_ = [ ]             # [ channel, busyUntilTick, lastUsedOrder, instrument ]
		for _ch_ in _aPool_  _aBusy_ + [ _ch_, -1, 0, "" ] next
		_aT1_ = []                # [ tick, order, bytes ]
		_ord_ = 0
		for _ch_ in _aPool_
			# RPN 0 (pitch-bend range) = 12 semitones, then the RPN is closed --
			# SIX messages, each its own event. The first cut packed them into ONE
			# event with one delta time; MIDI wants a delta before every message,
			# and the guard's reader, written apart from this writer, read
			# everything after it wrong: a note lost, every later pitch shifted.
			for _cc_ in [ [ 101, 0 ], [ 100, 0 ], [ 6, 12 ], [ 38, 0 ], [ 101, 127 ], [ 100, 127 ] ]
				_aT1_ + [ 0, _ord_, char(176 + _ch_) + char(_cc_[1]) + char(_cc_[2]) ]
			next
			_ord_++
		next
		_aT2_ = []
		_cDrum_ = ""
		_nUse_ = 0
		for _e_ in _aEv_
			_tk_ = floor(_e_[1] * _ppq_ + 0.5)
			_dur_ = floor(_e_[2] * _ppq_ + 0.5)
			if _dur_ < 1  _dur_ = 1 ok
			_vel_ = floor(_e_[5] * 127 + 0.5)
			if _vel_ < 1  _vel_ = 1 ok
			if _vel_ > 127  _vel_ = 127 ok
			if _e_[3] <= 0
				# a stroke: the drum channel, General MIDI's numbers
				_key_ = This._GmDrum(_e_[6])
				_cD_ = _e_[4]
				if _cD_ = ""  _cD_ = "drumkit" ok
				if _cD_ != _cDrum_
					_aT2_ + [ _tk_, 1, This._InstText(9, _cD_) ]
					_cDrum_ = _cD_
				ok
				_aT2_ + [ _tk_, 1, char(153) + char(_key_) + char(_vel_) ]
				_aT2_ + [ _tk_ + _dur_, 0, char(137) + char(_key_) + char(0) ]
				loop
			ok
			# the channel: a free one, least recently used; else the least recently used
			_pick_ = 0
			_bestOrd_ = 999999999
			for _i_ = 1 to len(_aBusy_)
				if _aBusy_[_i_][2] <= _tk_ and _aBusy_[_i_][3] < _bestOrd_
					_bestOrd_ = _aBusy_[_i_][3]
					_pick_ = _i_
				ok
			next
			if _pick_ = 0
				@aLosses + ("MIDI: a note at tick " + _tk_ + " found all fifteen channels sounding; it shares one")
				_pick_ = 1
				for _i_ = 2 to len(_aBusy_)
					if _aBusy_[_i_][3] < _aBusy_[_pick_][3]  _pick_ = _i_ ok
				next
			ok
			_ch_ = _aBusy_[_pick_][1]
			_nUse_++
			_aBusy_[_pick_][2] = _tk_ + _dur_
			_aBusy_[_pick_][3] = _nUse_
			_inst_ = _e_[4]
			if _inst_ = ""  _inst_ = "piano" ok
			# MU8: the instrument by NAME in a text event, then its program. The
			# first cut changed program only when the PROGRAM changed, so an oud
			# after a guitar on one channel (both GM 24) left no trace at all.
			if _aBusy_[_pick_][4] != _inst_
				_aT1_ + [ _tk_, 1, This._InstText(_ch_, _inst_) ]
				_aT1_ + [ _tk_, 1, char(192 + _ch_) + char(StzSoundGmProgram(_inst_)) ]
				_aBusy_[_pick_][4] = _inst_
			ok
			_m_ = 69 + 12 * log(_e_[3] / 440) / log(2)
			_key_ = floor(_m_ + 0.5)
			if _key_ < 0 or _key_ > 127
				@aLosses + ("MIDI: " + _e_[3] + " Hz is outside MIDI's keys; dropped")
				loop
			ok
			_aT1_ + [ _tk_, 2, This._Bend(_ch_, _m_ - _key_) ]
			_aT1_ + [ _tk_, 3, char(144 + _ch_) + char(_key_) + char(_vel_) ]
			if len(_e_) >= 7
				if _e_[7] > 0 and _e_[7] != _e_[3]
					# a glide: ten bends along the note, in log frequency
					for _s_ = 1 to 10
						_hz_ = _e_[3] * pow(_e_[7] / _e_[3], _s_ / 10)
						_ms_ = 69 + 12 * log(_hz_ / 440) / log(2)
						if fabs(_ms_ - _key_) > 12
							@aLosses + ("MIDI: a glide leaves the +-12 semitone bend range; clipped")
						ok
						# inside the note: the last bend a tick before its off. It was AT
						# the off, and a note-off sorts before a bend on the same tick,
						# so the glide's arrival belonged to no note (found by MU8's reader)
						_aT1_ + [ _tk_ + floor((_dur_ - 1) * _s_ / 10), 2, This._Bend(_ch_, _ms_ - _key_) ]
					next
				ok
			ok
			_aT1_ + [ _tk_ + _dur_, 0, char(128 + _ch_) + char(_key_) + char(0) ]
		next
		_b_ = "MThd" + This._Be(6, 4) + This._Be(1, 2) + This._Be(3, 2) + This._Be(_ppq_, 2)
		_b_ += This._Chunk(_t0_)
		_b_ += This._Chunk(This._Track(_aT1_))
		_b_ += This._Chunk(This._Track(_aT2_))
		return _b_

	def _GmDrum(pcStroke)
		switch pcStroke
		on "kick"   return 36
		on "snare"  return 38
		on "hihat"  return 42
		on "hat"    return 42      # the score's alias; it was written as 39, a hand clap
		on "crash"  return 49      # MU13: crash cymbal 1
		on "ride"   return 51      # MU13: ride cymbal 1
		on "dum"    return 64
		on "tak"    return 63
		on "ka"     return 62
		off
		return 39

	# a text event naming the instrument on a channel: "stz:inst 3 oud". Any
	# other reader skips text; this library's reader keeps the name.
	def _InstText(pnCh, pcInst)
		_t_ = "stz:inst " + pnCh + " " + pcInst
		return char(255) + char(1) + This._Vlq(len(_t_)) + _t_

	# a pitch bend of `pnSemis` (+-12 range) on channel ch
	def _Bend(pnCh, pnSemis)
		_v_ = 8192 + floor(pnSemis / 12 * 8192 + 0.5)
		if _v_ < 0  _v_ = 0 ok
		if _v_ > 16383  _v_ = 16383 ok
		return char(224 + pnCh) + char(_v_ % 128) + char(floor(_v_ / 128))

	# events [ tick, order, bytes ] -> a delta-timed track, ended
	def _Track(paE)
		# stable by tick, then by order (offs 0, drum/programs 1, bends 2, ons 3)
		_a_ = paE
		for _i_ = 2 to len(_a_)
			_x_ = _a_[_i_]
			_j_ = _i_ - 1
			while _j_ >= 1
				if _a_[_j_][1] < _x_[1]  exit ok
				if _a_[_j_][1] = _x_[1] and _a_[_j_][2] <= _x_[2]  exit ok
				_a_[_j_ + 1] = _a_[_j_]
				_j_--
			end
			_a_[_j_ + 1] = _x_
		next
		_s_ = ""
		_last_ = 0
		for _e_ in _a_
			_s_ += This._Vlq(_e_[1] - _last_) + _e_[3]
			_last_ = _e_[1]
		next
		return _s_ + This._Vlq(0) + char(255) + char(47) + char(0)

	def _Chunk(pcData)
		return "MTrk" + This._Be(len(pcData), 4) + pcData

	def _Be(pnV, pnBytes)
		_s_ = ""
		for _k_ = pnBytes - 1 to 0 step -1
			_s_ += char(floor(pnV / pow(256, _k_)) % 256)
		next
		return _s_

	def _Vlq(pnV)
		_v_ = pnV
		_s_ = char(_v_ % 128)
		_v_ = floor(_v_ / 128)
		while _v_ > 0
			_s_ = char(128 + (_v_ % 128)) + _s_
			_v_ = floor(_v_ / 128)
		end
		return _s_

	#-- shared: voices, pitch spelling -------------------------------------------

	# [ instrument, segments ] per instrument; a segment is [ at16, len16,
	# [ spelled pitches ] ] -- chords merged, overlaps cut, strokes left out
	def _Voices()
		_aV_ = []
		_bStroke_ = FALSE
		for _e_ in @oS.Events()
			if _e_[3] <= 0
				_bStroke_ = TRUE
				loop
			ok
			_inst_ = _e_[4]
			if _inst_ = ""  _inst_ = "piano" ok
			_at_ = floor(_e_[1] * 4 + 0.5)
			_ln_ = floor(_e_[2] * 4 + 0.5)
			if _ln_ < 1  _ln_ = 1 ok
			if fabs(_at_ / 4 - _e_[1]) > 0.01 or fabs(_ln_ / 4 - _e_[2]) > 0.01
				This._Loss("a note at beat " + _e_[1] + " was rounded to the sixteenth grid")
			ok
			_sp_ = This._Spell(_e_[3])
			if fabs(_sp_[4]) > 5
				This._Loss("a pitch sits " + floor(fabs(_sp_[4])) + " cents from the nearest quarter tone; written at the quarter tone")
			ok
			if len(_e_) >= 7
				if _e_[7] > 0 and _e_[7] != _e_[3]  This._Loss("a glide is written as its starting pitch") ok
			ok
			_vi_ = 0
			for _k_ = 1 to len(_aV_)
				if _aV_[_k_][1] = _inst_  _vi_ = _k_ ok
			next
			if _vi_ = 0
				_aV_ + [ _inst_, [] ]
				_vi_ = len(_aV_)
			ok
			_aSeg_ = _aV_[_vi_][2]
			_n_ = len(_aSeg_)
			if _n_ > 0
				if _aSeg_[_n_][1] = _at_ and _aSeg_[_n_][2] = _ln_
					_aV_[_vi_][2][_n_][3] + _sp_              # a chord
					loop
				ok
				if _aSeg_[_n_][1] + _aSeg_[_n_][2] > _at_
					_cut_ = _at_ - _aSeg_[_n_][1]
					if _cut_ < 1
						This._Loss("two notes of one voice start together with different lengths; the later is dropped")
						loop
					ok
					_aV_[_vi_][2][_n_][2] = _cut_
					This._Loss("a note was cut where the next note of its voice begins")
				ok
			ok
			_aV_[_vi_][2] + [ _at_, _ln_, [ _sp_ ] ]
		next
		if _bStroke_  This._Loss("strokes are not written in ABC or MusicXML here (MIDI carries them)") ok
		return _aV_

	# Hz -> [ step, alter (-1, -0.5, 0, 0.5, 1), octave, cents from that spelling ]
	def _Spell(pnHz)
		_m_ = 69 + 12 * log(pnHz / 440) / log(2)
		_q_ = floor(_m_ * 2 + 0.5) / 2
		_dev_ = (_m_ - _q_) * 100
		_k_ = floor(_q_)
		_half_ = (_q_ - _k_ = 0.5)
		_pc_ = _k_ % 12
		if _pc_ < 0  _pc_ += 12 ok
		_oct_ = floor(_k_ / 12) - 1
		_aNat_ = [ [ 0, "C" ], [ 2, "D" ], [ 4, "E" ], [ 5, "F" ], [ 7, "G" ], [ 9, "A" ], [ 11, "B" ] ]
		_nat_ = ""
		for _a_ in _aNat_
			if _a_[1] = _pc_  _nat_ = _a_[2] ok
		next
		if NOT _half_
			if _nat_ != ""  return [ _nat_, 0, _oct_, _dev_ ] ok
			for _a_ in _aNat_
				if _a_[1] = _pc_ - 1  return [ _a_[2], 1, _oct_, _dev_ ] ok
			next
		else
			if _nat_ != ""  return [ _nat_, 0.5, _oct_, _dev_ ] ok
			for _a_ in _aNat_
				if _a_[1] = _pc_ + 1  return [ _a_[2], -0.5, _oct_, _dev_ ] ok
			next
		ok
		return [ "C", 0, 4, 0 ]

	def _Loss(pc)
		if ring_find(@aLosses, pc) = 0  @aLosses + pc ok
