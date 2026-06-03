# Narrative
# --------
# pr()
#
# Extracted from stzchartest.ring, block #112.

load "../../stzBase.ring"


# Be careful: there is a hidden char that inverted the text "freind" and
# forced it to be written from right to left!

txt = "dear ‮friends!"

? txt
#-- dear ‮friends!


# Trying to get it in pure Ring

for c in txt
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
