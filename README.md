# Claude Code Custom Skills

Claude Code custom skills for project initialization and development workflows.

## Skills

| Skill | Description |
|-------|-------------|
| `init-speckit` | Initialize a new project with spec-kit (Spec-Driven Development) |
| `init-docker-dangerous` | Set up Docker environment for Claude Code `--dangerously-skip-permissions` mode |
| `sync-write-doc-to-studydev` | 대화에서 학습한 내용을 MDX 문서로 작성하여 study-dev에 저장 |
| `sync-publish-doc-to-studydev` | study-dev의 문서를 GitHub에 커밋/푸시 |
| `sync-from-github-remote` | 현재 git 레포를 리모트와 안전하게 동기화(fetch + pull), 미커밋 변경 보존 |
| `session-log` | 현재 대화를 요약해 프로젝트의 docs/sessions/에 작업 일지(Journal)로 저장 |
| `print` | 대화 내용을 순수 텍스트로 정리해 종이로 출력 (printbox, Out-Printer, Edge 불필요) |

## Installation

Copy the desired skill folder to your Claude Code skills directory:

```bash
# Clone this repo
git clone https://github.com/BissalMuni/skills.git

# Copy skills to Claude Code directory
cp -r skills/init-speckit ~/.claude/skills/
cp -r skills/init-docker-dangerous ~/.claude/skills/
cp -r skills/sync-write-doc-to-studydev ~/.claude/skills/
cp -r skills/sync-publish-doc-to-studydev ~/.claude/skills/
cp -r skills/sync-from-github-remote ~/.claude/skills/
cp -r skills/session-log ~/.claude/skills/
cp -r skills/print ~/.claude/skills/
# print 스킬은 인쇄 스크립트도 함께 배치한다 (SKILL.md 의 경로와 일치):
cp skills/print/print.ps1 "D:/Coding/printbox/print.ps1"
```

## Usage

In Claude Code, use the slash commands:

- `/init-speckit` — Create a new project with spec-kit structure
- `/init-docker-dangerous` — Set up Docker dangerous mode environment
- `/sync-write-doc-to-studydev` — 학습 내용을 MDX 문서로 정리/저장
- `/sync-publish-doc-to-studydev` — 문서를 GitHub에 배포
- `/sync-from-github-remote` — 현재 레포를 리모트와 동기화(pull), 미커밋 변경 보존
- `/session-log` — 현재 대화를 작업 일지로 docs/sessions/에 저장
- `/print` — 직전 답변/내용을 순수 텍스트로 정리해 종이로 출력 (눈 피로 시)

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
/sync-write-doc-to-studydev            → 대화 내용을 MDX 문서로 정리하여 study-dev/docs/에 저장
/sync-publish-doc-to-studydev          → study-dev를 GitHub에 커밋/푸시
```
