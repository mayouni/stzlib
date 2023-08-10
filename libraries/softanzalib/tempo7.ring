load "stzlib.ring"

# This Python code calculates the euclidean distance between
# two lists of numbers located in lists a and b:

'
def dist(a,b):
    s = 0.0
    n = len(a)
    for i in range(n):
        dist = a[i] - b[i]
        s += dist*dist
    return sqrt(s)

a = [ 1, 2, 3, 4, 5 ]
b = [ 4, 5, 6, 7, 8 ]

print(euc_dist(a,b))
#--> 6.71

'

# In Ring, with Softanza, we can reuse nearly the same code,
# like this :

pron()

	a = 1:5
	b = 4:8
	
	? euc_dist(a,b)
	#--> 6.71

proff()
# Executed in 0.03 second(s)

def euc_dist(a,b)':' # : is put between two ''
	s = 0.0
	n = len(a)

	for i in range1(n)':'
	# We use range1() to make it start from 1
	# We can also leave range() and add i++

		dist = a[i] - b[i]
		s += dist * dist
	next

	return sqrt(s)
