---
name: init-docker-dangerous
description: Docker 컨테이너에서 Claude Code --dangerously-skip-permissions 모드를 실행하기 위한 환경을 초기화하고, 프로젝트의 기능을 구현한 뒤 결과를 MD 파일로 저장합니다.
disable-model-invocation: true
---

# Docker Claude Dangerous Mode 초기화 및 실행

현재 프로젝트 디렉토리에 Docker 기반 Claude Code dangerous mode 실행 환경을 설정하고, 기능 구현까지 수행합니다.

## Phase 0: speckit 문서 확인 (GATE)

**이 단계는 Phase 1 시작 전에 반드시 실행해야 한다. 설계 없이 구현하지 않는다.**

spec-kit 표준 폴더 구조를 기준으로 파일 존재 여부와 완성도를 확인한다:

```
.specify/
└── memory/
    └── constitution.md      ← 프로젝트 헌법 (필수)

specs/
└── {###-feature-name}/
    ├── spec.md              ← 기능 명세 (필수)
    ├── plan.md              ← 구현 계획 (필수)
    └── tasks.md             ← 태스크 목록 (권장)
```

| 파일 | 경로 | 필수 여부 |
|------|------|-----------|
| Constitution | `.specify/memory/constitution.md` | 필수 |
| Spec | `specs/*/spec.md` | 필수 |
| Plan | `specs/*/plan.md` | 필수 |
| Tasks | `specs/*/tasks.md` | 권장 |

**판단 기준:**

- **Constitution이 없는 경우**: 중단. `/speckit.constitution`을 먼저 실행하도록 안내한다.
- **Spec이 없는 경우**: 중단. `/speckit.specify`를 먼저 실행하도록 안내한다.
- **Plan이 없는 경우**: 중단. `/speckit.plan`을 먼저 실행하도록 안내한다.
- **Tasks가 없는 경우**: 경고만 출력하고 진행 허용 (plan 기반으로 구현 가능).
- **모든 필수 파일이 있는 경우**: 각 파일의 핵심 내용을 요약하여 사용자에게 보여주고
  "이 설계를 기반으로 Docker 환경을 구성하고 구현을 진행할까요?"라고 확인한다.

## Phase 1: 환경 설정

### 1. 기존 파일 확인
- `Dockerfile.claude`와 `docker-compose.claude.yml`이 이미 존재하는지 확인
- 이미 존재하면 사용자에게 덮어쓸지 확인

### 2. 인증 방식: Claude Max (기본)

Claude Max 사용자를 기본으로 한다. 호스트의 `~/.claude/` 디렉토리를 컨테이너에 마운트하여 인증을 공유한다.

- 호스트의 `~/.claude/` 디렉토리를 컨테이너의 `/home/claude/.claude`에 마운트
- `--dangerously-skip-permissions` 플래그가 권한 설정을 무시하므로 별도 settings.json 불필요
- `.env`에 `ANTHROPIC_API_KEY` 불필요
- Windows에서 Git Bash 사용 시 경로 변환 방지를 위해 `MSYS_NO_PATHCONV=1` 환경변수를 docker 명령 앞에 붙여야 한다

### 3. Dockerfile.claude 생성

**중요**: 컨테이너 내부에서는 root로 실행한다. 컨테이너 자체가 샌드박스 역할을 하므로,
별도 사용자를 만들면 Docker volume 권한 문제(node_modules 등)가 발생한다.

```dockerfile
FROM node:20

RUN npm install -g @anthropic-ai/claude-code pnpm typescript

# Git 설정
RUN git config --global user.name "Docker Claude" && \
    git config --global user.email "claude@docker.local"

# Claude Code 설정 디렉토리 (호스트의 ~/.claude가 마운트됨)
RUN mkdir -p /root/.claude

WORKDIR /workspace

CMD ["bash"]
```

### 4. docker-compose.claude.yml 생성

- `container_name`을 프로젝트 디렉토리 이름 기반으로 설정: `{프로젝트명}-claude`
- 프로젝트 이름은 현재 디렉토리의 basename으로 결정 (예: `zoomlike` → `zoomlike-claude`)

**Claude Max 사용자용 (호스트 인증 마운트):**

