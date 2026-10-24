# No guard line at all: the engine guards with i < n, as every kernel did before.
k = StzKernelMakerQ()
k.TakesVector(:a)
k.ReturnsVector(:c)
k.ForEachElement('{ @c = @a * 2 }')
? StzKernelPuzzleQ("kp-05").Grade(k)
