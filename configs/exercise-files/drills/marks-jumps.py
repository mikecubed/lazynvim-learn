"""Task management system for practicing marks and jumps."""

from typing import List, Optional, Dict
from datetime import datetime


# --- Constants ---

PRIORITY_LOW = 1
PRIORITY_MEDIUM = 2
PRIORITY_HIGH = 3
PRIORITY_CRITICAL = 4

STATUS_OPEN = "open"
STATUS_IN_PROGRESS = "in_progress"
STATUS_DONE = "done"


# --- Models ---

class Task:
    def __init__(self, title: str, priority: int = PRIORITY_MEDIUM):
        self.title = title
        self.priority = priority
        self.status = STATUS_OPEN
        self.created_at = datetime.now()
        self.tags: List[str] = []

    def start(self):
        self.status = STATUS_IN_PROGRESS

    def complete(self):
        self.status = STATUS_DONE

    def add_tag(self, tag: str):
        if tag not in self.tags:
            self.tags.append(tag)

    def __repr__(self):
        return f"Task({self.title!r}, priority={self.priority})"


class Sprint:
    def __init__(self, name: str, duration_days: int = 14):
        self.name = name
        self.duration_days = duration_days
        self.tasks: List[Task] = []

    def add_task(self, task: Task):
        self.tasks.append(task)

    def open_tasks(self) -> List[Task]:
        return [t for t in self.tasks if t.status == STATUS_OPEN]

    def done_tasks(self) -> List[Task]:
        return [t for t in self.tasks if t.status == STATUS_DONE]

    def progress(self) -> float:
        if not self.tasks:
            return 0.0
        return len(self.done_tasks()) / len(self.tasks) * 100


# --- Report functions ---

def format_task_line(task: Task) -> str:
    icon = {"open": " ", "in_progress": "~", "done": "x"}
    marker = icon.get(task.status, "?")
    return f"[{marker}] {task.title} (P{task.priority})"


def print_sprint_report(sprint: Sprint) -> str:
    lines = [f"Sprint: {sprint.name}"]
    lines.append(f"Progress: {sprint.progress():.0f}%")
    lines.append("-" * 40)
    for task in sprint.tasks:
        lines.append(f"  {format_task_line(task)}")
    lines.append("-" * 40)
    lines.append(f"Total: {len(sprint.tasks)} tasks")
    return "\n".join(lines)


# --- Utility functions ---

def filter_by_priority(tasks: List[Task], min_priority: int) -> List[Task]:
    return [t for t in tasks if t.priority >= min_priority]


def filter_by_status(tasks: List[Task], status: str) -> List[Task]:
    return [t for t in tasks if t.status == status]


def bulk_tag(tasks: List[Task], tag: str):
    for task in tasks:
        task.add_tag(tag)


def count_by_status(tasks: List[Task]) -> Dict[str, int]:
    counts: Dict[str, int] = {}
    for task in tasks:
        counts[task.status] = counts.get(task.status, 0) + 1
    return counts


# --- Main ---

def main():
    sprint = Sprint("Q2-Week3")

    sprint.add_task(Task("Set up CI pipeline", PRIORITY_HIGH))
    sprint.add_task(Task("Write unit tests", PRIORITY_MEDIUM))
    sprint.add_task(Task("Update README", PRIORITY_LOW))
    sprint.add_task(Task("Fix login bug", PRIORITY_CRITICAL))
    sprint.add_task(Task("Code review PR #42", PRIORITY_MEDIUM))
    sprint.add_task(Task("Deploy to staging", PRIORITY_HIGH))

    sprint.tasks[0].start()
    sprint.tasks[3].start()
    sprint.tasks[3].complete()

    print(print_sprint_report(sprint))


if __name__ == "__main__":
    main()
