# Functions and classes for porting Perl/Raku code to Ring

say = new say	# Raku / Perl language

# Closes a say { ... } brace of ported Perl or Raku code and prints the answer that a ternary left in the named variable say.
#
# In Raku, say prints the value of an expression. Here the brace body is a Softanza ternary:
# b(condition) '??' bt(trueValue) '!!' bf(falseValue), which stores its answer in the named variable
# say, and the end of the brace prints it. The global say is already one of these. A brace that
# holds anything else prints the previous answer, or an empty line.
#
#   receiver   o1 = new say
#   example    rand = 0.7
#              say { b(rand < 0.9) '??' bt('Yes') '!!' bf('No') }
#              #--> Yes
#              say { b(rand < 0.5) '??' bt('Yes') '!!' bf('No') }
#              #--> No
#   see        console
class say
	vr(:say)
	# Prints the value that the last ternary b(...) '??' bt(...) '!!' bf(...) put in the named variable say, when the brace closes.
	#
	#   returns    nothing; it prints
	#   note       one empty line when no ternary has run yet
	#   warning    any other brace body leaves the variable as it was, so say { 5 } prints the
	#              previous answer, or an empty line before any
	def braceend()
		? v(:say)
