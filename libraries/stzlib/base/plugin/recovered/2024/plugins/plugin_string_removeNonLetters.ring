#< ring_pluging_file #>

t0 = clock()

@plugin_desc   = "Plugin for removing non letters from a given string"
@plugin_name   = "plugin_string_removeNonLetters"

@plugin_value  = "Hello~~#!<< Ring ;;$in <<Ring!"
@plugin_param  = []

@plugin_result = pluginFunc(@plugin_value, @plugin_param)
#--> HelloRinginRing

temp = ""
for i = 1 to 100000
	temp += "emm"
next

@plugin_time = ( clock() - t0 ) / clockspersecond()

func pluginFunc(value, aParams)
	nLen = len(value)
	cResult = ""
	for i = 1 to nLen
		if  isalpha(value[i])
			cResult += value[i]
		ok
	next

	return cResult
