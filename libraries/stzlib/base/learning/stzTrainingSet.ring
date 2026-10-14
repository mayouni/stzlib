# R4 step 0 -- stzTrainingSet: LABELED TRAINING DATA as a domain object (LAW 1)
# The container every learner in learning/ trains from: examples =
# [ features(list of numbers), label(string) ]. Deterministic split
# (no hidden randomness -- reproducibility is a LAW 3 value; shuffle
# explicitly with your own order when wanted).
#
#   oDs = new stzTrainingSet([ [ [5.1, 3.5], "setosa" ], ... ])
#   oDs.AddExample([4.9, 3.0], "setosa")
#   aTT = oDs.Split(0.8)   # [ trainDataset, testDataset ]

# Holds labelled examples, each a list of numbers and a label, in the form every learner of the learning module trains from.
#
# A training set is built from [ features, label ] pairs or filled one example at a time. Labels are
# kept as text. Split is a deterministic head and tail cut and never shuffles, so a run can be
# repeated exactly; order the examples yourself first when a shuffle is wanted. The learners
# (stzKnn, stzNaiveBayes, stzDecisionTree, stzLogisticRegression, stzNeuralNetwork) and stzTrainer
# take a set of this kind.
#
#   receiver   o1 = new stzTrainingSet([ [ [5.1, 3.5], "setosa" ], [ [4.9, 3.0], "setosa" ], [ [6.5,
#              2.8], "virginica" ], [ [6.3, 3.3], "virginica" ] ])
#   example    ? o1.NumberOfExamples()
#              #--> 4
#              ? @@( o1.Labels() )
#              #--> [ "setosa", "virginica" ]
#              o2 = o1.Split(0.75)
#              ? o2[1].NumberOfExamples()
#              #--> 3
#              ? o2[2].NumberOfExamples()
#              #--> 1
#   see        stzTrainer, stzKnn, stzNaiveBayes
class stzTrainingSet from stzObject

	@aExamples = []    # [ [ aFeatures, cLabel ] ... ]

	# Builds a training set from a list of examples, each a pair of a feature list and a label.
	#
	#   p          a list of [ features, label ] pairs, such as [ [ 5.1, 3.5 ], "setosa" ]
	#   returns    nothing; the object is built
	#   warning    a label is kept as text, so 42 becomes "42"; an argument that is not a list
	#              builds an empty set
	#   see        AddExample, Split
	def init(p)
		if isList(p)
			_n_ = len(p)
			for _i_ = 1 to _n_
				if isList(p[_i_]) and len(p[_i_]) = 2 and isList(p[_i_][1])
					@aExamples + [ p[_i_][1], "" + p[_i_][2] ]
				ok
			next
		ok

	# Appends one labelled example to the set.
	#
	#   paFeatures   the list of numbers describing the example
	#   pcLabel      its label, kept as text
	#   returns      nothing; use AddExampleQ to chain
	#   note         an argument that is not a list is ignored without a message, and the number of
	#                features is not checked against the earlier examples
	#   see          Examples, NumberOfExamples
	def AddExample(paFeatures, pcLabel)
		if isList(paFeatures)
			@aExamples + [ paFeatures, "" + pcLabel ]
		ok

		def AddExampleQ(paFeatures, pcLabel)
			This.AddExample(paFeatures, pcLabel)
			return This

	# Returns every example, in the order added.
	#
	#   returns    a list of [ features, label ] pairs
	#   see        AddExample, Labels
	def Examples()
		return @aExamples

	# Returns how many examples the set holds.
	#
	#   returns    a number
	#   see        Examples, NumberOfFeatures
	def NumberOfExamples()
		return len(@aExamples)

	# Returns the distinct labels, in the order they first appear.
	#
	#   returns    a list of text
	#   see        Examples
	def Labels()
		_acOut_ = []
		_n_ = len(@aExamples)
		for _i_ = 1 to _n_
			if ring_find(_acOut_, @aExamples[_i_][2]) = 0
				_acOut_ + @aExamples[_i_][2]
			ok
		next
		return _acOut_

	# Returns how many features the first example has, taken as the width of the set.
	#
	#   returns    a number; 0 for an empty set
	#   see        NumberOfExamples
	def NumberOfFeatures()
		if len(@aExamples) = 0
			return 0
		ok
		return len(@aExamples[1][1])

	# Cuts the set in two by position, the first part for training and the rest for testing; nothing is shuffled.
	#
	#   nRatio     the fraction of the examples that go to training, from 0 to 1
	#   returns    a list of two training sets, [ train, test ]
	#   note       the training part holds the first floor(count x ratio) examples; a ratio of 1.5
	#              puts all in training and 0 puts none; the set itself is not changed
	#   see        Examples
	#@ aka  deterministic head/tail split -- [ oTrain, oTest ]
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
