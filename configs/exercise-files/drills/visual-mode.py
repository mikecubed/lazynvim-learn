# Visual mode practice file

PRIMARY_COLORS = ["red", "green", "blue"]

SECONDARY_COLORS = ["orange", "purple", "yellow"]

DEPRECATED_ITEMS = ["old_func", "legacy_api", "broken_handler"]

# --- Shopping list ---

grocery_list = [
    "apples",
    "bananas",
    "cherries",
    "dates",
    "elderberries",
]

hardware_list = [
    "screws",
    "nails",
    "bolts",
    "washers",
]


def calculate_total(prices: list) -> float:
    """Sum all prices in the list."""
    total = 0.0
    for price in prices:
        total += price
    return total


def calculate_average(prices: list) -> float:
    """Calculate the average price."""
    if not prices:
        return 0.0
    return calculate_total(prices) / len(prices)


DELETE_THIS_FUNCTION = True

def unused_function():
    """This entire function should be deleted."""
    x = 1
    y = 2
    z = 3
    return x + y + z


def format_table(rows: list) -> str:
    """Format rows into an aligned table."""
    #     col1     col2     col3
    header = "Name     Price    Stock"
    lines = [header]
    lines.append("-" * 30)
    for row in rows:
        lines.append(f"{row[0]:<9}{row[1]:<9}{row[2]}")
    return "\n".join(lines)


# --- Data block ---
#
# These lines have a common prefix that can be
# edited with block selection:
#
#   ITEM: apple     $1.50
#   ITEM: banana    $0.75
#   ITEM: cherry    $2.00
#   ITEM: date      $3.50
#   ITEM: elder     $4.25


def process_items(items: list) -> list:
    """Filter and return valid items."""
    result = []
    for item in items:
        if item is not None:
            result.append(item)
    return result
