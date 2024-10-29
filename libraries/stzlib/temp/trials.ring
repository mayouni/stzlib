load "../stzlib.ring"

/*----------

pron()

o1 = new stzString("phpringringringpythonrubyruby")

? o1.NumberOfConsecutiveSubStringsOfNChars(4) + NL
#--> 26

? o1.ConsecutiveSubStringsOfNChars(4)
#--> [
#	"phpr", "ingr", "ingr", "ingp", "ytho", "nrub", "yrub",
#	"hpri", "ngri", "ngri", "ngpy", "thon", "ruby", "ruby",
#	"prin", "grin", "grin", "gpyt", "honr", "ubyr", "ring",
#	"ring", "ring", "pyth", "onru", "byru"
# ]


? o1.FindConsecutiveSubStringsOfNChars(4)
#--> [ 1, 2, 3, 4 ]

? @@NL( o1.FindConsecutiveSubStringsOfNCharsZZ(4) ) + NL
#--> [
#	[ 1, 4 ], [ 5, 8 ], [ 9, 12 ], [ 13, 16 ], [ 17, 20 ], [ 21, 24 ], [ 25, 28 ],
#	[ 2, 5 ], [ 6, 9 ], [ 10, 13 ], [ 14, 17 ], [ 18, 21 ], [ 22, 25 ], [ 26, 29 ],
#	[ 3, 6 ], [ 7, 10 ], [ 11, 14 ], [ 15, 18 ], [ 19, 22 ], [ 23, 26 ],
#	[ 4, 7 ], [ 8, 11 ], [ 12, 15 ], [ 16, 19 ], [ 20, 23 ], [ 24, 27 ]
# ]

? @@( o1.ConsecutiveSubStringsOfNCharsZ(4) ) + NL
#--> [
#	[ "phpr", 1 ], [ "ingr", 5 ], [ "ingr", 9 ], [ "ingp", 13 ], [ "ytho", 17 ],
#	[ "nrub", 21 ], [ "yrub", 25 ], [ "hpri", 2 ], [ "ngri", 6 ], [ "ngri", 10 ],
#	[ "ngpy", 14 ], [ "thon", 18 ], [ "ruby", 22 ], [ "ruby", 26 ], [ "prin", 3 ],
#	[ "grin", 7 ], [ "grin", 11 ], [ "gpyt", 15 ], [ "honr", 19 ], [ "ubyr", 23 ],
#	[ "ring", 4 ], [ "ring", 8 ], [ "ring", 12 ], [ "pyth", 16 ], [ "onru", 20 ],
#	[ "byru", 24 ]
# ]

? @@( o1.ConsecutiveSubStringsOfNCharsZZ(4) )
#--> [
#	[ "phpr", [ 1, 4 ] ], [ "ingr", [ 5, 8 ] ], [ "ingr", [ 9, 12 ] ],
#	[ "ingp", [ 13, 16 ] ], [ "ytho", [ 17, 20 ] ], [ "nrub", [ 21, 24 ] ],
#	[ "yrub", [ 25, 28 ] ], [ "hpri", [ 2, 5 ] ], [ "ngri", [ 6, 9 ] ],
#	[ "ngri", [ 10, 13 ] ], [ "ngpy", [ 14, 17 ] ], [ "thon", [ 18, 21 ] ],
#	[ "ruby", [ 22, 25 ] ], [ "ruby", [ 26, 29 ] ], [ "prin", [ 3, 6 ] ],
#	[ "grin", [ 7, 10 ] ], [ "grin", [ 11, 14 ] ], [ "gpyt", [ 15, 18 ] ],
#	[ "honr", [ 19, 22 ] ], [ "ubyr", [ 23, 26 ] ], [ "ring", [ 4, 7 ] ],
#	[ "ring", [ 8, 11 ] ], [ "ring", [ 12, 15 ] ], [ "pyth", [ 16, 19 ] ],
#	[ "onru", [ 20, 23 ] ], [ "byru", [ 24, 27 ] ] 
# ]

proff()
# Executed in 0.02 second(s).

/*-----------
*/
pron()

