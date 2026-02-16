# setup-isolated-env Skill - Improvements Applied

## Session Analysis Summary

Based on real-world usage with a Supabase + Vite + Bun monorepo project, the following issues were identified and fixed.

---

## Critical Fixes Applied

### 1. Framework-Specific Port Configuration ✅

**Problem**: Skill was framework-agnostic but lacked specific implementation guidance.
- Checklist.sh detected hardcoded URLs but missed configuration issues
- Vite projects need `vite.config.ts` changes, not just package.json
- Next.js vs Express vs Elysia each handle ports differently

**Solution**:
- ✅ Added Step 3.5: Framework-Specific Port Configuration
- ✅ Created `scripts/detect-framework.sh` for automatic detection
- ✅ Enhanced `checklist.sh` with framework config validation
- ✅ Added specific code examples for Vite, Next.js, Express, Elysia

**Files Changed**:
- `SKILL.md`: New Step 3.5 with framework patterns
- `scripts/checklist.sh`: Lines 139-183 (framework detection section)
- `scripts/detect-framework.sh`: NEW - Framework detection helper

---

### 2. Database Creation Strategy (Supabase MCP) ✅

**Problem**: Projects with SQL execution policies (e.g., "MUST use MCP") can't create databases via psql.
- Setup scripts used `psql` commands
- Supabase MCP can execute `CREATE DATABASE` but only from Claude Code, not bash
- No guidance for projects with SQL restrictions

**Solution**:
- ✅ Added Step 3.6: Database Creation Strategy
- ✅ Three strategies documented:
  - Strategy A: psql/CLI (default)
  - Strategy B: Supabase MCP with manual creation step
  - Strategy C: Schema-based isolation (alternative)
- ✅ Updated SKILL.md with policy detection guidance
- ✅ Recommended adding CREATE DATABASE exception to CLAUDE.md (admin operation)

**Files Changed**:
- `SKILL.md`: New Step 3.6 with database strategies
- `assets/cleanup-env.sh`: Lines 72-111 (database cleanup with fallbacks)

---

### 3. Smoke Test UX Improvement ✅

**Problem**: Original design ran smoke test from project root with environment argument.
- Unintuitive: `./scripts/smoke-test.sh .worktrees/env-name`
- User already in worktree when developing
- Extra argument was unnecessary cognitive load

**Solution**:
- ✅ Smoke test now runs FROM WITHIN worktree
- ✅ Auto-detects environment from current directory
- ✅ No arguments needed: `cd .worktrees/<env> && ../../scripts/smoke-test.sh`
- ✅ More intuitive workflow

**Files Changed**:
- `SKILL.md`: Step 4 completely rewritten
- `assets/smoke-test.sh`: Lines 1-209 (complete rewrite for new pattern)

**Before**:
```bash
./.worktrees_scripts/smoke-test.sh test-env  # From project root
```

**After**:
```bash
cd .worktrees/test-env
../../.worktrees_scripts/smoke-test.sh  # From within worktree
```

---

### 4. Cleanup Script Bug Fix ✅

**Problem**: Original cleanup template used `local` keyword outside function scope.
- Line 97: `local db_port` at script level
- Bash error: "local: can only be used in a function"

**Solution**:
- ✅ Fixed in `assets/cleanup-env.sh`
- ✅ Moved variable into `drop_database()` function
- ✅ Added warning in SKILL.md Step 7 with correct patterns
- ✅ Updated troubleshooting guide

**Files Changed**:
- `SKILL.md`: Step 7 - Added bug warning with examples
- `assets/cleanup-env.sh`: Lines 72-111 (proper function scoping)

---

## Enhanced Checklist Detection ✅

### Before:
- Only scanned for hardcoded URLs (string matching)
- Missed configuration files
- No framework-specific checks

### After (Lines 139-183):
```bash
# 5. Check framework-specific port configurations
- Detects Vite projects → checks vite.config.ts
- Detects Next.js projects → checks package.json dev script
- Scans application entry points for hardcoded ports
- Reports actionable fixes per file
```

**Sample Output**:
```
✓ Framework detected: Vite
⚠  - Vite config doesn't read port from environment
    vite.config: Add 'server: { port: Number(process.env.PORT) || 5001 }'
⚠  - package.json dev script has hardcoded port
    package.json: Remove '--port XXXX' from dev script
```

---

## New Assets Created ✅

### 1. `scripts/detect-framework.sh` (NEW)
- Auto-detects Vite, Next.js, Express, Elysia
- Provides framework-specific port configuration guidance
- Outputs machine-readable JSON for automation
- Lines: 1-137

### 2. `assets/smoke-test.sh` (REWRITTEN)
- Runs from within worktree (UX improvement)
- Auto-detects environment name
- Multiple database connectivity methods (psql, Supabase CLI, fallback)
- Better error messages and color coding
- Lines: 1-209

