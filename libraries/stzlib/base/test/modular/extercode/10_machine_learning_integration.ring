# Narrative
# --------
# Machine Learning Integration
#
# Extracted from stzextercodetest.ring, block #10.

load "../../../stzBase.ring"


pr()

#WARNING For that sample to work 'scikit-learn' must be installed ontop of python

oPyCode = new stzExterCode("python")

oPyCode.SetCode('
from sklearn.datasets import make_classification
from sklearn.model_selection import train_test_split
from sklearn.ensemble import RandomForestClassifier

# Generate synthetic data
X, y = make_classification(n_samples=100, n_features=4, random_state=42)
X_train, X_test, y_train, y_test = train_test_split(X, y, test_size=0.2)

# Train model
clf = RandomForestClassifier(random_state=42)
clf.fit(X_train, y_train)

# Get predictions
predictions = clf.predict(X_test)

res = {
    "accuracy": clf.score(X_test, y_test),
    "feature_importance": clf.feature_importances_.tolist(),
    "predictions": predictions.tolist(),
    "model_params": str(clf.get_params())
}
')
oPyCode.Execute()
? @@(oPyCode.Result())
#--> [
#	['accuracy', 1.0],
#	['feature_importance',
#		[ 0.05509410437235118, 0.12683805728497533, 0.32986783001366454, 0.48820000832900895 ]
#	],
#	['predictions',
#		[1, 0, 1, 1, 1, 0, 1, 0, 1, 0, 1, 0, 0, 0, 1, 0, 0, 0, 1, 0]
#	],
#	['model_params', [
#		[ 'bootstrap', True],
#		[ 'ccp_alpha': 0.0 ],
#		[ 'class_weight', Null],
#		[ 'criterion', 'gini' ],
#		[ 'max_depth', Null ],
#		[ 'max_features', 'sqrt' ],
#		[ 'max_leaf_nodes', Null ],
#		[ 'max_samples', Null ],
#		[ 'min_impurity_decrease', 0.0 ],
#		[ 'min_samples_leaf', 1 ],
#		[ 'min_samples_split', 2 ],
#		[ 'min_weight_fraction_leaf', 0.0 ],
#		[ 'monotonic_cst', Null ],
#		[ 'n_estimators', 100 ],
#		[ 'n_jobs', Null ],
#		[ 'oob_score', False ],
#		[ 'random_state', 42 ],
# 		[ 'verbose', 0 ],
# 		[ 'warm_start', False]
#	]
# ]

pf()
# Executed in 1.77 second(s) in Ring 1.23
