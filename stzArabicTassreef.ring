Load "SoftanzaLib.ring"
/*
// Use of a functional style, in english
? Tassreef("ذهب", Dhameer(:Mukhaatab), Jins(:Mudhakkar), Zamen(:Maadhi) )


// Same functional style but in arabic
? تصريف("رجع", ضمير(:مخاطَب), جنس(:مؤنّث), زمن(:ماضي))

// Use of declarative style, in english
ot = new Tassreef {
	cFi3l = "خرج"
	cDhameer = Dhameer(:Mukhaatab)
	cJins = Jins(:Muannath)
	cZamen = Zamen(:Maadhi)

	exec()	// Compute the Tassreef operation
	show()	// Show the verb after beeing conjugated
}
*/

of = new Fi3l("ترك")
? of.TassreefAll()

#----------------#
#   FUNCTIONS    #
#----------------#

func Tassreef( pcFi3l, pcDhameer, pcJins, pcZamen)
	o1 = new Fi3l(pcFi3l)
	return o1.Tassreef(pcDhameer, pcJins, pcZamen)

	// Arabic version
	func تصريف( pcFi3l, pcDhameer, pcJins, pcZamen )
		return Tassreef( pcFi3l, pcDhameer, pcJins, pcZamen)

func Dhameer(pcValue)
	switch pcValue
	on :Mutèkèllim	or 1 return "متكلّم"	
	on :Mukhaatab	return "مخاطَب"
	on :Ghaaib	return "غائب"

	on :متكلّم	return "متكلّم"	
	on :مخاطَب	return "مخاطَب"
	on :غائب	return "غائب"
	off

	// Arabic version
	func ضمير(pcValue)
		return Dhameer(pcValue)

func Jins(pcValue)
	switch pcValue
	on :Mudhakkar	return "مذكّر"
	on :Muannath	return "مؤنّث"

	on :مذكّر	return "مذكّر"
	on :مؤنّث	return "مؤنّث"
	off

	// Arabic version
	func جنس(pcValue)
		return Jins(pcValue)

func Zamen(pcValue)
	switch pcValue
	on :Haadhir	return "حاضر"
	on :Maadhi	return "ماضي"
	on :Mustakbal	return "مستقبل"

	// Arabic version
	on :حاضر	return "حاضر"
	on :ماضي	return "ماضي"
	on :مستقبل	return "مستقبل"
	off
	func زمن(pcValue)
		return Zamen(pcValue)

func Harf(pcValue)
	switch pcValue
	on :Hamzah		return "أ"
	on :Alif		return "ا"
	on :shaddah		return "ّ"
	on :TèèMarbootah	return "ة"
	on :TèèMaftoohah	return "ت"
	on :Yèè			return "ي"
	on :Seen		return "س"
	off 

func Chakl(pcValue)
	switch pcValue
	on :Dhammah	return "ُ"
	on :Dhammah2	return "ُُ"
	on :Fathah	return "َ"
	on :Fathah2	return "ََ"
	on :Kasrah	return "ِ"
	on :Kasrah2	return "ِِ"
	off

func Tinween(pcKalimah)
	cResult = pcKalimah
	oKalimah = new stzString(pcKalimah)

	switch oKalimah[ oKalimah.NumberOfChars() ]
	on Chakl(:Dhammah)	# Add stzLast(:Letter)
		cResult += Chakl(:Dhammah)
	on Chakl(:Ftahah)
		cResult += Chakl(:Ftahah)
	on Chakl(:Kasrah)
		cResult += Chakl(:Kasrah)
	off

	return cResult

func IsFi3l(pcKalimah)
	If IsTinween(pcKalimah) or
	   EkherHarf(pcKalimah) = Harf(:TèèMarbootah)
		return FALSE
	else
		return MAYBE # TODO: Add MAYBE as a 3rd logical variable along with TRUE and FALSE
	ok

func IsTinween(pcKalimah)
	oKalimah = new stzString(pcKalimah)
	cLastTwoChars = oKalimah.stzLeft(2)

	if cLastTwoChars = Chakl(:Dhammah2) or
	   cLastTwoChars = Chakl(:Fathah2) or
	   cLastTwoChars = Chakl(:Kasrah2)
		return TRUE
	else
		return FALSE
	ok

func GetTinween(pcKalimah)
	oKalimah = new stzString(pcKalimah)
	cLastTwoChars = oKalimah.NLeftChars(2)
	
	switch cLastTwoChars
	on Chakl(:Dhammah2)	return :Dhammah2
	on Chakl(:Fathah2)	return :Fathah2
	on Chakl(:Kasrah2)	return :Kasrah2
	off 

func EkherHarf(pcKalimah)
	oKalimah = new stzString(pcKalimah)
	return oKalimah.NLeftChars(1)


#-----------------#
#     CLASSES     #
#-----------------#

Class Tassreef
	cFi3l
	cDhameer
	cJins
	cZamen
	cResult

	def exec()
		o1 = new Fi3l(cFi3l)
		cResult = o1.Tassreef(cDhameer, cJins, cZamen)

	def show()
		? cResult

