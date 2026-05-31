# Narrative
# --------
# Using a PHP code inside Ring  #===
#
# Extracted from stzextinphptest.ring, block #1.

load "../../../stzBase.ring"

# This code snippet is written in PHP. It calculates the min
# and max of two lists of numbers:
"
echo(min(0, 150, 30, 20, -8, -200));  #--> -200
echo(max(0, 150, 30, 20, -8, -200));  #--> 150
"

# Nearly the same code can be written in Ring thanks to the
# Min(), Max() and echo() functions of SoftanzaLib:

pr()

echo( @Min([0, 150, 30, 20, -8, -200]) );   #--> -200	#ERROR #TODO
echo( @Max([0, 150, 30, 20, -8, -200]) );   #--> 150

#NOTE that the only difference is to put the numbers in a list
# by bounding them by [ and ], inside the min() and max() functions

pf()
# Executed in almost 0 second(s) in Ring 1.21
# Executed in 0.04 second(s) in Ring 1.20
