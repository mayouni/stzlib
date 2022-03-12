load "softanzalib.ring"

aList = [ 
	:name = "Mansour",
	:age = 45,
	:job = "Programmer",
	:freind = "Selmen"
]

StzHashListQ(aList) {
	Show()
	? ""

	AddPair( :country = "Tunisia" )

	UpdateNthPair( 2, :agex = 45 )

	UpdatePair( :job = "Programmer", :profession = "Developer" )

	Show()
}

