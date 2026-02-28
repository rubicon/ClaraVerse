#!/usr/bin/env bash
set -euo pipefail

# ============================================================================
# build-community.sh — Build ClaraVerse Community Edition from Scarlet
#
# Usage:
#   ./scripts/build-community.sh [--verify] [--dry-run] <target-directory>
#
# Strips cloud-only features (Supabase, telemetry, Turnstile, tours, feedback,
# device auth, insights) and sets up local JWT auth.
# ============================================================================

# --- Colors & helpers -------------------------------------------------------
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
CYAN='\033[0;36m'
BOLD='\033[1m'
NC='\033[0m'

info()  { echo -e "${BLUE}[INFO]${NC}  $*"; }
ok()    { echo -e "${GREEN}[OK]${NC}    $*"; }
warn()  { echo -e "${YELLOW}[WARN]${NC}  $*"; }
err()   { echo -e "${RED}[ERROR]${NC} $*"; }
phase() { echo -e "\n${CYAN}${BOLD}═══ Phase $1: $2 ═══${NC}\n"; }

# --- Argument parsing -------------------------------------------------------
VERIFY=false
DRY_RUN=false
TARGET=""

while [[ $# -gt 0 ]]; do
  case "$1" in
    --verify)  VERIFY=true; shift ;;
    --dry-run) DRY_RUN=true; shift ;;
    --help|-h)
      echo "Usage: $0 [--verify] [--dry-run] <target-directory>"
      echo ""
      echo "Options:"
      echo "  --verify    Run go build + npm build after conversion"
      echo "  --dry-run   Show what would be done without making changes"
      echo "  -h, --help  Show this help"
      exit 0
      ;;
    -*)
      err "Unknown option: $1"
      exit 1
      ;;
    *)
      if [[ -n "$TARGET" ]]; then
        err "Multiple target directories specified"
        exit 1
      fi
      TARGET="$1"
      shift
      ;;
  esac
done

if [[ -z "$TARGET" ]]; then
  err "Target directory required"
  echo "Usage: $0 [--verify] [--dry-run] <target-directory>"
  exit 1
fi

# --- Pre-flight checks ------------------------------------------------------
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
REPO_ROOT="$(cd "$SCRIPT_DIR/.." && pwd)"
OVERLAY_DIR="$SCRIPT_DIR/community-edition/overlay"

if [[ ! -f "$REPO_ROOT/backend/go.mod" ]]; then
  err "Must be run from the Scarlet repo root (expected backend/go.mod)"
  exit 1
fi

if [[ ! -d "$OVERLAY_DIR" ]]; then
  err "Overlay directory not found: $OVERLAY_DIR"
  exit 1
fi

if ! command -v rsync &>/dev/null; then
  err "rsync is required but not found"
  exit 1
fi

TARGET="$(realpath -m "$TARGET")"

info "Source:  $REPO_ROOT"
info "Overlay: $OVERLAY_DIR"
info "Target:  $TARGET"
info "Verify:  $VERIFY"
info "Dry run: $DRY_RUN"

if $DRY_RUN; then
  warn "DRY RUN — no changes will be made"
fi

# ============================================================================
# Phase 1: Copy repo
# ============================================================================
phase 1 "Copy repository"

if $DRY_RUN; then
  info "Would rsync $REPO_ROOT → $TARGET"
else
  mkdir -p "$TARGET"
  rsync -a \
    --exclude='.git' \
    --exclude='node_modules' \
    --exclude='scripts/community-edition' \
    --exclude='.env' \
    --exclude='.env.local' \
    --exclude='dist' \
    --exclude='build' \
    --exclude='tmp' \
    --exclude='backend/generated' \
    --exclude='backend/secure_files' \
    --exclude='backend/uploads' \
    "$REPO_ROOT/" "$TARGET/" || true
  ok "Repository copied to $TARGET"
fi

# ============================================================================
# Phase 2: Delete cloud-only files
# ============================================================================
phase 2 "Delete cloud-only files"

