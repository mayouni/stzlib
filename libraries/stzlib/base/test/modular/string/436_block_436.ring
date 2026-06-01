# Narrative
# --------
# #narration
#
# Extracted from stzStringTest.ring, block #436.

load "../../../stzBase.ring"


pr()

# When applied to the string "Hi!", RepeatedNTimes() will duplicate
# it, resulting in "Hi!Hi!Hi!".

? Q("Hi!").RepeatedNTimes(3)
#--> "Hi!Hi!Hi!"

# For all other types (stzList, stzNumber, and stzObject),
# it repeats the object value within a list:

? Q(5).RepeatedNTimes(3)
#--> [5, 5, 5]

? Q(1:3).RepeatedNTimes(3)
#--> [ 1:3, 1:3, 1:3 ]

# You might ask why we chose different behavior for strings
# compared to other types, and why we don't produce a list 
# when the function is applied to a string, like this:
# ? Q("Hi!").RepeatNTimes(3) #!--> [ "Hi!", "Hi!", "Hi!" ] ?

# The reason is that it feels more intuitive to duplicate the
# string directly when asked to repeat it, producing a string
# as the result, rather than a list!

# If you'd like to avoid potential confusion from this dual behavior,
# you can use RepeatNTimesXT(), where you explicitly specify the
# desired output format, like this:

? Q("Hi!").RepeatedNTimesXT(3, :InAString)
#--> "Hi!Hi!Hi!"

? Q("Hi!").RepeatedNTimesXT(0, :InAList)
#--> [ "Hi!", "Hi!", "Hi!" ]

pf()
# Executed in 0.08 second(s) in Ring 1.21
