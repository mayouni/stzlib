# UNIVERSE: flamenco -- the solea's compas, in the Phrygian "modo flamenco".
# DECLARED DATA ONLY. No logic lives here: stzSoundUniverse reads this list.
#
# The palo is defined by its compas before its harmony (plan 1.3). The mode
# is the Phrygian on E with its third raised over the tonic chord (G sharp)
# and natural in the descent to F and E -- declared as two sets. There are no
# palmas in this engine: hi-hat for the steady claps and snare for the
# accented ones STAND IN, and the file says so rather than naming them palmas.

func StzSoundUniverseData_flamenco()
	return [
		:name = "flamenco",
		:title = "Flamenco -- solea",
		:tempo = 132,
		:melody = "guitar",
		:defaultmode = "phrygian",
		:defaultcycle = "solea",
		:modes = [
			[ :name = "phrygian", :tonic = "E3",
			  :degrees    = [ 0, 100, 400, 500, 700, 800, 1000 ],
			  :descending = [ 0, 100, 300, 500, 700, 800, 1000 ],
			  :names = [ "E", "F", "G#", "A", "B", "C", "D" ] ] ],
		:cycles = [
			[ :name = "solea", :beats = 12, :accents = [ 3, 6, 8, 10, 12 ],
			  :layers = [ [ "drumkit", "hh hh sn hh hh sn hh sn hh sn hh sn" ] ],
			  :standin = "hi-hat and snare stand in for palmas" ] ],
		:sources = [ "the solea compas of twelve with accents on 3, 6, 8, 10, 12: standard in every flamenco method",
		             "the Phrygian / Andalusian cadence mode on E with a raised third: standard harmony texts" ],
		:confidence = "high for the compas, medium for the declared melodic mode",
		:listener = "UNPERCEIVED"
	]
