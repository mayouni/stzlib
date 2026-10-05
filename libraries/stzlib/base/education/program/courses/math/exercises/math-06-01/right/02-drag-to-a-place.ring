# The same drag written as a place: where A stands plus the offset.
oT = StzThalesPictureQ( StzMathFigureFont() )
nX = oT.ValueOf("A.icon.cx") + 50
nY = oT.ValueOf("A.icon.cy") + 30
oN = StzMathMotionOverQ(oT)
oN.State("A moved", [ [ :DragTo, "A.icon", nX, nY ] ])
oN.Apply(1)
oPic = oN.Picture()
? oPic.Fact(:angle, [ "B.icon", "A.icon", "C.icon" ])[:message]
nD = oPic.Fact(:distance, [ "A.icon", "K.icon" ])[:value]
nR = oPic.ValueOf("K.icon.r")
? fabs(nD - nR) < 0.01