```yaml
services:
  claude:
    container_name: ${PROJECT_NAME}-claude
    build:
      context: .
      dockerfile: Dockerfile.claude
    volumes:
      - .:/workspace
      # Claude Max 인증 정보 마운트 (호스트의 로그인 세션 공유)
      - ${USERPROFILE}/.claude:/home/claude/.claude
      - ${USERPROFILE}/.claude.json:/home/claude/.claude.json
    env_file:
      - .env
    stdin_open: true
    tty: true
    # 컨테이너 샌드박스 보안 설정
    cap_drop:
      - ALL
    cap_add:
      - CHOWN
      - SETUID
      - SETGID
      - DAC_OVERRIDE
    security_opt:
      - no-new-privileges:true
    read_only: false
    tmpfs:
      - /tmp:size=256m
```

**주의**: `node_modules`용 Docker named volume을 사용하지 않는다. Named volume은 root 소유로 생성되어 claude 사용자가 쓸 수 없는 권한 문제가 발생한다. `node_modules`는 workspace에 직접 생성된다.

**참고**: `${PROJECT_NAME}`은 실제 생성 시 프로젝트 디렉토리 이름으로 치환하여 하드코딩합니다.

**샌드박스 설계 원칙:**
- 컨테이너 = 샌드박스: Claude Code의 `--dangerously-skip-permissions`는 컨테이너 내부에서만 동작
- `cap_drop: ALL` + 필요한 최소 capability만 추가 → 호스트 시스템 보호
- `no-new-privileges` → 권한 상승 방지
- `tmpfs /tmp` → 임시 파일 격리
- `--dangerously-skip-permissions` 플래그가 모든 도구를 허용 → 별도 settings.json 불필요

### 5. .env 파일 확인
- `.env` 파일이 없으면 빈 `.env` 파일을 생성 (docker-compose에서 env_file 참조 에러 방지)
- Claude Max 사용자이므로 `ANTHROPIC_API_KEY` 항목 불필요 (호스트 인증 마운트로 대체)
- `.gitignore`에 `.env`가 없으면 추가

### 6. .gitignore 업데이트
- `.gitignore`에 다음 항목이 없으면 추가:
  - `.env`
  - `Dockerfile.claude`
  - `docker-compose.claude.yml`
  - `.claude-output/`

### 6. Docker 이미지 빌드 (조건부)
- 먼저 이미지가 이미 존재하는지 확인:
```bash
docker images --filter "reference={프로젝트명}-claude" --format "{{.ID}}"
```
- **이미지가 존재하고 Dockerfile.claude가 변경되지 않은 경우**: 빌드 스킵
- **이미지가 없거나 Dockerfile.claude가 변경된 경우**: 빌드 실행
```bash
docker compose -f docker-compose.claude.yml build
```

## Phase 2: 기능 구현 실행

### 7. 기존 컨테이너 확인
- 실행 전 동일 이름의 컨테이너가 이미 존재하는지 확인

```bash
docker ps -a --filter "name={프로젝트명}-claude" --format "{{.ID}} {{.Status}}"
```

- **실행 중(Up)인 경우**: 사용자에게 선택지 제공
  - "기존 컨테이너에 접속 (docker exec)"
  - "기존 컨테이너 중지 후 새로 실행"
  - "취소"
- **중지 상태(Exited)인 경우**: 자동으로 제거 후 새로 실행
  ```bash
  docker rm {프로젝트명}-claude
  ```
- **존재하지 않는 경우**: 그대로 진행

### 8. 구현 프롬프트 준비

**speckit 설계 문서를 반드시 먼저 읽어야 한다.** 구현은 이 문서들을 근거로 해야 하며, 추측이나 임의 판단으로 구현하지 않는다.

읽어야 할 파일 (존재하는 것만):
1. `.specify/memory/constitution.md` — 변하지 않는 원칙 (NON-NEGOTIABLE 항목 파악)
2. `specs/*/spec.md` — 기능 요구사항 (유저 스토리, 수용 기준)
3. `specs/*/plan.md` — 기술 구현 계획
4. `specs/*/tasks.md` — 구체적 작업 목록 (있으면 이것을 최우선으로 따름)
5. `CLAUDE.md` — 프로젝트별 AI 지시사항
6. `AGENTS.md` — AI 에이전트 지시사항

