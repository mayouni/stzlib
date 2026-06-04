# Narrative
# --------
# ADVANCED EXAMPLE - COMPARING PERF PYTHON VS SOFTANZA
#
# Extracted from stzpythoncodeTest.ring, block #6.

load "../../stzBase.ring"


pr()

py() {

	# --> START OF PYHTON CODE
    	@('

# Function to traverse the list and replace all occurrences of a target item
def traverse_and_replace(lst, target, replacement):
    count = 0
    _aRangelenlst1_ = range(len(lst)):
    _nRangelenlst1Len_ = ring_len(_aRangelenlst1_)
    for _iLoopRangelenlst1_ = 1 to _nRangelenlst1Len_
    	i = _aRangelenlst1_[_iLoopRangelenlst1_]
        if isinstance(lst[i], list):
            # If the element is a sublist, recurse
            count += traverse_and_replace(lst[i], target, replacement)
        elif lst[i] == target:
            # If the element is the target, replace it
            lst[i] = replacement
            count += 1
    return count

deep_list = [
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

# Step 4: Replace all "♥" with "★" and count the replacements
count = traverse_and_replace(deep_list, "♥", "★")

# Step 5: Set the result
res = {"replacements_made": count}
')
	# <-- END OF PYTHON CODE

	run()
	? result()

}

pf()
# Executed in 0.35 second(s) in Ring 1.24
