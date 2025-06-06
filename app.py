import time
from flask import Flask

app = Flask(__name__)

START = time.time()

def elapsed():
    running = time.time() - START
    minutes, seconds = divmod(running, 60)
    hours, minutes = divmod(minutes, 60)
    return "%d:%02d:%02d" % (hours, minutes, seconds)

@app.route('/')
def root():
    return f"Hello World (Python)! (up {elapsed()})\n"

def main():
    """Entry point for running the Flask app."""
    app.run(debug=True, host="0.0.0.0", port=8080)

if __name__ == "__main__":
    main()
