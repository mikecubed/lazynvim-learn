// sample.js — exercise file for LSP and completions lessons

class ShoppingCart {
  constructor(owner) {
    this.owner = owner;
    this.items = [];
  }

  addItem(name, price, quantity = 1) {
    const existing = this.items.find((i) => i.name === name);
    if (existing) {
      existing.quantity += quantity;
    } else {
      this.items.push({ name, price, quantity });
    }
  }

  removeItem(name) {
    this.items = this.items.filter((i) => i.name !== name);
  }

  total() {
    return this.items.reduce((sum, i) => sum + i.price * i.quantity, 0);
  }

  summary() {
    const lines = this.items.map(
      (i) => `  ${i.name} x${i.quantity} @ $${i.price.toFixed(2)}`
    );
    return [`Cart for ${this.owner}:`, ...lines, `Total: $${this.total().toFixed(2)}`].join(
      "\n"
    );
  }
}

export function createCart(owner) {
  return new ShoppingCart(owner);
}
