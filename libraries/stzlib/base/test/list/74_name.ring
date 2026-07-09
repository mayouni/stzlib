# Narrative
# --------
# StzNamedListQ: a list that also carries a name, via the :name = [...] form.
#
# The single named-parameter [ :langs = [...] ] gives the list both a Name()
# ("langs") and its Content(). Inside the Q(){} block the methods bind to
# that named list; StzType() confirms it is still a plain stzlist underneath.
# (The original recorded outputs were stale copy-paste: Name() shows the
# actual key "langs" not ":myage", and Content() comes back lower-cased.)
#
# Extracted from stzlisttest.ring, block #74.

load "../../stzBase.ring"

pr()

StzNamedListQ(:langs = [ :Ring, :Ruby, :Python ]) {

	? Name()
	#--> langs

	? Content()
	#--> [ "ring", "ruby", "python" ]

	? StzType()
	#--> stzlist

}

pf()
# Executed in almost 0 second(s) in Ring 1.27
# Executed in 0.03 second(s) before