Class Fi3l
	cContent = "فعل"
	bExtended = TRUE
	
	def init(pcStr)
		if pcStr != NULL
			cContent = pcStr
		ok

	def Content()
		return cContent

	def Jidhr()
		return Content()

	def Tassreef(pcDhameer, pcJins, pcZamen)

		cResult = ""
		/*
		switch Zamen
		on Maadhi
			switch Dhameer
			on Mutèkèllim
			on Mukhataba
			on Ghaaib
		on Haadhir
			Idem
		on Mustakbil
			Idem
		off
		*/
		switch pcZamen
		on Zamen(:Maadhi)

			switch pcDhameer
			on Dhameer(:Mutèkèllim)

				cResult = Jidhr() + "تُ"
				if bExtended
					cResult = "أنا " + cResult
				ok

			on Dhameer(:Mukhaatab)
				switch pcJins
				on Jins(:Mudhakkar)
					cResult =  Jidhr() + "تَ"
					if bExtended
						cResult = "أنتَ " + cResult
					ok

				on Jins(:Muannath)
					cResult =  Jidhr() + "تِ"
					if bExtended
						cResult = "أنتِ " + cResult
					ok
				off

			on Dhameer(:Ghaaib)

				switch pcJins
				on Jins(:Mudhakkar)
					cResult =  Jidhr()
					if bExtended
						cResult = "هو " + cResult
					ok

				on Jins(:Muannath)
					cResult =  Jidhr() + "تْ"
					if bExtended
						cResult = "هي " + cResult
					ok
				off
			off

		on Zamen(:Haadhir)
			switch pcDhameer
			on Dhameer(:Mutèkèllim)
				cResult = Harf(:Hamzah) + Jidhr() + Chakl(:Dhammah)
				if bExtended
					cResult = "أنا " + cResult
				ok

			on Dhameer(:Mukhaatab)
				switch pcJins
				on Jins(:Mudhakkar)
					cResult =  Jidhr() + "تَ"
					if bExtended
						cResult = "أنتَ " + cResult
					ok

				on Jins(:Muannath)
					cResult =  Jidhr() + "تِ"
					if bExtended
						cResult = "أنتِ " + cResult
					ok
				off

			on Dhameer(:Ghaaib)

				switch pcJins
				on Jins(:Mudhakkar)
					cResult =  Jidhr()
					if bExtended
						cResult = "هو " + cResult
					ok

				on Jins(:Muannath)
					cResult =  Jidhr() + "تْ"
					if bExtended
						cResult = "هي " + cResult
					ok
				off
			off

		on Zamen(:Mustakbal)
			switch pcDhameer
			on Dhameer(:Mutèkèllim)
				cResult = Harf(:Seen) + Harf(:Hamzah) + Jidhr() + Chakl(:Dhammah)
				if bExtended
					cResult = "أنا " + cResult
				ok

			on Dhameer(:Mukhaatab)
				switch pcJins
				on Jins(:Mudhakkar)
					cResult =  Harf(:Seen) + Harf(:TèèMaftoohah) + Jidhr()
					if bExtended
						cResult = "أنتَ " + cResult
					ok

				on Jins(:Muannath)
					cResult =  Harf(:Seen) + Harf(:TèèMaftoohah) + Jidhr() + "ين"
					if bExtended
						cResult = "أنتِ " + cResult
					ok
				off

			on Dhameer(:Ghaaib)

				switch pcJins
				on Jins(:Mudhakkar)
					cResult =  Harf(:Seen) + Harf(:Yèè) + Jidhr() + Chakl(:Dhammah)
					if bExtended
						cResult = "هو " + cResult
					ok

				on Jins(:Muannath)
					cResult =  Harf(:Seen) + Harf(:TèèMaftouhah) + Jidhr()
					if bExtended
						cResult = "هي " + cResult
					ok
				off
			off
		
		off

		return cResult

	func TassreefAll()
		aZamen = [ :Maadhi, :Haadhir, :Mustakbal  ]
		? Tassreef(Dhameer(:Mutèkèllim), Jins(:Male), aZamen[1])
		/*
		for cZamen in aZamen
			? cZamen + " : "
			? tab + "Dhameer Mutèkèllim - Male   : " + Tassreef(:Mutèkèllim, :Male, :cZamen)
			? tab + "Dhameer Mutèkèllim - Female : " + Tassreef(:Mutèkèllim, :Female, cZamen)
			? ""
			? tab + "Dhameer Mukhatab: "	 	 + Tassreef(:Mukhatab, :Male, cZamen)
			? tab + "Dhameer Mukhatab - Female   : " + Tassreef(:Mukhatab, :Female, cZamen)
			? ""
			? tab + "Dhameer Ghaaib: " 		 + Tassreef(:Ghaaib, :Male, cZamen)
			? tab + "Dhameer Ghaaib - Female   : "	 + Tassreef(:Ghaaib, :Female, cZamen)
			? ""
		next
