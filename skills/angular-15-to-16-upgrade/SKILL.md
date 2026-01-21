---
name: angular-15-to-16-upgrade
description: Guide for incrementally upgrading Nx library peerDependencies from Angular 15 to support both 15 and 16. Use when upgrading Angular libraries in a monolith, making libs dual-compatible, or preparing for Angular 16 migration.
allowed-tools: Read, Write, Edit, Bash, Glob, Grep
---

# Angular 15→16 Library Upgrade (Incremental)

Guide for upgrading Nx libraries to be dual-compatible with Angular 15 and 16.

## Strategy

Upgrade libraries one at a time while apps remain on Ng15. Libraries use widened peerDependencies to support both versions during transition.

## Breaking Changes Summary

| Area | Ng15 | Ng16 | Notes |
|------|------|------|-------|
| Node.js | 14.20+ | 16.14+ | Build env only |
| TypeScript | 4.8-4.9 | 4.9.3-5.0 | May need code fixes |
| Zone.js | 0.12+ | 0.13+ | Usually transparent |
| ngcc | Used | **Removed** | #1 blocker - must be Ivy-only |

## Prepare Ahead (Do While Still on Ng15)

These changes are safe to make now and will ease the final migration.

### 1. Remove Deprecated APIs (Removed in Ng16)

| API | Action | Schematic? |
|-----|--------|-----------|
| `entryComponents` | Remove from `@NgModule`/`@Component` (does nothing) | No - manual |
| `ANALYZE_FOR_ENTRY_COMPONENTS` | Remove references | No - manual |
| `ReflectiveInjector` | Replace with `Injector.create()` | No - manual |
| `EventManager.addGlobalEventListener` | Remove if used | No - manual |
| `@Directive/@Component moduleId` | Remove (no effect, removed in v17) | No - manual |

### 2. Verify All Deps Are Ivy-Only

**ngcc removal is the #1 migration blocker.** View Engine libraries won't work in Ng16.

```bash
# Check for View Engine packages
grep -r "__ivy_ngcc__" node_modules/*/package.json
grep -r "ngcc" node_modules/*/package.json
```

If any deps still need ngcc, contact maintainers or find alternatives before upgrading.

### 3. Migrate Class Guards to Functional (Optional but Recommended)

Class-based guards/resolvers are deprecated in Ng16. Refactor now for both versions:

```typescript
// OLD: Class-based (deprecated in Ng16)
@Injectable({ providedIn: 'root' })
export class AuthGuard implements CanActivate {
  constructor(private auth: AuthService) {}
  canActivate(): boolean {
    return this.auth.isLoggedIn();
  }
}

// NEW: Functional (works in Ng15 and Ng16)
export const authGuard: CanActivateFn = () => {
  return inject(AuthService).isLoggedIn();
};
```

### 4. Widen PeerDeps (Safe Now)

This doesn't break Ng15 consumers:

```json
"peerDependencies": {
  "@angular/core": "^15.0.0 || ^16.0.0",
  "@angular/common": "^15.0.0 || ^16.0.0",
  "@angular/router": "^15.0.0 || ^16.0.0"
}
```

### 5. Update Third-Party Ecosystem Libs

Check Ng16 support for:
- `@ngrx/*`
- `@angular/material` / `@angular/cdk`
- `ngx-*` or `@ngx-*` packages
- `primeng`, etc.

## Automatic Schematics (Run During `ng update`)

| Change | Auto-migrated? |
|--------|---------------|
| `runInInjectionContext` API change | **Yes** |
| Standalone component conversion | **Yes** (`ng g @angular/core:standalone`) |
| Router guards to functional | Partial - detected, may need review |
| `entryComponents` removal | No - manual (trivial) |
| `ReflectiveInjector` replacement | No - manual |

## API Changes Reference

### runInInjectionContext (Auto-migrated)

```typescript
// Ng15
injector.runInContext(() => { ... });

// Ng16
import { runInInjectionContext } from '@angular/core';
runInInjectionContext(injector, () => { ... });
```

**No manual work needed** - `ng update` handles this automatically.

### New Optional APIs (Adopt When Ready)

These are new in Ng16 but not required for compatibility:

- **`DestroyRef`** - Cleaner cleanup pattern
- **Input transforms** - Transform decorator inputs
- **Standalone components** - Optional, NgModules still supported

## Pre-flight Audit

Run before upgrading any library:

```bash
./skills/angular-15-to-16-upgrade/scripts/audit-lib-compat.sh libs/my-lib
```

Checks:
- Current peerDependencies versions
- Deprecated API usage
- View Engine remnants
- Third-party Angular ecosystem deps

## Upgrade Procedure

### 1. Audit the Library

```bash
./skills/angular-15-to-16-upgrade/scripts/audit-lib-compat.sh libs/my-lib
```

### 2. Fix Blocking Issues (While on Ng15)

- Remove `entryComponents`, `ANALYZE_FOR_ENTRY_COMPONENTS`
- Replace `ReflectiveInjector` with `Injector.create()`
- Update or replace any View Engine deps

### 3. Widen PeerDeps

```json
"peerDependencies": {
  "@angular/core": "^15.0.0 || ^16.0.0",
  "@angular/common": "^15.0.0 || ^16.0.0"
}
```

### 4. Test Both Versions

**Option A: CI Matrix**
```yaml
strategy:
  matrix:
    angular: [15, 16]
steps:
  - run: npm install @angular/core@${{ matrix.angular }}
  - run: nx test my-lib
```

**Option B: Local Verification**
```bash
nx test my-lib  # Ng15

npm install @angular/core@16 @angular/common@16 --no-save
nx test my-lib  # Ng16
git checkout package-lock.json
```

### 5. Commit

```bash
git commit -m "feat(my-lib): support Angular 15 and 16"
```

## Full App Migration (When All Libs Ready)

Once all libraries are dual-compatible:

```bash
# Nx
nx migrate @angular/core@16
nx migrate --run-migrations

# Or Angular CLI
ng update @angular/core@16 @angular/cli@16
```

Then remove `^15.0.0 ||` from library peerDependencies.

## Troubleshooting

### ngcc errors / View Engine errors

Library still uses View Engine. Options:
- Update to newer version of the library
- Find alternative package
- Fork and recompile as Ivy-only

### "Cannot find module" errors

Third-party dep doesn't support Ng16:
- Check for updated version
- Use `overrides` in package.json as temporary workaround
- Find alternative

### Type errors after upgrade

TypeScript version mismatch. Ng16 requires TS 4.9.3+.

### Peer dependency conflicts

Use `--legacy-peer-deps` cautiously, or add `overrides`:
```json
"overrides": {
  "problematic-package": {
    "@angular/core": "$@angular/core"
  }
}
```
