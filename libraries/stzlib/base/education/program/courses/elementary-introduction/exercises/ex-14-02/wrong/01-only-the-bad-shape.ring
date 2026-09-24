# Shows the unsound shape and never builds the governed one.
oGBad = new stzAgentGraph("bad")
oGBad.AddLLMActor("writer")
oGBad.AddEffect("send")
oGBad.Proposes("writer", "send")
? oGBad.IsSound()
