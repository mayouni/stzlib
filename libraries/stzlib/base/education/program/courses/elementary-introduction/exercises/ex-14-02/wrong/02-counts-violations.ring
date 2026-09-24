# Counts the violations instead of judging the second shape.
oGBad = new stzAgentGraph("bad")
oGBad.AddLLMActor("writer")
oGBad.AddEffect("send")
oGBad.Proposes("writer", "send")
? oGBad.IsSound()
? len( oGBad.Violations() )
