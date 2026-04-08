# Multi-file workflow practice

from dataclasses import dataclass


@dataclass
class Project:
    """A project with tasks."""
    name: str
    owner: str
    tasks: list


def create_project(name, owner):
    """Create a new project."""
    return Project(name=name, owner=owner, tasks=[])


def add_task(project, task):
    """Add a task to a project."""
    project.tasks.append(task)
    return project


def list_tasks(project):
    """List all tasks in a project."""
    for i, task in enumerate(project.tasks, 1):
        print(f"  {i}. {task}")


def main():
    proj = create_project("Demo", "admin")
    add_task(proj, "Set up environment")
    add_task(proj, "Write tests")
    add_task(proj, "Deploy")
    list_tasks(proj)
