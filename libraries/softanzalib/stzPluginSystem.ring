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

# loading plugins files from plugin folder

_aPlugins = LoadPlugins()
#--> [
#	[ "countVowels", 	"plugin_string_countVowels.ring" ],
#	[ "removeNonLetters", 	"plugin_string_removeNonLetters.ring" ],
#	[ "reverse", 		"plugin_string_reverse.ring" ]
# ]

pron()

	o1 = new ExtendedString("Hello Ring in Ring!")
	
	# Calling methods from the base class
	
	? o1.size() 	#--> 19
	? o1.upp() + NL	#--> HELLO RING IN RING!
	
	? "---" + NL

	# Calling plugins methods functions from the extended class

	#NOTE # that these methods are not defined in the class, but
	# loaded dynamically from the plugins files using the Xf() methhod

	? o1.Xf(:Reverse)
	#--> !gniR ni gniR olleH

	? o1.Xf(:countVowels)
	#--> 5

	? o1.Xf(:removeNonLetters)
	#--> HelloRinginRing

	//? o1.Xf(:doStaff) # The plugin does not exit
	#--> !!! Error (R35) : Can't create/open the file !!!

		#NOTE // To let it raise the error without interrpting
		# programm execution, use the fault-tolenrant version:

		? o1.Xff(:doStaff)

	? o1.Xf(:replace = [ "Hello", "Embedding" ]) + NL
	#--> Embedding Ring in Ring!

	? o1.Xf(:reverse)
	#--> !gniR ni gniR olleH

	# Checking the list of eXtended (plugin-based) functions
	# that were called on the string object in the lines above
	
	? @@( o1.XFuncts() ) + NL
	#--> [ "reverse", "countvowels", "removenonletters", "replace" ]

	# Tracing the call stack of the eXtend (plugin-based) functions
	# used against the object in the lines below

	# ~> # Returns function names, their params, wether the function
	# succeeded or raised an error, and the actual ouput of the call

	? @@NL( o1.XCalls() ) + NL 
	# [
	# 	[ "reverse", [ ], 1, "!gniR ni gniR olleH" ],
	# 	[ "countvowels", [ ], 1, 5 ],
	# 	[ "removenonletters", [ ], 1, "HelloRinginRing" ],
	# 	[ "dostaff", [ ], 0, "!!! Error (R35) : Can't create/open the file !!!" ],
	# 	[ "replace", [ "Hello", "Embedding" ], 1, "Embedding Ring in Ring!" ],
	# 	[ "reverse", [ ], 1, "!gniR ni gniR olleH" ]
	# ]

#TODO add ElapsedTime
#TODO add XfU() form --> returns the result and updates the objects

	# An eXTended form of the same function yieling alos the results

	//? @@NL( o1.XCallsXT() )

proff()
# Executed in 0.10 second(s).

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

class ExtendedString from BaseString
	@acFuncs = []
	@aCalls = []

	def XCalls()
		return @aCalls

	def Xfunctions()
		return @acFuncs

		def Xfuncts()
			return @acFuncs

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

			@aCalls + [ cFuncName, aParams, TRUE, result ]

		catch
			error = cCatchError
			@aCalls + [ cFuncName, aParams, FALSE, error ]
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
			@aCalls + [ cFuncName, aParams, TRUE, result ]

		catch
			error = '!!! ' + cCatchError + ' !!!'
			@aCalls + [ cFuncName, aParams, FALSE, error ]

			? NL+ error
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

	def size()
		return len(@str)

	def upp()
		return upper(@str)
