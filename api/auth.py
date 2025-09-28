#!/usr/bin/python3

# Define a dictionary to store user credentials
USER_CREDENTIALS = {
    "admin": "admin01",
    "user": "momo123"
}

def validate_credentials(username, password):
    """Validate the provided username and password."""
    if username in USER_CREDENTIALS and USER_CREDENTIALS[username] == password:
        return True
    return False
