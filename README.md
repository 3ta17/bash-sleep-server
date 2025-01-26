# Sleep-Walking Server Management Script

## Overview
This project provides a shell script to manage a simple "sleep-walking server" application. It demonstrates how to use case statements, process management, and basic shell scripting techniques.

The solution includes:
1. **`sleep-walking-server`**: A server simulation script that runs indefinitely and stores its process ID (PID) in a file.
2. **`1.sh`**: A script to start and stop the server, ensuring proper handling of process management.

---

## Features
- **Start the Server**: Launches the `sleep-walking-server` in the background and records its PID in a file for process management.
- **Stop the Server**: Stops the running server by reading its PID and cleaning up resources.
- **Error Handling**: Prevents starting multiple instances and gracefully handles invalid inputs.
- **Clear Feedback**: Provides meaningful messages for all operations (start, stop, errors).

---

## Usage

### Prerequisites
1. Ensure you have Bash installed (default on most Linux distributions).
2. Clone this repository and navigate to the project folder:
   ```bash
   git clone https://github.com/your-repo/sleep-walking-server.git
   cd sleep-walking-server
