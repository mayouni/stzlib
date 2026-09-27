# UNIVERSE: tunisian -- three tubu' of the ma'luf, the nuba's five iqa'at,
# and one rhythm of the popular mezwed repertoire (plan MU4).
# DECLARED DATA ONLY. No logic lives here: stzSoundUniverse reads this list.
#
# WHAT THE SOURCES GIVE, AND WHAT THEY DO NOT. The mode skeletons are
# Snoussi's (2003), as quoted beside d'Erlanger vol. 5 by Beyhom & Makhlouf
# (2021), in QUARTER-TONE STEPS. The cents below are that notation times 50 --
# arithmetic, not a measurement. No published cents measurement of these three
# tubu' was found. So:
#
# - On paper, Dhil's skeleton (two rast tetrachords, on G and on c, tonic c)
#   COINCIDES with Rast's. What the sources say makes it Tunisian -- a third
#   degree that moves between e-flat, e-half-flat and e (Tarnan, Cairo 1932),
#   a "very high" b-half-flat -- is a MOVEMENT no fixed degree list carries.
#   It is declared as :variants, and not rendered as if it were settled.
# - Sika's Tunisian mark IS declared as a second mode: the "Tunisian hijaz"
#   (3/4 + 5/4 + 2/4 tones) replacing the upper rast tetrachord.
# - Rasd al-Dhil: Snoussi's f-half-sharp (550) is declared; d'Erlanger's
#   f-sharp (600) is NOT merged in -- the sources disagree, and each is named.
#
# THE IQA'AT: meters are well sourced (the CNRS archive of Zghonda's booklet,
# 1992). Stroke patterns were found only for btayhi and barwal, on amateur
# pages; draj, khafif and khatm declare their meter and NO strokes -- they
# play silent rather than invented. The mezwed repertoire is popular music,
# not the ma'luf, and its own modes are not declared here.

