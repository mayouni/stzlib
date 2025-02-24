

def transform_to_ring(data):
    def _transform(obj):
        if isinstance(obj, dict):
            items = []
            for key, value in obj.items():
                items.append(f"[\'{key}\', {_transform(value)}]")
            return "[" + ", ".join(items) + "]"
        elif isinstance(obj, list):
            return "[" + ", ".join(_transform(item) for item in obj) + "]"
        elif isinstance(obj, str):
            return f"\'{obj}\'"
        elif isinstance(obj, (int, float)):
            return str(obj)
        else:
            return f"\'{str(obj)}\'"
    return _transform(data)

# Main code
print("Python script starting...")

data = {
    "numbers": [1, 2, 3, 4, 5],
    "mean": sum([1, 2, 3, 4, 5]) / 5
}

print("Data before transformation:", data)
transformed = transform_to_ring(data)
print("Data after transformation:", transformed)
with open("pydata.txt", "w") as f:
    f.write(transformed)
print("Data written to file")
