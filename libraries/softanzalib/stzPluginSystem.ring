/*
This code demonstrates how to implement a plugin system in Ring
using the feature of embedding Ring within Ring.

The code contains two classes: BaseString and ExtendedString.

The BaseString class provides basic string methods, such as size() and upp().

The purpose of the plugin system is to allow users to write custom methods
in separate files, stored in the plugins subfolder.

The system reads each plugin file, executes it in a separate Ring state,
and integrates the functions found in the plugin file as part of the
ExtendedString class.

To invoke the extended function, the programmer uses the Xf() method,
passing the name of the plugin function and the required parameters.

Here is an example of the content of a plugin file:

	#< ring_pluging_file #>
	
	@plugin_desc   = "Plugin for replacing a substring by an other in a given string"
	@plugin_name   = "plugin_string_replace"
	
	@plugin_value  = "Hello Ring in Ring!"
	@plugin_param  = [ "Hello", "Embedding" ]
	
	@plugin_result = pluginFunc(@plugin_value, @plugin_param)
	#--> Embedding Ring in Ring!
	
	func pluginFunc(value, aParams)
		cResult = substr(value, aParams[1], aParams[2])
		return cResult

The programmer should only give a name to the file with the format:
	{"plugin_string_" + @MethodName }

And then implement the function in the file by changing its body.

*/

load "stzlib.ring"

# loading plugins files from plugin folder (just the data about them)
# ~> plugins are run only when they are request
# ~> plugins are discovered dynamically from the \plugins\ folder

_aPlugins = LoadPlugins()
#--> [
#	[ "countVowels", 	"plugin_string_countVowels.ring" ],
#	[ "removeNonLetters", 	"plugin_string_removeNonLetters.ring" ],
#	[ "reverse", 		"plugin_string_reverse.ring" ]
# ]

