#---------------------------------------------------------------------------#
#  STZGEOATLAS -- names to shapes, without vendoring shapes (GE4)            #
#---------------------------------------------------------------------------#
#
#     oA = StzGeoAtlas(oFeatures)               # a file the CALLER loaded
#     oA.IndexOf("USA")                         # -> the feature, by any name
#     oA.IndexOf("FR")  oA.IndexOf("250")       # -> or by any code it has
#     oA.ValuesFor([ [ "France", 67 ], [ "Japan", 125 ] ])
#     oA.Unresolved([ "France", "Atlantis" ])   # -> what did NOT bind
#
# THE EXPERIENCE THIS GIVES, and the line it will not cross. A business
# tool takes a TABLE with a column of place names and draws a map from it:
# the user types "USA" and a shape appears. That resolution is the whole
# convenience, and it is made of two things -- a table of NAMES and a set
# of SHAPES. This file carries the first and refuses the second.
#
# WHY THE LINE IS THERE, unchanged since DN24b. A boundary dataset carries
# a POSITION on every disputed border, restated in every picture drawn from
# it, in a plane whose doctrine is that a picture must not assert what it
# cannot check. It also carries a VINTAGE -- right the day it lands and
# silently wrong after -- and a LICENCE the consumer would owe. None of
# that is true of a list of names and codes: "Cote d'Ivoire is also written
# Ivory Coast" is a fact about language, and this file is full of those.
#
# SO THE SHAPES ARE THE CALLER'S, ALWAYS. The atlas binds to a feature set
# they loaded, from a file they chose and can account for, and the map that
# results prints their source. What is added here is the part that is
# tedious and safe: folding case and accents, knowing that Burma and
# Myanmar are one country, and finding a numeric ISO id in a file that only
# writes names.
#
# WHAT IS NOT HERE, named: no fuzzy matching (a near miss is reported
# UNRESOLVED rather than guessed at -- a map that silently colours Niger
# for Nigeria is worse than one with a hole), no geocoding of addresses,
# no subdivisions below the country.

func StzGeoAtlas(poFeatures)
	_o_ = new stzGeoAtlas
	_o_.Bind(poFeatures)
	return _o_

# A NAME, FOLDED TO WHAT IT HAS IN COMMON WITH ITS OTHER SPELLINGS: accents
# off, case down, punctuation and spacing gone, a leading "the" dropped. So
# "Côte d'Ivoire", "COTE D IVOIRE" and "Cote_d_Ivoire" are one key, and
# "The Gambia" finds "Gambia".
func StzGeoNormalizeName(pcName)
	_c_ = StzRemoveDiacritics("" + pcName)
	_c_ = StzLower(ring_trim(_c_))
	if StzLeft(_c_, 4) = "the "  _c_ = StzStringSection(_c_, 5, len(_c_))  ok
	# BY CODE, NOT BY COMPARING CHARACTERS. Ring reads "a" <= "z" as an
	# arithmetic comparison and raises on it; ascii() says what is meant.
	_out_ = ""
	for _i_ = 1 to len(_c_)
		_n_ = ascii(_c_[_i_])
		if (_n_ >= 97 and _n_ <= 122) or (_n_ >= 48 and _n_ <= 57)
			_out_ += _c_[_i_]
		ok
	next
	return _out_

# THE ALIASES, and every one of them is a fact about LANGUAGE. A country's
# own name, its English name, its former name, the short form a table
# writes, the code a spreadsheet holds. Nothing here says where a border
# runs; the left column is what a caller might type and the right is what a
# boundary file is likely to call it.
#
# A file that calls something else again is not broken and this list is not
# the authority: IndexOf falls through to the file's own names and ids
# first, and an unmatched name is REPORTED, never guessed.
func StzGeoNameAliases()
	return [
		[ "usa",                    "united states of america" ],
		[ "united states",          "united states of america" ],
		[ "us",                     "united states of america" ],
		[ "america",                "united states of america" ],
		[ "uk",                     "united kingdom" ],
		[ "great britain",          "united kingdom" ],
		[ "britain",                "united kingdom" ],
		[ "england",                "united kingdom" ],
		[ "russia",                 "russian federation" ],
		[ "russian federation",     "russia" ],
		[ "south korea",            "korea" ],
		[ "republic of korea",      "south korea" ],
		[ "north korea",            "dem rep korea" ],
		[ "ivory coast",            "cote divoire" ],
		[ "cote d ivoire",          "cote divoire" ],
		[ "burma",                  "myanmar" ],
		[ "swaziland",              "eswatini" ],
		[ "macedonia",              "north macedonia" ],
		[ "holland",                "netherlands" ],
		[ "czechia",                "czech republic" ],
		[ "czech rep",              "czech republic" ],
		[ "vatican",                "vatican city" ],
		[ "holy see",               "vatican city" ],
		[ "east timor",             "timor leste" ],
		[ "cape verde",             "cabo verde" ],
		[ "congo kinshasa",         "dem rep congo" ],
		[ "democratic republic of the congo", "dem rep congo" ],
		[ "drc",                    "dem rep congo" ],
		[ "congo brazzaville",      "congo" ],
		[ "republic of the congo",  "congo" ],
		[ "laos",                   "lao pdr" ],
		[ "syria",                  "syrian arab republic" ],
		[ "iran",                   "islamic republic of iran" ],
		[ "venezuela",              "bolivarian republic of venezuela" ],
		[ "bolivia",                "plurinational state of bolivia" ],
		[ "tanzania",               "united republic of tanzania" ],
		[ "moldova",                "republic of moldova" ],
		[ "brunei",                 "brunei darussalam" ],
		[ "western sahara",         "w sahara" ],
		[ "bosnia",                 "bosnia and herzegovina" ],
		[ "central african rep",    "central african republic" ],
		[ "dominican rep",          "dominican republic" ],
		[ "eq guinea",              "equatorial guinea" ],
		[ "falklands",              "falkland islands" ],
		[ "s sudan",                "south sudan" ],
		[ "solomon isl",            "solomon islands" ],
		[ "turkey",                 "turkiye" ],
		[ "turkiye",                "turkey" ]
	]

