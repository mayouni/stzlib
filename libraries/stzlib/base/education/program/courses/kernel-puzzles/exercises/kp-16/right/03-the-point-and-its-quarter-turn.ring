# c times the point, plus s times the point turned a quarter: (-y, x).
k = StzKernelMakerQ()
k.TakesVectorOf(:p, :vec2)
k.TakesScalar(:c)
k.TakesScalar(:s)
k.ReturnsVectorOf(:q, :vec2)
k.ForEachElement('{ @q = c * @p + s * vec2(-@p.y, @p.x) }')
? StzKernelPuzzleQ("kp-16").Grade(k)
