# Narrative
# --------
# # You can create a script object bu specifying its name, abbreviation, or code
#
# Extracted from stzscripttest.ring, block #1.

load "../../stzBase.ring"


o1 = new stzScript(:Arabic)	# :Arabic is the name of the arabic script
? o1.Name() #--> arabic

o1 = new stzScript(:Arab)	# :Arab is the abbreviation of the arabic script
? o1.Name() #--> arabic

o1 = new stzScript("1")		# "1" is the code of the script
? o1.Name() #--> arabic