o1 = new stzString("phpringringringpythonrubyruby")
? o1.NumberOfConsecutiveSubStrings()
#--> 315
/*
? @@( o1.ConsecutiveSubStrings() ) + NL
#--> [
#	"p", "h", "p", "r", "i", "n", "g", "r", "i", "n", "g",
#	"r", "i", "n", "g", "p", "y", "t", "h", "o", "n", "r",
#	"u", "b", "y", "r", "u", "b", "y",
#
#	"ph", "pr", "in", "gr", "in", "gr", "in", "gp", "yt",
#	"ho", "nr", "ub", "yr", "ub", "hp", "ri", "ng", "ri",
#	"ng", "ri", "ng", "py", "th", "on", "ru", "by", "ru",
#	"by",
#
#	"php", "rin", "gri", "ngr", "ing", "pyt", "hon", "rub",
#	"yru", "hpr", "ing", "rin", "gri", "ngp", "yth", "onr",
#	"uby", "rub", "pri", "ngr", "ing", "rin", "gpy", "tho",
#	"nru", "byr", "uby", "phpr", "ingr", "ingr",
#
#	"ingp", "ytho", "nrub", "yrub", "hpri", "ngri", "ngri",
#	"ngpy", "thon", "ruby", "ruby", "prin", "grin", "grin",
#	"gpyt", "honr", "ubyr", "ring", "ring", "ring", "pyth",
#	"onru", "byru",
#
#	"phpri", "ngrin", "gring", "pytho", "nruby", "hprin",
#	"gring", "ringp", "ython", "rubyr", "pring", "ringr",
#	"ingpy", "thonr", "ubyru", "ringr", "ingri", "ngpyt",
#	"honru", "byrub", "ingri", "ngrin", "gpyth", "onrub",
#	"yruby",
#
#	"phprin", "gringr", "ingpyt", "honrub", "hpring", "ringri",
#	"ngpyth", "onruby", "pringr", "ingrin", "gpytho", "nrubyr",
#	"ringri", "ngring", "python", "rubyru", "ingrin", "gringp",
#	"ythonr", "ubyrub", "ngring", "ringpy", "thonru", "byruby",
#
#	"phpring", "ringrin", "gpython", "rubyrub", "hpringr", "ingring",
#	"pythonr", "ubyruby", "pringri", "ngringp", "ythonru", "ringrin",
#	"gringpy", "thonrub", "ingring", "ringpyt", "honruby", "ngringr",
#	"ingpyth", "onrubyr", "gringri", "ngpytho", "nrubyru",
#
#	"phpringr", "ingringp", "ythonrub", "hpringri", "ngringpy",
#	"thonruby", "pringrin", "gringpyt", "honrubyr", "ringring",
#	"ringpyth", "onrubyru", "ingringr", "ingpytho", "nrubyrub",
#	"ngringri", "ngpython", "rubyruby", "gringrin", "gpythonr",
#	"ringring", "pythonru",
#
#	"phpringri", "ngringpyt", "honrubyru", "hpringrin", "gringpyth",
#	"onrubyrub", "pringring", "ringpytho", "nrubyruby", "ringringr",
#	"ingpython", "ingringri", "ngpythonr", "ngringrin", "gpythonru",
#	"gringring", "pythonrub", "ringringp", "ythonruby", "ingringpy",
#	"thonrubyr",
#
#	"phpringrin", "gringpytho", "hpringring", "ringpython", "pringringr",
#	"ingpythonr", "ringringri", "ngpythonru", "ingringrin", "gpythonrub",
#	"ngringring", "pythonruby", "gringringp", "ythonrubyr", "ringringpy",
#	"thonrubyru", "ingringpyt", "honrubyrub", "ngringpyth", "onrubyruby",
#
#	"phpringring", "ringpythonr", "hpringringr", "ingpythonru", "pringringri",
#	"ngpythonrub", "ringringrin", "gpythonruby", "ingringring", "pythonrubyr",
#	"ngringringp", "ythonrubyru", "gringringpy", "thonrubyrub", "ringringpyt",
#	"honrubyruby", "ingringpyth", "ngringpytho", "gringpython",
#
#	"phpringringr", "ingpythonrub", "hpringringri", "ngpythonruby",
#	"pringringrin", "gpythonrubyr", "ringringring", "pythonrubyru",
#	"ingringringp", "ythonrubyrub", "ngringringpy", "thonrubyruby",
#	"gringringpyt", "ringringpyth", "ingringpytho", "ngringpython",
#	"gringpythonr", "ringpythonru",
#
#	"phpringringri", "ngpythonrubyr", "hpringringrin", "gpythonrubyru",
#	"pringringring", "pythonrubyrub", "ringringringp", "ythonrubyruby",
#	"ingringringpy", "ngringringpyt", "gringringpyth", "ringringpytho",
#	"ingringpython", "ngringpythonr", "gringpythonru", "ringpythonrub",
#	"ingpythonruby", "phpringringrin",
#
#	"gpythonrubyrub", "hpringringring", "pythonrubyruby", "pringringringp",
#	"ringringringpy", "ingringringpyt", "ngringringpyth", "gringringpytho",
#	"ringringpython", "ingringpythonr", "ngringpythonru", "gringpythonrub",
#	"ringpythonruby", "ingpythonrubyr", "ngpythonrubyru"
# ]

? @@( o1.FindConsecutiveSubStrings() ) + NL
#--> [
#	1, 2, 3, 4, 5, 6, 7, 8, 9, 10, 11, 12,
#	13, 14, 15, 16, 17, 18, 19, 20, 21, 22,
#	23, 24, 25, 26, 27, 28, 29
# ]

? @@( o1.FindconsecutiveSubStringsZZ() ) + NL
#--> [
#	[ 1, 1 ], [ 2, 2 ], [ 3, 3 ], [ 4, 4 ], [ 5, 5 ], [ 6, 6 ], [ 7, 7 ],
#	[ 8, 8 ], [ 9, 9 ], [ 10, 10 ], [ 11, 11 ], [ 12, 12 ], [ 13, 13 ],
#	[ 14, 14 ], [ 15, 15 ], [ 16, 16 ], [ 17, 17 ], [ 18, 18 ], [ 19, 19 ],
#	[ 20, 20 ], [ 21, 21 ], [ 22, 22 ], [ 23, 23 ], [ 24, 24 ], [ 25, 25 ],
#	[ 26, 26 ], [ 27, 27 ], [ 28, 28 ], [ 29, 29 ],
#
#	[ 1, 2 ], [ 2, 3 ], [ 3, 4 ], [ 4, 5 ], [ 5, 6 ], [ 6, 7 ], [ 7, 8 ],
#	[ 8, 9 ], [ 9, 10 ], [ 10, 11 ], [ 11, 12 ], [ 12, 13 ], [ 13, 14 ],
#	[ 14, 15 ], [ 15, 16 ], [ 16, 17 ], [ 17, 18 ], [ 18, 19 ], [ 19, 20 ],
#	[ 20, 21 ], [ 21, 22 ], [ 22, 23 ], [ 23, 24 ], [ 24, 25 ], [ 25, 26 ],
#	[ 26, 27 ], [ 27, 28 ], [ 28, 29 ],
#
#	[ 1, 3 ], [ 2, 4 ], [ 3, 5 ], [ 4, 6 ], [ 5, 7 ], [ 6, 8 ], [ 7, 9 ],
#	[ 8, 10 ], [ 9, 11 ], [ 10, 12 ], [ 11, 13 ], [ 12, 14 ], [ 13, 15 ],
#	[ 14, 16 ], [ 15, 17 ], [ 16, 18 ], [ 17, 19 ], [ 18, 20 ], [ 19, 21 ],
#	[ 20, 22 ], [ 21, 23 ], [ 22, 24 ], [ 23, 25 ], [ 24, 26 ], [ 25, 27 ],
#	[ 26, 28 ], [ 27, 29 ],
#
#	[ 1, 4 ], [ 2, 5 ], [ 3, 6 ], [ 4, 7 ], [ 5, 8 ], [ 6, 9 ], [ 7, 10 ],
#	[ 8, 11 ], [ 9, 12 ], [ 10, 13 ], [ 11, 14 ], [ 12, 15 ], [ 13, 16 ],
#	[ 14, 17 ], [ 15, 18 ], [ 16, 19 ], [ 17, 20 ], [ 18, 21 ], [ 19, 22 ],
#	[ 20, 23 ], [ 21, 24 ], [ 22, 25 ], [ 23, 26 ], [ 24, 27 ], [ 25, 28 ],
#	[ 26, 29 ],
#
#	[ 1, 5 ], [ 2, 6 ], [ 3, 7 ], [ 4, 8 ], [ 5, 9 ], [ 6, 10 ], [ 7, 11 ],
#	[ 8, 12 ], [ 9, 13 ], [ 10, 14 ], [ 11, 15 ], [ 12, 16 ], [ 13, 17 ],
#	[ 14, 18 ], [ 15, 19 ], [ 16, 20 ], [ 17, 21 ], [ 18, 22 ], [ 19, 23 ],
#	[ 20, 24 ], [ 21, 25 ], [ 22, 26 ], [ 23, 27 ], [ 24, 28 ], [ 25, 29 ],
#
#	[ 1, 6 ], [ 2, 7 ], [ 3, 8 ], [ 4, 9 ], [ 5, 10 ], [ 6, 11 ], [ 7, 12 ],
#	[ 8, 13 ], [ 9, 14 ], [ 10, 15 ], [ 11, 16 ], [ 12, 17 ], [ 13, 18 ],
#	[ 14, 19 ], [ 15, 20 ], [ 16, 21 ], [ 17, 22 ], [ 18, 23 ], [ 19, 24 ],
#	[ 20, 25 ], [ 21, 26 ], [ 22, 27 ], [ 23, 28 ], [ 24, 29 ],
#
#	[ 1, 7 ], [ 2, 8 ], [ 3, 9 ], [ 4, 10 ], [ 5, 11 ], [ 6, 12 ], [ 7, 13 ],
#	[ 8, 14 ], [ 9, 15 ], [ 10, 16 ], [ 11, 17 ], [ 12, 18 ], [ 13, 19 ],
#	[ 14, 20 ], [ 15, 21 ], [ 16, 22 ], [ 17, 23 ], [ 18, 24 ], [ 19, 25 ],
#	[ 20, 26 ], [ 21, 27 ], [ 22, 28 ], [ 23, 29 ],
#
#	[ 1, 8 ], [ 2, 9 ], [ 3, 10 ], [ 4, 11 ], [ 5, 12 ], [ 6, 13 ], [ 7, 14 ],
#	[ 8, 15 ], [ 9, 16 ], [ 10, 17 ], [ 11, 18 ], [ 12, 19 ], [ 13, 20 ],
#	[ 14, 21 ], [ 15, 22 ], [ 16, 23 ], [ 17, 24 ], [ 18, 25 ], [ 19, 26 ],
#	[ 20, 27 ], [ 21, 28 ], [ 22, 29 ],
#
#	[ 1, 9 ], [ 2, 10 ], [ 3, 11 ], [ 4, 12 ], [ 5, 13 ], [ 6, 14 ], [ 7, 15 ],
#	[ 8, 16 ], [ 9, 17 ], [ 10, 18 ], [ 11, 19 ], [ 12, 20 ], [ 13, 21 ],
#	[ 14, 22 ], [ 15, 23 ], [ 16, 24 ], [ 17, 25 ], [ 18, 26 ], [ 19, 27 ],
#	[ 20, 28 ], [ 21, 29 ],
#
#	[ 1, 10 ], [ 2, 11 ], [ 3, 12 ], [ 4, 13 ], [ 5, 14 ], [ 6, 15 ], [ 7, 16 ],
#	[ 8, 17 ], [ 9, 18 ], [ 10, 19 ], [ 11, 20 ], [ 12, 21 ], [ 13, 22 ],
#	[ 14, 23 ], [ 15, 24 ], [ 16, 25 ], [ 17, 26 ], [ 18, 27 ], [ 19, 28 ],
#	[ 20, 29 ],
#
#	[ 1, 11 ], [ 2, 12 ], [ 3, 13 ], [ 4, 14 ], [ 5, 15 ], [ 6, 16 ], [ 7, 17 ],
#	[ 8, 18 ], [ 9, 19 ], [ 10, 20 ], [ 11, 21 ], [ 12, 22 ], [ 13, 23 ],
#	[ 14, 24 ], [ 15, 25 ], [ 16, 26 ], [ 17, 27 ], [ 18, 28 ], [ 19, 29 ],
#
#	[ 1, 12 ], [ 2, 13 ], [ 3, 14 ], [ 4, 15 ], [ 5, 16 ], [ 6, 17 ], [ 7, 18 ],
#	[ 8, 19 ], [ 9, 20 ], [ 10, 21 ], [ 11, 22 ], [ 12, 23 ], [ 13, 24 ],
#	[ 14, 25 ], [ 15, 26 ], [ 16, 27 ], [ 17, 28 ], [ 18, 29 ],
#
#	[ 1, 13 ], [ 2, 14 ], [ 3, 15 ], [ 4, 16 ], [ 5, 17 ], [ 6, 18 ], [ 7, 19 ],
#	[ 8, 20 ], [ 9, 21 ], [ 10, 22 ], [ 11, 23 ], [ 12, 24 ], [ 13, 25 ],
#	[ 14, 26 ], [ 15, 27 ], [ 16, 28 ], [ 17, 29 ],
#
#	[ 1, 14 ], [ 2, 15 ], [ 3, 16 ], [ 4, 17 ], [ 5, 18 ], [ 6, 19 ], [ 7, 20 ],
#	[ 8, 21 ], [ 9, 22 ], [ 10, 23 ], [ 11, 24 ], [ 12, 25 ], [ 13, 26 ],
#	[ 14, 27 ], [ 15, 28 ], [ 16, 29 ]
# ]
=
? @@( o1.ConsecutiveSubStringsZ() ) + NL
#--> [
#	[ "p", 1 ], [ "hp", 2 ], [ "pri", 3 ], [ "ring", 4 ], [ "ingri", 5 ],
#	[ "ngring", 6 ], [ "gringri", 7 ], [ "ringring", 8 ], [ "ingringpy", 9 ],
#	[ "ngringpyth", 10 ], [ "gringpython", 11 ], [ "ringpythonru", 12 ],
#	[ "ingpythonruby", 13 ], [ "ngpythonrubyru", 14 ], [ "gpythonrubyruby", 15 ],
#	[ "pythonrubyruby", 16 ], [ "ythonrubyruby", 17 ], [ "thonrubyruby", 18 ],
#	[ "honrubyruby", 19 ], [ "onrubyruby", 20 ], [ "nrubyruby", 21 ],
#	[ "rubyruby", 22 ], [ "ubyruby", 23 ], [ "byruby", 24 ],
#	[ "yruby", 25 ], [ "ruby", 26 ], [ "uby", 27 ], [ "by", 28 ],
#	[ "y", 29 ],
#
#	[ "ph", 1 ], [ "hpr", 2 ], [ "prin", 3 ], [ "ringr", 4 ], [ "ingrin", 5 ],
#	[ "ngringr", 6 ], [ "gringrin", 7 ], [ "ringringp", 8 ], [ "ingringpyt", 9 ],
#	[ "ngringpytho", 10 ], [ "gringpythonr", 11 ], [ "ringpythonrub", 12 ],
#	[ "ingpythonrubyr", 13 ], [ "ngpythonrubyrub", 14 ], [ "gpythonrubyruby", 15 ],
#	[ "pythonrubyruby", 16 ], [ "ythonrubyruby", 17 ], [ "thonrubyruby", 18 ],
#	[ "honrubyruby", 19 ], [ "onrubyruby", 20 ], [ "nrubyruby", 21 ], [ "rubyruby", 22 ],
#	[ "ubyruby", 23 ], [ "byruby", 24 ], [ "yruby", 25 ], [ "ruby", 26 ], [ "uby", 27 ],
#	[ "by", 28 ],
#
#	[ "php", 1 ], [ "hpri", 2 ], [ "pring", 3 ], [ "ringri", 4 ], [ "ingring", 5 ],
#	[ "ngringri", 6 ], [ "gringring", 7 ], [ "ringringpy", 8 ], [ "ingringpyth", 9 ],
#	[ "ngringpython", 10 ], [ "gringpythonru", 11 ], [ "ringpythonruby", 12 ],
#	[ "ingpythonrubyru", 13 ], [ "ngpythonrubyruby", 14 ], [ "gpythonrubyruby", 15 ],
#	[ "pythonrubyruby", 16 ], [ "ythonrubyruby", 17 ], [ "thonrubyruby", 18 ],
#	[ "honrubyruby", 19 ], [ "onrubyruby", 20 ], [ "nrubyruby", 21 ], [ "rubyruby", 22 ],
#	[ "ubyruby", 23 ], [ "byruby", 24 ], [ "yruby", 25 ], [ "ruby", 26 ], [ "uby", 27 ],
#
#	[ "phpr", 1 ], [ "hprin", 2 ], [ "pringr", 3 ], [ "ringrin", 4 ], [ "ingringr", 5 ],
#	[ "ngringrin", 6 ], [ "gringringp", 7 ], [ "ringringpyt", 8 ], [ "ingringpytho", 9 ],
#	[ "ngringpythonr", 10 ], [ "gringpythonrub", 11 ], [ "ringpythonrubyr", 12 ],
#	[ "ingpythonrubyrub", 13 ], [ "ngpythonrubyruby", 14 ], [ "gpythonrubyruby", 15 ],
#	[ "pythonrubyruby", 16 ], [ "ythonrubyruby", 17 ], [ "thonrubyruby", 18 ],
#	[ "honrubyruby", 19 ], [ "onrubyruby", 20 ], [ "nrubyruby", 21 ], [ "rubyruby", 22 ],
#	[ "ubyruby", 23 ], [ "byruby", 24 ], [ "yruby", 25 ], [ "ruby", 26 ],
#
#	[ "phpri", 1 ], [ "hpring", 2 ], [ "pringri", 3 ], [ "ringring", 4 ],
#	[ "ingringri", 5 ], [ "ngringring", 6 ], [ "gringringpy", 7 ], [ "ringringpyth", 8 ],
#	[ "ingringpython", 9 ], [ "ngringpythonru", 10 ], [ "gringpythonruby", 11 ],
#	[ "ringpythonrubyru", 12 ], [ "ingpythonrubyruby", 13 ], [ "ngpythonrubyruby", 14 ],
#	[ "gpythonrubyruby", 15 ], [ "pythonrubyruby", 16 ], [ "ythonrubyruby", 17 ],
#	[ "thonrubyruby", 18 ], [ "honrubyruby", 19 ], [ "onrubyruby", 20 ],
#	[ "nrubyruby", 21 ], [ "rubyruby", 22 ], [ "ubyruby", 23 ], [ "byruby", 24 ],
#	[ "yruby", 25 ],
#
#	[ "phprin", 1 ], [ "hpringr", 2 ], [ "pringrin", 3 ], [ "ringringr", 4 ],
#	[ "ingringrin", 5 ], [ "ngringringp", 6 ], [ "gringringpyt", 7 ],
#	[ "ringringpytho", 8 ], [ "ingringpythonr", 9 ], [ "ngringpythonrub", 10 ],
#	[ "gringpythonrubyr", 11 ], [ "ringpythonrubyrub", 12 ], [ "ingpythonrubyruby", 13 ],
#	[ "ngpythonrubyruby", 14 ], [ "gpythonrubyruby", 15 ], [ "pythonrubyruby", 16 ],
#	[ "ythonrubyruby", 17 ], [ "thonrubyruby", 18 ], [ "honrubyruby", 19 ],
#	[ "onrubyruby", 20 ], [ "nrubyruby", 21 ], [ "rubyruby", 22 ], [ "ubyruby", 23 ],
#	[ "byruby", 24 ],
#
#	[ "phpring", 1 ], [ "hpringri", 2 ], [ "pringring", 3 ], [ "ringringri", 4 ],
#	[ "ingringring", 5 ], [ "ngringringpy", 6 ], [ "gringringpyth", 7 ],
#	[ "ringringpython", 8 ], [ "ingringpythonru", 9 ], [ "ngringpythonruby", 10 ],
#	[ "gringpythonrubyru", 11 ], [ "ringpythonrubyruby", 12 ], [ "ingpythonrubyruby", 13 ],
#	[ "ngpythonrubyruby", 14 ], [ "gpythonrubyruby", 15 ], [ "pythonrubyruby", 16 ],
#	[ "ythonrubyruby", 17 ], [ "thonrubyruby", 18 ], [ "honrubyruby", 19 ],
#	[ "onrubyruby", 20 ], [ "nrubyruby", 21 ], [ "rubyruby", 22 ], [ "ubyruby", 23 ],
#
#	[ "phpringr", 1 ], [ "hpringrin", 2 ], [ "pringringr", 3 ], [ "ringringrin", 4 ],
#	[ "ingringringp", 5 ], [ "ngringringpyt", 6 ], [ "gringringpytho", 7 ],
#	[ "ringringpythonr", 8 ], [ "ingringpythonrub", 9 ], [ "ngringpythonrubyr", 10 ],
#	[ "gringpythonrubyrub", 11 ], [ "ringpythonrubyruby", 12 ], [ "ingpythonrubyruby", 13 ],
#	[ "ngpythonrubyruby", 14 ], [ "gpythonrubyruby", 15 ], [ "pythonrubyruby", 16 ],
#	[ "ythonrubyruby", 17 ], [ "thonrubyruby", 18 ], [ "honrubyruby", 19 ],
#	[ "onrubyruby", 20 ], [ "nrubyruby", 21 ], [ "rubyruby", 22 ],
#
#	[ "phpringri", 1 ], [ "hpringring", 2 ], [ "pringringri", 3 ], [ "ringringring", 4 ],
#	[ "ingringringpy", 5 ], [ "ngringringpyth", 6 ], [ "gringringpython", 7 ],
#	[ "ringringpythonru", 8 ], [ "ingringpythonruby", 9 ], [ "ngringpythonrubyru", 10 ],
#	[ "gringpythonrubyruby", 11 ], [ "ringpythonrubyruby", 12 ], [ "ingpythonrubyruby", 13 ],
#	[ "ngpythonrubyruby", 14 ], [ "gpythonrubyruby", 15 ], [ "pythonrubyruby", 16 ],
#	[ "ythonrubyruby", 17 ], [ "thonrubyruby", 18 ], [ "honrubyruby", 19 ],
#	[ "onrubyruby", 20 ], [ "nrubyruby", 21 ],
#
#	[ "phpringrin", 1 ], [ "hpringringr", 2 ], [ "pringringrin", 3 ], [ "ringringringp", 4 ],
#	[ "ingringringpyt", 5 ], [ "ngringringpytho", 6 ], [ "gringringpythonr", 7 ],
#	[ "ringringpythonrub", 8 ], [ "ingringpythonrubyr", 9 ], [ "ngringpythonrubyrub", 10 ],
#	[ "gringpythonrubyruby", 11 ], [ "ringpythonrubyruby", 12 ], [ "ingpythonrubyruby", 13 ],
#	[ "ngpythonrubyruby", 14 ], [ "gpythonrubyruby", 15 ], [ "pythonrubyruby", 16 ],
#	[ "ythonrubyruby", 17 ], [ "thonrubyruby", 18 ], [ "honrubyruby", 19 ],	[ "onrubyruby", 20 ],
#
#	[ "phpringring", 1 ], [ "hpringringri", 2 ], [ "pringringring", 3 ],
#	[ "ringringringpy", 4 ], [ "ingringringpyth", 5 ], [ "ngringringpython", 6 ],
#	[ "gringringpythonru", 7 ], [ "ringringpythonruby", 8 ], [ "ingringpythonrubyru", 9 ],
#	[ "ngringpythonrubyruby", 10 ], [ "gringpythonrubyruby", 11 ], [ "ringpythonrubyruby", 12 ],
#	[ "ingpythonrubyruby", 13 ], [ "ngpythonrubyruby", 14 ], [ "gpythonrubyruby", 15 ],
#	[ "pythonrubyruby", 16 ], [ "ythonrubyruby", 17 ], [ "thonrubyruby", 18 ],
#	[ "honrubyruby", 19 ],
#
#	[ "phpringringr", 1 ], [ "hpringringrin", 2 ], [ "pringringringp", 3 ],
#	[ "ringringringpyt", 4 ], [ "ingringringpytho", 5 ], [ "ngringringpythonr", 6 ],
#	[ "gringringpythonrub", 7 ], [ "ringringpythonrubyr", 8 ], [ "ingringpythonrubyrub", 9 ],
#	[ "ngringpythonrubyruby", 10 ], [ "gringpythonrubyruby", 11 ], [ "ringpythonrubyruby", 12 ],
#	[ "ingpythonrubyruby", 13 ], [ "ngpythonrubyruby", 14 ], [ "gpythonrubyruby", 15 ],
#	[ "pythonrubyruby", 16 ], [ "ythonrubyruby", 17 ], [ "thonrubyruby", 18 ],
#
#	[ "phpringringri", 1 ], [ "hpringringring", 2 ], [ "pringringringpy", 3 ],
#	[ "ringringringpyth", 4 ], [ "ingringringpython", 5 ], [ "ngringringpythonru", 6 ],
#	[ "gringringpythonruby", 7 ], [ "ringringpythonrubyru", 8 ], [ "ingringpythonrubyruby", 9 ],
#	[ "ngringpythonrubyruby", 10 ], [ "gringpythonrubyruby", 11 ], [ "ringpythonrubyruby", 12 ],
#	[ "ingpythonrubyruby", 13 ], [ "ngpythonrubyruby", 14 ], [ "gpythonrubyruby", 15 ],
#	[ "pythonrubyruby", 16 ], [ "ythonrubyruby", 17 ],
#
#	[ "phpringringrin", 1 ], [ "hpringringringp", 2 ], [ "pringringringpyt", 3 ],
#	[ "ringringringpytho", 4 ], [ "ingringringpythonr", 5 ], [ "ngringringpythonrub", 6 ],
#	[ "gringringpythonrubyr", 7 ], [ "ringringpythonrubyrub", 8 ],
#	[ "ingringpythonrubyruby", 9 ], [ "ngringpythonrubyruby", 10 ],
#	[ "gringpythonrubyruby", 11 ], [ "ringpythonrubyruby", 12 ], [ "ingpythonrubyruby", 13 ],
#	[ "ngpythonrubyruby", 14 ], [ "gpythonrubyruby", 15 ], [ "pythonrubyruby", 16 ]
# ]
*/

