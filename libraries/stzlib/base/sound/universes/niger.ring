# UNIVERSE: niger -- a Zarma-Songhai starting set, the tende n-emnas, a
# takamba meter, and one Hausa sentence for the kalangu (plan MU4).
# DECLARED DATA ONLY. No logic lives here: stzSoundUniverse reads this list.
#
# THE THINNEST DECLARATION IN THIS LIBRARY, AND IT SAYS SO. No published
# intervals were found for Zarma-Songhai music. The only source for
# "pentatonic" is a user-written genre page. Surugue (1973) describes the
# one-string goje fiddle played by TOUCHING the string at its nodes -- touched
# partials -- which suggests a harmonic-series intonation; that is an
# inference, and is written here as one, not declared as a mode. The plan
# said of Niger that the listener is "the whole record": here that is
# literally true, and the mode below is a placeholder for their correction.
#
# THE INSTRUMENT IS A STAND-IN: the engine's bowed string is named imzad (a
# Tuareg fiddle); it stands in for the Zarma goje. Its slides are the point.

func StzSoundUniverseData_niger()
	return [
		:name = "niger",
		:title = "Niger -- Zarma, Tuareg, Hausa",
		:tempo = 84,
		:melody = "imzad",
		:defaultmode = "zarma",
		:defaultcycle = "tende",
		:modes = [
			[ :name = "zarma", :tonic = "A3",
			  :degrees = [ 0, 300, 500, 700, 1000 ],
			  :names = [ "1", "b3", "4", "5", "b7" ],
			  :ornaments = [ [ :kind = "slide", :when = "any" ] ],
			  :why = "minor pentatonic -- a PLACEHOLDER from a user-written page; every note is reached by a slide from the last, because on a fretless or one-string instrument intonation is a curve, not a step (plan 1.3)",
			  :confidence = "LOW: no published intervals found" ] ],
		:cycles = [
			[ :name = "tende", :beats = 4, :accents = [ 1 ],
			  :layers = [ [ "darbouka", "dum ~ ~ dum dum ~ dum dum" ],
			              [ "drumkit", "~ ~ sn ~ ~ ~ sn ~" ] ],
			  :standin = "darbouka for the mortar drum, snare for the hand claps (eqqas)",
			  :confidence = "HIGH: tende n-emnas, read from Schmidt (2018) fig. 1.5 p. 37" ],
			[ :name = "takamba", :beats = 6, :accents = [ 1 ], :layers = [],
			  :confidence = "meter 6/8 LOW (a machine-written genre page); stroke pattern NOT FOUND -- none declared" ] ],
		:sentences = [
			[ :text = "sannu da zuwa", :meaning = "welcome",
			  :syllables = [ [ "san", "L", 1 ], [ "nu", "H", 1 ], [ "da", "L", 1 ],
			                 [ "zu", "H", 1 ], [ "waa", "L", 2 ] ],
			  :confidence = "tones medium-high to high: Wiktionary (sannu), citing Newman 2007 (zuwa, p. 234); 'da' low from academic usage (medium); the long 'waa' takes two units" ] ],
		:drum = "kalangu",
		:tonepitch = [ :h = 220, :l = 165 ],
		:tonewhy = "Hausa has two tones, High and Low; Falling is High then Low on one heavy syllable, and there is no Rising (Newman 1996). NO source was found for how far a kalangu squeezes between them: the fourth (220 / 165 Hz) is this declaration's choice, stated. And one source warns a kalangu does not always follow the words' tones",
		:sources = [
			"Surugue, B. (1973) Instruments de musique et textes rituels Zarma-Songhay (Niger), pp. 107-110 (IRD archive)",
			"Schmidt, E. J. (2018) Rhythms of Value: Tuareg Music and Capitalist Reckonings in Niger, PhD, UCLA, fig. 1.5 p. 37",
			"Newman, P. (1996) 'Hausa Phonology', in Kaye & Daniels (eds.), Phonologies of Asia and Africa, pp. 542-543; Newman (2007) A Hausa-English Dictionary",
			"rateyourmusic.com genre page 'Songhai music' (user-written) -- the pentatonic claim, low" ],
		:confidence = "tende high; tones medium-high; scale LOW; takamba strokes absent",
		:listener = "UNPERCEIVED"
	]
