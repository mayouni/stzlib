# x' = c x - s y and y' = s x + c y: each point turned by the angle whose cosine is c.
k = StzKernelMakerQ()
k.TakesVectorOf(:p, :vec2)
k.TakesScalar(:c)
k.TakesScalar(:s)
k.ReturnsVectorOf(:q, :vec2)
k.ForEachElement('{ @q = vec2(c * @p.x - s * @p.y, s * @p.x + c * @p.y) }')
? StzKernelPuzzleQ("kp-16").Grade(k)
