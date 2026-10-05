# UNIVERSE: western -- the default nobody else escapes (plan section 4).
# DECLARED DATA ONLY. No logic lives here: stzSoundUniverse reads this list.
# Cents are twelve-tone equal temperament, exact by definition.

func StzSoundUniverseData_western()
	return [
		:name = "western",
		:title = "Western tonal",
		:tempo = 100,
		:melody = "piano",
		:defaultmode = "major",
		:defaultcycle = "four",
		:modes = [
			[ :name = "major", :tonic = "C4",
			  :degrees = [ 0, 200, 400, 500, 700, 900, 1100 ],
			  :names = [ "Do", "Re", "Mi", "Fa", "Sol", "La", "Ti" ] ],
			[ :name = "minor", :tonic = "A3",
			  :degrees = [ 0, 200, 300, 500, 700, 800, 1000 ],
			  :names = [ "La", "Ti", "Do", "Re", "Mi", "Fa", "Sol" ] ] ],
		:cycles = [
			[ :name = "four", :beats = 4, :accents = [ 1, 3 ],
			  :layers = [ [ "drumkit", "bd hh sn hh" ] ] ],
			[ :name = "waltz", :beats = 3, :accents = [ 1 ],
			  :layers = [ [ "drumkit", "bd hh hh" ] ] ] ],
		:sources = [ "twelve-tone equal temperament: definitional" ],
		:confidence = "high -- this is the tradition the rest of the field defaults to",
		:listener = "UNPERCEIVED"
	]
