---
name: docs-publish
description: study-dev 프로젝트의 새로운/변경된 문서를 GitHub에 커밋하고 푸시합니다. Use when user says "문서 올려줘", "배포해줘", "publish" or runs /docs-publish.
---

# 학습 문서 GitHub 배포

`study-dev` 프로젝트의 변경된 문서를 GitHub에 커밋하고 푸시한다.

## 전제 조건

- `study-dev` 프로젝트 경로: `~/Downloads/coding/study-dev`
- GitHub 리포: `BissalMuni/study-dev`
- `gh` CLI 인증 완료 상태

## 입력

```text
$ARGUMENTS
```

사용자 입력이 있으면 커밋 메시지로 반영한다.

## Workflow

### Step 1: 변경 사항 확인

```bash
cd ~/Downloads/coding/study-dev
git status
```

변경된 파일이 없으면 "배포할 변경 사항이 없습니다"라고 알리고 종료.

### Step 2: 변경 내용 분석

변경된 파일 목록을 분석한다:

- 새로 추가된 문서 (`.mdx` 파일)
- 수정된 문서
- 삭제된 문서
- 사이트 코드 변경 (`.tsx`, `.ts` 등)

### Step 3: 커밋 메시지 생성

변경 내용에 따라 커밋 메시지를 자동 생성:

- 문서 추가: `docs: add {제목} ({category})`
- 문서 수정: `docs: update {제목}`
- 복수 문서: `docs: add {N} new articles`
- 사이트 코드: `feat: {변경 내용 요약}`
- 혼합: `docs: add {문서} + fix: {코드 변경}`

### Step 4: 스테이징 및 커밋

```bash
cd ~/Downloads/coding/study-dev

# 문서 파일만 선택적 스테이징 (또는 전체)
git add docs/
# 사이트 코드 변경이 있으면 함께
git add src/ package.json

git commit -m "커밋 메시지"
```

### Step 5: 푸시

```bash
git push origin main
```

푸시 실패 시:
- 원격 변경이 있으면 `git pull --rebase` 후 재시도
- 인증 문제면 `gh auth status` 확인 안내

### Step 6: Vercel 배포 확인 (선택)

Vercel이 연결되어 있으면:
```bash
# Vercel 배포 상태 확인 (gh로는 불가, 별도 확인)
echo "Vercel 대시보드에서 배포 상태를 확인하세요"
```

### Step 7: 결과 보고

```
✅ 배포 완료!

📦 커밋: {commit hash} — {커밋 메시지}
📄 변경 파일:
  + docs/dev/backend/fullstack-layers.mdx (신규)
  ~ docs/dev/frontend/react-hooks.mdx (수정)

🔗 GitHub: https://github.com/BissalMuni/study-dev
🌐 사이트: {Vercel URL이 있으면 표시}
```

## Guidelines

- `docs/` 폴더 변경은 항상 `docs:` 접두사로 커밋
- 사이트 코드 변경은 별도 커밋으로 분리하는 것을 권장
- force push는 절대 하지 않는다
- 민감한 정보(API 키, 비밀번호 등)가 포함되지 않았는지 diff를 확인한다
