# The signs of the sines swapped: every point turns clockwise, wrong from element 1.
k = StzKernelMakerQ()
k.TakesVectorOf(:p, :vec2)
k.TakesScalar(:c)
k.TakesScalar(:s)
k.ReturnsVectorOf(:q, :vec2)
k.ForEachElement('{ @q = vec2(c * @p.x + s * @p.y, -s * @p.x + c * @p.y) }')
? StzKernelPuzzleQ("kp-16").Grade(k)