? @@( o1.ConsecutiveSubStringsZZ() )
#--> [ [ "p", [ 1, 1 ] ], [ "hp", [ 2, 2 ] ], [ "pri", [ 3, 3 ] ], [ "ring", [ 4, 4 ] ], [ "ingri", [ 5, 5 ] ], [ "ngring", [ 6, 6 ] ], [ "gringri", [ 7, 7 ] ], [ "ringring", [ 8, 8 ] ], [ "ingringpy", [ 9, 9 ] ], [ "ngringpyth", [ 10, 10 ] ], [ "gringpython", [ 11, 11 ] ], [ "ringpythonru", [ 12, 12 ] ], [ "ingpythonruby", [ 13, 13 ] ], [ "ngpythonrubyru", [ 14, 14 ] ], [ "gpythonrubyruby", [ 15, 15 ] ], [ "pythonrubyruby", [ 16, 16 ] ], [ "ythonrubyruby", [ 17, 17 ] ], [ "thonrubyruby", [ 18, 18 ] ], [ "honrubyruby", [ 19, 19 ] ], [ "onrubyruby", [ 20, 20 ] ], [ "nrubyruby", [ 21, 21 ] ], [ "rubyruby", [ 22, 22 ] ], [ "ubyruby", [ 23, 23 ] ], [ "byruby", [ 24, 24 ] ], [ "yruby", [ 25, 25 ] ], [ "ruby", [ 26, 26 ] ], [ "uby", [ 27, 27 ] ], [ "by", [ 28, 28 ] ], [ "y", [ 29, 29 ] ], [ "ph", [ 1, 2 ] ], [ "hpr", [ 2, 3 ] ], [ "prin", [ 3, 4 ] ], [ "ringr", [ 4, 5 ] ], [ "ingrin", [ 5, 6 ] ], [ "ngringr", [ 6, 7 ] ], [ "gringrin", [ 7, 8 ] ], [ "ringringp", [ 8, 9 ] ], [ "ingringpyt", [ 9, 10 ] ], [ "ngringpytho", [ 10, 11 ] ], [ "gringpythonr", [ 11, 12 ] ], [ "ringpythonrub", [ 12, 13 ] ], [ "ingpythonrubyr", [ 13, 14 ] ], [ "ngpythonrubyrub", [ 14, 15 ] ], [ "gpythonrubyruby", [ 15, 16 ] ], [ "pythonrubyruby", [ 16, 17 ] ], [ "ythonrubyruby", [ 17, 18 ] ], [ "thonrubyruby", [ 18, 19 ] ], [ "honrubyruby", [ 19, 20 ] ], [ "onrubyruby", [ 20, 21 ] ], [ "nrubyruby", [ 21, 22 ] ], [ "rubyruby", [ 22, 23 ] ], [ "ubyruby", [ 23, 24 ] ], [ "byruby", [ 24, 25 ] ], [ "yruby", [ 25, 26 ] ], [ "ruby", [ 26, 27 ] ], [ "uby", [ 27, 28 ] ], [ "by", [ 28, 29 ] ], [ "php", [ 1, 3 ] ], [ "hpri", [ 2, 4 ] ], [ "pring", [ 3, 5 ] ], [ "ringri", [ 4, 6 ] ], [ "ingring", [ 5, 7 ] ], [ "ngringri", [ 6, 8 ] ], [ "gringring", [ 7, 9 ] ], [ "ringringpy", [ 8, 10 ] ], [ "ingringpyth", [ 9, 11 ] ], [ "ngringpython", [ 10, 12 ] ], [ "gringpythonru", [ 11, 13 ] ], [ "ringpythonruby", [ 12, 14 ] ], [ "ingpythonrubyru", [ 13, 15 ] ], [ "ngpythonrubyruby", [ 14, 16 ] ], [ "gpythonrubyruby", [ 15, 17 ] ], [ "pythonrubyruby", [ 16, 18 ] ], [ "ythonrubyruby", [ 17, 19 ] ], [ "thonrubyruby", [ 18, 20 ] ], [ "honrubyruby", [ 19, 21 ] ], [ "onrubyruby", [ 20, 22 ] ], [ "nrubyruby", [ 21, 23 ] ], [ "rubyruby", [ 22, 24 ] ], [ "ubyruby", [ 23, 25 ] ], [ "byruby", [ 24, 26 ] ], [ "yruby", [ 25, 27 ] ], [ "ruby", [ 26, 28 ] ], [ "uby", [ 27, 29 ] ], [ "phpr", [ 1, 4 ] ], [ "hprin", [ 2, 5 ] ], [ "pringr", [ 3, 6 ] ], [ "ringrin", [ 4, 7 ] ], [ "ingringr", [ 5, 8 ] ], [ "ngringrin", [ 6, 9 ] ], [ "gringringp", [ 7, 10 ] ], [ "ringringpyt", [ 8, 11 ] ], [ "ingringpytho", [ 9, 12 ] ], [ "ngringpythonr", [ 10, 13 ] ], [ "gringpythonrub", [ 11, 14 ] ], [ "ringpythonrubyr", [ 12, 15 ] ], [ "ingpythonrubyrub", [ 13, 16 ] ], [ "ngpythonrubyruby", [ 14, 17 ] ], [ "gpythonrubyruby", [ 15, 18 ] ], [ "pythonrubyruby", [ 16, 19 ] ], [ "ythonrubyruby", [ 17, 20 ] ], [ "thonrubyruby", [ 18, 21 ] ], [ "honrubyruby", [ 19, 22 ] ], [ "onrubyruby", [ 20, 23 ] ], [ "nrubyruby", [ 21, 24 ] ], [ "rubyruby", [ 22, 25 ] ], [ "ubyruby", [ 23, 26 ] ], [ "byruby", [ 24, 27 ] ], [ "yruby", [ 25, 28 ] ], [ "ruby", [ 26, 29 ] ], [ "phpri", [ 1, 5 ] ], [ "hpring", [ 2, 6 ] ], [ "pringri", [ 3, 7 ] ], [ "ringring", [ 4, 8 ] ], [ "ingringri", [ 5, 9 ] ], [ "ngringring", [ 6, 10 ] ], [ "gringringpy", [ 7, 11 ] ], [ "ringringpyth", [ 8, 12 ] ], [ "ingringpython", [ 9, 13 ] ], [ "ngringpythonru", [ 10, 14 ] ], [ "gringpythonruby", [ 11, 15 ] ], [ "ringpythonrubyru", [ 12, 16 ] ], [ "ingpythonrubyruby", [ 13, 17 ] ], [ "ngpythonrubyruby", [ 14, 18 ] ], [ "gpythonrubyruby", [ 15, 19 ] ], [ "pythonrubyruby", [ 16, 20 ] ], [ "ythonrubyruby", [ 17, 21 ] ], [ "thonrubyruby", [ 18, 22 ] ], [ "honrubyruby", [ 19, 23 ] ], [ "onrubyruby", [ 20, 24 ] ], [ "nrubyruby", [ 21, 25 ] ], [ "rubyruby", [ 22, 26 ] ], [ "ubyruby", [ 23, 27 ] ], [ "byruby", [ 24, 28 ] ], [ "yruby", [ 25, 29 ] ], [ "phprin", [ 1, 6 ] ], [ "hpringr", [ 2, 7 ] ], [ "pringrin", [ 3, 8 ] ], [ "ringringr", [ 4, 9 ] ], [ "ingringrin", [ 5, 10 ] ], [ "ngringringp", [ 6, 11 ] ], [ "gringringpyt", [ 7, 12 ] ], [ "ringringpytho", [ 8, 13 ] ], [ "ingringpythonr", [ 9, 14 ] ], [ "ngringpythonrub", [ 10, 15 ] ], [ "gringpythonrubyr", [ 11, 16 ] ], [ "ringpythonrubyrub", [ 12, 17 ] ], [ "ingpythonrubyruby", [ 13, 18 ] ], [ "ngpythonrubyruby", [ 14, 19 ] ], [ "gpythonrubyruby", [ 15, 20 ] ], [ "pythonrubyruby", [ 16, 21 ] ], [ "ythonrubyruby", [ 17, 22 ] ], [ "thonrubyruby", [ 18, 23 ] ], [ "honrubyruby", [ 19, 24 ] ], [ "onrubyruby", [ 20, 25 ] ], [ "nrubyruby", [ 21, 26 ] ], [ "rubyruby", [ 22, 27 ] ], [ "ubyruby", [ 23, 28 ] ], [ "byruby", [ 24, 29 ] ], [ "phpring", [ 1, 7 ] ], [ "hpringri", [ 2, 8 ] ], [ "pringring", [ 3, 9 ] ], [ "ringringri", [ 4, 10 ] ], [ "ingringring", [ 5, 11 ] ], [ "ngringringpy", [ 6, 12 ] ], [ "gringringpyth", [ 7, 13 ] ], [ "ringringpython", [ 8, 14 ] ], [ "ingringpythonru", [ 9, 15 ] ], [ "ngringpythonruby", [ 10, 16 ] ], [ "gringpythonrubyru", [ 11, 17 ] ], [ "ringpythonrubyruby", [ 12, 18 ] ], [ "ingpythonrubyruby", [ 13, 19 ] ], [ "ngpythonrubyruby", [ 14, 20 ] ], [ "gpythonrubyruby", [ 15, 21 ] ], [ "pythonrubyruby", [ 16, 22 ] ], [ "ythonrubyruby", [ 17, 23 ] ], [ "thonrubyruby", [ 18, 24 ] ], [ "honrubyruby", [ 19, 25 ] ], [ "onrubyruby", [ 20, 26 ] ], [ "nrubyruby", [ 21, 27 ] ], [ "rubyruby", [ 22, 28 ] ], [ "ubyruby", [ 23, 29 ] ], [ "phpringr", [ 1, 8 ] ], [ "hpringrin", [ 2, 9 ] ], [ "pringringr", [ 3, 10 ] ], [ "ringringrin", [ 4, 11 ] ], [ "ingringringp", [ 5, 12 ] ], [ "ngringringpyt", [ 6, 13 ] ], [ "gringringpytho", [ 7, 14 ] ], [ "ringringpythonr", [ 8, 15 ] ], [ "ingringpythonrub", [ 9, 16 ] ], [ "ngringpythonrubyr", [ 10, 17 ] ], [ "gringpythonrubyrub", [ 11, 18 ] ], [ "ringpythonrubyruby", [ 12, 19 ] ], [ "ingpythonrubyruby", [ 13, 20 ] ], [ "ngpythonrubyruby", [ 14, 21 ] ], [ "gpythonrubyruby", [ 15, 22 ] ], [ "pythonrubyruby", [ 16, 23 ] ], [ "ythonrubyruby", [ 17, 24 ] ], [ "thonrubyruby", [ 18, 25 ] ], [ "honrubyruby", [ 19, 26 ] ], [ "onrubyruby", [ 20, 27 ] ], [ "nrubyruby", [ 21, 28 ] ], [ "rubyruby", [ 22, 29 ] ], [ "phpringri", [ 1, 9 ] ], [ "hpringring", [ 2, 10 ] ], [ "pringringri", [ 3, 11 ] ], [ "ringringring", [ 4, 12 ] ], [ "ingringringpy", [ 5, 13 ] ], [ "ngringringpyth", [ 6, 14 ] ], [ "gringringpython", [ 7, 15 ] ], [ "ringringpythonru", [ 8, 16 ] ], [ "ingringpythonruby", [ 9, 17 ] ], [ "ngringpythonrubyru", [ 10, 18 ] ], [ "gringpythonrubyruby", [ 11, 19 ] ], [ "ringpythonrubyruby", [ 12, 20 ] ], [ "ingpythonrubyruby", [ 13, 21 ] ], [ "ngpythonrubyruby", [ 14, 22 ] ], [ "gpythonrubyruby", [ 15, 23 ] ], [ "pythonrubyruby", [ 16, 24 ] ], [ "ythonrubyruby", [ 17, 25 ] ], [ "thonrubyruby", [ 18, 26 ] ], [ "honrubyruby", [ 19, 27 ] ], [ "onrubyruby", [ 20, 28 ] ], [ "nrubyruby", [ 21, 29 ] ], [ "phpringrin", [ 1, 10 ] ], [ "hpringringr", [ 2, 11 ] ], [ "pringringrin", [ 3, 12 ] ], [ "ringringringp", [ 4, 13 ] ], [ "ingringringpyt", [ 5, 14 ] ], [ "ngringringpytho", [ 6, 15 ] ], [ "gringringpythonr", [ 7, 16 ] ], [ "ringringpythonrub", [ 8, 17 ] ], [ "ingringpythonrubyr", [ 9, 18 ] ], [ "ngringpythonrubyrub", [ 10, 19 ] ], [ "gringpythonrubyruby", [ 11, 20 ] ], [ "ringpythonrubyruby", [ 12, 21 ] ], [ "ingpythonrubyruby", [ 13, 22 ] ], [ "ngpythonrubyruby", [ 14, 23 ] ], [ "gpythonrubyruby", [ 15, 24 ] ], [ "pythonrubyruby", [ 16, 25 ] ], [ "ythonrubyruby", [ 17, 26 ] ], [ "thonrubyruby", [ 18, 27 ] ], [ "honrubyruby", [ 19, 28 ] ], [ "onrubyruby", [ 20, 29 ] ], [ "phpringring", [ 1, 11 ] ], [ "hpringringri", [ 2, 12 ] ], [ "pringringring", [ 3, 13 ] ], [ "ringringringpy", [ 4, 14 ] ], [ "ingringringpyth", [ 5, 15 ] ], [ "ngringringpython", [ 6, 16 ] ], [ "gringringpythonru", [ 7, 17 ] ], [ "ringringpythonruby", [ 8, 18 ] ], [ "ingringpythonrubyru", [ 9, 19 ] ], [ "ngringpythonrubyruby", [ 10, 20 ] ], [ "gringpythonrubyruby", [ 11, 21 ] ], [ "ringpythonrubyruby", [ 12, 22 ] ], [ "ingpythonrubyruby", [ 13, 23 ] ], [ "ngpythonrubyruby", [ 14, 24 ] ], [ "gpythonrubyruby", [ 15, 25 ] ], [ "pythonrubyruby", [ 16, 26 ] ], [ "ythonrubyruby", [ 17, 27 ] ], [ "thonrubyruby", [ 18, 28 ] ], [ "honrubyruby", [ 19, 29 ] ], [ "phpringringr", [ 1, 12 ] ], [ "hpringringrin", [ 2, 13 ] ], [ "pringringringp", [ 3, 14 ] ], [ "ringringringpyt", [ 4, 15 ] ], [ "ingringringpytho", [ 5, 16 ] ], [ "ngringringpythonr", [ 6, 17 ] ], [ "gringringpythonrub", [ 7, 18 ] ], [ "ringringpythonrubyr", [ 8, 19 ] ], [ "ingringpythonrubyrub", [ 9, 20 ] ], [ "ngringpythonrubyruby", [ 10, 21 ] ], [ "gringpythonrubyruby", [ 11, 22 ] ], [ "ringpythonrubyruby", [ 12, 23 ] ], [ "ingpythonrubyruby", [ 13, 24 ] ], [ "ngpythonrubyruby", [ 14, 25 ] ], [ "gpythonrubyruby", [ 15, 26 ] ], [ "pythonrubyruby", [ 16, 27 ] ], [ "ythonrubyruby", [ 17, 28 ] ], [ "thonrubyruby", [ 18, 29 ] ], [ "phpringringri", [ 1, 13 ] ], [ "hpringringring", [ 2, 14 ] ], [ "pringringringpy", [ 3, 15 ] ], [ "ringringringpyth", [ 4, 16 ] ], [ "ingringringpython", [ 5, 17 ] ], [ "ngringringpythonru", [ 6, 18 ] ], [ "gringringpythonruby", [ 7, 19 ] ], [ "ringringpythonrubyru", [ 8, 20 ] ], [ "ingringpythonrubyruby", [ 9, 21 ] ], [ "ngringpythonrubyruby", [ 10, 22 ] ], [ "gringpythonrubyruby", [ 11, 23 ] ], [ "ringpythonrubyruby", [ 12, 24 ] ], [ "ingpythonrubyruby", [ 13, 25 ] ], [ "ngpythonrubyruby", [ 14, 26 ] ], [ "gpythonrubyruby", [ 15, 27 ] ], [ "pythonrubyruby", [ 16, 28 ] ], [ "ythonrubyruby", [ 17, 29 ] ], [ "phpringringrin", [ 1, 14 ] ], [ "hpringringringp", [ 2, 15 ] ], [ "pringringringpyt", [ 3, 16 ] ], [ "ringringringpytho", [ 4, 17 ] ], [ "ingringringpythonr", [ 5, 18 ] ], [ "ngringringpythonrub", [ 6, 19 ] ], [ "gringringpythonrubyr", [ 7, 20 ] ], [ "ringringpythonrubyrub", [ 8, 21 ] ], [ "ingringpythonrubyruby", [ 9, 22 ] ], [ "ngringpythonrubyruby", [ 10, 23 ] ], [ "gringpythonrubyruby", [ 11, 24 ] ], [ "ringpythonrubyruby", [ 12, 25 ] ], [ "ingpythonrubyruby", [ 13, 26 ] ], [ "ngpythonrubyruby", [ 14, 27 ] ], [ "gpythonrubyruby", [ 15, 28 ] ], [ "pythonrubyruby", [ 16, 29 ] ] ]

proff()
# Executed in 0.01 second(s).

/*-----------

pron()

# Example usage:
/*
str = "abcdefghi"
chunks = ConsecutiveSubStringsOfNChars(str, 2)
? chunks  # Output: ["ab", "cd", "ef", "gh", "bc", "de", "fg", "hi"]

str = "Hello"
chunks = ConsecutiveSubStringsOfNChars(str, 2)
? chunks  # Output: ["He", "ll", "el", "lo"]

str = "123456789012"
? ConsecutiveSubStringsOfNChars(str,3)
*/
pron()

str = "phpringringringpythonrubyruby"
? ConsecutiveSubStringsOfNChars(str, 4)

proff()

func ConsecutiveSubStringsOfNChars(str, n)

    if not isString(str) return [] ok
    if not isNumber(n) return [] ok
    if n <= 0 return [] ok
    if n > len(str) return [] ok
    
    aResult = []

   for i = 1 to n
	    # First pass - starting from position 1
	    for j = i to len(str) step n
	        if j + n - 1 <= len(str)
	            add(aResult, substr(str, j, n))
	        ok
	    next

   next

    return aResult

