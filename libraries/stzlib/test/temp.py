


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


data = {
    "integer": 42,
    "decimal": 3.14159,
    "negative": -17,
    "calculation": 2 ** 8
}


transformed = transform_to_ring(data)

with open("' + @cDataFile + '", "w") as f:
    f.write(transformed)
