# Narrative
# --------
# TODO
#
# Extracted from stzsubstringTest.ring, block #2.

load "../../stzBase.ring"

pr()

? @.UppercaseSubString("ring").In("I LOVE THE ring LANGUAGE!")
#--> I LOVE THE RING LANGUAGE!

@1 '<~' { Move("ring").From("php ring ruby").ToEndOf("I do love ") }
@2 '<~' { Uppercase("ring").In(@1) }
@3 '<~' { Remove("do").From(@1) }

@1 '<~' { Move("ring").From("php ring ruby").ToEndOf("I do love ") }
@2 '<~' { Uppercase("ring").In('~>') & Remove("do").Form(@1) }

Show( v[@1, @2] )


@2.Show()

pf()
