
/*
	In practice, an object won't host just one contraint but many!
	That's why we designed this class to help us:

	- enforce many constraints on an object
	- name those constraints so we can manage them by name
*/

func IsListOfConstraints(pObject, paConstraints)
	if NOT ListIsHashList(paConstraints)
		return FALSE
	ok

	bResult = TRUE

	for aConstraint in paConstraints
		cConstraint = aConstraint[2]
		if NOT IsConstraint(pObject, cConstraint)
			bResult = FALSE
			exit
		ok
	next

	return bResult
	
func IsListOfNamedConstraints(pObject, paConstraints)
	if NOT IsListOfPairs(paConstraints)
		return FALSE
	ok

	bResult = TRUE

	for aPair in paConstraints
		if NOT IsNamedConstaint(pObject, aPair)
			bResult = FALSE
			exit
		ok
	next

	return bResult

class stzListOfConstraints from stzObject
	@acConstraints

	def init(pObject, paConstraints)
		if IsEmptyList(paConstraints)
			@acConstraints = []

		but IsListOfNamedConstraints(pObject, paConstraints)
			@acConstraints = paConstraints

		but IsListOfConstraints(pObject, paConstraints)
			for cConstraint in paConstraints
				@acConstraints + [ :Noname, cConstraint ]
			next

		else
			StzRaise("Can't create the object!")
		ok

	def Content()
		return @acConstraints

		def Value()
			return This.Content()

	def Constraints()
		return @acConstraints

	def Add(pContraint)
		if NOT IsConstraint(pConstraint)
			StzRaise("Can't add constraint")
		ok

		if IsUnnamedConstraint(pConstraint)
			StzConstraint
		but IsNamedConstraint(pConstraint)

		ok

	def RemoveConstaint(pcConstraintName)
		if isNumber(pcConstraintName)
			This.RemoveNthConstraint(pcConstraintName)
		else
			
		ok

	def RemoveNthConstraint(n)
		// TODO

	def RemoveAllConstraints()
		// TODO

	def RemoveConstraints(paConstraints)
		// TODO

	def CheckNthConstraint(n)
		// TODO

	def CheckAllConstraints()
		for acConstraint in @oStzListOfConstraints.Content()
			This.CheckConstraint(acConstraint[1])
		next

	def CheckConstraints(paConstraints)
		// TODO
