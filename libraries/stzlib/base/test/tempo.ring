load "../stzbase.ring"

/*---

decimals(3)
t1= clock()
? _IsListOfNumbers_(list(100_000))
t2= clock()
? (t2-t1)/clockspersecond()

func _IsListOfNumbers_(paList)
    if NOT isList(paList)
        return 0
    ok
    nLen = len(paList)
    for i = 1 to nLen
        if not isNumber(paList[i])
            return 0
        ok
    next
return 1

