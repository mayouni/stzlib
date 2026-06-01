# Narrative
# --------
#
# Extracted from stznaturaltest.ring, block #3.

load "../../../stzBase.ring"

pr()

Yesterday I thought about {+fruits:list ~1} and came up with {~1 ["banana", "apple", "cherry"]}.
What did I call them? {?name}
How many are there? {?count}

Actually, let me make an {+other:list} and {fill-it-with ~1} the same items as in {~1 @fruits..content}.
Now {uppercase} that {other:list} because LOUD FRUITS ARE BETTER!
Here they are: {show} them!

Wait...
What if I {^joinXT ~2} the {~1 other:list} I made above using {~2 " | "} as a spearator?
What {?type} is that?
Let me {boxXT ~2} it with {~1 rounded=true} and {~2 hashed=true}.
Beautiful: {show-0it}

pf()
