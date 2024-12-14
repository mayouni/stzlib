load "../max/stzmax.ring"


/*==========
*/
profon()

o1 = new stzString("   irum epsum     elo  n   ")

? @@( o1.FindOverSpaces() ) + NL
#--> [ 2, 3, 15, 16, 17, 18, 23, 26, 27 ]

? @@( o1.FindOverSpacesZZ() )
#--> [ [ 2, 3 ], [ 15, 18 ], [ 23, 27 ] ]

proff()
# Executed in 0.01 second(s).

/*------- #narration Simplify VS RemoveOverSpaces

profon()

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
# Executed in 0.06 second(s) in Ring 1.22

/*-------

profon()

o1 = new stzString("   irum epsum     elo  n   ")
o1.ReplaceOverSpaces(:With = "~")
? @@( o1.Content() )
#--> " ~~irum epsum ~~elo ~~"

proff()
# Executed in 0.04 second(s).

/*=======

profon()

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

profon()

o1 = new stzString("CAIRO")
o1.BoxEachCharXT([ :rounded = TRUE ])
? o1.Content()
#-->
# ╭───┬───┬───┬───┬───╮
# │ C │ A │ I │ R │ O │
# ╰───┴───┴───┴───┴───╯

proff()
# Executed in 0.04 second(s) in Ring 1.22

/*---------

profon()

o1 = new stzListOfChars([ "C", "A", "I", "R", "O" ])
? o1.BoxXT([
	[ "rounded", 1 ],
	[ "positionchar", "♥" ],
	[ "hilighted", [ 3, 3 ] ], # Duplication is managed internally
	[ "casesensitive", 1 ]
])
#-->
# ╭───┬───┬───┬───┬───╮
# │ C │ A │ I │ R │ O │
# ╰───┴───┴─♥─┴───┴───╯

proff()
# Executed in 0.08 second(s) in Ring 1.22

/*---------

profon()

? Q("CAIRO").VizFindBoxedXT("I", [
	[ "rounded", 1 ], [ "positionchar", "♥" ] ] )
#-->
# ╭───┬───┬───┬───┬───╮
# │ C │ A │ I │ R │ O │
# ╰───┴───┴─♥─┴───┴───╯

proff()

# Executed in 0.09 second(s) in Ring 1.22
/*---------

profon()

? Q("RINGORIALAND").vizFind("I") + NL
#--> RINGORIALAND
#    -^----^-----

? Q("CAIRO").vizFindBoxedXT("I", []) + NL
#-->
# ┌───┬───┬───┬───┬───┐
# │ C │ A │ I │ R │ O │
# └───┴───┴─•─┴───┴───┘

? Q("CAIRO").vizFindXT("I", [
	:Boxed = TRUE,
	:Rounded = TRUE,
	:PositionChar = "♥"]
)
#-->
#    ╭───┬───┬───┬───┬───╮
#--> │ C │ A │ I │ R │ O │
#    ╰───┴───┴─♥─┴───┴───╯

proff()
# Executed in 0.15 second(s) in Ring 1.22

/*------

profon()

SetStringArtStyle(:geo)

? StringArtXT("R", :flower)
#-->
# .-------.    
# |  _ _   \   
# | ( ' )  |   
# |(_ o _) /   
# | (_,_).' __ 
# |  |\ \  |  |
# |  | \ `'   /
# |  |  \    / 
# ''-'   `'-' 


? StringArtStyle()
#--> geo

proff()
# Executed in almost 0 second(s) in Ring 1.22
