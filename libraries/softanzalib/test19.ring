
colors = [
	:red = 2,	#--> [ "red", 2 ]
	:green = 1,
	:blue = 1,
	:yellow = 1,
	:pink = 3
]

/*
colors = [
	[ "red", 2 ],
	[ "green", 1 ],
	[ "blue", 1 ],
	[ "yellow", 1 ],
	[ "pink", 3 ]
]
*/

? colors #--> [ [ "red", 2 ],[ "green", 1 ], [ "blue", 1 ], [ "yellow", 1 ], [ "pink", 3 ] ]
? islist( colors[3] ) #--> TRUE
? find(colors, "blue" ) #--> 0
? len(colors) #--> 5

? colors[ "pink" ] #--> 3

