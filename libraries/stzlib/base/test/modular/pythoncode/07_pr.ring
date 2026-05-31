# Narrative
# --------
# pr()
#
# Extracted from stzpythoncodeTest.ring, block #7.

load "../../../stzBase.ring"


aDeep =  [
    	42, "apple", "♥", ["sun", 314, [-7, "moon", "♥"], "rain"], [
        99,
        "star", "♥",
        [
            0,
            "♥", "cloud",
            [
                272,
                "wind", "♥",
                [
                    "tree",
                    100,
                    [
                        "fish", "♥",
                        "♥", "bird",
                        [
                            8,
                            "sky", "♥",
                            [
                                "♥", "river",
                                162,
                                [
                                    "fire", "♥", "♥",
                                    "♥", "stone",
                                    ["lake", "♥", 77]
                                ]
                            ]
                        ],
                        "winter", "♥"
                    ]
                ]
            ],
            "♥", "summer", "♥"
        ],
        "night", "♥", "♥"
    ]
]

o1 = new stzList(aDeep)
o1.DeepReplace("♥", "★")
? @@NL (o1.Content())

pf()
# Executed in 0.01 second(s) in Ring 1.24
