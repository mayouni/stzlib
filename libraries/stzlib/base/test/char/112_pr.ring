# Narrative
# --------
# pr()
#
# Extracted from stzchartest.ring, block #112.

load "../../stzBase.ring"

pr()

# Be careful: there is a hidden char that inverted the text "freind" and
# forced it to be written from right to left!

txt = "dear ‮friends!"

? txt
#-- dear ‮friends!


# Trying to get it in pure Ring

for i = 1 to len(txt)
	? txt[i]
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

# Trying to know it in Softanza's Chars() function

? "---"

? Chars(txt)
#-->
'
d
e
a
r
 
f
r
i
e
n
d
s
!
'

pf()
# Executed in almost 0 second(s) in Ring 1.27
