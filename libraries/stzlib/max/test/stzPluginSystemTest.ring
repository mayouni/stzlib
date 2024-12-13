
load "../stzmax.ring"


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
		cResult = ring_substr2(value, aParams[1], aParams[2])
		return cResult

The programmer should only give a name to the file with the format:
	{"plugin_string_" + @MethodName }

And then implement the function in the file by changing its body.

*/

# loading plugins files from plugin folder (just the data about them)
# ~> plugins are run only when they are request
# ~> plugins are discovered dynamically from the \plugins\ folder

_aPlugins = LoadPlugins()
#--> [
#	[ "countVowels", 	"plugin_string_countVowels.ring" ],
#	[ "removeNonLetters", 	"plugin_string_removeNonLetters.ring" ],
#	[ "reverse", 		"plugin_string_reverse.ring" ]
# ]

profon()

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
	# to make the update and returns _TRUE_ or _FALSE_, depending whethe the update
	# has neen successful or not.

	# This is normal because the first happens in a managed environment, but the
	# second happens in an external plugin-ebvironmend involving unmaneged fatures
	# like reading and closing files (made by the operation system).

	# To Chek it, write this to get _TRUE_:

	? o1.XfU(:replace = [ "Hello", "Embedding" ])
	#--> _TRUE_

	# In this case, the XFunction has been executed and the
	# main object has been succefully replaced

	? o1.Content() + NL
	#--> Embedding Ring in Ring!

	# Or write this and get _FALSE_:

	? o1.XfU(:doStaff) + NL
	#--> _FALSE_

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

	# To get the list of xfunctions used aloong with how many times they
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

	? o1.XTime(:removeNonLetters) + NL # in seconds
	#--> 0.04

	#TODO Add this feature

/*	? o1.XTimeByFunct()

	? o1.XSortTime() # Or XSortUpTime()

	? o1.XSortDownTime()

	# TODO: Profiling also the part of time taken by the main
	# program before and after calling the plugin
*/
	#~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~#
	#   PLUGIN-BASED FUNCTIONS ARE MEM-CACHED BY DEFAULT   #
	#~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~#

	#TODO Add this feature

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

	#~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~#
	#   PLUGIN-BASED FUNCTIONS CAN BE TIMED, SIZED, AND LOOPED   #
	#~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~#

	#TODO Add this feature

	# Timed Plugin-Fuctions
	#~~~~~~~~~~~~~~~~~~~~~~

	# To restric a plugin-function to a maximum of 3 seconds, we add TM() suffix:

	//? o1.XfTM(:reverse = "...FIRST PART... Other art of the string ...", 0.01)
	#--> ...TRAP TSRIF... Other part of the string ...

	# As you see, the reversing stops at the "... FIRST PART..." of  the string
	# when 3 sconds have elapsed. The remaining part is returned as-is.
	# ~> A feature commonly called Graceful Degradation.

	# To cancel the operation and raise an error instead, add X to TM():

	//? o1.XfTMX(:reverse = "...FIRST PART... Other part of the string ...", 3)
	#--> Execution cancelled! The maximum time required has been exceeded.

	# Sized Plugin-Fuctions
	#~~~~~~~~~~~~~~~~~~~~~~

	# The functions can also be constrained by size in bytes:
/*
	? o1.XfSZ(:reverse, "... a large string ...", 120)
	#--> only the part of size 120 bytes is reversed, the rest is returned as-is.

	? o1.XfSX(:reverse, "... a large string ...", 120)
	#--> The operaion is cancelled, and an error is raised!
*/
	# Looped Plugin-Fuctions
	#~~~~~~~~~~~~~~~~~~~~~~~

	# If the inner code خب the plugin function is based on a main loop, you can
	# constraint it to run only a given number of iterations using the L() suffix.
	# (we metaphorically say that the function LOOPED, analogous to the TIMED and
	# SIZED namings used above):
/*
	? o1.XfL(:reverse, "... a large string ...", 99)
	#--> only the first 99 chars are reversed, the rest of the string are returned as-is?

	? o1.XfLX(:reverse, "... a large string ...", 99)
	#--> If the internal plugin loop exceeds 99 iterations, an error is raised.
*/
	# Fault-tolerant Timed, Sized, and Looped Plugin-functions
	#~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~

	# To raise errors in a fault-tolerant way so the main program receives
	# the errors but continues execution of the next actions, use the Xff()
	# form of the calling function:
