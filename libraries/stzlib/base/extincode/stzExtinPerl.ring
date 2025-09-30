# Functions and classes for porting Perl/Raku code to Ring

say = new say	# Raku / Perl language

class say
	vr(:say)
	def braceend()
		? v(:say)
