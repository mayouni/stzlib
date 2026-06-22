# Narrative
# --------
# FindW / ItemsW with the @NextItem cursor and the :Where named form.
#
# The condition ' @NextItem = "*" ' selects each position whose successor is
# "*". FindW returns those POSITIONS -- [ 2, 5, 8 ] -- while ItemsW returns
# the VALUES at them -- [ "A", "B", "C" ]. The :Where = '...' named argument
# is an alternative to passing the condition string positionally. W is the
# single performant + expressive conditional form (the old WXT is retired).
#
# Extracted from stzlisttest.ring, block #548.

load "../../stzBase.ring"

pr()

o1 = new stzList(["_", "A", "*", "_", "B", "*", "_", "C", "*" ])

? o1.FindW( :Where = ' @NextItem = "*" ' )
#--> [ 2, 5, 8 ]

? o1.ItemsW( :Where = ' @NextItem = "*" ' )
#--> [ "A", "B", "C" ]

pf()
# Executed in 0.20 second(s).
