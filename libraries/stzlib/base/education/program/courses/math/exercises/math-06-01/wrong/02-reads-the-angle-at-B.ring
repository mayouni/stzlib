# Drags A, then reads the angle at B, which Thales says nothing about.
oT = StzThalesPictureQ( StzMathFigureFont() )
oN = StzMathMotionOverQ(oT)
oN.State("A moved", [ [ :DragBy, "A.icon", 50, 30 ] ])
oN.Apply(1)
oPic = oN.Picture()
? oPic.Fact(:angle, [ "A.icon", "B.icon", "C.icon" ])[:message]
? 1
