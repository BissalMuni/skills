# Claude Code Custom Skills

Claude Code custom skills for project initialization and development workflows.

## Skills

| Skill | Description |
|-------|-------------|
| `init-speckit` | Initialize a new project with spec-kit (Spec-Driven Development) |
| `init-docker-dangerous` | Set up Docker environment for Claude Code `--dangerously-skip-permissions` mode |

## Installation

Copy the desired skill folder to your Claude Code skills directory:

```bash
# Clone this repo
git clone https://github.com/BissalMuni/skills.git

# Copy skills to Claude Code directory
cp -r skills/init-speckit ~/.claude/skills/
cp -r skills/init-docker-dangerous ~/.claude/skills/
```

## Usage

In Claude Code, use the slash commands:

- `/init-speckit` — Create a new project with spec-kit structure
- `/init-docker-dangerous` — Set up Docker dangerous mode environment

## spec-kit Workflow

```
/init-speckit          → Project scaffolding
/speckit.constitution  → Define project principles
/speckit.specify       → Define feature requirements
/speckit.plan          → Create implementation plan
/speckit.tasks         → Generate task list
/speckit.implement     → Execute implementation
```
