load "../max/stzmax.ring"

? @@( MergeContiguousSections([ [ 1, 4 ], [ 6, 8 ], [ 9, 10 ], [ 12, 13 ], [ 13, 15 ] ]) )

func MergeContiguousSections(sections)
	nLen = len(sections)
	if nLen <= 1
		return sections
	ok

	// Sort the sections based on the start of each section
	for i = 1 to nLen - 1
		for j = i + 1 to nLen
			if sections[i][1] > sections[j][1]
				temp = sections[i]
				sections[i] = sections[j]
				sections[j] = temp
			ok
		next
	next

	// Merge contiguous sections
	mergedSections = []
	current = sections[1]

	for i = 2 to nLen
		// If current section overlaps or is contiguous with the next section
		if sections[i][1] <= current[2] + 1
			// Extend the current section's end
			current[2] = @max([ current[2], sections[i][2] ])
		else
			// Add the current section to merged sections and start a new current
			mergedSections + current
			current = sections[i]
		ok
	next

	// Add the last section
	mergedSections + current

	return mergedSections


/*---

pron()

# Given the string: "abracadabra", replace programatically:
#
#	the first 'a' with 'A'
#	the second 'a' with 'B'
#	the fourth 'a' with 'C'
#	the fifth 'a' with 'D'
#	the first 'b' with 'E'
#	the second 'r' with 'F'
#
# The answer should, of course, be : "AErBcadCbFD".

Q("abracadabra") {

	ReplaceNth(5, 'a', :with = 'D')
	ReplaceNth(4, 'a', :with = 'C')
	ReplaceNth(2, 'a', :with = 'B')
	ReplaceNth(1, 'a', :with = 'A')

	ReplaceNth(1, 'b', :with = 'E')
	ReplaceNth(2, 'r', :with = 'F')

	? Content()
	#--> AErBcadCbFD
}

proff()
# Executed in 0.01 second(s) in Ring 1.21

/*---

pron()

Q("abracadabra") {
	ReplaceManyNthSubStrings([
		[ 1, 'a', :with = 'A' ],
		[ 2, 'a', :with = 'B' ],
		[ 4, 'a', :with = 'C' ],
		[ 5, 'a', :with = 'D' ],
	
		[ 1, 'b', :with = 'E' ],
		[ 2, 'r', :with = 'F' ]
	])

	? Content()
}

proff()

/*---

pron()

Naturally() {
	Given the string "abracadabra" replace programatically

		the first 'a' with 'A'
		the second 'a' with 'B'
		the fourth 'a' with 'C'
		the fifth 'a' with 'D'
		the first 'b' with 'E'
		the second 'r' with 'F'

	The answer should of course be "AErBcadCbFD"
}

proff()

