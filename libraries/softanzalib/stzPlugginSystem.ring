/*
This code demonstrates how to implement a plugin system in Ring
using the feature of embedding Ring within Ring.

The code contains two classes: BaseStrings and ExtendedString.

The BaseStrings class provides basic string methods, such as size() and upp().

The purpose of the plugin system is to allow users to write custom methods
in separate files, stored in the plugins subfolder.

The system reads each plugin file, executes it in a separate Ring state,
and integrates the functions found in the plugin file as part of the
ExtendedString class.

To invoke the extended function, the programmer uses the Xf() method,
passing the name of the plugin function and the required parameters.

Here is an example of the content of a plugin file:

	#< ring_pluging_file #>
	
	@plugin_desc   = "Plugin for reversing a string"
	@plugin_name   = "plugin_string_reverse"
	
	@plugin_value  = "Hello Ring in Ring!"
	@plugin_param  = []
	
	@plugin_result = pluginFunc(@plugin_value, @plugin_param)
	#--> !gniR ni gniR olleH
	
	func pluginFunc(value, aParams)
		return reverse(value)

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

	? o1.Xf(:replace = [ "Hello", "Embedding" ])
	#--> Embedding Ring in Ring!

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
	@acPlugins = []

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
			@acPlugins  + cFuncName

		catch
			error = cCatchError
		done

		# Removing the state from memory
		ring_state_delete(pState)
		
		# Returning the result or raising an error

		if error = ""
			return result
		else
			raise(error)
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
