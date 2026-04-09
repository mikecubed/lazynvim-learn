"""Invoice processing module with LSP-friendly code."""

from typing import List, Optional, Dict
import os
import json
import sys
import math


TAX_RATE = 0.08
DISCOUNT_THRESHOLD = 100


class LineItem:
    def __init__(self, name: str, quantity: int, price: float):
        self.name = name
        self.quantity = quantity
        self.price = price

    def calculate_total(self) -> float:
        """Return total for this line item."""
        return self.quantity * self.price


class Invoice:
    def __init__(self, customer: str, items: Optional[List[LineItem]] = None):
        self.customer = customer
        self.items: List[LineItem] = items or []
        self.paid = False

    def add_item(self, item: LineItem):
        self.items.append(item)

    def calculate_total(self) -> float:
        """Sum all line item totals plus tax."""
        subtotal = sum(item.calculate_total() for item in self.items)
        return subtotal + (subtotal * TAX_RATE)

    def apply_discount(self, percent: float) -> float:
        total = self.calculate_total()
        if total > DISCOUNT_THRESHOLD:
            return total * (1 - percent / 100)
        return total

    def summary(self) -> Dict[str, object]:
        return {
            "customer": self.customer,
            "items": len(self.items),
            "total": self.calculate_total(),
            "paid": self.paid,
        }


def format_invoice(inv: Invoice) -> str:
    lines = [f"Invoice for {inv.customer}"]
    for item in inv.items:
        cost = item.calculate_total()
        lines.append(f"  {item.name}: {item.quantity} x ${item.price:.2f} = ${cost:.2f}")
    lines.append(f"  Total: ${inv.calculate_total():.2f}")
    return "\n".join(lines)


def create_sample_invoice() -> Invoice:
    inv = Invoice("Acme Corp")
    inv.add_item(LineItem("Widget", 5, 9.99))
    inv.add_item(LineItem("Gadget", 2, 24.50))
    inv.add_item(LineItem("Doohickey", 10, 1.75))
    return inv


# Type error on purpose — passing int where str expected
def print_invoice_header(title: str) -> None:
    print("=" * len(title))
    print(title)
    print("=" * len(title))


def main():
    inv = create_sample_invoice()
    print_invoice_header(42)
    print(format_invoice(inv))
    discounted = inv.apply_discount(10)
    print(f"After 10% discount: ${discounted:.2f}")


if __name__ == "__main__":
    main()
