import subprocess
import json
import sys

def spotify_status():
    result = subprocess.run(["playerctl", "--player=spotify", "status"], capture_output=True, text=True)
    result = result.stdout.strip()
    if result == "Paused":
        return "Paused"
    elif result == "No players found":
        return "Not Found"
    elif result == "Playing":
        return "Playing"
    else:
        return "Unknown"

def parse_spotify_data(data):
    parsed_data = {}
    artist, title = None, None  # Initialize artist and title
    
    lines = data.splitlines()
    for line in lines:
        if "artist" in line:
            index = line.find("artist") + len("artist")
            artist = line[index:].strip()
        elif "title" in line:
            index = line.find("title") + len("title")
            title = line[index:].strip()

    if artist and title:
        return f"{title} By {artist}"
    else:
        return "Unknown song"

def main():
    status = spotify_status()
    data = {}
    if len(sys.argv) > 1:
        argument = sys.argv[1]
        if argument == "playpause":
            if status == "Paused":
                result = subprocess.run(["playerctl", "--player=spotify", "play"], capture_output=True, text=True)
            elif status == "Playing":
                result = subprocess.run(["playerctl", "--player=spotify", "pause"], capture_output=True, text=True)
        elif argument == "focus":
            result = subprocess.run('swaymsg "[app_id=spotify] focus"', shell=True, capture_output=True, text=True)
    if status == "Paused":
        data = {'text': "Spotify Is Paused"}
    elif status == "Playing":
        result = subprocess.run(["playerctl", "--player=spotify", "metadata"], capture_output=True, text=True)
        to_write = parse_spotify_data(result.stdout)
        data = {'text': "Now Playing:  " + to_write}
    else:
        data = {'text': " "}
    
    print(json.dumps(data))

if __name__ == "__main__":
    main()
