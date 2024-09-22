#< ring_pluging_file #>

t0 = clock()

@plugin_desc   = "Plugin for reversing a string"
@plugin_name   = "plugin_string_reverse"

@plugin_value  = "Hello Ring in Ring!"
@plugin_param  = []

@plugin_result = pluginFunc(@plugin_value, @plugin_param)
#--> !gniR ni gniR olleH

@plugin_time = ( clock() - t0 ) / clockspersecond()

func pluginFunc(value, aParams)
	return reverse(value)
