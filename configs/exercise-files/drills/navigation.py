import os
import sys
from typing import Dict, List, Optional

# Configuration constants
MAX_RETRIES = 3
TIMEOUT = 30
BASE_URL = "https://api.example.com"
DEBUG = False


def connect(host: str, port: int) -> bool:
    """Establish a connection to the remote server."""
    print(f"Connecting to {host}:{port}...")
    return True


def disconnect():
    """Close the active connection."""
    print("Disconnecting...")


# --- Data models ---

class User:
    def __init__(self, name: str, email: str):
        self.name = name
        self.email = email
        self.active = True

    def deactivate(self):
        """Mark the user as inactive."""
        self.active = False

    def __repr__(self):
        return f"User({self.name!r}, active={self.active})"


class Database:
    def __init__(self, path: str):
        self.path = path
        self.users: List[User] = []
        self._connected = False

    def open(self):
        """Open the database file."""
        if not os.path.exists(self.path):
            raise FileNotFoundError(self.path)
        self._connected = True

    def close(self):
        """Close the database."""
        self._connected = False

    def add_user(self, user: User):
        """Insert a user record."""
        self.users.append(user)

    def find_user(self, name: str) -> Optional[User]:
        """Look up a user by name."""
        for user in self.users:
            if user.name == name:
                return user
        return None

    def list_active(self) -> List[User]:
        """Return all active users."""
        return [u for u in self.users if u.active]

    def summary(self) -> Dict[str, int]:
        """Return counts of active and inactive users."""
        active = len(self.list_active())
        return {"active": active, "inactive": len(self.users) - active}


# --- Utility functions ---

def validate_email(email: str) -> bool:
    """Check if an email address looks valid."""
    return "@" in email and "." in email.split("@")[1]


def format_report(db: Database) -> str:
    """Generate a plain-text report of database contents."""
    lines = [f"Database: {db.path}"]
    lines.append(f"Total users: {len(db.users)}")
    stats = db.summary()
    lines.append(f"Active: {stats['active']}, Inactive: {stats['inactive']}")
    lines.append("")
    for user in db.users:
        status = "ACTIVE" if user.active else "INACTIVE"
        lines.append(f"  {user.name} <{user.email}> [{status}]")
    return "\n".join(lines)


def main():
    """Entry point — set up the database and print a report."""
    db = Database("users.db")
    db.add_user(User("Alice", "alice@example.com"))
    db.add_user(User("Bob", "bob@example.com"))
    db.add_user(User("Charlie", "charlie@example.com"))
    db.users[1].deactivate()
    print(format_report(db))


if __name__ == "__main__":
    main()
