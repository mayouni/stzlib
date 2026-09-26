# UNIVERSE: raga -- Yaman over teental (plan MU4).
# DECLARED DATA ONLY. No logic lives here: stzSoundUniverse reads this list.
#
# The tuning is the common 5-limit just reading of Kalyan thaat's swaras
# (Re 9/8, Ga 5/4, Ma-tivra 45/32, Pa 3/2, Dha 5/3, Ni 15/8), NOT a measurement
# -- Hindustani intonation moves with the performer and the phrase. The
# gamakas declared are three MEENDS, the glides into Re, Ga and Ma-tivra going
# up (the identifying ni-re-ga-ma(t) movement); no reliable source was found
# for a kan swar, so none is declared. There is no sitar or bansuri here: the
# engine's flute (a jet pipe) plays, and the darbouka stands in for tabla --
# dum for the bass-resonant bols (dha, dhin), tak for tin and ta, which keeps
# what khali sounds like: after khali's dha on 9, the bass drops out for the
# tin tin ta ta of 10 to 13. (This line first said "9 to 12"; the theka the
# source gives says otherwise, and MU4's guard caught the sentence.)

func StzSoundUniverseData_raga()
	return [
		:name = "raga",
		:title = "Hindustani raga",
		:tempo = 72,
		:melody = "flute",
		:defaultmode = "yaman",
		:defaultcycle = "teental",
		:modes = [
			[ :name = "yaman", :tonic = "D4",
			  :degrees = [ 0, 204, 386, 590, 702, 884, 1088 ],
			  :names = [ "Sa", "Re", "Ga", "Ma (tivra)", "Pa", "Dha", "Ni" ],
			  :emphasis = [ 3, 7 ],
			  :avoidascending = [ 5 ],
			  :avoidwhy = "Sa and Pa are often skipped or kept weak going up (Wikipedia, after Bor's Raga Guide); ragakosh gives .N R G M P M D N S'",
			  :ornaments = [ [ :kind = "slide", :to = 2, :when = "up" ],
			                 [ :kind = "slide", :to = 3, :when = "up" ],
			                 [ :kind = "slide", :to = 4, :when = "up" ] ],
			  :pakad = ".N R G R S, P M G R S",
			  :why = "vadi Ga, samvadi Ni; the first quarter of the night",
			  :confidence = "high for the swaras and rules; medium for the tuning (a textbook just reading); low-medium for the meends (teaching sources)" ] ],
		:cycles = [
			[ :name = "teental", :beats = 16, :accents = [ 1, 5, 13 ],
			  :layers = [ [ "darbouka", "dum dum dum dum dum dum dum dum dum tak tak tak tak dum dum dum" ] ],
			  :vibhags = [ 4, 4, 4, 4 ], :sam = 1, :tali = [ 5, 13 ], :khali = [ 9 ],
			  :standin = "darbouka for tabla: dha/dhin -> dum, tin/ta -> tak" ] ],
		:sources = [ "Wikipedia 'Yaman (raga)', citing Bor (ed.), The Raga Guide, and Bhatkhande",
		             "ragakosh.com (Yaman)", "Wikipedia 'Teental'",
		             "spardhaschoolofmusic.com; hclconcerts.com (meend in Yaman) -- teaching blogs" ],
		:confidence = "see each part",
		:listener = "UNPERCEIVED"
	]