/*
	? o1.XffTMX(:reverse, " ... large string 1 ...")
	? o1.XffSZX(:reverse, " ... large string 2 ...")
	? o1.XffLX(:reverse, " ... large string 3...")

	# If we suppose that only the second call is erroneous, we get:

	#--> "... large string 1 reversed in part depending on the time contsraint..."
	#--> Error: Can't run the plugin-function! Maximum size exceeded.
	#--> "... large string 3 reversed in part depending on the number of loops..."

	# This leads to robust code, especially when running multiple calls in a list
	# calls (using Xf([ xf1, xf2, ... ])  or when calling them concurrently (using
	# Xf() with the C() suffix).
*/
	# Added Value of TIMED, SIZED, and LOOPED calls
	#~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~

	# 1. When used consciously, these features can prevent runaway processes,
	#    memory bloat, or CPU hogging, which is especially valuable in shared
	#    or resource-constrained environments.

	# 2. Developers can fine-tune the behavior of plugins without modifying
	#    the plugin code itself, which is extremely powerful for system
	#    administrators and DevOps teams.

	# 3. These features can be used as built-in profiling tools, helping
	#    developers identify and optimize slow or resource-intensive operations.

	# 4. When running multiple calls concurrently, these constraints can
	#    prevent any single operation from monopolizing system resources.

	# 5. The system becomes more resilient to poorly optimized or
	#    potentially malicious plugins.

	# 6. The system can adapt to different execution environments by
	#    adjusting these constraints.

	# 7. Improved programming and debugging experience.

	#~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~#
	#   PLUGIN-FILES ARE CHECKED AT EACH CALL FOR MODIFICATION  #
	#~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~#

	#TODO Add this feature
/*
	# Each time a plugin function is called, the Softanza plugin system
	# checks wether the plugin file has changed since the last call.

	# This helps optimize the call and reinitialize the plugin state
	# only when necessary (see the next section for more details).

	# Alternatively, we can check this manually using the function:

	? XHasChanged(:plugin-func-name) # returns _TRUE_ or _FALSE_

	# Addiionnaly, we can get when the ctime of last hange:

	? XTimeOfLastChange(:plugin-func-name) # returns time in HH:MM:SS format
*/
	#~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~#
	#   PLUGIN STATES (RING VM STATES) ARE LAZY-LOADED, REUSABLE, AND HOT-RELOADED   #
	#~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~#

	#TODO Add this feature


/*	1. Program Launch
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
	   |   |   |   |   |-- Reset instance variables to _NULL_ (clean instance); retain in memory
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

	#~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~#
	#   PLUGIN STATES (RING VM STATES) CAN BE PAUSED AND THEN RESUMED   #
	#~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~#

	#TODO Add this feature
/*
	# Plugins states can be paused and then resumed.

	# By pausing states, we can free up system resources for other processes.

	# or persisit our pluging data (or workflows involving multiple plugins
	# in a scenario of long-running processes).

	# This allows us to free the system from these processes and resume
	# them only when required.

	# This can be done during an Xfunction call by adding a P() suffix to its name:

	o1.XfP(:funcname)  #--> runs the plugin-function and pauses its state

	o1.XfUP(:funcname) #--> runs the same function also updates the main object

	o1.XffP(:funcname)  #--> runs the same function with fault tolerance.

	# Alternatively, we can use the dedicated function directly:

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
*/
	#~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~#
	#   DELAGATING MAIN CONTROL FLOW TO A LIST OF CALLED PLUGINS   #
	#~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~#

	#TODO Add this feature

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

//	o1.Xf([:removeNonLetters, :Replace = ["Embedding", "Hello"], :reverse])
	#--> !gniRnigniRolleR

	# Here, the main program makes a single Xf() call with an array of three
	# plugins. Each plugin calls the next one in the list, resulting in the
	# final output without unnecessary back-and-forth with the main program.
	
	# Traditional Approach (Less Efficient)
	#~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
	
	# For comparison, the traditional approach involves separate calls for each plugin:

	# Example