func StzSoundUniverseData_tunisian()
	return [
		:name = "tunisian",
		:title = "Tunisian tubu' and iqa'at",
		:tempo = 88,
		:melody = "oud",
		:defaultmode = "dhil",
		:defaultcycle = "btayhi",
		:modes = [
			[ :name = "dhil", :tonic = "C4",
			  :degrees = [ 0, 200, 350, 500, 700, 900, 1050 ],
			  :names = [ "c", "d", "e-half-flat", "f", "g", "a", "b-half-flat" ],
			  :ajnas = [ [ "rast (below the tonic, on G)", -3, [ -500, -300, -150, 0 ] ],
			             [ "rast", 1, [ 0, 200, 350, 500 ] ] ],
			  :variants = [ [ 3, [ 300, 350, 400 ], "Tarnan (1932): three separated forms of the third" ],
			                [ 7, [ 1050 ], "the b-half-flat is 'very high' -- not quantified" ] ],
			  :why = "Snoussi: two rast tetrachords sharing c; tonic c; the range reaches down to G",
			  :confidence = "high for the skeleton (Snoussi), medium for the moving third (a recording described, not measured)" ],
			[ :name = "sika", :tonic = "E4-50",
			  :degrees = [ 0, 150, 350, 550, 700, 850, 1050 ],
			  :names = [ "e-half-flat", "f", "g", "a", "b-half-flat", "c", "d" ],
			  :ajnas = [ [ "sika (trichord)", 1, [ 0, 150, 350 ] ], [ "rast", 3, [ 0, 200, 350, 500 ] ] ],
			  :why = "Snoussi: a sika trichord on e-half-flat joined at g to a rast tetrachord",
			  :confidence = "high for the skeleton (Snoussi)" ],
			[ :name = "sika_hijaz", :tonic = "E4-50",
			  :degrees = [ 0, 150, 350, 500, 750, 850, 1050 ],
			  :names = [ "e-half-flat", "f", "g", "a-half-flat", "b", "c", "d" ],
			  :ajnas = [ [ "sika (trichord)", 1, [ 0, 150, 350 ] ],
			             [ "Tunisian hijaz (3/4 + 5/4 + 2/4)", 3, [ 0, 150, 400, 500 ] ] ],
			  :why = "Snoussi: the upper rast may be replaced by a 'Tunisian hijaz' -- the documented Tunisian difference from the Eastern Sikah",
			  :confidence = "high for the skeleton (Snoussi)" ],
			[ :name = "rasdaldhil", :tonic = "C4",
			  :degrees = [ 0, 200, 350, 550, 700, 900, 1050 ],
			  :names = [ "c", "d", "e-half-flat", "f-half-sharp", "g", "a", "b-half-flat" ],
			  :ajnas = [ [ "Tunisian hijaz, iraq form (3-4-3)", 2, [ 0, 150, 350, 500 ] ],
			             [ "rast", 5, [ 0, 200, 350, 500 ] ] ],
			  :avoiddescending = [ 4 ],
			  :avoidwhy = "Ghanim (1932) often leaves out the fourth going down, and leaps e-half-flat to g -- a 'pentatonic feeling'",
			  :why = "Snoussi: c, a whole tone, then two tetrachords sharing a note; d'Erlanger instead gives a nakriz pentachord with f-SHARP (600) -- the sources disagree on the fourth, and Snoussi's is the one declared",
			  :confidence = "high for Snoussi's skeleton; the fourth degree is disputed between sources" ] ],
		:cycles = [
			[ :name = "btayhi", :beats = 8, :accents = [ 1 ],
			  :layers = [ [ "darbouka", "dum ~ ~ tak ~ ~ tak ~ ~ ~ dum ~ tak ~ ~ ~" ] ],
			  :confidence = "meter 4/2 high (CNRS); strokes LOW (an amateur rhythm FAQ, 'Tunisia' variant)" ],
			[ :name = "barwal", :beats = 2, :accents = [ 1 ],
			  :layers = [ [ "darbouka", "dum dum ~ tak dum ~ tak ~" ] ],
			  :confidence = "meter 2/4 high (CNRS); strokes LOW (a school-exchange page)" ],
			[ :name = "draj", :beats = 6, :accents = [ 1 ], :layers = [],
			  :confidence = "meter 6/4 high (CNRS); strokes NOT FOUND -- none declared" ],
			[ :name = "khafif", :beats = 6, :accents = [ 1 ], :layers = [],
			  :confidence = "meter 6/4 high (CNRS); strokes NOT FOUND -- none declared" ],
			[ :name = "khatm", :beats = 3, :accents = [ 1 ], :layers = [],
			  :confidence = "meter 3/4 (or 6/8) high (CNRS); strokes NOT FOUND -- none declared" ],
			[ :name = "fazzani", :beats = 2, :accents = [ 1 ],
			  :layers = [ [ "bendir", "dum tak ~ tak dum tak tak ~" ] ],
			  :confidence = "LOW: one notation image on an amateur page; one summary says it is played with a triplet feel, so the straight notation may be an approximation" ] ],
		:nubaorder = [ "btayhi", "barwal", "draj", "khafif", "khatm" ],
		:sources = [
			"Beyhom, A. & Makhlouf, 'A VIAMAP exploration of the Tunisian tubu'', CTUPM, 2 June 2021 -- quoting Snoussi, Initiation a la musique tunisienne (2003) pp. 47-49, 56-57, and d'Erlanger, La musique arabe vol. 5 (1949) figs. 148, 149, 170",
			"CREM-CNRS archive, Tunisie: Anthologie du Malouf -- Nuba al-ramal (booklet by Fethi Zghonda, 1992): the iqa'at and their meters",
			"khafif.com/rhy (btayhi, 'Tunisia' variant); zictrad.free.fr/Afrique/Tunisie.htm (barwal, fazzani) -- amateur, low" ],
		:confidence = "skeletons high, cents derived not measured, strokes low where given and absent where not",
		:listener = "HEARD 2026-09-26 by the Principal (Mansour Ayouni), through five ORIGINAL examples written in this universe (not committed): 'far from being qualified'. Which part fails -- the tuning, the phrasing, the rhythms or the synthetic timbre -- is not yet said"
	]
