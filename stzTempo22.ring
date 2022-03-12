load "softanzalib.ring"

o1 = new stzGrid(9)
o1 {
	//ShowRanks = TRUE
	
	SetVLine(1, "A":"C")
	SetVLine(2, "1":"3")
	SetVLine(3, "E":"G")
	Show()

	SwapVLinesAndHLines()
	Show()
}

/*-----------------

o1 = new stzGrid([ [ 1, 2, 3 ],
		   [ 4, 5, 6 ],
		   [ 7, 8, 9 ]
		 ])

o1 {
	Show()
	SwapVLinesAndHLines()
	Show()
}

/*-----------------

a = [
	[ 1, 2, 3 ],
	[ 4, 5, 6 ],
	[ 7, 8, 9 ]
]

/*-----------------

o1 = new stzList([])
? o1.MergeMany(a)

/*-----------------

StzGrid(a) {
	Show()

	SwapLines()
	Show()

	ReverseHLines()
	Show()

	ReverseVLines()
	Show()

	? Diagonal1()
	? Diagonal2()

	ReverseNodes()
	Show()
}


