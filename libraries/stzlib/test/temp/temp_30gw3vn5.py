
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

# Iterative function to traverse the list and replace all occurrences of a target item
def traverse_and_replace_iterative(lst, target, replacement):
    stack = [(lst, 0)]  # Stack stores (list, index) pairs
    
    while stack:
        current_list, idx = stack.pop()
        
        # Process elements until we reach the end of the current list
        while idx < len(current_list):
            if isinstance(current_list[idx], list):
                # If it is a sublist, push it onto the stack and start processing it
                stack.append((current_list, idx + 1))  # Save next index to resume later
                current_list = current_list[idx]       # Move into the sublist
                idx = 0                                # Start at beginning of sublist
            else:
                # If it is the target, replace it
                if current_list[idx] == target:
                    current_list[idx] = replacement
                idx += 1
    
    return lst  # Return the modified list

# The provided deep list with "♥" already embedded
deep_list = [
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
]

# Replace all "♥" with "★" and set the modified list as the result
res = traverse_and_replace_iterative(deep_list, "♥", "★")
    
print("Data before transformation:", res)
transformed = transform_to_ring(res)
print("Data after transformation:", transformed)
with open("temp\\pyresult_30gw3vn5.txt", "w") as f:
    f.write(transformed)
print("Data written to file")
