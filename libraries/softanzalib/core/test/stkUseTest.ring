
load "../common/stkUse.ring"

? len($LOADED_RING_FILES)
#--> 0

use("lightGuiLib.ring")
use("../object/stzCoreObject.ring")
use("../string/stzCoreString.ring")

? $LOADED_RING_FILES

use("lightGuiLib.ring")
use("../object/stzCoreObject.ring")
use("../string/stzCoreString.ring")

? $LOADED_RING_FILES

Use([
	"LightGuiLib.ring",
	"../object/stzCoreObject.ring",
	"../string/stzCoreString.ring",
	"../string/stzCoreChar.ring"
])

? $LOADED_RING_FILES


o1 = new stkString("hello!")
? o1.Content()
