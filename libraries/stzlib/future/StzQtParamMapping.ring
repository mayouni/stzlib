_acSupportedOpeningModes = [
	:NotOpen =  [ InRingQt(QIODevice_Not_Open), InQt(0x0000) ]
	:ReadOnly = [ InRingQt(QIODevice_Read_Only), InQt(0x0001) ]
	:WriteOnly = InRingQt(QIODevice_Write_Only), 0x0002
	:ReadWrite = InRingQt(QIODevice_Read_Write), ReadOnly | WriteOnly
	:Append = InRingQt(QIODevice_Append), 0x0004
	:Truncate = InRingQt(QIODevice_Truncate), 0x0008
	:Text = InRingQt(QIODevice_Text), 0x0010
	:Unbuffered = InRingQt(QIODevice_Unbuffered), 0x0020

	:NewOnly 0x0040
	:ExistingOnly 0x0080	
]

_acSupportedStreamStatuses = [
	:Ok = InQt(0),
	:ReadPastEnd = InQt(1),
	:ReadCorruptData = InQt(2),
	:WriteFailed = InQt(3),
]

class StzQtParamMapping
	def GetQtValueForStzParam(:ok)

	def GetRingqtValueForStzParam(:ok)

	def GetStzValueForQtParam(1)