# Binds the names and codes a caller types to the shapes of a boundary file the caller loaded, and reports what did not bind instead of guessing.
#
# A business table has a column of place names and wants a map: the user types USA and a shape
# appears. This class does the tedious and safe half: folding case, accents and punctuation, knowing
# that Burma and Myanmar are one country (about 50 aliases, each a fact about language, not about a
# border), finding a numeric id in a file that writes names, and a 2 or 3 letter code through the
# library's country table. The shapes are the CALLER'S file, never vendored here: the boundary data
# carries a position on every disputed border, a vintage and a licence the library will not own
# (test/graphics/atlas/README.md). A near miss is reported by Unresolved and never guessed, because
# a map that silently colours Niger for Nigeria is worse than one with a hole. IndexOf tries, in
# order, the file's id as written, the file's own name folded, an alias in either direction, then a
# country code. ValuesFor answers one value per feature, in the file's order, with the empty text
# where nothing bound: exactly what stzGeoMap.SetValues takes, so a table becomes a choropleth in
# two calls. Pictures, each looked at by 'stzlib-docs visual pass (a model reading the PNG)' on
# 2026-10-05: doc/gallery/stzGeoAtlas/table_to_map.png, a typed table drawn on the world with the
# unbound keys listed and the unmentioned countries hatched, RIGHT; how_a_key_resolves.png, the page
# of 21 keys and what each found, RIGHT; niger_regions_table.png, a table with a misspelt region,
# RIGHT (the misspelt region and the forgotten one are hatched and named). Index:
# doc/gallery/INDEX_geo.md.
#
#   receiver   o1 = StzGeoAtlas(StzGeoFeaturesFromJson(read("../graphics/niger_adm1.geojson")))
#   example    ? o1.IndexOf("AGADEZ")
#              #--> 1
#              ? o1.IndexOf("Tillabery")
#              #--> 0
#   see        stzGeoFeatures, stzGeoMap
class stzGeoAtlas from stzObject
	@oF = NULL
	@aByName = []     # normalised name -> feature index
	@aById = []       # id as written in the file -> feature index
	@aAlias = []

	# Binds the atlas to a boundary file the caller loaded and indexes its names and ids; raises an error when it is not an object.
	#
	#   poFeatures   the stzGeoFeatures the caller loaded: the atlas carries names and never shapes
	#   returns      nothing; the atlas is bound
	#   note         StzGeoAtlas(oFeatures) builds and binds in one call
	#   see          StzGeoAtlas, Features
	def Bind(poFeatures)
		if NOT isObject(poFeatures)
			stzraise("stzGeoAtlas: give the features the CALLER loaded -- this file " +
				"carries names, never shapes.")
		ok
		@oF = poFeatures
		@aByName = []
		@aById = []
		@aAlias = StzGeoNameAliases()
		for _i_ = 1 to @oF.Count()
			_n_ = StzGeoNormalizeName(@oF.NameOf(_i_))
			if _n_ != ""  @aByName + [ _n_, _i_ ]  ok
			_id_ = ring_trim("" + @oF.IdOf(_i_))
			if _id_ != ""  @aById + [ StzLower(_id_), _i_ ]  ok
		next

	# Returns the boundary file the atlas is bound to.
	#
	#   returns    a stzGeoFeatures
	#   see        Bind, Count
	def Features()
		return @oF

	# Returns how many features the bound file holds.
	#
	#   returns    a number, 177 for the 110m world
	#   see        Features
	def Count()
		return @oF.Count()

	# Returns every name the bound file uses, folded as the atlas compares them: lowercase, no accents, no punctuation.
	#
	#   returns    a list of text, one per named feature; "fiji" first for the 110m world
	#   note       What a caller compares their own column against when a name will not bind
	#   see        IndexOf
	#@ aka  every name the bound file actually uses, normalised -- what a caller compares their own column against when something will not bind
	def Names()
		_a_ = []
		for _i_ = 1 to len(@aByName)  _a_ + @aByName[_i_][1]  next
		return _a_

	# Returns the position of the feature a key stands for: its id, its name, an alias or a country code; 0 when nothing matches.
	#
	#   pKey       the key as the caller typed it, text or a number, such as "Niger", "NE", "NER",
	#              "562", "Ivory Coast" or "USA"
	#   returns    a number from 1, or 0
	#   note       Order: the file's id as written, the file's own name folded, an alias in either
	#              direction, then a 2 or 3 letter code. "Brasil" does not find Brazil: no fuzzy
	#              match
	#   see        Has, NameOf, StzGeoNormalizeName
	#@ aka  -- resolution -----------------------------------------------------------
	def IndexOf(pKey)
		_k_ = "" + pKey
		_t_ = ring_trim(_k_)
		if _t_ = ""  return 0  ok

		# 1. the id, exactly as the file writes it (ISO numeric, usually)
		_i_ = _GeoLookup(@aById, StzLower(_t_))
		if _i_ > 0  return _i_  ok

		# 2. the file's own name, folded
		_n_ = StzGeoNormalizeName(_t_)
		_i_ = _GeoLookup(@aByName, _n_)
		if _i_ > 0  return _i_  ok

		# 3. an alias, in either direction -- a caller may type the formal
		# name at a file that uses the short one, or the other way round
		for _a_ = 1 to len(@aAlias)
			_l_ = StzGeoNormalizeName(@aAlias[_a_][1])
			_r_ = StzGeoNormalizeName(@aAlias[_a_][2])
			if _n_ = _l_
				_i_ = _GeoLookup(@aByName, _r_)
				if _i_ > 0  return _i_  ok
			but _n_ = _r_
				_i_ = _GeoLookup(@aByName, _l_)
				if _i_ > 0  return _i_  ok
			ok
		next

		# 4. a two- or three-letter code, through the library's own country
		# table -- the authority for codes, which is not this file's job
		if len(_t_) = 2 or len(_t_) = 3
			_c_ = _GeoCountryNameOfCode(_t_)
			if _c_ != ""
				_i_ = _GeoLookup(@aByName, StzGeoNormalizeName(_c_))
				if _i_ > 0  return _i_  ok
				for _a_ = 1 to len(@aAlias)
					if StzGeoNormalizeName(@aAlias[_a_][1]) = StzGeoNormalizeName(_c_)
						_i_ = _GeoLookup(@aByName, StzGeoNormalizeName(@aAlias[_a_][2]))
						if _i_ > 0  return _i_  ok
					ok
				next
			ok
		ok
		return 0

	# TRUE if a key stands for a feature of the bound file.
	#
	#   pKey       the key as the caller typed it
	#   returns    TRUE or FALSE
	#   see        IndexOf
	def Has(pKey)
		return This.IndexOf(pKey) > 0

	# Returns the bound file's own name for the feature a key stands for.
	#
	#   pKey       the key as the caller typed it
	#   returns    text such as "United States of America" for "USA"; "" when nothing matches
	#   see        IndexOf
	def NameOf(pKey)
		_i_ = This.IndexOf(pKey)
		if _i_ < 1  return ""  ok
		return @oF.NameOf(_i_)

	# Returns the rings of the largest part of the feature a key stands for, as the caller's file drew them.
	#
	#   pKey       the key as the caller typed it
	#   returns    a list of flat lon, lat rings, the outer edge first; [ ] when nothing matches
	#   note       Largest by point count
	#   see        PartsOf, PointOf
	#@ aka  the shape a name stands for: the rings of its largest part, as the CALLER'S file drew them
	def ShapeOf(pKey)
		_i_ = This.IndexOf(pKey)
		if _i_ < 1  return []  ok
		return @oF.RingsOf(_i_, @oF.LargestPartOf(_i_))

	# Returns every part of the feature a key stands for, islands included.
	#
	#   pKey       the key as the caller typed it
	#   returns    a list of parts, each a list of rings; [ ] when nothing matches
	#   see        ShapeOf
	#@ aka  every part of it, islands included
	def PartsOf(pKey)
		_i_ = This.IndexOf(pKey)
		if _i_ < 1  return []  ok
		return @oF.PartsOf(_i_)

	# Returns a place for a label or a symbol: the mean of the points of the largest ring of the feature a key stands for.
	#
	#   pKey       the key as the caller typed it
	#   returns    a list [ lon, lat ] in degrees; [ ] when nothing matches
	#   note       A mean of points, not a centroid: on a crescent it can fall outside the feature
	#   see        ShapeOf, stzGeoMap.LabelPointOf
	#@ aka  a place to put a label or a symbol: the mean of its largest ring
	def PointOf(pKey)
		_i_ = This.IndexOf(pKey)
		if _i_ < 1  return []  ok
		_r_ = @oF.OuterRingOf(_i_, @oF.LargestPartOf(_i_))
		_n_ = len(_r_) / 2
		if _n_ < 1  return []  ok
		_sx_ = 0  _sy_ = 0
		for _j_ = 1 to _n_
			_sx_ += _r_[_j_ * 2 - 1]
			_sy_ += _r_[_j_ * 2]
		next
		return [ _sx_ / _n_, _sy_ / _n_ ]

	# Turns a table of key and value rows into one value per feature, in the file's order: what stzGeoMap.SetValues takes.
	#
	#   paRows     the table as a list of [ key, value ] rows in any order
	#   returns    a list with one item per feature: the row's value, or "" where no row bound
	#   note       Rows that are not pairs are skipped; if two rows bind one feature the later wins
	#   see        Unresolved, Uncovered, stzGeoMap.SetValues
	#@ aka  -- a table of rows, become a map ----------------------------------------
	def ValuesFor(paRows)
		_a_ = []
		for _i_ = 1 to @oF.Count()  _a_ + ""  next
		for _r_ = 1 to len(paRows)
			if NOT (isList(paRows[_r_]) and len(paRows[_r_]) >= 2)  loop  ok
			_i_ = This.IndexOf(paRows[_r_][1])
			if _i_ > 0  _a_[_i_] = paRows[_r_][2]  ok
		next
		return _a_

	# Returns the keys of the table that bound to no feature, so the caller learns it before the picture shows holes.
	#
	#   paRows     the table as a list of [ key, value ] rows, or of bare keys
	#   returns    a list of text, [ ] when everything bound
	#   note       Brasil and Atlantis come back from a table that also holds Brazil
	#   see        ValuesFor, Uncovered
	#@ aka  WHAT DID NOT BIND, and it is answered rather than swallowed. A map built from a table the caller has not checked is a map with holes in it, and the caller should learn that here and not from the picture.
	def Unresolved(paRows)
		_a_ = []
		for _r_ = 1 to len(paRows)
			_k_ = paRows[_r_]
			if isList(_k_) and len(_k_) >= 1  _k_ = _k_[1]  ok
			if This.IndexOf(_k_) < 1  _a_ + ("" + _k_)  ok
		next
		return _a_

	# Returns the names of the features that no row of the table reached.
	#
	#   paRows     the table as a list of [ key, value ] rows, or of bare keys
	#   returns    a list of the file's own names, in the file's order
	#   note       163 of the 177 countries for a table of 16 rows
	#   see        Unresolved, ValuesFor
	#@ aka  ...and which features the caller's table said nothing about
	def Uncovered(paRows)
		_seen_ = []
		for _i_ = 1 to @oF.Count()  _seen_ + 0  next
		for _r_ = 1 to len(paRows)
			_k_ = paRows[_r_]
			if isList(_k_) and len(_k_) >= 1  _k_ = _k_[1]  ok
			_i_ = This.IndexOf(_k_)
			if _i_ > 0  _seen_[_i_] = 1  ok
		next
		_a_ = []
		for _i_ = 1 to @oF.Count()
			if _seen_[_i_] = 0  _a_ + @oF.NameOf(_i_)  ok
		next
		return _a_

func _GeoLookup(paPairs, pcKey)
	for _i_ = 1 to len(paPairs)
		if paPairs[_i_][1] = pcKey  return paPairs[_i_][2]  ok
	next
	return 0

# THE LIBRARY'S OWN COUNTRY TABLE is the authority for codes, and this file
# does not keep a second one. It answers the country's name for a two- or
# three-letter code, or "" -- which the caller's own file then has to know
# under some spelling.
func _GeoCountryNameOfCode(pcCode)
	_c_ = StzUpper(ring_trim("" + pcCode))
	_a_ = LocaleCountriesXT()
	for _i_ = 1 to len(_a_)
		if StzUpper("" + _a_[_i_][3]) = _c_ or StzUpper("" + _a_[_i_][4]) = _c_
			return StzReplace("" + _a_[_i_][2], "_", " ")
		ok
	next
	return ""
