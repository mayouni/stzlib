load "../stzmax.ring"

/*==========

pron()

o1 = new stzString("   irum epsum     elo  n   ")

? @@( o1.FindOverSpaces() ) + NL
#--> [ 2, 3, 15, 16, 17, 18, 23, 26, 27 ]

? @@( o1.FindOverSpacesZZ() )
#--> [ [ 2, 3 ], [ 15, 18 ], [ 23, 27 ] ]

proff()
# Executed in 0.01 second(s).

/*------- #narration Simplify VS RemoveOverSpaces

pron()

# Simplify: string is trimmed and redundant spaces are removed
# ~> QtBased

o1 = new stzString("   irum epsum     elo  n   ")

o1.Simplify() + NL
? @@( o1.Content() )
#--> "irum epsum elo n"

# RemoveOverSpaces : redundant spaces are removed but string is not trimmed

o1 = new stzString("   irum epsum     elo  n   ")

o1.RemoveOverSpaces()
? @@( o1.Content() )
#--> " irum epsum elo "

proff()
# Executed in 0.03 second(s).

/*-------

pron()

o1 = new stzString("   irum epsum     elo  n   ")
o1.ReplaceOverSpaces(:With = "~")
? @@( o1.Content() )
#--> " ~~irum epsum ~~elo ~~"

proff()
# Executed in 0.04 second(s).

/*=======

pron()

o1 = new stzString("CAIRO")
o1.BoxEachChar()
? o1.Content()
#-->
# ┌───┬───┬───┬───┬───┐
# │ C │ A │ I │ R │ O │
# └───┴───┴───┴───┴───┘

proff()
# Executed in 0.04 second(s).

/*------
*/
pron()

o1 = new stzString("CAIRO")
o1.BoxEachCharXT(:rounded)
? o1.Content()

proff()

//? Q("RINGORIALAND").vizFind("I")
#--> RINGORIALAND
#    -^----^-----

? Q("CAIRO").vizFindBoxedXT("I", [])

//? Q("CAIRO").vizFindXT("I", [ :Boxed _TRUE_, :PositionChar = "♥"])
#-->
#    ╭───┬───┬───┬───┬───╮
#--> │ C │ A │ I │ R │ O │
#    ╰───┴───┴─♥─┴───┴───╯

/*
? SetStringArtStyle(:geo)

? StringArtXT("R", :flower)
#--> You get a floral "R" like the one showan in the example above

? CurrentStringArtStyle()
#--> geo
