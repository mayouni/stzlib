

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

import cv2

# Load the pre-trained Haar Cascade classifier
face_cascade = cv2.CascadeClassifier(cv2.data.haarcascades + "haarcascade_frontalface_default.xml")

# Load image
image = cv2.imread("images/face.jpg")

# Convert to grayscale for detection
gray = cv2.cvtColor(image, cv2.COLOR_BGR2GRAY)

# Detect faces
faces = face_cascade.detectMultiScale(gray, scaleFactor=1.1, minNeighbors=5, minSize=(30, 30))

# Process results and draw on image
face_results = []
for i, (x, y, w, h) in enumerate(faces):
    # Draw orange rectangle (BGR format: orange is approximately (0, 165, 255))
    cv2.rectangle(image, (x, y), (x+w, y+h), (0, 165, 255), 2)
    
    # Calculate and draw center point
    center_x = int(x + w/2)
    center_y = int(y + h/2)
    cv2.circle(image, (center_x, center_y), 5, (0, 165, 255), 2)
    
    face_results.append({
        "face_id": i + 1,
        "bbox": [int(x), int(y), int(w), int(h)],
        "center": [center_x, center_y]
    })

# Save the annotated image
cv2.imwrite("images/face2.jpg", image)

res = {
    "total_faces": len(faces),
    "faces": face_results,
    "output_file": "images/face2.jpg"
}

print("Data before transformation:", res)
transformed = transform_to_ring(res)
print("Data after transformation:", transformed)
with open("pyresult.txt", "w") as f:
    f.write(transformed)
print("Data written to file")
