# UNIVERSE: gamelan -- Javanese slendro, lancaran (plan MU4).
# DECLARED DATA ONLY. No logic lives here: stzSoundUniverse reads this list.
#
# EVERY GAMELAN IS TUNED DIFFERENTLY ON PURPOSE (plan 1.3), so two real sets
# are declared, measured: the average of thirty (Surjodiningrat et al.), with
# its STRETCHED octave of 1208 cents, and Kyai Kanyut Mesem of the
# Mangkunegaran. Same phrase, two gamelans, two answers -- that is the point.
#
# PAIRED DETUNING IS BALINESE (ombak), not Javanese. The plan's MU4 row asked
# for slendro "with paired detuning", so a third mode applies it -- and this
# line says that the combination is this declaration's, not a tradition's.
#
# The colotomic instruments are stand-ins: the FM bell for the gong ageng, the
# FM metallophone for kenong, kempul and ketuk, at pitches this file chose.

func StzSoundUniverseData_gamelan()
	return [
		:name = "gamelan",
		:title = "Javanese gamelan -- slendro",
		:tempo = 132,
		:melody = "metallophone",
		:defaultmode = "slendro",
		:defaultcycle = "lancaran",
		:modes = [
			[ :name = "slendro", :tonic = "D4",
			  :degrees = [ 0, 231, 474, 717, 955 ], :octave = 1208,
			  :names = [ "1 (barang)", "2 (gulu)", "3 (dada)", "5 (lima)", "6 (nem)" ],
			  :why = "the average of 30 slendro gamelans: Surjodiningrat, Sudarjana & Susanto (1972; English 1993), via the Scala archive",
			  :confidence = "high (measured)" ],
			[ :name = "kanyutmesem", :tonic = "D4",
			  :degrees = [ 0, 223, 476, 712, 937 ], :octave = 1200,
			  :names = [ "1", "2", "3", "5", "6" ],
			  :why = "Kyai Kanyut Mesem, Mangkunegaran, Solo (1/1 = 291 Hz) -- the measurer is not named in the archive file",
			  :confidence = "medium on provenance" ],
			[ :name = "slendro_paired", :tonic = "D4",
			  :degrees = [ 0, 231, 474, 717, 955 ], :octave = 1208,
			  :names = [ "1", "2", "3", "5", "6" ],
			  :pairdetunehz = 6,
			  :why = "the averaged slendro played in PAIRS 6 Hz apart so each note beats -- Balinese ombak practice applied to a Javanese scale, by this declaration",
			  :confidence = "a stated combination, not a tradition" ] ],
		:cycles = [
			[ :name = "lancaran", :beats = 16, :accents = [ 16 ],
			  :layers = [
			      [ "bell", "~ ~ ~ ~ ~ ~ ~ ~ ~ ~ ~ ~ ~ ~ ~ 1_", "degrees" ],
			      [ "metallophone", "~ ~ ~ 1 ~ ~ ~ 1 ~ ~ ~ 1 ~ ~ ~ 1", "degrees" ],
			      [ "metallophone", "~ ~ ~ ~ ~ 5_ ~ ~ ~ 5_ ~ ~ ~ 5_ ~ ~", "degrees" ],
			      [ "metallophone", "2 ~ 2 ~ 2 ~ 2 ~ 2 ~ 2 ~ 2 ~ 2 ~", "degrees" ] ],
			  :colotomy = "T W T N T P T N T P T N T P T G -- ketuk odd, wela 2, kenong 4 8 12 16, kempul 6 10 14, gong 16",
			  :standin = "bell = gong ageng; metallophone = kenong, kempul, ketuk",
			  :confidence = "high: Wikipedia 'Lancaran', citing Lindsay, Javanese Gamelan (1992) pp. 48-49" ] ],
		:sources = [ "Surjodiningrat, Sudarjana & Susanto (1972/1993), via the Huygens-Fokker Scala archive",
		             "Lindsay, J. (1992) Javanese Gamelan, pp. 48-49 (lancaran)" ],
		:confidence = "tunings measured; the pairing is a declared combination",
		:listener = "UNPERCEIVED"
	]
