# Narrative
# --------
# #narration
#
# Extracted from stzStringTest.ring, block #656.

load "../../stzBase.ring"


pr()

# Do you think "ê" and "ê" are the same?
# If one should trust the visual shape of these two strings, then yes...
# but, the truth, is that they are different.

# In fact, both Ring and Softanza know it:

? "ê" = "ê"
#--> FALSE

? Q("ê").IsEqualTo("ê")
#--> FALSE

# and that's because ê is just one char:

Q("ê") { ? NumberOfChars() ? Unicode() }
#--> 1
#--> 234

# while ê are two chars:

Q("ê") { ? NumberOfChars() ? Unicode() }
#--> 2
#--> [101, 770]

# And we can do even better by getting the names of the chars in every string.
# So "ê" contains one char called :

? Q("ê").CharName() 
#--> LATIN SMALL LETTER E WITH CIRCUMFLEX

# While "ê" contains two chars called:

? Q("ê").CharsNames() 	
#--> [ 'LATIN SMALL LETTER E', 'COMBINING CIRCUMFLEX ACCENT' ]

# Combining characters is an advanced aspect of Unicode we are not going to delve
# in now. For more details you can read these FAQs at the following link:
# http://unicode.org/faq/char_combmark.html

pf()
# Executed in 0.11 second(s) in Ring 1.22
# Executed in 0.36 second(s) in Ring 1.18
# Executed in 0.75 second(s) in Ring 1.17
