#< ring_pluging_file #>

t0 = clock()

@plugin_desc   = "Plugin for replacing a substring by an other in a given string"
@plugin_name   = "plugin_string_replace"

@plugin_value  = "Hello Ring in Ring!"
@plugin_param  = [ "Hello", "Embedding" ]

@plugin_max_time  = 0
@plugin_max_size  = 0
@pluging_max_loop = 0

@pluging_partial_result _FALSE_

@plugin_result = pluginFunc(@plugin_value, @plugin_param)
#--> Embedding Ring in Ring!

@plugin_time = ( clock() - t0 ) / clockspersecond()

func pluginFunc(value, aParams)

	while TRUE

		# Function logic

		cResult = ring_substr2(value, aParams[1], aParams[2])

		# Checking time constraint

		elapsed = ( clock() - t0 ) / clockspersecond()

		if @plugin_max_time > 0 and elapsed > @plugin_max_time
			if @pluging_partial_result
				return cResult
			else
				raise("Cancelled! Maximum allowed time has been exceeded.")
			ok
		ok

		# Checking size constraint

		if @plugin_max_time > 0 and len(cResult) > @plugin_max_size
			if @pluging_partial_result
				return ring_substr2(cResult, 1, @plugin_max_size)
			else

			raise("Cancelled! Maximum allowed time has been exceeded.")
			ok
		ok

		# If not, return the result

		return cResult

	end
