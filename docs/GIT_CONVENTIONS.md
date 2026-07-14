# Git Conventions

## Branch Naming
- feature/short-description
- fix/short-description
- chore/short-description
- release/v1.0.0

## Commit Messages (Conventional Commits)
Format: type(scope): description

Types: feat, fix, docs, style, refactor, test, chore, ci, perf

Examples:
- feat(pos): add barcode scanner integration
- fix(sync): resolve conflict on inventory update
- chore(deps): upgrade supabase_flutter to 2.9.0

## Pull Requests
- One feature per PR
- Include test plan checklist
- Link related issues
- Require CI pass before merge

## Tags
- Semantic versioning: v1.0.0, v1.1.0, v2.0.0
- Pre-release: v1.0.0-beta.1

## Protected Files
Never commit: .env, credentials, API keys, service_role keys
