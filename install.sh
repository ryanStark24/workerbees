#!/usr/bin/env bash
set -euo pipefail

SCRIPT_DIR=$(CDPATH= cd -- "$(dirname -- "$0")" && pwd)
SOURCE_DIR="$SCRIPT_DIR/skills"
PROJECT_DIR=$(pwd)
FORCE=0
DRY_RUN=0
INTERACTIVE=0
TARGETS=()
SELECTED_GROUPS=()
SCOPES=()
SCOPE_EXPLICIT=0

usage() {
    cat <<'EOF'
Install WorkerBees skills.

Usage:
  ./install.sh --target TARGET [--target TARGET ...] [options]
  ./install.sh --all [options]
  ./install.sh                    # interactive selection

Targets:
  cursor       Cursor project or user skill directory.
  antigravity  Antigravity workspace or global skill directory.
  codex        Codex repository or user skill directory.
  claude       Claude Code project or personal skill directory.

Options:
  --all                  Install every target.
  --target TARGET        Install one target; may be repeated.
  --group GROUP          Install general, salesforce, or all skills; may be repeated (default: all).
  --scope SCOPE          Install at project or global scope; may be repeated.
                         Without this flag, Cursor uses project scope and other targets use global scope.
  --project-dir PATH     Project/workspace root for project scope (default: current directory).
  --force                Replace differing WorkerBees-managed files.
  --dry-run              Print intended changes without writing.
  -h, --help             Show this help.

Environment overrides:
  CURSOR_SKILLS_DIR, ANTIGRAVITY_SKILLS_DIR, CODEX_HOME, CLAUDE_HOME
  <TARGET>_PROJECT_SKILLS_DIR and <TARGET>_GLOBAL_SKILLS_DIR
EOF
}

die() {
    printf 'ERROR: %s\n' "$*" >&2
    exit 1
}

add_target() {
    local candidate=$1
    local existing
    case "$candidate" in
        cursor|antigravity|codex|claude) ;;
        *) die "Unknown target: $candidate" ;;
    esac
    for existing in "${TARGETS[@]:-}"; do
        [ "$existing" = "$candidate" ] && return 0
    done
    TARGETS+=("$candidate")
}

add_group() {
    local candidate=$1
    local existing
    case "$candidate" in
        all)
            add_group general
            add_group salesforce
            return 0
            ;;
        general|salesforce) ;;
        *) die "Unknown group: $candidate" ;;
    esac
    for existing in "${SELECTED_GROUPS[@]:-}"; do
        [ "$existing" = "$candidate" ] && return 0
    done
    SELECTED_GROUPS+=("$candidate")
}

add_scope() {
    local candidate=$1
    local existing
    case "$candidate" in
        project|global) ;;
        *) die "Unknown scope: $candidate" ;;
    esac
    for existing in "${SCOPES[@]:-}"; do
        [ "$existing" = "$candidate" ] && return 0
    done
    SCOPES+=("$candidate")
}

while [ "$#" -gt 0 ]; do
    case "$1" in
        --all)
            add_target cursor
            add_target antigravity
            add_target codex
            add_target claude
            shift
            ;;
        --target)
            [ "$#" -ge 2 ] || die "--target requires a value"
            add_target "$2"
            shift 2
            ;;
        --group)
            [ "$#" -ge 2 ] || die "--group requires a value"
            add_group "$2"
            shift 2
            ;;
        --scope)
            [ "$#" -ge 2 ] || die "--scope requires a value"
            SCOPE_EXPLICIT=1
            add_scope "$2"
            shift 2
            ;;
        --project-dir)
            [ "$#" -ge 2 ] || die "--project-dir requires a path"
            PROJECT_DIR=$2
            shift 2
            ;;
        --force)
            FORCE=1
            shift
            ;;
        --dry-run)
            DRY_RUN=1
            shift
            ;;
        -h|--help)
            usage
            exit 0
            ;;
        *)
            die "Unknown option: $1"
            ;;
    esac
done

[ "${#SELECTED_GROUPS[@]}" -gt 0 ] || add_group all

if [ "${#TARGETS[@]}" -eq 0 ]; then
    [ -t 0 ] || die "No target selected. Use --target or --all."
    INTERACTIVE=1
    printf 'WorkerBees skill installer\n'
    for candidate in cursor antigravity codex claude; do
        printf 'Install for %s? [y/N] ' "$candidate"
        read -r reply
        case "$reply" in
            y|Y|yes|YES|Yes) add_target "$candidate" ;;
        esac
    done
    [ "${#TARGETS[@]}" -gt 0 ] || die "No target selected."
