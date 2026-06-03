# Narrative
# --------
#
# Extracted from stznaturalmarkuptest.ring, block #2.

load "../../stzBase.ring"

pr()

o1 = new stzNaturalMarkup('
	#<
	Create a {+list:fruits 1~} using {#1 ["banana", "apple", "cherry"]}.
	{?how-many} item we`ve just added?
	{Show} them on the screen.
	Thanks a lot!
	#>

	#<
	Make a {+string 1~} with "Ring+Softanza" inside it
	{Uppercase} it
	{Replace 2~} the {#1 "+"} sign with the lovely {#2 ^heart} char
	#>
')

? @@NL( o1.Blocks() )

? @@NL( o1.DynamicParts() )

pf()
