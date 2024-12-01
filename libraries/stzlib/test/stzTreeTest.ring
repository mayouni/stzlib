load "../max/stzmax.ring"

// INCMPLETE: NOT READY FOR TESTING.

/*---- Test Setup and Initialization ----

pron()

o1 = new stzTree([
	
        "Root",

        [ "Node1",

		[ "SubNode1.1", "Leaf1.1.1" ],
           	"Leaf1.2"
        ],

        [ "Node2", 
            	"Leaf2.1", 
            	[ "SubNode2.2", "Leaf2.2.1", "Leaf2.2.2" ]
        ],

        "Leaf3"
    ])
    
    o1.Show()

proff()
# Executed in 0.02 second(s) in Ring 1.21

/*---- TODO: Make it possible the input of a tree in a string:

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
			"Writing",
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

pron()

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

proff()
