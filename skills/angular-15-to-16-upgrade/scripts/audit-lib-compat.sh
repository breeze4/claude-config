#!/bin/bash
# Audit an Nx library for Angular 15→16 upgrade readiness
# Usage: ./audit-lib-compat.sh <lib-path>
#
# Checks:
# - Current peerDependencies versions
# - Deprecated API usage that's removed in Ng16
# - Class-based guards (deprecated in Ng16)
# - Third-party dependencies that may block upgrade

set -e

LIB_PATH="${1:-.}"

if [[ ! -d "$LIB_PATH" ]]; then
    echo "Error: Directory not found: $LIB_PATH"
    exit 1
fi

PACKAGE_JSON="$LIB_PATH/package.json"
SRC_PATH="$LIB_PATH/src"

echo "========================================"
echo "Angular 15→16 Compatibility Audit"
echo "Library: $LIB_PATH"
echo "========================================"
echo

# Check if package.json exists
if [[ ! -f "$PACKAGE_JSON" ]]; then
    echo "Warning: No package.json found at $PACKAGE_JSON"
    echo "This may be a buildable lib without its own package.json."
    echo "Check the root package.json for peerDependencies."
    echo
fi

# 1. Check peerDependencies
echo "## PeerDependencies"
echo "-------------------"
if [[ -f "$PACKAGE_JSON" ]]; then
    if command -v jq &> /dev/null; then
        PEER_DEPS=$(jq -r '.peerDependencies // {} | to_entries[] | "\(.key): \(.value)"' "$PACKAGE_JSON" 2>/dev/null || echo "")
        if [[ -n "$PEER_DEPS" ]]; then
            echo "$PEER_DEPS"
            echo
            # Check for exact Angular 15 pins
            if echo "$PEER_DEPS" | grep -q "@angular.*\^15\|@angular.*~15"; then
                echo "⚠  Angular peerDeps are pinned to 15.x"
                echo "   Action: Widen to '^15.0.0 || ^16.0.0'"
            elif echo "$PEER_DEPS" | grep -q "@angular.*16"; then
                echo "✓ Already includes Angular 16 support"
            fi
        else
            echo "No peerDependencies found."
        fi
    else
        echo "Install jq for detailed analysis. Showing raw:"
        grep -A 20 '"peerDependencies"' "$PACKAGE_JSON" | head -20 || echo "None found"
    fi
else
    echo "Skipped (no package.json)"
fi
echo

# 2. Check for removed APIs in Ng16
echo "## Removed APIs (Must Fix)"
echo "--------------------------"

REMOVED_APIS=(
    "entryComponents"
    "ANALYZE_FOR_ENTRY_COMPONENTS"
    "ReflectiveInjector"
    "addGlobalEventListener"
    "moduleId"
)

FOUND_REMOVED=0

if [[ -d "$SRC_PATH" ]]; then
    for pattern in "${REMOVED_APIS[@]}"; do
        MATCHES=$(grep -r --include="*.ts" -l "$pattern" "$SRC_PATH" 2>/dev/null || true)
        if [[ -n "$MATCHES" ]]; then
            echo "⚠  Found '$pattern' in:"
            echo "$MATCHES" | sed 's/^/   /'
            FOUND_REMOVED=$((FOUND_REMOVED + 1))
        fi
    done

    if [[ $FOUND_REMOVED -eq 0 ]]; then
        echo "✓ No removed APIs detected"
    fi
else
    echo "Skipped (no src directory)"
fi
echo

# 3. Check for deprecated APIs (auto-migrated or deprecated)
echo "## Deprecated APIs (Review)"
echo "---------------------------"

DEPRECATED_PATTERNS=(
    "runInContext"
    "ComponentFactoryResolver"
)

FOUND_DEPRECATED=0

if [[ -d "$SRC_PATH" ]]; then
    for pattern in "${DEPRECATED_PATTERNS[@]}"; do
        MATCHES=$(grep -r --include="*.ts" -l "$pattern" "$SRC_PATH" 2>/dev/null || true)
        if [[ -n "$MATCHES" ]]; then
            echo "ℹ  Found '$pattern' in:"
            echo "$MATCHES" | sed 's/^/   /'
            if [[ "$pattern" == "runInContext" ]]; then
                echo "   Note: Auto-migrated by ng update schematic"
            fi
            FOUND_DEPRECATED=$((FOUND_DEPRECATED + 1))
        fi
    done

    if [[ $FOUND_DEPRECATED -eq 0 ]]; then
        echo "✓ No deprecated APIs detected"
    fi
