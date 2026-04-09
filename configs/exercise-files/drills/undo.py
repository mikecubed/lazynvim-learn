# Undo practice file

import os


def connect(host, port):
    """Establish a connection to the server."""
    url = f"http://{host}:{port}"
    print(f"Connecting to {url}...")
    return url


def disconnect(connection):
    """Close the connection gracefully."""
    print(f"Closing {connection}")
    connection = None
    return True


DELETE_THIS_LINE = "remove me with dd"


def validate(data):
    """Check that data meets the required format."""
    if not isinstance(data, dict):
        return False
    required = ["name", "email", "role"]
    for field in required:
        if field not in data:
            return False
    return True


config = {
    "host": "localhost",
    "port": 8080,
    "debug": True,
    "timeout": 30,
}


def transform(items):
    """Transform items to uppercase."""
    result = []
    for item in items:
        result.append(item.upper())
    return result


REPLACE_ME = "old_value"

CHANGE_THIS = "original text here"
