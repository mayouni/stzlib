# Each new component is a dot product of the point with one row of the rotation.
k = StzKernelMakerQ()
k.TakesVectorOf(:p, :vec2)
k.TakesScalar(:c)
k.TakesScalar(:s)
k.ReturnsVectorOf(:q, :vec2)
k.ForEachElement('{ @q = vec2(dot(@p, vec2(c, -s)), dot(@p, vec2(s, c))) }')
? StzKernelPuzzleQ("kp-16").Grade(k)