CLOUD_FILES=(
  # Backend handlers
  "backend/internal/handlers/device_auth.go"
  "backend/internal/handlers/feedback.go"
  "backend/internal/handlers/telemetry.go"
  "backend/internal/handlers/insights.go"
  "backend/internal/handlers/admin_system_models.go"

  # Backend services
  "backend/internal/services/device_service.go"
  "backend/internal/services/feedback_service.go"
  "backend/internal/services/telemetry_service.go"
  "backend/internal/services/engagement_service.go"
  "backend/internal/services/insights_service.go"

  # Backend auth
  "backend/pkg/auth/supabase.go"
  "backend/internal/middleware/auth.go"

  # Backend models
  "backend/internal/models/daily_metrics.go"
  "backend/internal/models/device.go"
  "backend/internal/models/engagement.go"
  "backend/internal/models/feedback.go"

  # Backend jobs
  "backend/internal/jobs/daily_metrics_aggregator.go"
  "backend/internal/jobs/engagement_health.go"

  # Frontend components
  "frontend/src/components/auth/GuestOrProtectedRoute.tsx"
  "frontend/src/components/auth/GuestTurnstileGate.tsx"
  "frontend/src/components/auth/TurnstileWidget.tsx"
  "frontend/src/components/ui/TourButton.tsx"
  "frontend/src/components/settings/DevicesSection.tsx"
  "frontend/src/components/settings/DevicesSection.module.css"

  # Frontend hooks/types/styles
  "frontend/src/hooks/useShepherdTour.ts"
  "frontend/src/types/shepherd.d.ts"
  "frontend/src/styles/shepherd-theme.css"

  # Frontend services
  "frontend/src/services/telemetryService.ts"
  "frontend/src/services/feedbackService.ts"
  "frontend/src/services/guestChatMigration.ts"
  "frontend/src/services/deviceService.ts"
  "frontend/src/services/tourService.ts"
  "frontend/src/services/systemModelsService.ts"

  # Frontend stores
  "frontend/src/store/useTelemetryStore.ts"
  "frontend/src/store/useGuestStore.ts"

  # Frontend pages
  "frontend/src/pages/DeviceAuth.tsx"
  "frontend/src/pages/DeviceAuth.css"
  "frontend/src/pages/admin/HealthDashboard.tsx"
  "frontend/src/pages/admin/InsightsDashboard.tsx"
  "frontend/src/pages/admin/AutoPilotDashboard.tsx"
  "frontend/src/pages/admin/SystemModels.tsx"

  # Frontend lib
  "frontend/src/lib/supabase.ts"
)

CLOUD_DIRS=(
  "frontend/src/components/feedback"
  "frontend/src/tours"
)

deleted=0
skipped=0

# In dry-run mode, check against source since target hasn't been copied yet
CHECK_BASE="$TARGET"
if $DRY_RUN; then
  CHECK_BASE="$REPO_ROOT"
fi

for f in "${CLOUD_FILES[@]}"; do
  if [[ -f "$CHECK_BASE/$f" ]]; then
    if $DRY_RUN; then
      info "Would delete: $f"
    else
      rm -f "$TARGET/$f"
    fi
    deleted=$((deleted + 1))
  else
    warn "Not found (skipping): $f"
    skipped=$((skipped + 1))
  fi
done

for d in "${CLOUD_DIRS[@]}"; do
  if [[ -d "$CHECK_BASE/$d" ]]; then
    if $DRY_RUN; then
      info "Would delete directory: $d/"
    else
      rm -rf "$TARGET/$d"
    fi
    deleted=$((deleted + 1))
  else
    warn "Directory not found (skipping): $d/"
    skipped=$((skipped + 1))
  fi
done

ok "Deleted $deleted cloud-only files/dirs ($skipped skipped)"

# ============================================================================
# Phase 3: Apply overlay files
# ============================================================================
phase 3 "Apply overlay files"