fi

[ -d "$SOURCE_DIR" ] || die "Skill source directory not found: $SOURCE_DIR"
[ -d "$SOURCE_DIR/general" ] || die "General skill source directory not found: $SOURCE_DIR/general"
[ -d "$SOURCE_DIR/salesforce" ] || die "Salesforce skill source directory not found: $SOURCE_DIR/salesforce"

frontmatter_value() {
    local key=$1
    local file=$2
    awk -v wanted="$key" '
        NR == 1 && $0 == "---" { in_frontmatter = 1; next }
        in_frontmatter && $0 == "---" { exit }
        in_frontmatter && index($0, wanted ":") == 1 {
            sub("^[^:]+:[[:space:]]*", "")
            print
            exit
        }
    ' "$file"
}

validate_source_package() {
    local package_dir=$1
    local entrypoint="$package_dir/SKILL.md"
    local folder_name
    local skill_name
    local description
    folder_name=$(basename -- "$package_dir")
    [ -f "$entrypoint" ] || die "Missing SKILL.md in $package_dir"
    skill_name=$(frontmatter_value name "$entrypoint")
    description=$(frontmatter_value description "$entrypoint")
    [ -n "$skill_name" ] || die "Missing frontmatter name in $entrypoint"
    [ -n "$description" ] || die "Missing frontmatter description in $entrypoint"
    [ "$skill_name" = "$folder_name" ] || die "Skill name '$skill_name' does not match folder '$folder_name'"
    case "$skill_name" in
        *[!a-z0-9-]*) die "Invalid skill name: $skill_name" ;;
    esac
}

