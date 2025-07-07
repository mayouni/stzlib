
# Wrappers functions and class for stkPointer class (from CORE layer)

func StzPointerQ(pParams)
    return new stkPointer(pParams)

func StzNullPointerQ()
    return new stzPointer(NULL)

func StzStringPointerQ(cString, nBufferSize)
	if IsNull(nBufferSize)
		nBufferSize = 0
	ok
    return new stzPointer([cString, "char", [nBufferSize, true, "utf8"]])

func StzObjectPointerQ(pObject)
    return new stzPointer([pObject, "object"])


class stzPointer from stkPointer
