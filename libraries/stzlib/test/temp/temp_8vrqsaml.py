
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

# Function to generate a deeply nested list with specified maximum depth
def generate_deep_list(max_depth, num_items=10):
    """
    Generates a nested list with "max_depth" levels.
    Each level contains "num_items" items followed by a sublist, except the deepest level.
    """
    current = ["item"] * num_items  # Deepest level has only items
    for _ in range(max_depth):
        current = ["item"] * num_items + [current]  # Add items and nest the previous list
    return current

# Function to set an item at a specific level and index
def set_item(deep_list, k, j, value):
    """
    Sets the item at level k, index j in the deep list to the specified value.
    k is the depth level (0 to max_depth), j is the item index (0 to num_items-1).
    """
    current = deep_list
    for _ in range(k):
        current = current[-1]  # Navigate to the sublist at each level
    current[j] = value

# Function to traverse the list and replace all occurrences of a target item
def traverse_and_replace(lst, target, replacement):
    """
    Recursively traverses the list, replaces "target" with "replacement",
    and returns the count of replacements made.
    """
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

# Parameters
max_depth = 1000  # Number of nesting levels
num_items = 10   # Number of items per level before the sublist

# Step 1: Generate the deep list
deep_list = generate_deep_list(max_depth, num_items)

# Step 2: Generate 100 unique random positions to place "♥"
positions = set()
while len(positions) < 100:
    k = random.randint(0, max_depth - 1)  # Level from 0 to 999
    j = random.randint(0, num_items - 1)  # Item index from 0 to 9
    positions.add((k, j))

# Step 3: Place "♥" at the selected positions
for k, j in positions:
    set_item(deep_list, k, j, "♥")

# Step 4: Replace all "♥" with "★" and count the replacements
count = traverse_and_replace(deep_list, "♥", "★")

# Step 5: Set the result
res = {"replacements_made": count}

print("Data before transformation:", res)
transformed = transform_to_ring(res)
print("Data after transformation:", transformed)
with open("temp\\pyresult_8vrqsaml.txt", "w") as f:
    f.write(transformed)
print("Data written to file")
