# Narrative
# --------
# Natural Language Processing
#
# Extracted from stzextercodetest.ring, block #32.

load "../../../stzBase.ring"


pr()

oProlog = new stzExterCode(:Prolog)
oProlog.SetCode('

	% Define a simple grammar for English sentences

	sentence(sentence(NP, VP)) --> noun_phrase(NP), verb_phrase(VP).
	
	noun_phrase(noun_phrase(Det, Noun)) --> determiner(Det), noun(Noun).
	noun_phrase(noun_phrase(Pronoun)) --> pronoun(Pronoun).
	
	verb_phrase(verb_phrase(Verb, NP)) --> verb(Verb), noun_phrase(NP).
	verb_phrase(verb_phrase(Verb)) --> verb(Verb).
	
	determiner(determiner(the)) --> [the].
	determiner(determiner(a)) --> [a].
	
	noun(noun(cat)) --> [cat].
	noun(noun(dog)) --> [dog].
	noun(noun(mouse)) --> [mouse].
	
	pronoun(pronoun(he)) --> [he].
	pronoun(pronoun(she)) --> [she].
	pronoun(pronoun(it)) --> [it].
	
	verb(verb(chases)) --> [chases].
	verb(verb(eats)) --> [eats].
	verb(verb(sleeps)) --> [sleeps].
	
	% Parse sentences

	parse_sentences(Result) :-
	    Sentence1 = [the, cat, chases, the, mouse],
	    Sentence2 = [a, dog, eats],
	    Sentence3 = [it, sleeps],
	    
	    (phrase(sentence(Tree1), Sentence1) -> ParseResult1 = [success, Tree1] ; ParseResult1 = [failure]),
	    (phrase(sentence(Tree2), Sentence2) -> ParseResult2 = [success, Tree2] ; ParseResult2 = [failure]),
	    (phrase(sentence(Tree3), Sentence3) -> ParseResult3 = [success, Tree3] ; ParseResult3 = [failure]),
	    
	    Result = [
		sentence1-ParseResult1,
		sentence2-ParseResult2,
		sentence3-ParseResult3
	    ].
	
	% Define result

	res(Result) :- parse_sentences(Result).
')

oProlog.Run()

? @@( oProlog.Result() )
#--> [
#	[
#		"sentence1",
#		[
#			"success",
#			[
#				[ [ "the" ], [ "cat" ] ],
#				[
#					[ "chases" ],
#					[ [ "the" ], [ "mouse" ] ]
#				]
#			]
#		]
#	],
#	[
#		"sentence2",
#		[
#			"success",
#			[
#				[ [ "a" ], [ "dog" ] ],
#				[ [ "eats" ] ]
#			]
#		]
#	],
#	[
#		"sentence3",
#		[
#			"success",
#			[
#				[ [ "it" ] ],
#				[ [ "sleeps" ] ]
#			]
#		]
#	]
# ]

pf()
# Executed in 0.37 second(s) in Ring 1.23

#================================#
#  Javascript Langauge Examples  #
#================================#
