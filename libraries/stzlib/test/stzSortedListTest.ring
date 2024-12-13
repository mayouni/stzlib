load "../max/stzmax.ring"

/*--
*/
profon

o1 = new stzSortedList([ 2, 1, 4, 3 ])
? o1.Content()
#--> [ 1, 2, 3, 4, 5 ]

proff()
# Executed in 0.02 second(s) in Ring 1.21

#--

profon

o1 = new stzSortedList([ 2, 1, 4, 6 ])
o1.Add(5)
? o1.Content()
#--> [ 1, 2, 3, 4, 5, 6 ]

proff()
# Executed in 0.01 second(s).

#--

profon

o1 = new stzSortedList([ 2, 1, 4, 6 ])
o1 + 5
? o1.Content()
#--> [ 1, 2, 3, 4, 5, 6 ]

proff()
# Executed in 0.01 second(s).
