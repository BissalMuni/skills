---
name: init-speckit
description: Initialize a new project with spec-kit (Spec-Driven Development). Use when user runs /init-speckit.
---

# Initialize Project with spec-kit

spec-kit을 사용하여 새 프로젝트를 Spec-Driven Development 구조로 초기화한다.

## spec-kit이란?

GitHub이 만든 Spec-Driven Development 도구. AI 코딩 에이전트(Claude Code, Copilot, Gemini 등)와 함께 사용하기 위한 구조화된 개발 방법론.

- **Constitution**: 프로젝트의 변하지 않는 원칙 (비기능 요구사항, 기술 스택 등)
- **Specification**: 구체적인 기능 요구사항
- **Plan**: 기술적 구현 계획 (아키텍처, 의존성)

자세한 정보: https://github.com/github/spec-kit

## Workflow

### Step 1: 프로젝트 정보 수집

사용자에게 다음을 질문한다:

- 프로젝트 이름
- 프로젝트 설명 (한 줄)
- 프레임워크 선택 (Next.js / Vite React / Node.js / None)

### Step 2: 프로젝트 생성

프레임워크 선택에 따라 실행:

- **Next.js**: `pnpm create next-app@latest {name} --typescript --tailwind --eslint --app --src-dir`
- **Vite React**: `pnpm create vite {name} --template react-ts`
- **Node.js**: `mkdir {name} && cd {name} && pnpm init`
- **None**: `mkdir {name} && cd {name} && pnpm init`

### Step 3: spec-kit 초기화

```bash
cd {name}
bunx @spec-kit/cli init . --assistant claude
```

bunx가 없으면 `npx @spec-kit/cli`로 대체한다.

spec-kit이 생성하는 파일:

```
.spec/
├── constitution.md    # 프로젝트 원칙 (기술 스택, 코딩 컨벤션, 비기능 요구사항)
├── spec.md            # 기능 명세 (유저 스토리, 요구사항)
└── plan.md            # 기술 계획 (아키텍처, 의존성, 구현 순서)

AGENTS.md              # AI 에이전트 지시사항
```

### Step 4: Claude Code 슬래시 커맨드 생성

`.claude/commands/` 디렉토리에 spec-kit 워크플로우용 슬래시 커맨드를 생성한다.

생성할 파일:

```
.claude/commands/
├── speckit.constitution.md   # /speckit.constitution — 프로젝트 원칙 생성/수정
├── speckit.specify.md        # /speckit.specify — 기능 명세 작성
├── speckit.clarify.md        # /speckit.clarify — 모호한 요구사항 명확화
├── speckit.plan.md           # /speckit.plan — 구현 계획 수립
├── speckit.tasks.md          # /speckit.tasks — 작업 목록 생성
├── speckit.implement.md      # /speckit.implement — 계획 기반 구현
├── speckit.analyze.md        # /speckit.analyze — 교차 문서 일관성 분석
├── speckit.checklist.md      # /speckit.checklist — 요구사항 품질 체크리스트
└── speckit.taskstoissues.md  # /speckit.taskstoissues — GitHub Issue 변환
```

각 커맨드 파일 내용:

#### speckit.constitution.md

```markdown
---
description: Create or update project constitution (governing principles, tech stack, conventions)
---

# Constitution 워크플로우

## 입력

\`\`\`text
$ARGUMENTS
\`\`\`

사용자 입력이 있으면 반영한다 (없으면 대화형으로 진행).

## 절차

1. `.spec/constitution.md`를 읽는다 (없으면 새로 생성).
2. 사용자와 대화하여 다음을 정의한다:
   - 기술 스택 및 프레임워크
   - 코딩 컨벤션 (언어, 스타일, 네이밍)
   - 비기능 요구사항 (성능, 보안, 접근성)
   - 프로젝트 제약 조건
3. `.spec/constitution.md`에 결과를 기록한다.
4. `CLAUDE.md`에 관련 지시사항을 반영한다.
```

#### speckit.specify.md

```markdown
---
description: Define feature specifications with user stories and requirements
---

# Specification 워크플로우

## 입력

\`\`\`text
$ARGUMENTS
\`\`\`

사용자 입력이 있으면 반영한다.

## 절차

1. `.spec/constitution.md`를 읽어 프로젝트 원칙을 파악한다.
2. `.spec/spec.md`를 읽는다 (없으면 새로 생성).
3. 사용자와 대화하여 기능 요구사항을 정의한다:
   - 유저 스토리 (As a... I want... So that...)
   - 기능 요구사항 (구체적, 측정 가능)
   - 성공 기준
   - 불명확한 부분은 [NEEDS CLARIFICATION]으로 표시 (최대 3개)
4. `.spec/spec.md`에 결과를 기록한다.
5. **WHAT과 WHY**에 집중하고, **HOW**는 포함하지 않는다.
```

#### speckit.clarify.md

```markdown
---
description: Clarify ambiguous or underspecified areas in the feature spec
---

# Clarify 워크플로우

## 입력

\`\`\`text
$ARGUMENTS
\`\`\`

사용자 입력이 있으면 반영한다.

## 절차

1. `.spec/spec.md`를 읽는다.
2. `.spec/constitution.md`를 읽어 프로젝트 원칙을 파악한다.
3. spec에서 모호하거나 불완전한 부분을 자동 탐지한다:
   - 기능 범위, 데이터 모델, UX/UI, 비기능 요구사항, 에지 케이스
4. 탐지된 모호한 부분에 대해 최대 5개의 대화형 질문을 한다.
5. 사용자 답변을 `.spec/spec.md`의 `## Clarifications` 섹션에 기록한다.
6. 우선순위: 범위 > 보안 > UX > 기술적 세부사항
```

#### speckit.plan.md

```markdown
---
description: Create technical implementation plan based on spec
---

