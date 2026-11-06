# A child for stzReactor_defects_narrated.ring: prints each argument after the script name between [ ].
aArgs = sysargv
nArgs = len(aArgs)
for i = 3 to nArgs
	? "[" + aArgs[i] + "]"
next
