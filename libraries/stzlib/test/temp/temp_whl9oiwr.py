
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


import random

# Function to traverse the list and replace all occurrences of a target item
def traverse_and_replace(lst, target, replacement):
    count = 0
    for i in range(len(lst)):
        if isinstance(lst[i], list):
            # If the element is a sublist, recurse
            count += traverse_and_replace(lst[i], target, replacement)
        elif lst[i] == target:
            # If the element is the target, replace it
            lst[i] = replacement
            count += 1
    return count

deep_list = aDeep =  [
    	42, "apple", "♥", ["sun", 314, [-7, "moon", "♥"], "rain"], [
        99,
        "star", "♥",
        [
            0,
            "♥", "cloud",
            [
                272,
                "wind", "♥",
                [
                    "tree",
                    100,
                    [
                        "fish", "♥",
                        "♥", "bird",
                        [
                            8,
                            "sky", "♥",
                            [
                                "♥", "river",
                                162,
                                [
                                    "fire", "♥", "♥",
                                    "♥", "stone",
                                    ["lake", "♥", 77]
                                ]
                            ]
                        ],
                        "winter", "♥"
                    ]
                ]
            ],
            "♥", "summer", "♥"
        ],
        "night", "♥", "♥"
]

# Step 4: Replace all "♥" with "★" and count the replacements
count = traverse_and_replace(deep_list, "♥", "★")

# Step 5: Set the result
res = {"replacements_made": count}

print("Data before transformation:", res)
transformed = transform_to_ring(res)
print("Data after transformation:", transformed)
with open("temp\\pyresult_whl9oiwr.txt", "w") as f:
    f.write(transformed)
print("Data written to file")
