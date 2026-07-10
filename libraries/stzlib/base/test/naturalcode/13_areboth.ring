load "../../stzBase.ring"


pr()

o1 = NaturallyIn("ar", "أنشئ قائمةََ بـ [ 3, 1, 3, 3, 1, 3, 2 ] ثمّ احذف تكراراتِها ورتّبها واقلبها")

? @@( o1.Result() )
#--> [ 2, 1, 3 ]

? o1.Code()
#-->
#
# oList = new stzList([ 3, 1, 3, 3, 1, 3, 2 ])
# oList.RemoveDuplicates()
# oList.Reverse()
# @result = oList.Content()

pf()

















//? "(retired test; see header for rationale)"


# Narrative
# --------
# (retired) baturalcode: baturalcode DSL relies on stzString IsUppercase/LengthQ/AreNegative wrappers; ported piecemeal as needed by Softanza natural narratives.
#
#SKIP retired -- see header

