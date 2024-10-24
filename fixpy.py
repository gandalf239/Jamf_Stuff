import os
import subprocess

def correct_python_code(file_path):
    # Check if the file exists
    if not os.path.exists(file_path):
        print(f"Error: File '{file_path}' not found.")
        return

    # Define the command to run 2to3 tool
    command = ['2to3', '-w', '-n', file_path]

    try:
        # Run the command
        subprocess.run(command, check=True)
        print(f"Code in '{file_path}' has been successfully converted to Python 3.x.")
    except subprocess.CalledProcessError as e:
        print(f"Error: Conversion of '{file_path}' failed with error: {e}")

if __name__ == "__main__":
    # Provide the path to the Python 2.x script here
    python2_script_path = "path/to/your/python2_script.py"

    # Correct the Python code
    correct_python_code(python2_script_path)
