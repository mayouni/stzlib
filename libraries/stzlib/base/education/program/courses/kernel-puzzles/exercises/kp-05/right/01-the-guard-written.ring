# The learner's own guard: only the threads with an element write.
k = StzKernelMakerQ()
k.TakesVector(:a)
k.ReturnsVector(:c)
k.Guard('{ @i < n }')
k.ForEachElement('{ @c = @a * 2 }')
? StzKernelPuzzleQ("kp-05").Grade(k)
