# Only x is turned: a point on the y axis stays at the origin.
k = StzKernelMakerQ()
k.TakesVectorOf(:p, :vec2)
k.TakesScalar(:c)
k.TakesScalar(:s)
k.ReturnsVectorOf(:q, :vec2)
k.ForEachElement('{ @q = vec2(c * @p.x, s * @p.x) }')
? StzKernelPuzzleQ("kp-16").Grade(k)