/*
	o1.XfU(:removeNonLetters)
	o1.XfU(:Replace = ["Embedding", "Hello"])
	o1.Xf(:reverse)
*/
	# This method requires multiple interactions with the main program, leading to
	# decreased performance.
	
	# Benefits of Delegated Control Flow
	#~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
	
	# ~> Improved performance: Calling plugins sequentially eliminates unnecessary overhead.
	# ~> Efficient memory usage: Streamlined execution reduces memory usage.
	# ~> Cleaner code: Main program handles fewer individual calls, leading to more concise code.

	#~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~#
	#   PLUGIN LIFECYCLE MANAGEMENT    #
	#~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~#
	
	#TODO Add this feature

	# Softanza's plugin system covers core concepts of plugin lifecycle management:

	# 1. Plugin creation: Initiated on first call using Xf() function
	# 2. Lifecycle operations: Caching, cleaning, pausing, resuming, and closing
	# 3. Activation control: Plugins can be deactivated/activated
	#    (using "off_"/"on_" filename prefixes)
	
	# Querying Plugin Status
	#~~~~~~~~~~~~~~~~~~~~~~~
	
	# Get status of individual or multiple plugins:
/*
	? XStatus(:plugin-name1)
	 #--> :Paused

	? XStatus([ :plugin1, :plugin2 ])
	#--> [ :Paused, :Active ]
	
	# Retrieve plugins by their status:

	? XPluginsThatAre(:Paused) 
	#--> [ :plugin1, :plugin3 ]
*/	
	# Lifecycle History
	#~~~~~~~~~~~~~~~~~~
/*	
	# Get full lifecycle history of a plugin:

	? XStatusXT(:plugin-name1)
	 #--> [ :Initiated, :Paused, :Resumed, :Cleaned, :Closed ]
*/	
	# Detailed Lifecycle Timing
	#~~~~~~~~~~~~~~~~~~~~~~~~~~
	
	# Retrieve detailed timing information for plugin lifecycle:
/*
	? XStatusXTT(:plugin-name1)
	#--> [
	#     :Initiated = [
	#         :TimeElapsed = 0,
	#         :CalledFirst = 2.14,
	#         :CalledLast = 4.80,
	#         :NumberOfCalls = 5
	#     ],
	#     :Paused = 5,
	#     :Resumed = [
	#         :TimeElapsed = 10.12,
	#         :CalledFirst = 10.14,
	#         :CalledLast  = 28.15,
	#         :NumberOfCalls = 2
	#     ],
	#     :Cleaned = [
	#         :TimeElapsed = 14.80,
	#         :CalledFirst = 5.10,
	#         :CalledLast  = 5.15,
	#         :NumberOfCalls = 1
	#     ],
	#     :Closed = 18.12
	# ]
	
	# The timing data provides insights into plugin behavior:

	# - Plugin initiation: First call at 2.14s, last call before pause at 4.80s
	# - Paused: At 5s after the last call
	# - Resumed: After 10.12s of inactivity

	# - Post-resume: First call at 10.14s, last call at 28.15s
	# ~> Performance note: 2 calls in 38.28s (average 19.14s per call) may indicate performance issues

	# - And so on.

	# This detailed lifecycle information allows for comprehensive 
	# analysis and optimization of plugin behavior and resource usage.
*/	
	#~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~#
	#   CONCURRENT EXECUTION OF PLUGIN-FUNCTIONS   #
	#~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~#

	#TODO Add this feature

	# To run there plugin funcions concurrently, use the C() suffix of the Xf() functo,:
/*
	aData = o1.XfC([
		:readFile = "myfile.txt",
		:readXLS  = "mysheet.xls",
		:readURL  = "www.myurl.com"
	])

	? aData[1] = "...content of the text file..."
	? aDate[2] = [ "...the XLS table here in a tabular list..." ]
	? aData[3] = "...content of the HTML page requested..."

*/
	#~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~#
	#  CANCELLABLE EXECUTION OF MULTIPLE PLUGIN-FUNCTIONS  #
	#~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~#

	#TODO Add this feature

	# In case that a serie of functions called contains functions that update
	# data in the main program, Softanza Pluggin System allows cancelling
	# the serie and resetting the main data at its inial value, if any error
	# happens during the plugins call.

	# To do so, we use the B() suffix (B for fo Back) with the XfU() function:
/*
	o1.XfUB([
		:make-first-update,
		:make-second-update,
		:make-third-update
	])

	# The value of o1 object will be updated by the three called plugin-functions
	# only if all of them were sucessfully executed.

	# Otherwise, when an error happens, say while executing the third fucntion,
	# the hole update opeation is cancelled and an error is raised:

	#--> Error: Can't execute the defined functions.
	# 	    	:make-first-update: OK
	# 	 	:make-second-update : Can't open file!
*/
	#~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~#
	#   DEPENDENCY MANAGEMENT OF THE RING LIBS (TO BE) LOADED BY THE PLUGINS  #
	#~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~#
	
	#TODO Add this feature

	# Softanza's plugin system includes a lightweight dependency management feature
	# for Ring libraries loaded by plugins.

	# This system allows for verificationof plugin dependencies without compromising
	# the isolation of each plugin's execution environment.
		
	# The main program can then check these (to be loaded) libraries:
