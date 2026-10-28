# The two new components in each other's place: x' lands in y.
k = StzKernelMakerQ()
k.TakesVectorOf(:p, :vec2)
k.TakesScalar(:c)
k.TakesScalar(:s)
k.ReturnsVectorOf(:q, :vec2)
k.ForEachElement('{ @q = vec2(s * @p.x + c * @p.y, c * @p.x - s * @p.y) }')
? StzKernelPuzzleQ("kp-16").Grade(k)
