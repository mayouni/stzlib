#< ring_pluging_file #>

@plugin_desc   = "Plugin for removing non letters from a given string"
@plugin_name   = "plugin_string_removeNonLetters"

@plugin_value  = "Hello~~#!<< Ring ;;$in <<Ring!"
@plugin_param  = []

@plugin_result = pluginFunc(@plugin_value, @plugin_param)
#--> HelloRinginRing


func pluginFunc(value, aParams)
	nLen = len(value)
	cResult = ""
	for i = 1 to nLen
		if  isalpha(value[i])
			cResult += value[i]
		ok
	next

	return cResult
