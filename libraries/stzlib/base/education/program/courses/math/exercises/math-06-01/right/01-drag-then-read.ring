# The story, one declared state, the angle and the circle read off the moved picture.
oT = StzThalesPictureQ( StzMathFigureFont() )
oN = StzMathMotionOverQ(oT)
oN.State("A moved", [ [ :DragBy, "A.icon", 50, 30 ] ])
oN.Apply(1)
oPic = oN.Picture()
? oPic.Fact(:angle, [ "B.icon", "A.icon", "C.icon" ])[:message]
nOff = oPic.Fact(:expr, [ "dist(A.icon, K.icon) - K.icon.r", "px" ])[:value]
? fabs(nOff) < 0.01
