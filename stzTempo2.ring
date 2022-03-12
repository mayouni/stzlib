// Function with no parms
f1 = :sayhello
call f1()

// Function with params
f2 = :say
call f2("Ring")

// A function returned by an other function
f = getfunc(2)
call f("God")

// A function sent as a paramter to an other (higher order) function
? Derivative(:twice)

func Derivative(pcFunction)
	n = call pcFunction(3)
	return n * (1-n)

func twice(n)
	return n*2

func sayhello()
	? "Hello!"

func say(cSomething)
	? cSomething

func getfunc(pnFuncNumber)
	switch pnFuncNumber
	on 1	return f1
	on 2	return f2
	off
