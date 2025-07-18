#~~~~~~~~~~~~~~~~~~~~#
#  GLOBAL CONSTANTS  #
#~~~~~~~~~~~~~~~~~~~~#

# Factors used for converting between memory units

MEMORY_UNITS = [
	:Bit,
	:Byte,
	:KiloByte,
	:MegaByte,
	:GigaByte,
	:TeraByte,
	:PetaByte,
	:ExaByte,
	:ZettaByte,
	:YottaByte
]

# CONVERSION FACTORS BETWEEN MEMORY UNITS

KILOBYTE_TO_BIT_FACTOR  = 8192 # 1024 * 8

MEGABYTE_TO_KILOBYTE_FACTOR = 1024 		# 1024
MEGABYTE_TO_BIT_FACTOR      = 8388608 		# (1024 ^ 2) * 8

GIGABYTE_TO_BYTE_FACTOR     = 1073741824 	# (1024 ^ 3)
GIGABYTE_TO_KILOBYTE_FACTOR = 1048576 		# (1024 ^ 2)
GIGABYTE_TO_BIT_FACTOR      = 8589934592 	# (1024 ^ 3) * 8

TERABYTE_TO_BYTE_FACTOR     = 1099511627776 	# (1024 ^ 4)
TERABYTE_TO_KILOBYTE_FACTOR = 1073741824 	# (1024 ^ 3)
TERABYTE_TO_BIT_FACTOR      = 8796093022208 	# (1024 ^ 4) * 8

PETABYTE_TO_BYTE_FACTOR     	= 1125899906842624 	# (1024 ^ 5)
PETABYTE_TO_KILOBYTE_FACTOR 	= 1099511627776 	# (1024 ^ 4)
PETABYTE_TO_BIT_FACTOR      	= 8881784197001216 	# (1024 ^ 5) * 8

EXABYTE_TO_BYTE_FACTOR     	= 1152921504606846976 	# (1024 ^ 6)
EXABYTE_TO_KILOBYTE_FACTOR 	= 1125899906842624 	# (1024 ^ 5)
EXABYTE_TO_BIT_FACTOR      	= 9223372036854775808 	# (1024 ^ 6) * 8

ZETTABYTE_TO_BYTE_FACTOR     	= 1180591620717411303424 	# (1024 ^ 7)
ZETTABYTE_TO_KILOBYTE_FACTOR 	= 1152921504606846976 		# (1024 ^ 6)
ZETTABYTE_TO_BIT_FACTOR      	= 9444732965739290426368 	# (1024 ^ 7) * 8

YOTTABYTE_TO_BYTE_FACTOR      	= 1208925819614629174706176 	# (1024 ^ 8)
YOTTABYTE_TO_KILOBYTE_FACTOR  	= 1180591620717411303424 	# (1024 ^ 7)
YOTTABYTE_TO_BIT_FACTOR       	= 95428956661160094070998016 	# (1024 ^ 8) * 8

# Global constants for 32-bit architecture
RING_32BIT_STRING_STRUCTURE_SIZE = 40
RING_32BIT_LIST_STRUCTURE_SIZE = 48
RING_32BIT_ITEM_STRUCTURE_SIZE = 16
RING_32BIT_ITEMS_STRUCTURE_SIZE = 16

# Global constants for 64-bit architecture
RING_64BIT_STRING_STRUCTURE_SIZE = 48
RING_64BIT_LIST_STRUCTURE_SIZE = 80
RING_64BIT_ITEM_STRUCTURE_SIZE = 24
RING_64BIT_ITEMS_STRUCTURE_SIZE = 32

RING_NUMBER_CONTENT_SIZE = 3

RING_STRING_ARRAYSIZE = 32

#==

func MemoryUnits()
	return MEMORY_UNITS