pron()

	o1 = new XString("Hello Ring in Ring!")
	
	#~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~#
	#   CALLIN SOME METHOS FROM THE BASE OBJECT   #
	#~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~#
	# ~> Just to say that they are available in the pluguable
	# version of the object (XString) by inheritance

	? o1.size() 	#--> 19
	? o1.upp() + NL	#--> HELLO RING IN RING!
	
	? "---" + NL

	#~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~#
	#   USING THE PLUGIN-BASED XMETHODS ON THE XSTRING OBJECT   #
	#~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~#

	# Calling plugins methods functions from the extended class
	# (commly called XMethods, or XFunctions where the X means Plugin)

	#NOTE # These xmethods are not defined in the class, but loaded
	# dynamically from the plugins files using the Xf() method

	# The xmethods are run in a songly-isolated environmenet
	# (defined by a specific Ring VM state)

	? o1.Xf(:Reverse)
	#--> !gniR ni gniR olleH

	? o1.Xf(:countVowels)
	#--> 5

	? o1.Xf(:removeNonLetters)
	#--> HelloRinginRing

	//? o1.Xf(:doStaff) # The plugin does not exit
	#--> !!! Error (R35) : Can't create/open the file !!!

		#NOTE // To let it raise the error without interrupting
		# programm execution, use the fault-tolenrant version:

		? o1.Xff(:doStaff)

	? o1.Xf(:replace = [ "Hello", "Embedding" ]) + NL
	#--> Embedding Ring in Ring!

	? o1.Xf(:reverse) + NL
	#--> !gniR ni gniR olleH

	? "---" + NL

	#~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~#
	#   UPDATING THE BASE OBJECT WITHE THE OUTPUT OF THE PLUGIN-BASED FUNCTIONS   #
	#~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~#

	# As you see, Xf() functions always return a value, even if the
	# meaning of the function is an action. This is noraml, because
	# the plugin-based functions run in an isolate Ring state. And
	# hence it can noot make any action (side-effect) on the
	# objects (and variables) on the main program.

	# To make the update, you just add the U suffix to the bame of the Xf() function.

	# Let's check the base object content first (you will notice that none of the
	# xfunctions we called above has changed its initial value)

	? o1.Content()
	#--> Hello Ring in Ring!

	# Now, let's update the string object by calling one of our plugin-based
	# functions, and then check the again its content

	o1.XfU(:reverse)

	? o1.Content()
	#--> !gniR ni gniR olleH

	? "---" + NL

	#~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~#
	#   OPTING A PROTECTIVE-CODING STYKE WHILE UPDATING WITH PLUGIN-BASED FUNCTIONS   #
	#~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~#

	# A diffence worh noting here, between updating things in Softanza using
	# normal update functions and plugin-based functions (XfU()), is that the
	# first just makes the update and returns nothing, but the XfU() makes tries
	# to make the update and returns TRUE or FALSE, depending whethe the update
	# has neen successful or not.

	# This is normal because the first happens in a managed environment, but the
	# second happens in an external plugin-ebvironmend involving unmaneged fatures
	# like reading and closing files (made by the operation system).

	# To Chek it, write this to get TRUE:

	? o1.XfU(:replace = [ "Hello", "Embedding" ])
	#--> TRUE

	# In this case, the XFunction has been executed and the
	# main object has been succefully replaced

	? o1.Content() + NL
	#--> Embedding Ring in Ring!

	# Or write this and get FALSE:

	? o1.XfU(:doStaff) + NL
	#--> FALSE

	# Hence you are able to opt for a protective-style to check
	# plugin-based functions in a conditional code like this:

	if o1.Xf(:replace = [ "Embedding", "Hello" ])
		? "The string object has been changed back to its initial value!"
		? o1.Content()
	else
		raise("Sorry! Can't update the string.")
	ok

	? "---" + NL

	#~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~#
	#   TRACING THE PLUGIN-BASED FUNCTIONS   #
	#~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~#

	# Checking the list of eXtended (plugin-based) functions
	# that were called on the XString object
	
	? @@( o1.XFuncts() ) + NL # or XFunctions() or simply Xfs()
	#--> [ "reverse", "countvowels", "removenonletters", "replace" ]

	# We can uste the XCalls() function return a useful set of data
	# along with the xfunctions list:

	? @@NL( o1.XCalls() ) + NL 
	# [
	# 	[ "reverse", [ ], 1, "!gniR ni gniR olleH", 0 ],
	# 	[ "countvowels", [ ], 1, 5, 0 ],
	# 	[ "removenonletters", [ ], 1, "HelloRinginRing", 0.04 ],
	# 	[ "dostaff", [ ], 0, "Error (R35) : Can't create/open the file", 0 ],
	# 	[ "replace", [ "Hello", "Embedding" ], 1, "Embedding Ring in Ring!", 0 ],
	# 	[ "reverse", [ ], 1, "!gniR ni gniR olleH", 0 ]
	# ]

	# ~> As you can see, XCalls() returns function names, their params,
	# wether the function, succeeded or raised an error, the actual
	# ouput of the call (or the error message), and finally the executin
	# time of the called function in the plugin file.

	# Now, if you look closely to the list of functions returned by Xfs(),
	# above, you'll note that :reverse and :replace xfunctions figure only once,
	# although they have been called more times in code we wrote.

	# To get the list of xfunctions used alogon with how many times they
	# called, we use the Z() prefix with the Xfs() function:

	? @@NL( o1.XfsZ()) + NL
	#--> [
	# 	[ "reverse", [ 1, 6, 7 ] ],
	# 	[ "countvowels", [ 2 ] ],
	# 	[ "removenonletters", [ 3 ] ],
	# 	[ "dostaff", [ 4 ] ],
	# 	[ "replace", [ 5, 8, 9 ] ]
	# ]

	# Hence we see the :reverse has been called 3 times, in the 1st,
	# 6th, and 7th call; :replace has been called 3 times in the
	# 5th, 8th, and 9th call; while the others (:countvowels,
	# :removeNonLetters, and :doStaff) have been called just once
	# (respectively in the 2th, 3rd and 4th calls).

	#NOTE // These features produce a dynamic structure of the call
	# stuck of the plugin system, and enables you to make a compete
	# and deep analysis of what happened. Sutch level of debuggability
	# is necessary because plugin-fuctions are not necessary provided
	# by you, but their use in the main program is your entire responsibility!

	? "---" + NL

	#~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~#
	#   GETTING THE FAILED AND THE SUCCESEEDED CALLS  #
	#~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~#

	# We can check the number of erronous calls

	? o1.HowManyXErrors() # Or HowManyXFialedCall()
	#--> 1

	# And get the erronous functions, along with ther params
	# and error messages

	? @@NL( o1.XErrors() ) + NL # Or XErroneousCalls()
	#--> [
	# 	[ "dostaff", [ ], "Error (R35) : Can't create/open the file" ]
	# ]

	# Same analogy for successful calls

	? o1.NumberOfXSuccesses() # NumberOf is an alternative of HowMany in Softanza
	#--> 8

	? @@NL( o1.XSuccesses() ) # Or XSucceseededCalls()
	#--> [
	# 	[ "reverse", [ ], "!gniR ni gniR olleH" ],
	# 	[ "countvowels", [ ], 5 ],
	# 	[ "removenonletters", [ ], "HelloRinginRing" ],
	# 	[ "replace", [ "Hello", "Embedding" ], "Embedding Ring in Ring!" ],
	# 	[ "reverse", [ ], "!gniR ni gniR olleH" ],
	# 	[ "reverse", [ ], "!gniR ni gniR olleH" ],
	# 	[ "replace", [ "Hello", "Embedding" ], "Embedding Ring in Ring!" ],
	# 	[ "replace", [ "Embedding", "Hello" ], "Embedding Ring in Ring!" ]
	# ]


	? "---" + NL

	#~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~#
	#   PROFILING THE PLUGIN-BASED FUNCTIONS   #
	#~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~#

	? o1.XTime() + NL # in seconds
	#--> 0.04

	//? o1.XTimeByFunct()

	#TODO
	//? o1.XSortTime() # Or XSortUpTime()

	#TODO
	//? o1.XSortDownTime()

	# TODO: Profiling also the part of time taken by the main
	# program before and after calling the plugin

	#~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~#
	#   PLUGIN-BASED FUNCTIONS ARE MEM-CACHED BY DEFAULT   #
	#~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~#

	# Because the main maintains all the data related to the
	# functions called inside the plugins, including the params
	# we used to call them, and thir relative ouputs, Softanza
	# checks automatically if the output of a new call could
	# be served from that data in memory, before calling the plugin.

	#TODO # illustrate the usefulness of this feature with a
	# relatively heavy code in terms of performance.

	# Now, you may ask: what if the plugin file has been changed
	# in-between, how can we check it?

	# For that, we provide the fellowing function

	//? XPluginFileHasBeenChanged() # return TRUE or FALSE

	#TODO // think of the best way to implemented, and how the
	# main program could be notified if the plugin file is changed

	#TODO // illustrate this by an example

	#~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~#
	#   DELAGATING THE MAIN CONTROL FLOW THE THE PLUGIN-BASED FUNCTIONS   #
	#~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~#


	# Sometimes, it's better for performance to not goback to the main program
	# each time a plugin-function has been called, to tell to the control flow
	# what xfunction to call next. Instead, we can delegate this to the plugins
	# who will call the next one directly, without encombrating the main program.

	# To do this, we must tell to the plugin, when we call it, what other plusgin
	# to call after his work is finished. So we use the same Xf() we used above,
	# by providing iyt with not only one plugin, by by many:

	//? o1.Xf([ :remomeNonLetters, :Replace = [ "Embedding", "Hello" ], :reverse)
	#--> !gniRnigniRolleR

	# With this, the main program make only only collective call. Then each plugin
	# calls the next (ie each Ring instance calls the next), leading to a more
	# performant code and efficient mememry use.

	# To make the same think by going back each time to the main program, we say

	//? o1.XfU(:remomeNonLetters)
	//? o1.XfU(:Replace = [ "Embedding", "Hello" ])
	//? o1.Xf(:Reverse)

	#TODO implement this feature

	#TODO study the addition of ReusablePlugins (pool of states)

