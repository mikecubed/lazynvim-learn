import os
import sys
from typing import List, Optional

# TODO: add logging support
STATUS_OPEN = "open"
STATUS_DONE = "done"


class TodoItem:
    def __init__(self, title: str, priority: int = 1):
        self.title = title
        self.priority = priority
        self.status = STATUS_OPEN
        self.tags: List[str] = []

    def complete(self):
        """Mark this item as done."""
        self.status = STATUS_DONE

    def add_tag(self,tag: str):
        """Attach a tag to the item."""
        if tag not in self.tags:
            self.tags.append(tag)

    def __repr__(self):
        return f"TodoItem({self.title!r}, priority={self.priority}, status={self.status!r})"


class TodoList:
    def __init__(self, name: str):
        self.name = name
        self.items: List[TodoItem] = []

    def add(self, title: str, priority: int = 1) -> TodoItem:
        """Create and append a new TodoItem."""
        item = TodoItem(title, priority)
        self.items.append(item)
        return item

    def pending(self) -> List[TodoItem]:
        """Return all items that are not yet done."""
        return [i for i in self.items if i.status == STATUS_OPEN]

    def summary(self) -> str:
        total = len(self.items)
        done = total - len(self.pending())
        return f"{self.name}: {done}/{total} complete"


def load_from_file(path: str) -> Optional[TodoList]:
    """Load a TodoList from a plain-text file (one title per line)."""
    if not os.path.exists(path):
        print(f"File not found: {path}", file=sys.stderr)
        return None
    todo_list = TodoList(os.path.basename(path))
    with open(path) as f:
        for line in f:
            title = line.strip()
            if title:
                todo_list.add(title)
    return todo_list


def print_summary(todo_list: TodoList):
    """Print a summary and all pending items to stdout."""
    print(todo_list.summary())
    for item in todo_list.pending():
        print(f"  [ ] {item.title}  (priority={item.priority})")