package_matches() {
    local source=$1
    local destination=$2
    local source_entry
    local destination_entry
    local relative
    [ -d "$destination" ] && [ ! -L "$destination" ] || return 1

    # Compare every entry in both directions. File contents, directory/file
    # type changes, symlink targets, and stale destination entries all matter.
    while IFS= read -r source_entry; do
        relative=${source_entry#"$source/"}
        destination_entry="$destination/$relative"
        if [ -L "$source_entry" ]; then
            [ -L "$destination_entry" ] || return 1
            [ "$(readlink -- "$source_entry")" = "$(readlink -- "$destination_entry")" ] || return 1
        elif [ -d "$source_entry" ]; then
            [ -d "$destination_entry" ] && [ ! -L "$destination_entry" ] || return 1
        elif [ -f "$source_entry" ]; then
            [ -f "$destination_entry" ] && [ ! -L "$destination_entry" ] || return 1
            cmp -s -- "$source_entry" "$destination_entry" || return 1
            if [ -x "$source_entry" ]; then
                [ -x "$destination_entry" ] || return 1
            else
                [ ! -x "$destination_entry" ] || return 1
            fi
        else
            return 1
        fi
    done < <(find "$source" -mindepth 1 -print | LC_ALL=C sort)

    while IFS= read -r destination_entry; do
        relative=${destination_entry#"$destination/"}
        source_entry="$source/$relative"
        if [ -L "$destination_entry" ]; then
            [ -L "$source_entry" ] || return 1
        elif [ -d "$destination_entry" ]; then
            [ -d "$source_entry" ] && [ ! -L "$source_entry" ] || return 1
        elif [ -f "$destination_entry" ]; then
            [ -f "$source_entry" ] && [ ! -L "$source_entry" ] || return 1
        else
            return 1
        fi
    done < <(find "$destination" -mindepth 1 -print | LC_ALL=C sort)
    return 0
}

path_exists() {
    [ -e "$1" ] || [ -L "$1" ]
}

preflight_parent() {
    local destination=$1
    local ancestor
    ancestor=$(dirname -- "$destination")
    while ! path_exists "$ancestor"; do
        [ "$ancestor" != "/" ] || break
        ancestor=$(dirname -- "$ancestor")
    done
    [ -d "$ancestor" ] || die "Destination parent is not a directory: $ancestor"
    if [ "$DRY_RUN" -ne 1 ] && [ ! -w "$ancestor" ]; then
        die "Destination parent is not writable: $ancestor"
    fi
}

preflight_package() {
    local source=$1
    local destination=$2
    if [ -L "$destination" ]; then
        die "Destination is a symbolic link and will not be followed: $destination"
    fi
    if package_matches "$source" "$destination"; then
        return 0
    fi
    if path_exists "$destination" && [ "$FORCE" -ne 1 ]; then
        die "Destination differs: $destination (use --force to update WorkerBees-managed files)"
    fi
    preflight_parent "$destination"
}

copy_package() {
    local source=$1
    local destination=$2
    local parent
    local package_name
    local staging
    local backup_dir=""
    local had_destination=0
    # Recheck at mutation time as well as during preflight so a destination
    # swapped to a symlink between phases is never accepted or followed.
    if [ -L "$destination" ]; then
        die "Destination is a symbolic link and will not be followed: $destination"
    fi
    if package_matches "$source" "$destination"; then
        printf 'UNCHANGED %s\n' "$destination"
        return 0
    fi
    if [ "$DRY_RUN" -eq 1 ]; then
        printf 'DRY RUN install package %s -> %s\n' "$source" "$destination"
        return 0
    fi

    parent=$(dirname -- "$destination")
    package_name=$(basename -- "$destination")
    mkdir -p -- "$parent"
    staging=$(mktemp -d "$parent/.workerbees-stage.${package_name}.XXXXXX")
    if ! cp -R -- "$source/." "$staging/" || ! package_matches "$source" "$staging"; then
        rm -rf -- "$staging"
        die "Staging verification failed for $destination"
    fi

    if path_exists "$destination"; then
        had_destination=1
        backup_dir=$(mktemp -d "$parent/.workerbees-backup.${package_name}.XXXXXX")
        if ! mv -- "$destination" "$backup_dir/original"; then
            rm -rf -- "$staging" "$backup_dir"
            die "Could not preserve existing destination: $destination"
        fi
    fi

    if ! mv -- "$staging" "$destination"; then
        [ "$had_destination" -eq 0 ] || mv -- "$backup_dir/original" "$destination"
        [ -z "$backup_dir" ] || rm -rf -- "$backup_dir"
        rm -rf -- "$staging"
        die "Could not install staged package: $destination"
    fi
    if ! package_matches "$source" "$destination"; then
        rm -rf -- "$destination"
        [ "$had_destination" -eq 0 ] || mv -- "$backup_dir/original" "$destination"
        [ -z "$backup_dir" ] || rm -rf -- "$backup_dir"
        die "Verification failed for $destination; previous package restored"
    fi
    [ -z "$backup_dir" ] || rm -rf -- "$backup_dir"
    printf 'INSTALLED %s\n' "$destination"
}

target_requested() {
    local wanted=$1
    local target
    for target in "${TARGETS[@]}"; do
        [ "$target" = "$wanted" ] && return 0
    done
    return 1
}

group_requested() {
    local wanted=$1
    local group
    for group in "${SELECTED_GROUPS[@]}"; do
        [ "$group" = "$wanted" ] && return 0
    done
    return 1
}

scope_requested() {
    local target=$1
    local wanted=$2
    local scope
    if [ "$SCOPE_EXPLICIT" -eq 0 ]; then
        if [ "$target" = cursor ]; then
            [ "$wanted" = project ]
        else
            [ "$wanted" = global ]
        fi
        return
    fi
    for scope in "${SCOPES[@]}"; do
        [ "$scope" = "$wanted" ] && return 0
    done
    return 1
}

CURSOR_PROJECT_ROOT=${CURSOR_PROJECT_SKILLS_DIR:-${CURSOR_SKILLS_DIR:-"$PROJECT_DIR/.cursor/skills"}}
CURSOR_GLOBAL_ROOT=${CURSOR_GLOBAL_SKILLS_DIR:-${CURSOR_SKILLS_DIR:-"$HOME/.cursor/skills"}}
ANTIGRAVITY_PROJECT_ROOT=${ANTIGRAVITY_PROJECT_SKILLS_DIR:-"$PROJECT_DIR/.agents/skills"}
ANTIGRAVITY_GLOBAL_ROOT=${ANTIGRAVITY_GLOBAL_SKILLS_DIR:-${ANTIGRAVITY_SKILLS_DIR:-"$HOME/.gemini/config/skills"}}
CODEX_PROJECT_ROOT=${CODEX_PROJECT_SKILLS_DIR:-"$PROJECT_DIR/.agents/skills"}
if [ -n "${CODEX_GLOBAL_SKILLS_DIR:-}" ]; then
    CODEX_GLOBAL_ROOT=$CODEX_GLOBAL_SKILLS_DIR
elif [ -n "${CODEX_HOME:-}" ]; then
    CODEX_GLOBAL_ROOT="$CODEX_HOME/skills"
else
    CODEX_GLOBAL_ROOT="$HOME/.agents/skills"
fi
CLAUDE_PROJECT_ROOT=${CLAUDE_PROJECT_SKILLS_DIR:-"$PROJECT_DIR/.claude/skills"}
CLAUDE_GLOBAL_ROOT=${CLAUDE_GLOBAL_SKILLS_DIR:-${CLAUDE_HOME:-"$HOME/.claude"}/skills}

WORK_SOURCES=()
WORK_DESTINATIONS=()

queue_package() {
    local source=$1
    local destination=$2
    local index
    for ((index = 0; index < ${#WORK_DESTINATIONS[@]}; index++)); do
        if [ "${WORK_DESTINATIONS[$index]}" = "$destination" ]; then
            [ "${WORK_SOURCES[$index]}" = "$source" ] || die "Two packages resolve to the same destination: $destination"
            return 0
        fi
    done
    WORK_SOURCES+=("$source")
    WORK_DESTINATIONS+=("$destination")
}

skill_count=0
SKILL_NAMES=()
while IFS= read -r entrypoint; do
    package_dir=${entrypoint%/SKILL.md}
    validate_source_package "$package_dir"
    category=$(basename -- "$(dirname -- "$package_dir")")
    group_requested "$category" || continue
    skill_count=$((skill_count + 1))
    skill_name=$(basename -- "$package_dir")
    for existing_skill_name in "${SKILL_NAMES[@]:-}"; do
        [ "$existing_skill_name" != "$skill_name" ] || die "Duplicate skill package name: $skill_name"
    done
    SKILL_NAMES+=("$skill_name")
    if target_requested cursor; then
        scope_requested cursor project && queue_package "$package_dir" "$CURSOR_PROJECT_ROOT/$skill_name"
        scope_requested cursor global && queue_package "$package_dir" "$CURSOR_GLOBAL_ROOT/$skill_name"
    fi
    if target_requested antigravity; then
        scope_requested antigravity project && queue_package "$package_dir" "$ANTIGRAVITY_PROJECT_ROOT/$skill_name"
        scope_requested antigravity global && queue_package "$package_dir" "$ANTIGRAVITY_GLOBAL_ROOT/$skill_name"
    fi
    if target_requested codex; then
        scope_requested codex project && queue_package "$package_dir" "$CODEX_PROJECT_ROOT/$skill_name"
        scope_requested codex global && queue_package "$package_dir" "$CODEX_GLOBAL_ROOT/$skill_name"
    fi
    if target_requested claude; then
        scope_requested claude project && queue_package "$package_dir" "$CLAUDE_PROJECT_ROOT/$skill_name"
        scope_requested claude global && queue_package "$package_dir" "$CLAUDE_GLOBAL_ROOT/$skill_name"
    fi
done < <(find "$SOURCE_DIR" -mindepth 3 -maxdepth 3 -type f -name SKILL.md -print | LC_ALL=C sort)

[ "$skill_count" -gt 0 ] || die "No skill packages found in $SOURCE_DIR"

# Preflight the entire requested installation before creating any directories or
# replacing any package. A conflict in one target therefore cannot leave other
# targets partially updated.
work_index=0
while [ "$work_index" -lt "${#WORK_SOURCES[@]}" ]; do
    preflight_package "${WORK_SOURCES[$work_index]}" "${WORK_DESTINATIONS[$work_index]}"
    work_index=$((work_index + 1))
done

work_index=0
while [ "$work_index" -lt "${#WORK_SOURCES[@]}" ]; do
    copy_package "${WORK_SOURCES[$work_index]}" "${WORK_DESTINATIONS[$work_index]}"
    work_index=$((work_index + 1))
done

if [ "$DRY_RUN" -eq 1 ]; then
    printf 'Dry run complete for %s skill package(s).\n' "$skill_count"
else
    printf 'Verified installation of %s skill package(s).\n' "$skill_count"
fi

if [ "$INTERACTIVE" -eq 1 ] && target_requested cursor; then
    printf 'Cursor project: %s\n' "$PROJECT_DIR"
fi
