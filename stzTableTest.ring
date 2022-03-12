load "stzlib.ring"

aMyTable = 
[
	[ "Nb",	    "Name" ,   "Salary" ],
	[    1,	  "Omrane" ,      35000 ],
	[    2,   "Kahlil" ,      12890 ],
	[    3,    "Aziza" ,       5200 ]
]

o1 = new stzTable(aMyTable)

? o1.FindCol("Salary")
? o1.ToString()
