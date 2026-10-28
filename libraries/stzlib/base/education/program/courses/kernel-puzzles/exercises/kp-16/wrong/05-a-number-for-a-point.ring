# The output holds a vec2 per element; one number is refused.
k = StzKernelMakerQ()
k.TakesVectorOf(:p, :vec2)
k.TakesScalar(:c)
k.TakesScalar(:s)
k.ReturnsVectorOf(:q, :vec2)
k.ForEachElement('{ @q = length(@p) }')
? StzKernelPuzzleQ("kp-16").Grade(k)