proff()
# Executed in 0.28 second(s).

#---------------------------------------#
#  IMPLEMENTATION OF THE PLUGIN SYSTEM  #
#=======================================#

func PathSeparator()
	if isWindows()
		return "\"
	else
		return "/"
	ok

	func PathSep()
		return PathSeparator()

func LoadPlugins()
	aList = dir("plugins")
	nLen = len(aList)

	aResult = []
	
	for i = 1 to nLen
		cPluginFile = aList[i][1]
		acParts = split(cPluginFile, "_")
		cPluginFunc = split(acParts[3], ".")[1]
		aResult + [ cPluginFunc, cPluginFile ]
	next

	return aResult

class XString from BaseString
	@acFuncs = []
	@aCalls = []

	def XCalls()
		return @aCalls

	def NumberOfXCalls()
		return len(@aCalls)

		#< @FunctionAlternativeForms

		def HowManyXCalls()
			return len(@aCalls)

		def HowManyXCall()
			return len(@aCalls)

		#>

	def XTime()
		nResult = 0
		nLen = len(@aCalls)

		for i = 1 to nLen
			nResult += @aCalls[i][5]
		next

		return nResult

	def XErrors()
		aResult = []
		nLen = len(@aCalls)

		for i = 1 to nLen
			if @aCalls[i][3] = 0
				aResult + [ @aCalls[i][1], @aCalls[i][2], @aCalls[i][4] ]
			ok
		next

		return aResult

		#< @FunctionAlternativeForms

		def XErroneousCalls()
			return This.XErrors()

		def XFailedCalls()
			return This.XErrors()

		#>

	def NumberOfXErrors()
		return len( This.XErrors() )

		#< @FunctionAlternativeForms

		def HowManyXErrors()
			return This.NumberOfXErrors()

		def HowManyXError()
			return This.NumberOfXErrors()

		def NumberofXErrorneousCalls()
			return This.NumberOfXErrors()

		def HowManyXErroneousCalls()
			return This.NumberOfXErrors()

		def HowManyXErroneousCall()
			return This.NumberOfXErrors()

		def NumberofXFailedCalls()
			return This.NumberOfXErrors()

		def HowManyXFailedCalls()
			return This.NumberOfXErrors()

		def HowManyXFailedCall()
			return This.NumberOfXErrors()

		#>

	def XSuccesses()
		aResult = []
		nLen = len(@aCalls)

		for i = 1 to nLen
			if @aCalls[i][3] = 1
				aResult + [ @aCalls[i][1], @aCalls[i][2], @aCalls[i][4] ]
			ok
		next

		return aResult

		#< @FunctionAlternativeForms

		def XSuccessfulCalls()
			return This.XSuccesses()

		def XSucceededCalls()
			return This.XSuccesses()

		def XSucceeded()
			return This.XSuccesses()

		#>

	def NumberOfXSuccesses()
		return len( This.XSuccesses() )

		#< @FunctionAlternativeForms

		def HowManyXSuccess()
			return This.NumberOfXSuccesses()

		def HowManyXSuccesses()
			return This.NumberOfXSuccesses()

		def NumberOfXSucessfulCalls()
			return This.NumberOfXSuccesses()

		def NumberOfXSucceededCalls()
			return This.NumberOfXSuccesses()

		def HowManyXSucceededCalls()
			return This.NumberOfXSuccesses()

		def HowManyXSucceededCall()
			return This.NumberOfXSuccesses()

		#>

	def XFunctions()
		return @acFuncs

		#< @FunctionAlternativeForms

		def XFuncts()
			return @acFuncs

		def Xfs() # s for plural
			return @acFuncs

		#>

	def NumberOfXFunctions()
		return len(@acFuncs)

		#< @FunctionAlternativeForms

		def NumberOfXFuncts()
			return len(@acFuncs)

		def NumberOfXfs()
			return len(@acFuncs)

		#--

		def HowManyXFunctions()
			return len(@acFuncs)

		def HowManyXFunction()
			return len(@acFuncs)

		def HowManyXFuncts()
			return len(@acFuncs)

		def HowManyXFunct()
			return len(@acFuncs)

		def HowManyXfs()
			return len(@acFuncs)

		def HowManyXf()
			return len(@acFuncs)

		#>

	def XfunctionsZ()
		aResult = []
		nLen = len(@aCalls)
		acSeen = []

		for i = 1 to nLen

			if ring_find(acSeen, @aCalls[i][1]) = 0
				aResult + [ @aCalls[i][1], [ i ] ]
				acSeen + @aCalls[i][1]
			else
				aResult[ @aCalls[i][1] ] + i
			ok
		next

		return aResult

		#< @FunctionAlternativeForms

		def XFuncsZ()
			return This.XfunctionsZ()

		def XfsZ()
			return This.XfunctionsZ()

		#>

	def XfU(FuncOrFuncAndParams)
		try
			result = This.Xf(FuncOrFuncAndParams)
			This.UpdateWith(result)
			return TRUE
		catch
			return FALSE
		done

	def Xf(FuncOrFuncAndParams)

		if isString(FuncOrFuncAndParams)
			cFuncName = FuncOrFuncAndParams
			aParams = []

		but isList(FuncOrFuncAndParams) and len(FuncOrFuncAndParams) = 2 and
		    isString(FuncOrFuncAndParams[1])
			cFuncName = FuncOrFuncAndParams[1]
			aParams = FuncOrFuncAndParams[2]

		else
			raise("Bad function name!")
		ok

		# Getting the name of the plugin file name

		if _aPlugins[cFuncName] = NULL
			raise("Inexistant function name!")
		ok

		cPluginFile = 'plugins' + PathSep() + _aPlugins[cFuncName]

		# Setting the containers of the output
		result = ""
		error = ""

		# Initiating and running the plugin in a separate VM
		pState = ring_state_init()

		try

			cCode = read(cPluginFile)
			ring_state_runcode(pState, cCode)

			# Setting the value and params of the pluging function

			cValue = '@plugin_value = ' + @@(This.Content())
			ring_state_runcode(pState, cValue)

			cParam = '@plugin_param = ' + @@(aParams)
			ring_state_runcode(pState, cParam)

			# Getting the result
			result = ring_state_findvar(pState, '@plugin_result')[3]

			# Recording the plugin

			if find(@acFuncs, cFuncName) = 0
				@acFuncs + cFuncName
			ok

			time = ring_state_findvar(pState, '@plugin_time')[3]
			@aCalls + [ cFuncName, aParams, TRUE, result, time ]

		catch
			error = cCatchError
			@aCalls + [ cFuncName, aParams, FALSE, error, 0 ]
		done

		# Removing the state from memory
		ring_state_delete(pState)
		
		# Returning the result or raising an error

		if error = ""
			return result
		else
			raise(error)
		ok

	# The fault-tolerant form of Xf()

	def Xff(FuncOrFuncAndParams)

		if isString(FuncOrFuncAndParams)
			cFuncName = FuncOrFuncAndParams
			aParams = []

		but isList(FuncOrFuncAndParams) and len(FuncOrFuncAndParams) = 2 and
		    isString(FuncOrFuncAndParams[1])
			cFuncName = FuncOrFuncAndParams[1]
			aParams = FuncOrFuncAndParams[2]

		else
			raise("Bad function name!")
		ok

		# Getting the name of the plugin file name

		cPluginFile = 'plugins' + PathSep() + _aPlugins[cFuncName]

		# Setting the containers of the output
		result = ""
		error = ""

		# Initiating and running the plugin in a separate VM
		pState = ring_state_init()

		try

			cCode = read(cPluginFile)
			ring_state_runcode(pState, cCode)

			# Setting the value and params of the pluging function

			cValue = '@plugin_value = ' + @@(This.Content())
			ring_state_runcode(pState, cValue)

			cParam = '@plugin_param = ' + @@(aParams)
			ring_state_runcode(pState, cParam)

			# Getting the result
			result = ring_state_findvar(pState, '@plugin_result')[3]

			# Recording the plugin
			time = ring_state_findvar(pState, '@plugin_time')[3]
			@aCalls + [ cFuncName, aParams, TRUE, result, time ]

		catch
			error = cCatchError
			@aCalls + [ cFuncName, aParams, FALSE, error, 0 ]

			? NL+ '!!!' + error + '!!!'
		done

		# Removing the state from memory
		ring_state_delete(pState)
		
		# Returning the result or raising an error

		if error = ""
			return result
		ok

class BaseString
	@str

	def init(pcStr)
		@str = pcStr

	def content()
		return @str

	def updateWith(str)
		@str = str

	def size()
		return len(@str)

	def upp()
		return upper(@str)
