# Claude Code Custom Skills

Claude Code custom skills for project initialization and development workflows.

## Skills

| Skill | Description |
|-------|-------------|
| `init-speckit` | Initialize a new project with spec-kit (Spec-Driven Development) |
| `init-docker-dangerous` | Set up Docker environment for Claude Code `--dangerously-skip-permissions` mode |
| `docs-write` | 대화에서 학습한 내용을 MDX 문서로 작성하여 study-dev에 저장 |
| `docs-publish` | study-dev의 문서를 GitHub에 커밋/푸시 |

## Installation

Copy the desired skill folder to your Claude Code skills directory:

```bash
# Clone this repo
git clone https://github.com/BissalMuni/skills.git

# Copy skills to Claude Code directory
cp -r skills/init-speckit ~/.claude/skills/
cp -r skills/init-docker-dangerous ~/.claude/skills/
cp -r skills/docs-write ~/.claude/skills/
cp -r skills/docs-publish ~/.claude/skills/
```

## Usage

In Claude Code, use the slash commands:

- `/init-speckit` — Create a new project with spec-kit structure
- `/init-docker-dangerous` — Set up Docker dangerous mode environment
- `/docs-write` — 학습 내용을 MDX 문서로 정리/저장
- `/docs-publish` — 문서를 GitHub에 배포

## spec-kit Workflow

```
/init-speckit          → Project scaffolding
/speckit.constitution  → Define project principles
/speckit.specify       → Define feature requirements
/speckit.plan          → Create implementation plan
/speckit.tasks         → Generate task list
/speckit.implement     → Execute implementation
```

## docs Workflow

```
(아무 프로젝트에서 공부)
/docs-write            → 대화 내용을 MDX 문서로 정리하여 study-dev/docs/에 저장
/docs-publish          → study-dev를 GitHub에 커밋/푸시
```
