load "stzlib.ring"

/*--------

pron()

o1 = new stzString("what a <<nice>>> day!")

? o1.Sit(
	:OnSection = [10, 13],
	:Harvest = [ :NCharsBefore = 2, :NCharsAfter = 3 ]
)

#--> [ "<<", ">>>" ]

proff()
# Executed in 0.05 second(s)

/*--------

pron()

o1 = new stzString("what a <<nice>>> day!")
? o1.SectionBounds(10, 13, 2, 3)
#--> [ "<<", ">>>" ]

? o1.SectionBoundsIB(9, 14, 2, 3)
#--> [ "<<", ">>>" ]

#--

? @@( o1.SectionBoundsZ(10, 13, 2, 3) )
#--> [ [ "<<", 8 ], [ ">>>", 14 ] ]

? @@( o1.SectionBoundsZZ(10, 13, 2, 3) )
#--> [ [ "<<", [ 8, 9 ] ], [ ">>>", [ 14, 16 ] ] ]

#--

? @@( o1.SectionBoundsIBZ(9, 14, 2, 3) )
#--> [ [ "<<", 8 ], [ ">>>", 14 ] ]

? @@( o1.SectionBoundsIBZZ(9, 14, 2, 3) )
#--> [ [ "<<", [ 8, 9 ] ], [ ">>>", [ 14, 16 ] ] ]

proff()
# Executed in 0.21 second(s)

/*=======

# Using Section() (or Slice()) to get a part of a list

aList = 1:20

# Verbose form:
? Q(aList).Section(:FromPosition = 4, :To = :LastItem)
#--> 4:20

# Short form:
? Q(1:20).Slice(4, :Last)
#--> 4:20

/*======

Q("PROGRAMMING") {

   ? Boxed()

   ? BoxedRound()

   ? BoxEachChar()

   ? BoxEachCharRound()

}

#-->
# ┌─────────────┐
# │ PROGRAMMING │
# └─────────────┘
# ╭─────────────╮
# │ PROGRAMMING │
# ╰─────────────╯
# ┌───┬───┬───┬───┬───┬───┬───┬───┬───┬───┬───┐
# │ P │ R │ O │ G │ R │ A │ M │ M │ I │ N │ G │
# └───┴───┴───┴───┴───┴───┴───┴───┴───┴───┴───┘
# ╭───┬───┬───┬───┬───┬───┬───┬───┬───┬───┬───╮
# │ P │ R │ O │ G │ R │ A │ M │ M │ I │ N │ G │
# ╰───┴───┴───┴───┴───┴───┴───┴───┴───┴───┴───╯
