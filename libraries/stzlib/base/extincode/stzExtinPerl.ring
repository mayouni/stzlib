# Functions and classes for porting Perl/Raku code to Ring

_say_ = new _say_	# Raku / Perl language

class _say_
	vr(:say)
	def braceend()
		? v(:say)