else
    echo "Skipped (no src directory)"
fi
echo

# 4. Check for class-based guards (deprecated in Ng16)
echo "## Class-Based Guards (Deprecated)"
echo "-----------------------------------"

if [[ -d "$SRC_PATH" ]]; then
    GUARD_MATCHES=$(grep -r --include="*.ts" -l "implements CanActivate\|implements CanDeactivate\|implements CanLoad\|implements Resolve" "$SRC_PATH" 2>/dev/null || true)
    if [[ -n "$GUARD_MATCHES" ]]; then
        echo "ℹ  Class-based guards found (deprecated in Ng16):"
        echo "$GUARD_MATCHES" | sed 's/^/   /'
        echo "   Recommendation: Migrate to functional guards"
    else
        echo "✓ No class-based guards detected"
    fi
else
    echo "Skipped (no src directory)"
fi
echo

# 5. Check for View Engine remnants
echo "## Ivy Compatibility"
echo "--------------------"
if [[ -d "$SRC_PATH" ]]; then
    VE_PATTERNS=$(grep -r --include="*.ts" -l "enableIvy.*false" "$SRC_PATH" 2>/dev/null || true)
    if [[ -n "$VE_PATTERNS" ]]; then
        echo "⚠  Possible View Engine references found:"
        echo "$VE_PATTERNS" | sed 's/^/   /'
    else
        echo "✓ No View Engine compatibility code detected"
    fi
else
    echo "Skipped (no src directory)"
fi
echo

# 6. Check third-party Angular deps
echo "## Third-Party Angular Dependencies"
echo "------------------------------------"
if [[ -f "$PACKAGE_JSON" ]] && command -v jq &> /dev/null; then
    ANGULAR_ECOSYSTEM=(
        "@ngrx"
        "@angular/material"
        "@angular/cdk"
        "ngx-"
        "@ngx-"
        "primeng"
        "ng-"
    )

    ALL_DEPS=$(jq -r '(.dependencies // {}) + (.peerDependencies // {}) | keys[]' "$PACKAGE_JSON" 2>/dev/null || echo "")

    THIRD_PARTY_FOUND=0
    for pkg_pattern in "${ANGULAR_ECOSYSTEM[@]}"; do
        MATCHING=$(echo "$ALL_DEPS" | grep "$pkg_pattern" || true)
        if [[ -n "$MATCHING" ]]; then
            echo "$MATCHING" | while read -r pkg; do
                VERSION=$(jq -r ".dependencies[\"$pkg\"] // .peerDependencies[\"$pkg\"] // \"?\"" "$PACKAGE_JSON")
                echo "   $pkg: $VERSION"
            done
            THIRD_PARTY_FOUND=1
        fi
    done

    if [[ $THIRD_PARTY_FOUND -eq 0 ]]; then
        echo "✓ No third-party Angular ecosystem deps found"
    else
        echo
        echo "   Action: Verify these packages support Angular 16"
    fi
else
    echo "Skipped (no package.json or jq not installed)"
fi
echo

# 7. Summary
echo "========================================"
echo "Summary"
echo "========================================"

TOTAL_ISSUES=$((FOUND_REMOVED + FOUND_DEPRECATED))

if [[ $FOUND_REMOVED -gt 0 ]]; then
    echo "❌ $FOUND_REMOVED removed API(s) - must fix before upgrade"
fi

if [[ $FOUND_DEPRECATED -gt 0 ]]; then
    echo "ℹ  $FOUND_DEPRECATED deprecated API(s) - review recommended"
fi

if [[ $TOTAL_ISSUES -eq 0 ]]; then
    echo "✓ Library appears ready for dual-compat upgrade"
    echo "   Next steps:"
    echo "   1. Widen peerDependencies to '^15.0.0 || ^16.0.0'"
    echo "   2. Test with both Angular versions"
fi