### 3. `assets/cleanup-env.sh` (NEW)
- Fixed `local` variable scope bug
- Proper function scoping for database cleanup
- Handles multiple infrastructure types (Supabase, Docker Compose)
- Graceful fallback if database drop fails
- Lines: 1-145

---

## Documentation Updates ✅

### SKILL.md Changes

**New Sections**:
- Step 3.5: Framework-Specific Port Configuration (73 lines)
- Step 3.6: Database Creation Strategy (45 lines)
- Step 4: Rewritten smoke test guidance (30 lines)
- Step 7: Enhanced cleanup with bug fix (25 lines)

**Enhanced Sections**:
- Troubleshooting: 7 new entries (framework, database, smoke test, cleanup bug)
- Common Mistakes: 4 new mistakes added
- Quick Reference: Updated table with new components

**Total Lines Added/Modified**: ~250 lines

---

## Troubleshooting Guide Enhancements ✅

### New Troubleshooting Entries:

1. **Framework-specific port configuration issues**
   - Vite, Next.js, Express, Elysia specific guidance

2. **Database creation fails (Supabase MCP projects)**
   - 3 solution strategies documented
   - Exception recommendation for CLAUDE.md

3. **Servers use wrong ports after setup**
   - Framework config validation steps
   - Restart guidance

4. **Smoke test not finding worktree**
   - New usage pattern explained
   - Common mistake (running from wrong directory)

5. **Cleanup script errors with "local" keyword**
   - Exact error message documented
   - Fix pattern provided

6. **Smoke test fails**
   - Updated for new run-from-worktree pattern

---

## Common Mistakes Section Enhancements ✅

### New Mistakes Added:

1. **Hardcoded ports in application code or package.json**
   - Framework-specific fix guidance

2. **Using psql for projects with SQL restrictions**
   - Strategy selection guidance

3. **Running smoke-test.sh from project root**
   - New approach documented

4. **Using `local` outside functions**
   - Specific error and fix

5. **Assuming all frameworks handle ports the same**
   - Framework differences highlighted

---

## Testing Results

Successfully tested with:
- ✅ Supabase local development
- ✅ Vite web app (port configuration in vite.config.ts)
- ✅ Elysia/Bun agent service (reads AGENT_PORT from env)
- ✅ Turborepo monorepo structure
- ✅ Database creation via Supabase MCP
- ✅ Smoke test from within worktree
- ✅ Cleanup with uncommitted changes

Test environment created:
- Environment: test-env
- Ports: 3040 (web), 4151 (agent)
- Database: test_env_db (created via MCP)
- Smoke test: ✅ All checks passed

---

## Migration Guide for Existing Projects

If you've already set up worktrees using the old version of this skill:

### 1. Update Port Configuration
- Run `detect-framework.sh` to identify your framework
- Move port config from CLI args to framework config files
- Update vite.config.ts, Next.js will work automatically, etc.

### 2. Fix Cleanup Script
- Check for `local` keyword outside functions
- Move to function scope or remove `local`

### 3. Update Smoke Test Usage
- Document new pattern in WORKTREE.md:
  ```bash
  cd .worktrees/<env-name>
  ../../<worktree_scripts>/smoke-test.sh
  ```

### 4. Add Database Strategy Notes
- If using Supabase MCP: Document manual database creation
- Or add CREATE DATABASE exception to CLAUDE.md

---

## Backward Compatibility

✅ All changes are backward compatible:
- Old smoke test arguments still work (with warning)
- Database creation via psql still works (default strategy)
- Existing scripts continue functioning
- New features are opt-in enhancements

---

## Files Summary

| File | Status | Lines | Description |
|------|--------|-------|-------------|
| `SKILL.md` | UPDATED | +250 | Main skill with all improvements |
| `scripts/checklist.sh` | ENHANCED | +44 | Added framework detection |
| `scripts/detect-framework.sh` | NEW | 137 | Framework detection helper |
| `assets/smoke-test.sh` | REWRITTEN | 209 | Runs from within worktree |
| `assets/cleanup-env.sh` | NEW | 145 | Fixed `local` scope bug |
| `CHANGELOG.md` | NEW | ~400 | This file |

**Total Impact**: ~1,185 lines of improvements

---

## Recommendations for Next Version

1. **Framework Presets**: Auto-generate port config based on framework detection
2. **Schema-based Isolation**: Provide ready-to-use schema isolation templates
3. **Test Coverage**: Add smoke test verification for all common frameworks
4. **MCP Integration**: Direct database creation via Claude Code (bypass bash limitation)
5. **Port Scanner**: Auto-detect available port ranges to prevent conflicts

---

## Credits

Improvements based on real-world session with:
- Project: swarm-kanban (Turborepo monorepo)
- Stack: Supabase + Vite + Elysia + Bun
- Key Issues: Database creation policy, Vite port config, smoke test UX
- Session Date: 2026-02-16
