# Narrative
# --------
# pr()
#
# Extracted from stzchartest.ring, block #112.
#ERR Error (C22) : Function redefinition, function is already defined!

load "../../stzBase.ring"

pr()

# Be careful: there is a hidden char that inverted the text "freind" and
# forced it to be written from right to left!

txt = "dear ‮friends!"

? txt
#-- dear ‮friends!


# Trying to get it in pure Ring

_nTxt1Len_ = ring_len(txt)
for _iLoopTxt1_ = 1 to _nTxt1Len_
	c = txt[_iLoopTxt1_]
	? c
next
#-->
'
d
e
a
r
 
�
�
�
f
r
i
e
n
d
s
!
'

# Trying to know it in Softanza
? ""

pf()