**프롬프트 구성 규칙:**
- tasks.md가 있으면: 완료되지 않은(`- [ ]`) 태스크를 순서대로 구현하도록 지시
- tasks.md가 없고 plan.md가 있으면: plan의 Phase 순서대로 구현하도록 지시
- 사용자가 직접 프롬프트를 제공한 경우: 해당 내용에 speckit 문서 컨텍스트를 추가
- 어떤 경우에도 constitution의 NON-NEGOTIABLE 원칙을 프롬프트에 명시

사용자에게 확인:
- 읽은 설계 문서를 요약하여 "이 내용을 기반으로 구현할까요?"라고 확인
- 사용자가 수정하거나 다른 작업을 지정하면 그에 따름

### 9. Docker 컨테이너에서 Claude Code 실행
- 컨테이너를 실행하고 Claude Code를 `--dangerously-skip-permissions` 모드로 실행
- `-p` 플래그로 구현 프롬프트를 전달하고 `--output-format stream-json`으로 결과를 캡처
- 프롬프트는 반드시 speckit 설계 문서(constitution, spec, plan, tasks)를 근거로 구성한다
- `--name` 플래그 대신 `container_name`이 compose에 설정되어 있으므로 `--rm` 사용 시 주의

프롬프트 구성 예시:
```
다음 speckit 설계 문서를 기반으로 구현을 진행해:

1. Constitution 원칙 준수 (.specify/memory/constitution.md 참조)
2. Spec 요구사항: [spec.md에서 읽은 유저 스토리 요약]
3. 구현 대상: [plan.md 또는 tasks.md에서 읽은 작업 목록]

tasks.md가 있으면 완료되지 않은 태스크(- [ ])를 순서대로 구현하고,
각 태스크 완료 시 - [x]로 체크해.
```

```bash
docker compose -f docker-compose.claude.yml run --rm claude \
  claude --dangerously-skip-permissions \
    -p "구현 프롬프트 내용" \
    --output-format stream-json \
    2>&1 | tee /workspace/.claude-output/raw-output.jsonl
```

- 타임아웃: 최대 10분 (600000ms)
- 실행 전 출력 디렉토리 생성: `mkdir -p .claude-output`
- `.claude-output/`을 `.gitignore`에 추가

### 10. 실행 결과를 MD 파일로 저장

실행 완료 후, 결과를 파싱하여 `.claude-output/result.md`에 저장합니다.

파일 형식:
```markdown
# Claude Dangerous Mode 실행 결과

- **실행 일시**: YYYY-MM-DD HH:MM
- **프롬프트**: (사용한 프롬프트 요약)
- **소요 시간**: N초
- **종료 상태**: 성공/실패

## 변경된 파일
- `path/to/file1` — 설명
- `path/to/file2` — 설명

## 실행 요약
(Claude의 최종 응답 텍스트)

## 에러/경고
(있으면 기록, 없으면 "없음")
```

### 11. 추가 필요 조치를 MD 파일로 저장

실행 결과를 분석하여 `.claude-output/follow-up.md`에 후속 조치를 저장합니다.

파일 형식:
```markdown
# 추가 필요 조치

## 수동 확인 필요
- [ ] 항목1: 설명
- [ ] 항목2: 설명

## 추가 구현 필요
- [ ] 항목1: 설명

## 테스트 필요
- [ ] 항목1: 설명

## 환경 설정 필요
- [ ] 항목1: 설명 (예: API 키 설정, 외부 서비스 등)
```

분석 기준:
- 구현되지 않은 spec 항목이 있는지 확인
- 에러나 경고가 발생했는지 확인
- 테스트가 필요한 부분 식별
- 환경 변수나 외부 서비스 설정이 필요한지 확인
- 보안 관련 주의사항이 있는지 확인

## Phase 3: 완료 메시지

### 12. 완료 메시지 출력

```
✅ Docker Claude Dangerous Mode 실행 완료!

📄 결과 파일:
  .claude-output/result.md      — 실행 결과 요약
  .claude-output/follow-up.md   — 추가 필요 조치

수동 실행 방법:
  docker compose -f docker-compose.claude.yml run --rm claude bash

컨테이너 안에서:
  claude login              # 최초 1회
  claude --dangerously-skip-permissions

이미지 재빌드 (Claude Code 업데이트 시):
  docker compose -f docker-compose.claude.yml build --no-cache
```
