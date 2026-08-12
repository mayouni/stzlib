#---------------------------------#
#  COMMON FOR ALL OBJECT CLASSES  #
#---------------------------------#

func @IsObject(p)
	return isObject(p)

func @IsStzObject(p)
	if NOT isObject(p)
		return 0
	ok
	try
		return p.IsStzObject()
	catch
		return 0
	done

func ObjectClassName(obj)
	return classname(obj)

	func @ObjectClassName(obj)
		return ObjectClassName(obj)

func ObjectAttributes(obj)
	return attributes(obj)

	func @ObjectAttributes(obj)
		return ObjectAttributes(obj)

func ObjectMethods(obj)
	return methods(obj)

	func @ObjectMethods(obj)
		return ObjectMethods(obj)

func ObjectsAreEqual(obj1, obj2)
	if classname(obj1) != classname(obj2)
		return 0
	ok
	_aAttrs1_ = attributes(obj1)
	_aAttrs2_ = attributes(obj2)
	if len(_aAttrs1_) != len(_aAttrs2_)
		return 0
	ok
	return 1
