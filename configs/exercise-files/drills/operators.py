# Operator practice file

import os
import sys


def greet_user(name):
    """Greet someone by name."""
    message = "Hello, World!"
    print(message)
    return message


def calculate_total(items):
    """Calculate total from a list of prices."""
    total = sum(items)
    tax = total * 0.08
    final = total + tax
    return final


def remove_me(x):
    """This entire function should be deleted."""
    temp = x + 1
    temp = temp * 2
    return temp


old_config = {"host": "localhost", "port": 8080}

settings = {"debug": True, "verbose": False}


def format_name(first, last):
    """Format a full name."""
    full = first + " " + last
    return full.strip()


def process_data(raw_input):
    """Process raw data into output."""
    result = []
    for item in raw_input:
        cleaned = item.strip()
        if len(cleaned) > 0:
            result.append(cleaned)
    return result


word_to_surround = hello
another_word = world

INDENT_ME = "fix"
INDENT_ALSO = "fix"


def build_query(table, columns):
    """Build a simple query string."""
    cols = ", ".join(columns)
    query = f"SELECT {cols} FROM {table}"
    return query
