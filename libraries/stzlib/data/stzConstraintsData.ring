	_aConstraints = [	#TODO: Provide a set of default constraints
			# and complete other stz types

	  #--------------------------#
	 #   CONSTRAINTS ON LISTS   #
	#--------------------------#

	:OnStzList = [
		/* ... */
		:MustBeAHashList = '{
			Q(@list).IsHashList()
		}', 

		:MustHave@n@Items = '{
			Q(@list).NumberOfItems() = @n@
		}'
	],

	  #----------------------------#
	 #   CONSTRAINTS ON STRINGS   #
	#----------------------------#

	:OnStzString = [
		:MustBeUppercase = '{
			Q(@str).IsUppercase()
		}',

		:MustBegingWith@substr@ = '{
			Q(@str).BeginsWith(susbtr)
		}',

		:MustHave@n1@CharsIncluding@n2@Spaces = '{
			Q(@str).NumberOfChars()  = n1 and
			Q(@stz).NumberOfSpaces() = n2
		}'
	],

	  #---------------------------------#
	 #    CONSTRAINTS ON HASHLISTS     #
	#---------------------------------#

	:OnStzHashList = [

		:KeysMustBeStzClassNames = '{
			Q(@hashlist).KeysQ().AllItemsAreStzClassNames()	
		}',

		:KeysMustBeStzClassNamesPrefixedBy@str@ = '{
			Q(@hashlist).KeysQ().RemoveFromStartCSQ(@str@, :CS = FALSE).AllItemsAreStzClassNames()	
		}',

		:ValuesMustBeStrings = '{
			Q(@hashlist).ValuesQ().ItemsAreAllStrings()
		}',

		:ValuesMustBeValidRingCodes = '{
			Q(@hashlist).ValuesQ().AllItemsAreValidRingCodes()
		}',

		# Example: :AKeyMustBeOneOfThese@where_what_why_todo@
		:AKeyMustBeOneOfThese@list@ = '{
			Q(@hashlist).KeysQ().IsMadeOf(@list@)
		}',

		:ValuesMustBeNonNullStrings = '{
			Q(@hashlist).ValuesQ().AllItemsAreNonNullStrings()
		}'

	]

] 

