
$aGlobalHelp = [] # Populated at the start of each class file

func Help(cStzClassOrFunc)
	if CheckParams()
		if isList(cStzClassOrFunc) and StzListQ(cStzClassOrFunc).IsForNamedParam()
			cStzClassOrFunc = cStzClassOrFunc[2]
		ok
	ok

	cResult = $aGlobalHelp[cStzClassOrFunc][1]

	if cResult = ""
		StzRaise("Inexistant help for this entry!")
	ok

	return cResult

	func HelpFor(cStzClassOrFunc)
		return Help(cStzClassOrFunc)

func HelpXT(cStzClassOrFunc)
	if CheckParams()
		if isList(cStzClassOrFunc) and StzListQ(cStzClassOrFunc).IsForNamedParam()
			cStzClassOrFunc = cStzClassOrFunc[2]
		ok
	ok

	cResult = $aGlobalHelp[cStzClassOrFunc][1]

	if cResult = ""
		StzRaise("Inexistant help for this entry!")
	ok

	cHelpXT = $aGlobalHelp[cStzClassOrFunc][2]

	if cHelpXT = ""
		StzRaise("Inexistant extended help for this entry!")
	ok

	return cResult + NL + NL+ cHelpXT

	func HelpForXT(cStzClassOrFunc)
		return HelpXT(cStzClassOrFunc)
