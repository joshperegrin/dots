import os
import subprocess
import json
import numpy as np
from PIL import Image, ImageFilter
import shutil
import random

# Directory containing files
DIRECTORY = "/home/josh/Pictures/wallpapers/fav"
# Subdirectory for blurred wallpapers
BLUR_DIR = os.path.join(DIRECTORY, "blurred")
# State file to remember the last processed file
STATE_FILE = "/home/josh/bin/command_state.json"
# Output path for Rofi
ROFI_IMAGE_PATH = os.path.expanduser("~/.config/rofi/images/background.jpg")

def ensure_blur_dir():
    """Ensure the blurred subdirectory exists."""
    os.makedirs(BLUR_DIR, exist_ok=True)

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
            current_aspect = width / height

            if current_aspect > target_aspect:
                new_width = int(height * target_aspect)
                left = (width - new_width) // 2
                top = 0
                right = left + new_width
                bottom = height
            else:
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

def blur_image(source_path, dest_path, blur_radius=25, noise_level=10):
    """Create a blurred version of an image with added noise (fast using NumPy)."""
    try:
        with Image.open(source_path) as img:
            img = img.convert("RGB")
            blurred = img.filter(ImageFilter.GaussianBlur(blur_radius))
            arr = np.array(blurred, dtype=np.int16)
            noise = np.random.randint(-noise_level, noise_level + 1, arr.shape, dtype=np.int16)
            arr = np.clip(arr + noise, 0, 255).astype(np.uint8)
            noisy_img = Image.fromarray(arr)
            noisy_img.save(dest_path, "JPEG", quality=95)
    except Exception as e:
        print(f"Failed to blur image: {e}")

def run_command():
    ensure_blur_dir()

    files = get_files()
    if not files:
        print("No files found.")
        return

    last_index = get_last_index()
    next_index = (last_index + 1) % len(files)
    file_to_process = os.path.join(DIRECTORY, files[next_index])

    # Define blurred image path in subdirectory
    blur_filename = os.path.splitext(files[next_index])[0] + "_blur.jpg"
    blurred_image_path = os.path.join(BLUR_DIR, blur_filename)

    # Set main wallpaper (normal)
    print(f"Setting main wallpaper: {file_to_process}")
    subprocess.run([
        "swww", "img", "--namespace", "wallpaper",
        "--transition-step", "50", "--transition-fps", "90", file_to_process
    ])

    # Check if blurred wallpaper already exists
    if os.path.exists(blurred_image_path):
        print(f"Using existing blurred wallpaper: {blurred_image_path}")
    else:
        print(f"Creating blurred wallpaper: {blurred_image_path}")
        blur_image(file_to_process, blurred_image_path)

    # Set blurred wallpaper
    print("Setting blurred wallpaper...")
    result = subprocess.run([
        "swww", "img", "--transition-step", "50", "--transition-fps", "90", blurred_image_path
    ], capture_output=True, text=True)

    if result.returncode != 0:
        print("Error setting blurred wallpaper:", result.stderr)

    # Convert for Rofi preview
    convert_to_jpg(file_to_process, ROFI_IMAGE_PATH)

    # Save state
    save_last_index(next_index)

if __name__ == "__main__":
    run_command()
