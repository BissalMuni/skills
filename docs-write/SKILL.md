---
name: docs-write
description: 현재 대화에서 공부한 내용을 MDX 문서로 작성하여 study-dev 프로젝트의 docs/ 폴더에 저장합니다. Use when user says "문서로 만들어줘", "정리해줘", "공부 내용 저장" or runs /docs-write.
---

# 학습 내용 MDX 문서 작성

현재 대화에서 학습한 내용을 MDX 문서로 정리하여 `study-dev` 프로젝트에 저장한다.

## 전제 조건

- `study-dev` 프로젝트 경로: `~/Downloads/coding/study-dev`
- 문서 저장 위치: `study-dev/docs/` 하위

## 입력

```text
$ARGUMENTS
```

사용자 입력이 있으면 반영한다 (카테고리, 제목, 범위 등).

## Workflow

### Step 1: 대화 내용 분석

현재 대화에서 학습한 내용을 분석한다:

- **주제 파악**: 무엇에 대해 학습했는가
- **카테고리 분류**: 다음 중 적절한 카테고리 선택
  - `dev/backend` — 백엔드 관련 (FastAPI, SQLAlchemy, DB 등)
  - `dev/frontend` — 프론트엔드 관련 (React, TypeScript, CSS 등)
  - `dev/devops` — 인프라/배포 관련 (Docker, Nginx, CI/CD 등)
  - `dev/fullstack` — 전체 스택에 걸친 내용
  - `etc/concept` — 일반 개발 개념
  - `etc/tool` — 도구 사용법
  - 사용자가 다른 카테고리를 지정하면 그에 따른다
- **핵심 내용 추출**: 코드 예시, 개념 설명, 다이어그램 등

### Step 2: 문서 메타데이터 결정

사용자에게 확인하거나 자동으로 결정:

- **title**: 한국어 제목 (간결하고 명확하게)
- **slug**: 영문 kebab-case 파일명 (예: `fullstack-layers`)
- **description**: 한 줄 설명
- **tags**: 관련 키워드 배열
- **date**: 오늘 날짜 (YYYY-MM-DD)

사용자가 별도 지정하지 않으면 대화 내용에서 자동 추론한다.

### Step 3: MDX 문서 작성

다음 형식으로 MDX 파일을 작성한다:

```mdx
---
title: "제목"
description: "한 줄 설명"
category: "dev/backend"
date: "YYYY-MM-DD"
tags: ["tag1", "tag2"]
---

# 제목

도입부 설명 (1-2문장)

## 핵심 개념

(대화에서 학습한 핵심 내용 정리)

## 상세 설명

### 소주제 1
(설명 + 코드 예시)

### 소주제 2
(설명 + 코드 예시)

## 실제 코드 예시

(현재 프로젝트에서 가져온 실제 코드 예시가 있으면 포함)

## 핵심 정리

> 요약 인용문 또는 핵심 포인트 정리
```

### Step 4: 문서 작성 규칙

1. **대화 내용 기반**: 대화에서 학습한 내용만 정리한다. 추가 검색이나 보충은 최소화.
2. **실제 코드 포함**: 현재 프로젝트의 실제 코드를 예시로 사용한다 (파일 경로 명시).
3. **한국어 작성**: 본문은 한국어로 작성. 코드, 기술 용어는 영문 유지.
4. **계층적 구조**: 제목(h1) → 섹션(h2) → 하위섹션(h3) 구조를 따른다.
5. **코드 블록**: 언어 태그 필수 (```python, ```typescript 등).
6. **다이어그램**: 텍스트 기반 다이어그램은 코드 블록으로 포함.
7. **간결함**: 불필요한 반복 없이 핵심만 정리.

### Step 5: 파일 저장

1. `study-dev` 프로젝트 경로 확인:
   ```bash
   ls ~/Downloads/coding/study-dev/docs/
   ```

2. 해당 카테고리 폴더에 MDX 파일 저장:
   ```
   study-dev/docs/{category}/{slug}.mdx
   ```
   예: `study-dev/docs/dev/backend/fullstack-layers.mdx`

3. 카테고리 폴더가 없으면 생성한다.

### Step 6: 결과 보고

```
✅ 문서 저장 완료!

📄 파일: docs/{category}/{slug}.mdx
📝 제목: {title}
🏷️ 태그: {tags}

로컬 확인: cd ~/Downloads/coding/study-dev && pnpm dev
배포: /docs-publish 실행
```

## 소스 프로젝트 코드 참조

현재 작업 중인 프로젝트(study-dev가 아닌 프로젝트)의 코드를 문서에 포함할 때:

1. 해당 프로젝트의 실제 파일을 읽어서 관련 코드를 추출한다.
2. 코드 블록에 원본 파일 경로를 주석으로 표시한다:
   ```python
   # 출처: law-matcher/backend/api/v1/departments.py
   @router.patch("/{dept_id}")
   async def update_department(...):
   ```
3. 전체 파일이 아닌, 학습에 필요한 부분만 발췌한다.

## Guidelines

- 문서 하나에 하나의 주제만 다룬다
- 너무 길지 않게 (200줄 이내 권장)
- 기존 문서와 중복되지 않도록 기존 docs/ 폴더를 먼저 확인한다
- 문서 저장만 하고 git commit/push는 하지 않는다 (/docs-publish가 담당)
