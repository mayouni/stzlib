load "../stzlib.ring"

profon

# Let's consider this natural language sentence:

# "Unless you have a photographic memory, repetition is vital"

# In softanza terms, it can expressed as a Computer-natural Code (CnC),
# that we can interact with, like this:

StzNaturalCodeQ() {
	# Define a value, you the Human ;)
	you = _("Human")

	# Set a natural language consruct around that value
	Say('{
		Unless(you).have.a("photographic memory")._("repetition").is("vital")
	}') #--> Unless you have a photographic memory, repetition is vital.
	
	# Experiment the construct by, first, defining an assumption
	Let('{
		_(you).have.a("photographic memory")
	}')

	# and then by asking a question and getting its answer!
	Ask( _("repetition") ) #--> NOT _("vital")

	# Experiment the other way around by assuming the opposite case:
	Let('{
		_(you).have.a("weak memory")
	}')

	# and ask again for wether repetition is vital or not:
	Ask( _("repetition") ) #--> _("vital")
}

proff()

/*-----------------------
*/
NaturalCode() {

	SetDialogBetween([ :Sun, :Moon ])
	SetTalker(:Sun).TalkingTo(:Moon) # Or just SetTalker(:Sun) because they'r only two

	Let('
		It.Seems.That._(:you).hate(:me)

		DialogFacts() #--> [ '_(:Sun).Thinks._(:Moon).Hates(:Sun)' ]
	')

	# :Sun talking and answering himself
	Say('
		It.Seems.What()		#--> That._(:Moon).hates(:Me)
		Does(:Moon).Hates(:Me)	#--> MAYBE
	')

	# :Moon taking the floor
	
	Say('
		SetTalker(:Moon).TalkingTo(:Moon)	# Or SetMonolog(:Moon)

			Is(:Someone, :Talking).To(:Me)	#--> YES
			WhoIs(:Talking).To(:Me)	# :Moon
		
			DialogFacts()  #--> [ '_(:Sun).Thinks._(:Moon).Hates(:Sun)' ]
	
		SetTalker(:Moon).TalkingTo(:Sun)

			I.DoNot.hate(:you)
	')

	DialogFacts() 	#--> [ '_(:Sun).Thinks._(:Moon).Hatse(:Sun)',
			# 	'_(:Moon).Says.DoNot.Hates(:Sun)' ]

	Does(:Moon).Hates(:Sun)	#--> No
	Does(:Sun).Thinks(:Moon).Hates(:Sun) #--> Yes

	Do([ :Son, :Moon ]).Agree() 	#--> No

	Does(:Sun).Asked(:Moon)		#--> Yes
	Does(:Moon).Answerd(:Sun)	#--> Yes
	Do(:Sun).ReactedTo(:Moon) 	#--> No

	Say('
		SetTalker(:Sun).TalkingTo(:Moon)
		I.Recognize._(:you).DoNot.Hate(:me)
	')

	DialogFacts() 	#--> [ '_(:Sun).Thinks._(:Moon).Hates(:Sun)',
			# 	'_(:Moon).Says.DoNot.Hates(:Sun)',
			# 	'_(:Sun).Recognizes._(:Moon).DoNot.Hates(:Sun)' ]

	Does(:Sun).Recognize._(:Moon).DoNot.Hates(:Sun) #--> Yes
	Does([ :Son, :Moon ]).Agree() #--> Yes
}
