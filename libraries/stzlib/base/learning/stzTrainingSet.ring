# R4 step 0 -- stzTrainingSet: LABELED TRAINING DATA as a domain object (LAW 1)
# The container every learner in learning/ trains from: examples =
# [ features(list of numbers), label(string) ]. Deterministic split
# (no hidden randomness -- reproducibility is a LAW 3 value; shuffle
# explicitly with your own order when wanted).
#
#   oDs = new stzTrainingSet([ [ [5.1, 3.5], "setosa" ], ... ])
#   oDs.AddExample([4.9, 3.0], "setosa")
#   aTT = oDs.Split(0.8)   # [ trainDataset, testDataset ]

class stzTrainingSet from stzObject

	@aExamples = []    # [ [ aFeatures, cLabel ] ... ]

	def init(p)
		if isList(p)
			_n_ = len(p)
			for _i_ = 1 to _n_
				if isList(p[_i_]) and len(p[_i_]) = 2 and isList(p[_i_][1])
					@aExamples + [ p[_i_][1], "" + p[_i_][2] ]
				ok
			next
		ok

	def AddExample(paFeatures, pcLabel)
		if isList(paFeatures)
			@aExamples + [ paFeatures, "" + pcLabel ]
		ok

		def AddExampleQ(paFeatures, pcLabel)
			This.AddExample(paFeatures, pcLabel)
			return This

	def Examples()
		return @aExamples

	def NumberOfExamples()
		return len(@aExamples)

	def Labels()
		_acOut_ = []
		_n_ = len(@aExamples)
		for _i_ = 1 to _n_
			if ring_find(_acOut_, @aExamples[_i_][2]) = 0
				_acOut_ + @aExamples[_i_][2]
			ok
		next
		return _acOut_

	def NumberOfFeatures()
		if len(@aExamples) = 0
			return 0
		ok
		return len(@aExamples[1][1])

	# deterministic head/tail split -- [ oTrain, oTest ]
	def Split(nRatio)
		_nCut_ = floor(len(@aExamples) * nRatio)
		_aTrain_ = []
		_aTest_ = []
		_n_ = len(@aExamples)
		for _i_ = 1 to _n_
			if _i_ <= _nCut_
				_aTrain_ + @aExamples[_i_]
			else
				_aTest_ + @aExamples[_i_]
			ok
		next
		return [ new stzTrainingSet(_aTrain_), new stzTrainingSet(_aTest_) ]
