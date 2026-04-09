# Search and replace practice file

import json


def get_old_name():
    """Return the old_name value."""
    old_name = "alpha"
    return old_name


def set_old_name(value):
    """Set the old_name to a new value."""
    old_name = value
    print(f"old_name is now {old_name}")
    return old_name


def use_old_name():
    """Use old_name in a computation."""
    old_name = get_old_name()
    result = old_name.upper()
    return result


# Configuration
max_retries = 3
timeout_seconds = 30
use_cache = True


def fetch_data(url):
    """Fetch data from a URL."""
    print(f"Fetching: {url}")
    data = {"status": "ok"}
    return data


def parse_response(data):
    """Parse the response data."""
    result = json.loads(data)
    return result


def get_user_count():
    """Return the number of users."""
    user_count = 42
    return user_count


def get_item_count():
    """Return the number of items."""
    item_count = 100
    return item_count


snake_case_one = "first"
snake_case_two = "second"
snake_case_three = "third"