overlay_count=$(find "$OVERLAY_DIR" -type f | wc -l)

if $DRY_RUN; then
  info "Would copy $overlay_count overlay files from $OVERLAY_DIR"
  find "$OVERLAY_DIR" -type f | while read -r f; do
    rel="${f#"$OVERLAY_DIR"/}"
    info "  → $rel"
  done
else
  rsync -a "$OVERLAY_DIR/" "$TARGET/"
  ok "Applied $overlay_count overlay files"
fi

# ============================================================================
# Phase 4: Post-process dependencies
# ============================================================================
phase 4 "Post-process dependencies"

PKG_JSON="$TARGET/frontend/package.json"
CLOUD_PACKAGES=(
  "@supabase/supabase-js"
  "@marsidev/react-turnstile"
  "shepherd.js"
  "react-shepherd"
)

if [[ -f "$PKG_JSON" ]]; then
  if $DRY_RUN; then
    info "Would remove cloud packages from package.json"
  else
    # Remove cloud packages and fix trailing commas in one pass
    python3 -c "
import re, json, sys
pkgs = sys.argv[2:]
text = open(sys.argv[1]).read()
for pkg in pkgs:
    pattern = r'\n\s*\"' + re.escape(pkg) + r'\":\s*\"[^\"]*\",?'
    text = re.sub(pattern, '', text)
# Fix trailing commas before closing braces/brackets
text = re.sub(r',(\s*[}\]])', r'\1', text)
open(sys.argv[1], 'w').write(text)
for pkg in pkgs:
    print(f'  Removed {pkg}')
" "$PKG_JSON" "${CLOUD_PACKAGES[@]}"

    ok "Cleaned frontend/package.json"
  fi
else
  warn "frontend/package.json not found"
fi

# Run go mod tidy (best-effort)
if [[ -f "$TARGET/backend/go.mod" ]]; then
  if $DRY_RUN; then
    info "Would run 'go mod tidy' in backend/"
  else
    info "Running go mod tidy..."
    if (cd "$TARGET/backend" && go mod tidy 2>&1); then
      ok "go mod tidy succeeded"
    else
      warn "go mod tidy failed (non-fatal)"
    fi
  fi
fi

# ============================================================================
# Phase 5: Verify (optional)
# ============================================================================
if $VERIFY; then
  phase 5 "Verify build"

  # Go build
  info "Building Go backend..."
  if (cd "$TARGET/backend" && go build ./cmd/server/ 2>&1); then
    ok "Go backend builds successfully"
  else
    err "Go backend build failed"
    exit 1
  fi

  # Frontend build
  info "Installing frontend dependencies..."
  if (cd "$TARGET/frontend" && npm install 2>&1); then
    ok "npm install succeeded"
  else
    err "npm install failed"
    exit 1
  fi

  info "Building frontend..."
  if (cd "$TARGET/frontend" && npm run build 2>&1); then
    ok "Frontend builds successfully"
  else
    err "Frontend build failed"
    exit 1
  fi

  # Check for cloud references
  info "Checking for remaining cloud references..."
  cloud_refs=$(grep -rl "supabase\|turnstile\|dodo\|PROMO_" "$TARGET/" \
    --include="*.go" --include="*.ts" --include="*.tsx" \
    2>/dev/null || true)

  if [[ -n "$cloud_refs" ]]; then
    warn "Cloud references found in:"
    echo "$cloud_refs" | while read -r f; do
      warn "  $f"
    done
  else
    ok "No cloud references found in application code"
  fi
else
  info "Skipping verification (use --verify to enable)"
fi

# ============================================================================
# Done
# ============================================================================
echo ""
echo -e "${GREEN}${BOLD}✓ Community edition built at: $TARGET${NC}"
echo ""
echo "Next steps:"
echo "  cd $TARGET"
echo "  cp .env.example .env      # Edit with your settings"
echo "  docker compose up -d      # Start services"
echo ""
