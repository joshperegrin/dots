import os
import subprocess
import json
from PIL import Image
import shutil
from collections import Counter
import colorsys

# Directory containing files
DIRECTORY = "/home/josh/Pictures/wallpapers/fav"
# State file to remember the last processed file
STATE_FILE = "/home/josh/bin/command_state.json"
# Output path for Rofi
ROFI_IMAGE_PATH = os.path.expanduser("~/.config/rofi/images/background.jpg")

def get_files():
    return sorted([
        f for f in os.listdir(DIRECTORY)
        if os.path.isfile(os.path.join(DIRECTORY, f)) and f.lower().endswith((".jpg", ".png", ".gif"))
    ])

def get_last_index():
    if os.path.exists(STATE_FILE):
        with open(STATE_FILE, "r") as f:
            try:
                return json.load(f).get("last_index", -1)
            except json.JSONDecodeError:
                return -1
    return -1

def save_last_index(index):
    with open(STATE_FILE, "w") as f:
        json.dump({"last_index": index}, f)

def convert_to_jpg(source_path, dest_path, output_width=560, output_height=512):
    try:
        with Image.open(source_path) as img:
            img = img.convert("RGB")
            width, height = img.size
            target_aspect = output_width / output_height

            # Determine crop area that matches target aspect ratio, centered
            current_aspect = width / height

            if current_aspect > target_aspect:
                # Image is too wide — crop width
                new_width = int(height * target_aspect)
                left = (width - new_width) // 2
                top = 0
                right = left + new_width
                bottom = height
            else:
                # Image is too tall — crop height
                new_height = int(width / target_aspect)
                top = (height - new_height) // 2
                left = 0
                right = width
                bottom = top + new_height

            cropped = img.crop((left, top, right, bottom))
            resized = cropped.resize((output_width, output_height), Image.LANCZOS)
            resized.save(dest_path, "JPEG")
    except Exception as e:
        print(f"Failed to convert image: {e}")

def run_command():
    files = get_files()
    if not files:
        print("No files found.")
        return

    last_index = get_last_index()
    next_index = (last_index + 1) % len(files)
    file_to_process = os.path.join(DIRECTORY, files[next_index])

    # Set wallpaper using swww
    print(f"Setting wallpaper: {file_to_process}")
    result = subprocess.run([
        "swww", "img", "--transition-step", "50", "--transition-fps", "90", file_to_process
    ], capture_output=True, text=True)

    if result.returncode != 0:
        print("Error setting wallpaper:", result.stderr)

    # Convert and copy to rofi image
    convert_to_jpg(file_to_process, ROFI_IMAGE_PATH)

    # Save state
    save_last_index(next_index)
   


if __name__ == "__main__":
    run_command()
