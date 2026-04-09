# Copy and paste practice file

import math


def square(n):
    """Return the square of n."""
    return n * n


def cube(n):
    """Return the cube of n."""
    return n * n * n


def double(n):
    """Return double the value."""
    return n * 2


# --- Constants ---

PI = 3.14159
TAU = 6.28318
EULER = 2.71828

important_word = "CLIPBOARD"


# --- Data processing ---

def process_alpha(data):
    """Process alpha dataset."""
    result = []
    for item in data:
        if item > 0:
            result.append(item * 2)
    return result


def process_beta(data):
    """Process beta dataset."""
    result = []
    for item in data:
        if item > 0:
            result.append(item * 3)
    return result


# --- Report section ---
# This paragraph describes the report format.
# Reports are generated daily at midnight.
# Each report contains a summary and detail section.
# The summary lists totals and the detail lists individual items.

def generate_report(title, items):
    """Create a formatted report string."""
    lines = []
    lines.append(f"=== {title} ===")
    lines.append("")
    for item in items:
        lines.append(f"  - {item}")
    lines.append("")
    lines.append(f"Total: {len(items)} items")
    return "\n".join(lines)


def print_report(title, items):
    """Print a report to stdout."""
    print(generate_report(title, items))


# --- Main ---

def main():
    nums = [1, 2, 3, 4, 5]
    alpha = process_alpha(nums)
    beta = process_beta(nums)
    print_report("Alpha", alpha)
    print_report("Beta", beta)


if __name__ == "__main__":
    main()
