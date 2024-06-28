load "stzlib.ring"


/*-------

pron()

o1 = new stzList([
	"",
	"ABCDEF", "GHIJKL", "123346",
	"MNOPQU", "RSTUVW", "984332",
	""
])

? o1.FindW('  Q(This[@i]).IsMadeOfNumbers()  ')
#--> [ 4, 7 ]

proff()
# Executed in 0.12 second(s)

/*=======

pron()

o1 = new stzString("
ABCDEF
GHIJKL
123346
MNOPQU
RSTUVW
984332")

o1.RemoveLinesW(' Q(This[@i]).IsMadeOfNumbers() ')

? o1.Content()
#--> "
# ABCDEF
# GHIJKL
# MNOPQU
# RSTUVW"

proff()
# Executed in 0.12 second(s)

/*-------
*/
pron()

o1 = new stzString("
ABCDEF
GHIJKL
123346
MNOPQU
RSTUVW
984332")

o1.RemoveLinesWXT(' Q(@Line).IsMadeOfNumbers() ')

? o1.Content()
#--> "
# ABCDEF
# GHIJKL
# MNOPQU
# RSTUVW"

proff()
# Executed in 0.16 second(s)

/*=====

pron()

o1 = new stzList([ "A", "b", 2, "C", 3, "♥" ])

? o1.ContainsW(' isNumber(This[@i]) ')
#--> TRUE
# Executed in 0.06 second(s)

? o1.ContainsWXT(' isNumber(@CurrentItem) ')
#--> TRUE
# Executed in 0.10 second(s)

proff()
# Executed in 0.12 second(s)

/*-----
*/

