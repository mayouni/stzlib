
load "../stzbase.ring"

#NOTE Read this
# https://github.com/mayouni/stzlib/blob/main/libraries/stzlib/base/doc/narrations/stzstring-emptiness-narration.md

/*--- SOFTANZA NULLINESS

# Only empty strings and the NullObject() are considered null,
# everything else is not null

pr()

? IsNull("") #--> TRUE
? IsNull([]) #--> FALSE
? IsNull(0) #--> FALSE
? IsNull(NullObject()) #--> TRUE
? IsNull(TrueObject()) #--> FALSE
? IsNull(FalseObject()) #--> FALSE

/*--- SOFTANZA EMpTINESS

# Emptiness applies to "" for strings, [] for lists, and NullObject() for objects

? IsEmpty("") #--> TRUE
? IsEmpty([]) #--> TRUE
? IsEmpty(0) #--> FALSE
? IsEmpty(NullObject()) #--> TRUE
? IsEmpty(FalseObject()) #--> FALSE

/*--- SOFTANZA TRUTHNESS #TODO

# Everything is true except 0, "", FalseObject(), and NullObject()
# Make a simular article to this:
# https://github.com/mayouni/stzlib/blob/main/libraries/stzlib/base/doc/narrations/stzstring-emptiness-narration.md

? ""

? IsTrue("") #--> FALSE
? IsTrue(0) #--> FALSE
? IsTrue(NullObject()) #--> FALSE
? IsTrue(FalseObject()) #--> FALSE

? IsTrue(123) #--> TRUE
? IsTrue(-23) #--> TRUE

? IsTrue("text") #--> TRUE
? IsTrue([1, 2, 3]) #--> TRUE
? IsTrue([]) #--> TRUE

/*--- SOFTANZA FALSINESS #TODO

# The strict inverse of TRUTH

? IsFalse("") #--> TRUE
? IsFalse(0) #--> TRUE
? IsFalse(NullObject()) #--> TRUE
? IsFalse(FalseObject()) #--> TRUE

? IsFalse(123) #--> FALSE
? IsFalse(-23) #--> FALSE

? IsFalse("text") #--> FALSE
? IsFalse([1, 2, 3]) #--> FALSE
? IsFalse([]) #--> False

