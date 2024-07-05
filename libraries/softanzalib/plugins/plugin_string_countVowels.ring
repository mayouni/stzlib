#< ring_pluging_file #>

@plugin_desc   = "Plugin for counting vowels in a given string"
@plugin_name   = "plugin_string_countVowels"

@plugin_value  = "Hello Ring in Ring!"
@plugin_param  = []

@plugin_result = pluginFunc(@plugin_value, @plugin_param)
#--> 5

func pluginFunc(value, aParams)
	nlen = len(value)
	
	cStr = lower(value)
	acVowels = ["a", "e", "i", "o", "u"]

	nResult = 0

	for i = 1 to nlen
		if find(acVowels, value[i])
			nResult++
		ok
	next

	return nResult
