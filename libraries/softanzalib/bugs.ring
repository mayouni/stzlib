
/*---------------- #narration ...WXT() vs ...W()
*/

# This code sample demonstrates an advanced feature of SoftanzaLib 
# called Conditional Code. We will explain what Conditional Code is,
# and then We'll explore two main forms of conditional functions:
# `..WXT()` and `..W()`, comparing their expressiveness, performance, and use cases.

# This comparison will help you understand when to use each
# function for optimal results in your code.

# 1. Conditional code, by example:

	# To each fucntion in Softanza, ther is a ..W() extension that
	# runs the same function but with a conditional code (W ~> Where).
	# Conditional code is a en expression you provide to the function
	# to be evaluated against each element in the data set.
	
	# Let's take the example of Find() function, that we use like this:
	
	? Q("--a--a--a--").Find("a")
	#--> [ 3, 6, 9 ]

	# We can achieve the same result using the W() extended form:

	? Q("--a--a--a--").FindWXT(' Q(@Char).IsLetter() ') # Ignore the XT() for now.
	#--> [ 3, 6, 9 ]

	# In this case, the condition ' Q(@Char).IsLetter() ' is evaluated against
	# each character of the string, returning the positions of all letters.
	
	# Building on this concept, we'll explore two main forms of conditional
	# functions : `WXT()` and `W()`, comparing their expressiveness, performance,
	# and use cases. This comparison will help you understand when to use each
	# function for optimal results in your code.

	# Todo so, let's initiate a stzList object with the fellwong items:

	o1 = new stzList([ "A", "B", "♥", "♥", "C", "♥", "♥", "D", "♥","♥" ])

	? "---" + NL + NL

# 2. The `..WXT()` Form: Expressive but Less Performant

	# The `WXT()` function is designed for use when the condition
	# expression contains sophisticated keywords beyond the basic
	# "@i" and "This[@i]"-like keywords.

	# This option offers greater expressiveness but at the
	# cost of performance.

	# When you use the `..WXT()` form, SoftanzaLib performs an
	# internal process called 'transpiling'. This process translates
	# the provided conditional code by replacing sophisticated
	# keywords (like @CurrentItem, @NextItem, etc.) with their
	# basic equivalents using only @i and This[@i]. For example:

	# 	- @CurrentItem becomes This[@i]
	# 	- @NextItem becomes This[@i+1]
	# 	- @PreviousItem becomes This[@i-1]

	# Hence, this transpiling step allows `..WXT()` to be more
	# expressive, but it also introduces a performance overhead.

	# Examples using `WXT()`:


	? @@( o1.FindWXT('{ @CurrentItem = @NextItem }') ) + NL
	#--> [ 3, 6, 9 ]
	
	? o1.FindFirstWXT(' @CurrentItem = @NextItem ')
	#--> 3
	
	? o1.FindFirstWXT(' @CurrentItem = @PreviousItem ')
	#--> 4
	
	? o1.FindLastWXT(' @CurrentItem = @NextItem ')
	#--> 9
	
	? o1.FindNthWXT(2, ' @CurrentItem = @NextItem ') + NL
	# Executed in 1.32 second(s)

	? "---" + NL + NL

# 3. The `..W()` Form: Restrictive but More Performant

	# The `..W()` form restricts you to expressing your conditions
	# using only "@i" and "This[@i]", regardless of their complexity.
	# This limitation makes `W()` less expressive but more performant.

	# Examples using `W()`:

	? @@( o1.FindW(' This[@i] = This[@i+1] ') ) + NL
	#--> [ 3, 6, 9 ]
	
	? o1.FindFirstW(' This[@i] = This[@i+1] ')
	#--> 3
	
	? o1.FindFirstW(' This[@i] = This[@i-1] ')
	#--> 4
	
	? o1.FindLastW(' This[@i] = This[@i+1] ')
	#--> 9
	
	? o1.FindNthW(2, ' This[@i] = This[@i+1] ') + NL
	# Executed in 0.80 second(s)
	
	? "---" + NL + NL

	#NOTE # on Performance Comparison

	# The performance gain from using `W()` instead of `WXT()`
	# (1.32 seconds vs 0.80 seconds in our example) becomes more
	# significant when running complex conditional codes on
	# large datasets.

# 4. When choosing the wrong form, whoud you should expect?

	# When using just basic keywords (i.e., @i and This[@i]-like) with
	# the `WXT()` function, your code will work, but you'll incur an
	# unnecessary performance cost due to the transpiling process:


	? o1.FindNthWXT(2, ' This[@i] = This[@i+1] ') #--> 6
	# Executed in 0.23 second(s)
	
	? o1.FindNthW(2, ' This[@i] = This[@i+1] ') #--> 6
	# Executed in 0.15 second(s)

	# Conversely, using sophisticated keywords with the `W()` function
	# will result in an error:

	//? o1.FindFirstW(' This[@i] = @PreviousItem ')
	#--> Error message: Using uninitialized variable: @previousitem

# 5. An Additional small syntax difference

	# In `WXT()`, you can bound the conditional code with curly braces { and }.
	# This syntactic sugar is used to mimic real Ring code and provide programmers
	# coming to Ring from other languages with a familiar experience. Like This:

	? o1.FindWXT('{
		len(@Char) = 1 and
		IsLetter(@Char) and
		@Char != "X"
	}')

	# However, this isn't possible in the `W()` form.

	# This difference aligns with the general trade-off between
	# expressiveness and performance.

# 6. Key Takeaways

	# 1. Use `WXT()` when you need to express complex conditions with
	#    sophisticated keywords.

	# 2. Use `W()` for better performance and write your condition
	#    using only @i and This[@i].

	# 3. Be aware of the performance implications when choosing between
	#    `WXT()` and `W()`, especially for large datasets or complex operations.

	# 4. Alwas remember that `WXT()` allows for more flexible syntax (like using
	#    sophisticaded keywords and curly braces), while `W()` form is more
	#    restrictive but faster.
	
# By understanding these differences, you can make informed decisions about
# which function form to use in your conditional code, balancing expressiveness
# and performance based on your specific needs.
