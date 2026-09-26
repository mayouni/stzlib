# UNIVERSE: maqam -- Arabic maqam, Rast and Hijaz (plan MU4).
# DECLARED DATA ONLY. No logic lives here: stzSoundUniverse reads this list.
#
# THE GRID IS 24-TET, as the plan's MU4 row says, and that is a THEORISTS'
# grid: the 1932 Cairo Congress measured regional intonations that sit off
# it (Rast's third lower in Syria than in Egypt, Hijaz's second often raised).
# The quarter-tone values below are the textbook ones, not a region's.
# A maqam is not a scale (plan 1.3): the ajnas and the movement (sayr) are the
# identity. What is declared of the sayr here is small and says so: the
# degrees emphasised, and Rast's descent through the flat seventh.

func StzSoundUniverseData_maqam()
	return [
		:name = "maqam",
		:title = "Arabic maqam",
		:tempo = 96,
		:melody = "oud",
		:defaultmode = "rast",
		:defaultcycle = "maqsum",
		:modes = [
			[ :name = "rast", :tonic = "C4",
			  :degrees    = [ 0, 200, 350, 500, 700, 900, 1050 ],
			  :descending = [ 0, 200, 350, 500, 700, 900, 1000 ],
			  :names = [ "Rast", "Dukah", "Sikah", "Jaharkah", "Nawa", "Husayni", "Awj" ],
			  :ajnas = [ [ "rast", 1, [ 0, 200, 350, 500 ] ],
			             [ "rast", 5, [ 0, 200, 350, 500 ] ],
			             [ "nahawand (descending)", 5, [ 0, 200, 300, 500 ] ] ],
			  :emphasis = [ 1, 5 ],
			  :why = "Rast ascends through the half-flat seventh and descends through the flat one: the upper jins is Rast going up and Nahawand coming down" ],
			[ :name = "hijaz", :tonic = "D4",
			  :degrees = [ 0, 100, 400, 500, 700, 800, 1000 ],
			  :names = [ "Dukah", "Kurd", "Hijaz", "Nawa", "Husayni", "Ajam", "Kardan" ],
			  :ajnas = [ [ "hijaz", 1, [ 0, 100, 400, 500 ] ],
			             [ "nahawand", 4, [ 0, 200, 300, 500 ] ] ],
			  :emphasis = [ 1, 4 ],
			  :why = "the augmented second between degrees 2 and 3 is the jins; the upper jins declared is Nahawand on the fourth, as most printed scales give it -- Rast on the fourth is the other common one, and is not declared" ] ],
		:cycles = [
			[ :name = "maqsum", :beats = 8, :accents = [ 1, 5 ],
			  :layers = [ [ "darbouka", "dum tak ~ tak dum ~ tak ~" ] ] ] ],
		:sources = [ "maqamworld.com: Rast family, Hijaz family (ajnas and scales)",
		             "Marcus, S. (1989) Arab Music Theory in the Modern Period, UCLA: the 24-tone grid and its critics",
		             "maqsum as D T - T D - T -: the standard teaching form" ],
		:confidence = "medium -- textbook intervals on a theorists' grid; regional intonation is not declared",
		:listener = "UNPERCEIVED"
	]
