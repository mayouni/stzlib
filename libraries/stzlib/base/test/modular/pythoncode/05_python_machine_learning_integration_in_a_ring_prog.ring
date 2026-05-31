# Narrative
# --------
# Python Machine Learning Integration in a Ring program
#
# Extracted from stzpythoncodeTest.ring, block #5.

load "../../../stzBase.ring"


pr()

py() {

# Start of the python code

@('
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
    "predictions": predictions.tolist()
}
') # end of the python code

# Bakc to Ring: run the code and get the result

Execute()
? @@NL(Result())

} # closing brace of the py() object

#--> [
#	[ "accuracy", 0.90 ],
#	[ "feature_importance", [ 0.06, 0.08, 0.35, 0.51 ] ],
#	[ "predictions", [ 1, 0, 0, 1, 1, 1, 0, 0, 1, 0, 0, 0, 0, 1, 1, 1, 0, 0, 0, 1 ] ]
# ]


pf()
# Executed in 1.87 second(s) in Ring 1.24
