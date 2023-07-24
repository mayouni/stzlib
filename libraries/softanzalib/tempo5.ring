load "stzlib.ring"

pron()

//list = [1, 2, 3, 4, 5, 1, 2, 3]
list = 1:10_000
list + 1 + 2 + 3 + 4 + 5 + 1 + 2 + 3
duplicates = find_duplicates(list)
? @@(duplicates)

proff()

def find_duplicates(list)
	duplicates = []
	nLen = len(list)

	for i = 1 to nLen - 1
		for j = i + 1 to nLen
			if list[i] = list[j]
				duplicates + [i, j]
			ok
		next	
	next

	return duplicates
