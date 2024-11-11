load "../max/stzmax.ring"

// INCMPLETE: NOT READY FOR TESTING.

/* TODO: Make it possible the input of a tree in a string:

cTree = "
	Skills
		Writing
		Programming
	Places
		Africa
			Tunisia
			Algeria
			Morroco
		Europe
			France
			Italy
			Spain
	Misc
		Name
		Job
		Age
"

/*-------------------

myTree =
[ 
	:Root = "Mansour",
		:Skills = [
			"Wrinting",
			"Programming"
		],
	
		:Places = [
			:Africa = [
				"Tunisia",
				"Algeria",
				"Marocoo"
			],
	
			:Europe = [
				"France",
				"Spain",
				"Italy"
			]
		],
	
		:Misc = [
			"Name",
			"Job",
			"Age"
		]
	
]

? myTree[:Places][:Africa][1]
? find(myTree, "Programming")

/*---------------------

oTree = new stzTree {
	AddNode("Skills") {
		AddLeaf("Programming")
		AddLeaf("Writing")
	}

	AddNode("Places") {
		AddNode("Africa") {
			AddLeaf("Tunisia")
			AddLeaf("Algeria")
			AddLeaf("Marrocco")
		}

		AddNode("Europe") {
			AddLeaf("France")
			AddLeaf("Spain")
			AddLeaf("Italy")
		}
	}

	
}



oTree = new stzTree(myTree)
oTree.Show()
*/
