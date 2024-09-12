load "zailib.ring"

#=========

# Run any llm locally via a REST API or CLI
# https://github.com/ollama/ollama

# Dialog with any LLM (+100) using the same OpenAI prompt form
# https://docs.litellm.ai/docs/

#========
/*
? Z("Transform to passive form")[ "Few companies dominate the tech world" ]
#--> "The tech world is dominated by few companies

? Z("classify by continent")[ "France", "Libya", "Niger", "Palestine", "Spain", "Senegal" ]
#--> [
# 	:Europe = [ "France", "Spain" ],
#	:Africa = [ "Libya", "Niger", "Senegal" ],
# 	:Asia   = [ "Palestine" ]
# ]

? Z("Opposite of")[ "Tall", "Strong", "Good" ]
#--> [ "Small", "Weak", "Bad" ]

? Z("Say it in the future")[ "I've done it." ]
#--> "I will do it"

? Z("Translate in arabic")[ "Resist and you will win!" ]
#o--> "! اصبر و ستننصر"

? Z("A random word about resistance")
#--> Resilience

#=======
# Consider these suggestions from Mahmoud

Hello Mansour

>> "Yes, Z() is a function that returns an object and [] is an overloaded operator accessing it. If no params are provided with [] then the object behaves like a function that deals only with the main prompt between ()."

This is NICE MAGIC :D

if you want to push this forward
Think about something like this 

new Z {
     "SOME STRING"
     "Another String"  [ ...  list items ... ]
}

And use BraceExprEval() : Natural Language Programming — Ring 1.19 documentation (ring-lang.github.io)

Another idea
Define a class ZaiLib
And an attribute called Z
then define func getZ
that return the object that uses Operator()

So we have
new ZaiLib {
             Z  [... some list ...]
}

Greetings,
Mahmoud
