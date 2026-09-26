# UNIVERSE: westafrican -- the 12/8 standard bell pattern (plan MU4).
# DECLARED DATA ONLY. No logic lives here: stzSoundUniverse reads this list.
#
# A RHYTHM, AND DECLARED AS ONE: no scale. West and Central Africa hold
# hundreds of pitch systems, and "West African" is not one of them; declaring
# a scale under this name would be the tourist's version plan section 7
# warns about. So the universe has a timeline and no modes, and a phrase
# played in it is REFUSED with that reason. The bell is the reference the
# ensemble hears, not a downbeat (plan 1.3).

func StzSoundUniverseData_westafrican()
	return [
		:name = "westafrican",
		:title = "West African 12/8 timeline",
		:tempo = 360,
		:melody = "",
		:defaultmode = "",
		:defaultcycle = "standard",
		:modes = [],
		:cycles = [
			[ :name = "standard", :beats = 12, :accents = [ 1 ],
			  :layers = [ [ "bell", "a5 ~ a5 ~ a5 a5 ~ a5 ~ a5 ~ a5" ],
			              [ "drumkit", "bd ~ ~ bd ~ ~ bd ~ ~ bd ~ ~" ] ],
			  :standin = "the FM bell stands in for the gankogui/agogo; the kick marks the four dotted-quarter pulses" ] ],
		:sources = [ "the standard pattern x.x.xx.x.x.x: Toussaint, The Geometry of Musical Rhythm (2013); Agawu, The African Imagination in Music (2016)" ],
		:confidence = "high for the pattern; the pulse layer is a teaching aid, not a tradition's part",
		:listener = "UNPERCEIVED"
	]
