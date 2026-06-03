# Narrative
# --------
# Void operator removing noise words
#
# Extracted from stznaturalmarkuptest.ring, block #15.

load "../../stzBase.ring"


	cMarkup = '
	Create {+data:list ~1} with {#1 ["x", "y", "z"]}.
	Now {show-0it-0on-0screen}!
	{what-0is-0the-0name}?
	'
	
	oNML = new stzNaturalMarkup(cMarkup)
	oNML.Run()

#--> ["x", "y", "z"]
#--> data

proff()
