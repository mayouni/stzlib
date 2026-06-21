# Narrative
# --------
# Transpiling the @NextItem shortcut used inside conditional-code strings.
#
# Softanza lets you write terse conditional-code expressions against the
# items of a list, where @NextItem is a placeholder for "the element that
# follows the current one". StzCCodeQ(...).Transpiled() expands that DSL
# string into the real Ring it stands for: @NextItem becomes This[@i + 1],
# the index just past the current cursor @i. Here the predicate
# IsNotANumber() is carried through unchanged, showing the transpiler only
# rewrites the navigation token and leaves the method call intact.
#
# Extracted from stzlisttest.ring, block #208.

load "../../stzBase.ring"

pr()

? StzCCodeQ('Q(@NextItem).IsNotANumber()').Transpiled()
#--> Q(  This[@i + 1]  ).IsNotANumber(  )

pf()
# Executed in 0.07 second(s) in Ring 1.21
# Executed in 0.30 second(s) in Ring 1.17
