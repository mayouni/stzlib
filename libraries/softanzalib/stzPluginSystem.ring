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
	
	#~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~#
	#   CALLING SOME METHODS FROM THE BASE OBJECT   #
	#~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~#
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

	#~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~#
	#   UPDATING THE BASE OBJECT WITH THE OUTPUT OF THE PLUGIN-BASED FUNCTIONS   #
	#~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~#

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

	#~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~#
	#  OPTING FOR A PROTECTIVE-CODING STYLE WHILE UPDATING WITH PLUGIN-BASED FUNCTIONS  #
	#~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~#

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

	#~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~#
	#   CHECKING VOTH FAILED AND SUCCEEDED PLUGIN-BASED CALLS  #
	#~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~#

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

	# Because the main program maintains all the data related to the
	# functions called inside the plugins files, including the params
	# we used to call them, and thir relative ouputs, Softanza
	# checks automatically if the output of a new call could
	# be served from that data in memory, before calling the plugin.

	#TODO # illustrate the usefulness of this feature with a
	# relatively heavy code in terms of performance.

	# Now, you may ask: what if the plugin file has been changed
	# in-between, how can we check it?
	#--> See the HOT-RELOADING feature in the next section

	# For that, we provide the fellowing function

	#~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~#
	#   PLUGIN-FILES ARE CHECKED AT EACH CALL FOR MODIFICATION  #
	#~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~#

	# Each time a plugin function is called, the Softanza plugin system
	# checks wether the plugin file has changed since the last call.

	# This helps optimize the call and reinitialize the plugin state
	# only when necessary (see the next section for more details).

	# Alternatively, we can check this manually using the function:

	? XHasChanged(:plugin-func-name) # returns TRUE or FALSE

	# Addiionnaly, we can get when the ctime of last hange:

	? XTimeOfLastChange(:plugin-func-name) # returns time in HH:MM:SS format

	#TODO Implement this feature

	#~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~#
	#   PLUGIN STATES (RING VM STATES) ARE LAZY-LOADED, REUSABLE, AND HOT-RELOADED   #
	#~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~#

	/*

	1. Program Launch
	   |
	   |-- Identify active plugins (identified by plugin file naming convention "on_.." or "off_..")
	   |   |-- Load names and attributes into memory
	   |
	   |-- No VM instances created initially (lazy-loaded on first call)
	
	2. At Xfunction invocation (using Xf() function)
	   |
	   |-- Check cached sets of params/output
	   |   |
	   |   |-- If match found in memory cache:
	   |   |   |
	   |   |   |-- Check if plugin file has changed
	   |   |   |   |
	   |   |   |   |-- If unchanged:
	   |   |   |   |   |-- Serve output directly from memory cache
	   |   |   |   |   |-- No further action required
	   |   |   |   |
	   |   |   |   |-- If changed:
	   |   |   |   |   |
	   |   |   |   |   |-- Create new instance of plugin file
	   |   |   |   |   |-- Compare params/output with cached value; update cache if different
	   |   |   |   |   |-- Reset instance variables to NULL (clean instance); retain in memory
	   |   |
	   |   |-- If match NOT found in memory cache:
	   |   |   | 
	   |   |   |-- Check for reusable instance matching plugin function
	   |   |   |   | 
	   |   |   |   |-- If reusable instance found:
	   |   |   |   |   |
	   |   |   |   |   |-- Check if plugin file has changed
	   |   |   |   |   |   |
	   |   |   |   |   |   |-- If unchanged:
	   |   |   |   |   |   |   |-- Use reusable instance to obtain output
	   |   |   |   |   |   |   |-- Clean instance and retain in memory
	   |   |   |   |   |   |
	   |   |   |   |   |   |-- If changed:
	   |   |   |   |   |   |   |-- Create new instance of plugin
	   |   |   |   |   |   |   |-- Set params, execute code, obtain output
	   |   |   |   |   |   |   |-- Clean newly created instance; save for future use
	   |   |   |   | 
	   |   |   |   |-- If a reusable instance NOT found:
	   |   |   |   |   |
	   |   |   |   |   |-- Create a new instance of plugin
	   |   |   |   |   |-- Set params, execute code, obtain output
	   |   |   |   |   |-- Clean newly created instance; save for future use
	
	3. XRefresh() Function invocation
	   |
	   |-- Check state instances in memory against file status and defined lifetime
	   |
	   |-- Restart instances requiring update (file changed, lifetime not elapsed)
	   |-- Destroy instances with elapsed lifetime


	4. Explictly saving an instance, restarting it, or destroying it.
	   |
	   |-- Save, restart, or destroy instances using their respective pointers
	   |   |-- To save an instance, its pointer must be retained in the program
	   |   |-- To restart or destroy, the pointer must already be in memory

	5. Retrieving Instance Information
	   |
	   |-- Get their list along with useful data about their status/use statistics
	   |-- Retrieve specific information about a particular plugin instance

	*/

	#NOTE ON HOT-RELOADING FEATURE
	# Hot reload supercharges development! It lets game devs tweak mechanics
	# and UI live, updates running apps without downtime, and sculpts UIs on
	# the fly for fast designer feedback.

	#TODO Implement these 3 features

	#~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~#
	#   PLUGIN STATES (RING VM STATES) CAN BE PAUSED AND THEN RESUMED   #
	#~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~#

	# Plugins states can be paused and then resumed.

	# By pausing states, we can free up system resources for other processes.

	# or persisit our pluging data (or workflows involving multiple plugins
	# in a scenario of long-running processes).

	# This allows us to free the system from these processes and resume
	# them only when required.

	# This can be done during an Xfunction call by adding a P() suffix to its name:

	o1.XfP(:funcname)  #--> runs the plugin-function and pauses its state

	o1.XfUP(:funcname) #--> runs the same function also updates the main object

	o1.Xff(:funcname)  #--> runs the same function with fault tolerance.

	# alternatively, we can use the dedicated function directly:

	o1.XPause(:funcname)

	# When a plugin state is paused, the next time its function is called,
	# it will weak up and resume as if it was still active, retaining the
	# data from the momement it was paused.

	o1.Xf(:funcname) #--> Resumes the plugin states and runs the function.

	# We can also explicitly resume any paused plugin by:

	o1.XResume(:funcname)

	# Many plugins can be paused/resumed in one operation, simply by providion
	# the functions we showed above by a list of params:

	o1.XfP([ :funcname1, :funcname2, :funcname3 ])

	# Each plugin function can be resumed alone, or all them can be resumed
	# togethor in one call:

	o1.Xf([ :funcname1, :funcname2, :funcname3 ])

	# Alternatively, the next functions can be used:

	o1.XPause([ :funcname1, :funcname2, :funcname3 ]) # Pauses many plugins states

	o1.XResume([ :funcname1, :funcname2, :funcname3 ]) # Resumes many plugins states
	#TODO Implement this pause/resume feature

	#~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~#
	#   DELAGATING MAIN CONTROL FLOW TO A LIST OF CALLED PLUGINS   #
	#~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~#


	# Traditionally, after calling a plugin function, the control flow returns
	# to the main program to determine the next function to execute. This can
	# be inefficient.

	# A better approach is to delegate this responsibility to the plugins themselves.

	# Each plugin can specify the next plugin to call after finishing its work. This
	# eliminates the need for the main program to handele each call individually,
	# improving performance and memory usage.
	
	# How it Works?
	#~~~~~~~~~~~~~~
	
	# We achieve this in Softanza, simply, by providing the Xf() function with
	# a list of plugins instead of just one. Each plugin in the list is called
	# sequentially by the previous one, streamlining the execution flow.
	
	# Example
	
	// Calling multiple plugins in one go

	# o1.Xf([:removeNonLetters, :Replace = ["Embedding", "Hello"], :reverse])
	#--> !gniRnigniRolleR

	# Here, the main program makes a single Xf() call with an array of three
	# plugins. Each plugin calls the next one in the list, resulting in the
	# final output without unnecessary back-and-forth with the main program.
	
	# Traditional Approach (Less Efficient)
	#~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
	
	# For comparison, the traditional approach involves separate calls for each plugin:

	# Example

	# o1.XfU(:removeNonLetters)
	# o1.XfU(:Replace = ["Embedding", "Hello"])
	# o1.Xf(:reverse)

	# This method requires multiple interactions with the main program, leading to
	# decreased performance.
	
	# Benefits of Delegated Control Flow
	#~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
	
	# ~> Improved performance: Calling plugins sequentially eliminates unnecessary overhead.
	# ~> Efficient memory usage: Streamlined execution reduces memory usage.
	# ~> Cleaner code: Main program handles fewer individual calls, leading to more concise code.

	#TODO implement this feature

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