# Plan 워크플로우

## 입력

\`\`\`text
$ARGUMENTS
\`\`\`

사용자 입력이 있으면 반영한다.

## 절차

1. `.spec/constitution.md`와 `.spec/spec.md`를 읽는다.
2. `.spec/plan.md`를 읽는다 (없으면 새로 생성).
3. 다음을 설계한다:
   - 아키텍처 개요
   - 파일 구조
   - 의존성 목록
   - 구현 순서 (우선순위별)
   - 기술적 결정 사항과 근거
4. constitution 원칙과의 정합성을 검증한다.
5. `.spec/plan.md`에 결과를 기록한다.
```

#### speckit.tasks.md

```markdown
---
description: Generate actionable task list from the implementation plan
---

# Tasks 워크플로우

## 입력

\`\`\`text
$ARGUMENTS
\`\`\`

사용자 입력이 있으면 반영한다.

## 절차

1. `.spec/plan.md`와 `.spec/spec.md`를 읽는다.
2. `.spec/tasks.md`를 생성한다.
3. plan을 실행 가능한 작업 목록으로 분해한다:
   - 형식: `- [ ] [T001] 작업 설명 (파일 경로)`
   - Phase별 그룹핑: Setup → Core → Features → Polish
   - 의존성 순서 고려
   - 각 작업은 독립적으로 실행/검증 가능해야 한다
4. 작업 수와 예상 Phase를 요약 보고한다.
```

#### speckit.implement.md

```markdown
---
description: Execute implementation based on plan and tasks
---

# Implement 워크플로우

## 입력

\`\`\`text
$ARGUMENTS
\`\`\`

사용자 입력이 있으면 반영한다.

## 절차

1. `.spec/` 디렉토리의 모든 파일을 읽는다 (constitution, spec, plan, tasks).
2. tasks.md가 있으면 작업 목록을 따라 구현한다. 없으면 plan.md를 기반으로 구현한다.
3. 구현 규칙:
   - constitution 원칙을 준수한다
   - Phase 순서대로 진행한다 (Setup → Core → Features → Polish)
   - 각 작업 완료 시 tasks.md에서 체크한다: `- [x]`
   - 테스트가 필요한 경우 vitest로 작성한다
4. 구현 완료 후 spec 기준으로 검증한다.
5. 진행 상황을 보고한다.
```

#### speckit.analyze.md

```markdown
---
description: Cross-artifact consistency analysis (read-only)
---

# Analyze 워크플로우

## 입력

\`\`\`text
$ARGUMENTS
\`\`\`

사용자 입력이 있으면 반영한다.

## 절차

1. `.spec/` 디렉토리의 모든 파일을 읽는다 (constitution, spec, plan, tasks).
2. 교차 분석 수행: 중복, 모호성, 갭, Constitution 위반, 일관성 검증.
3. Markdown 보고서 출력: Severity별 분류 (CRITICAL / WARNING / INFO).
4. **읽기 전용**: 파일을 수정하지 않는다.
```

#### speckit.checklist.md

```markdown
---
description: Generate quality checklists to validate requirements completeness
---

# Checklist 워크플로우

## 핵심: 요구사항의 단위 테스트

체크리스트는 구현이 아닌 **요구사항의 품질**을 검증한다.

## 입력

\`\`\`text
$ARGUMENTS
\`\`\`

사용자 입력이 있으면 반영한다 (예: "ux", "security", "api").

## 절차

1. `.spec/` 디렉토리의 문서를 읽는다.
2. 체크리스트 범위를 결정한다 (도메인, 깊이).
3. `.spec/checklists/[domain].md`에 체크리스트를 생성한다.
4. 항목 형식: `- [ ] CHK001 - 질문 [품질 차원, 참조]`
5. 품질 차원: Completeness, Clarity, Consistency, Measurability, Coverage
```

#### speckit.taskstoissues.md

```markdown
---
description: Convert tasks into GitHub issues
---

# Tasks to Issues 워크플로우

## 입력

\`\`\`text
$ARGUMENTS
\`\`\`

사용자 입력이 있으면 반영한다.

## 절차

1. `.spec/tasks.md`를 읽어 작업 목록을 파싱한다.
2. Git remote URL이 GitHub인 경우에만 진행한다.
3. 각 작업에 대해 `gh issue create`로 GitHub Issue를 생성한다.
4. **절대로 remote URL과 다른 리포지토리에 Issue를 생성하지 않는다.**
```

### Step 5: CLAUDE.md 생성

프로젝트 루트에 CLAUDE.md를 생성하여 Claude Code 지시사항을 기록한다:

```markdown
# Project: {name}

- Use pnpm as package manager
- Use vitest for testing
- Follow spec-kit workflow: constitution → spec → plan → implement
- Refer to `.spec/` for project specifications
```

### Step 6: 공통 설정

```bash
# .gitignore에 .env 추가 확인
# git init (아직 안 되어 있으면)
git add -A && git commit -m "Initial project setup with spec-kit"
```

### Step 7: 결과 보고

생성된 프로젝트 구조를 요약하여 보여준다.

## spec-kit 워크플로우 안내

초기화 후 사용자에게 다음 워크플로우를 안내한다:

```
1. constitution 작성  →  프로젝트 원칙 정의
2. spec 작성          →  기능 요구사항 정의
3. plan 작성          →  기술 구현 계획
4. implement          →  AI 에이전트가 plan 기반으로 코드 생성
5. validate           →  spec 기준으로 검증
```

## Guidelines

- 패키지 매니저는 항상 pnpm을 사용한다
- 테스트 프레임워크는 vitest를 기본으로 한다
- spec-kit 초기화는 반드시 프로젝트 생성 후에 실행한다
- 커밋 메시지는 영어로 작성한다