/*	
	? XLoadedLibs(:plugin-name)
	#--> [ "stzlib.ring", "mathlib.ring", "statslib.ring" ]
	
	# Before executing the plugin, the programmer can verify if all required
	# libraries are availabel (accessible by the code running in the plgin-file):
	
	if XLoadedLibsAvailable(:plugin-name)
		output = Xf(:plugin-name)
	else
		raise("Can't run the plugin file! Some loaded libs are not available.")
	ok

	# Leading to a more robust and stable code.

	# We can also see the dependecy tree of all the plugins

	? XLibsTree()
	#--> XLibsTree
	# 	|-- "stdlib.ring"
	# 	|	|-- plugin-name1
	# 	|	|-- plugin-name3
	# 	|	|-- plugin-name5
	# 	|
	# 	|-- "mathlib.ring"
	# 	|	|-- plugin-name2
	# 	|	|-- plugin-name4
	# 	|
	# 	|-- "statslib.ring"
	# 	|	|-- plugin-name5
*/
	#~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~#
	#   PLUGIN VERSIONING AND COMPATIBILITY   #
	#~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~#

	# Plugin versioning is a crucial feature for managing the evolution
	# of plugins over time. It allows us to track changes, ensure
	# compatibility, and manage updates effectively.

	# Let's see how Softanza Plugging System allows them.

	# Setting and checking plugin versions
	#~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
/*
	# Plugin versions are defined by an incremental number at the end of
	# the plugin file name), and can be checked using XVersion():

	? XVersion(:reverse_V1) # Or XCurrentVersion()
	#--> V1

	? XVersions(:reverse)
	#--> [ V1, V2, V3 ]

	? XLastVersion(:reverse)
	#--> V3

	XSetActiveVersion(:reverse, :V2)

	? XVersion(:reverse)
	#--> V2

	? HasVersion(:reverse, :V5)
	#--> _FALSE_
*/
	# Defining the compatible plugins versions with the main program
	#~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
/*
	# Declared in the global variable:

	_aXCompatiblePlugins = [
		:reverse = [ :V3, :V2 ],
		:removeNonLetters = [ :V5 ],
		:otherPluggin = [ :V1 ]
	]

	# We get this information using:
	? XCompatiblePlugins()

	# We can check a plugin compatible versions by:
	? XCompatibleVersions(:reverse)
	#--> [ :V3, :V2 ]

	# We can chek if a given version of a plugin is compatible with
	# the main program by:

	? XIsCompatible(:reverse, :V2)
	#--> _TRUE_

	# This enable writing a robust code like this:

	if XIsCompatible(:reverse, :V1)
		? XfV(:reverse, "Hello World!", :V1) # Note the use of V() suffix for Version
	else
		raise("Can't proceed. Plugin version is not compatible with the main program.")
	ok

	# Add makes it possible to run a plugin in any of its compatible versions

	for version in XCompatibleVersions(:reverse)
		? "Output of version " + version + ": "
		see XfV(:reverse, "أهلا بالعالم !", version)
	next
	#--> Output of version V2 : ! �ل٧ع؄٧ب� �؄ه٣�
	#--> Output of version V3 : ! ملاعلاب الهأ

	# As you see, it's clear that V3 added the support of Unicode  chars (arabic here)
	# in the reverse plugging function.

	# You can check it in the metatdata of the XVersions() function along with the XT suffix:

	? XVersionsXT(:reverse)
	#--> [ :V1 = "Basic version", :V2 = "Better performance", :V3 = "Unicode support" ]

	#NOTE
	# Those meta data are read for @plugin_description variable in the header of the plugin file.
*/
	# Updating a plugin to its last version
	#~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
/*
	XUpdate(:reverse)

	# Which can also be achieved by:

	XSetActiveVersion(:reverse, XLastVersion(:reverse))

	#NOTE
	# By convention, plusing ages is defined by the number figuring in its
	# version number. Hence, V3 versions is newer then V2 version, V2 version
	# is newer then V1 version, and vice versa.
*/
	# Dependencies management on plugins versions
	#~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~

	#NOTE
	# Dependency management features we showed earlier apply to plugins versions
	# since they are just different plugin files.	

proff()
# Executed in 0.25 second(s).
