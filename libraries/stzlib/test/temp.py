

def transform_to_ring(data):
    def _transform(obj):
        if isinstance(obj, dict):
            items = []
            for key, value in obj.items():
                items.append(f"['{key}', {_transform(value)}]")
            return "[" + ", ".join(items) + "]"
        elif isinstance(obj, list):
            return "[" + ", ".join(_transform(item) for item in obj) + "]"
        elif isinstance(obj, str):
            # Check if the string looks like a Python dictionary
            if obj.startswith("{") and obj.endswith("}"):
                try:
                    # Try to convert the string back to a dictionary using eval
                    # This is safe here because we know the source is from get_params()
                    dict_obj = eval(obj)
                    if isinstance(dict_obj, dict):
                        # If successful, transform the dictionary
                        return _transform(dict_obj)
                except:
                    # If eval fails, just treat it as a normal string
                    pass
            return f"'{obj}'"
        elif isinstance(obj, (int, float)):
            # Convert to string first to check for scientific notation
            str_val = str(obj)
            if "e" in str_val.lower():  # Check for scientific notation
                return f"'{str_val}'"
            return str_val
        elif obj is None:
            return "NULL"
        elif isinstance(obj, bool):
            return str(obj).upper()  # Convert True/False to TRUE/FALSE
        else:
            return f"'{str(obj)}'"
    return _transform(data)

# Main code
print("Python script starting...")

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

print("Data before transformation:", res)
transformed = transform_to_ring(res)
print("Data after transformation:", transformed)
with open("pyresult.txt", "w") as f:
    f.write(transformed)
print("Data written to file")
