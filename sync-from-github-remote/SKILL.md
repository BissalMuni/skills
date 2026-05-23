---
name: sync-from-github-remote
description: 현재 git 레포지토리를 GitHub 리모트와 안전하게 동기화(fetch + pull)합니다. 로컬 미커밋 변경을 보존하며 ahead/behind 상태에 따라 fast-forward, rebase, 또는 충돌 보고를 수행합니다. Use when user says "리모트 동기화", "깃 동기화", "최신으로 맞춰줘", "pull", "sync" or runs /sync-from-github-remote.
---

# Git 리모트 동기화

현재 작업 중인 git 레포지토리의 현재 브랜치를 GitHub 리모트와 안전하게 동기화한다.
**받아오기(pull) 중심**이며, 로컬의 커밋되지 않은 변경을 절대 잃지 않도록 처리한다.

## 핵심 원칙

- 로컬 미커밋 변경(modified/untracked)은 **절대 손실하지 않는다**.
- `--ff-only`를 우선 시도하고, 불가능할 때만 rebase/merge를 고려한다.
- force push, `reset --hard`, 무분별한 `checkout --` 등 파괴적 명령은 사용하지 않는다.
- 모든 단계에서 무엇을 할지 먼저 보여주고, 위험 가능성이 있으면 사용자에게 확인받는다.

## 입력

```text
$ARGUMENTS
```

인자가 없으면 현재 브랜치를 그 upstream과 동기화한다.
인자로 브랜치명이 주어지면 해당 브랜치를 대상으로 한다.

## Workflow

### Step 1: 현재 상태 파악

```bash
git rev-parse --abbrev-ref HEAD          # 현재 브랜치
git remote -v                            # 리모트 확인
git fetch                                # 리모트 최신 정보 가져오기
git status -sb                           # ahead/behind + 로컬 변경
```

리모트가 없으면 "리모트가 설정되어 있지 않습니다"라고 알리고 종료.

### Step 2: ahead/behind 판단

`git status -sb`의 `[ahead N, behind M]`로 4가지 경우를 구분한다:

| 상태 | 의미 | 처리 |
|------|------|------|
| up to date | 동일 | 동기화 불필요, 종료 |
| behind만 | 리모트가 앞섬 | **Step 3 (받아오기)** |
| ahead만 | 로컬이 앞섬 | 받아올 것 없음. push 여부 안내 |
| 양쪽 (diverged) | 갈라짐 | **Step 4 (분기 처리)** |

### Step 3: 받아오기 (behind)

먼저 들어올 커밋이 로컬 변경 파일과 겹치는지 확인:

```bash
git diff --name-only HEAD @{u}            # 들어올 변경 파일
git status -s                             # 로컬 변경 파일
```

- **겹치지 않으면** → fast-forward로 안전:
  ```bash
  git pull --ff-only
  ```
  (미커밋 변경은 그대로 보존됨)

- **겹치면** → 충돌 위험. 사용자에게 알리고 선택받는다:
  - 로컬 변경을 stash 후 pull, 다시 pop (`git stash` → `git pull --ff-only` → `git stash pop`)
  - 또는 먼저 커밋(`/git-commit`)할지 제안

### Step 4: 분기 처리 (diverged)

로컬과 리모트가 갈라진 경우. 미커밋 변경이 있으면 먼저 정리(커밋 또는 stash)하도록 안내한 뒤:

```bash
git pull --rebase
```

rebase 충돌이 나면 충돌 파일을 보고하고, 자동 해결하지 말고 사용자와 함께 해결한다.
(`git rebase --abort`로 안전하게 되돌릴 수 있음을 안내)

### Step 5: 결과 보고

```
✅ 동기화 완료

📍 브랜치: main
⬇️ 받은 커밋: 1개 (3b57984..1055a93)
   - docs: add 폐쇄망 한국어 문서검색 앱 아키텍처

📌 보존된 로컬 변경 (미커밋):
   ~ docs/etc/tool/foo.mdx (수정)
   + docs/etc/tool/bar.mdx (신규)

다음 단계: 로컬 변경을 올리려면 /docs-publish 또는 /git-commit
```

## Guidelines

- pull 후에는 항상 `git status -sb`로 최종 상태를 확인해 보고한다.
- 미커밋 변경이 보존되었는지 명시적으로 보고한다.
- 동기화는 "받아오기"가 기본이다. push는 사용자가 명시적으로 요청할 때만 (`/docs-publish` 등 활용).
- study-dev 같은 문서 프로젝트에서는 받아온 뒤 충돌 없이 로컬 변경이 남아 있는 게 정상이다.
