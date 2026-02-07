#!/bin/bash

##############################################################################
# module-paths.sh - Find and list all LanManVan module paths
# 
# Usage:
#   ./module-paths.sh                    # Search in default ./modules dir
#   ./module-paths.sh /custom/path       # Search in custom directory
#   ./module-paths.sh /path1:/path2      # Search in multiple directories
#   ./module-paths.sh --find module_name # Find specific module
#   ./module-paths.sh --list             # List all modules with paths
#
##############################################################################

set -e

# Colors for output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m' # No Color

# Default modules directory
DEFAULT_MODULES_PATH="./modules"

# Function to print colored output
print_success() {
    echo -e "${GREEN}[✓]${NC} $1"
}

print_info() {
    echo -e "${BLUE}[*]${NC} $1"
}

print_error() {
    echo -e "${RED}[!]${NC} $1"
}

print_warn() {
    echo -e "${YELLOW}[⚠]${NC} $1"
}

# Function to check if a directory is a module
is_module_dir() {
    local dir="$1"
    
    # Check for module.yaml
    if [ -f "$dir/module.yaml" ]; then
        return 0
    fi
    
    # Check for known module files (.py, .sh, .go, .rb)
    if ls "$dir"/*.py >/dev/null 2>&1 || \
       ls "$dir"/*.sh >/dev/null 2>&1 || \
       ls "$dir"/*.go >/dev/null 2>&1 || \
       ls "$dir"/*.rb >/dev/null 2>&1; then
        return 0
    fi
    
    return 1
}

# Function to find all modules recursively
find_all_modules() {
    local base_dir="$1"
    local prefix="$2"
    
    if [ ! -d "$base_dir" ]; then
        return
    fi
    
    for item in "$base_dir"/*; do
        if [ -d "$item" ]; then
            local basename=$(basename "$item")
            local qualname="${prefix}${basename}"
            
            if is_module_dir "$item"; then
                echo "$qualname|$item"
            else
                # Recurse into subdirectory as namespace
                new_prefix="${qualname}."
                find_all_modules "$item" "$new_prefix"
            fi
        fi
    done
}

# Function to print formatted module info
print_module_info() {
    local name="$1"
    local path="$2"
    
    # Get module description if available
    local desc=""
    if [ -f "$path/module.yaml" ]; then
        desc=$(grep "^description:" "$path/module.yaml" | sed 's/description: *//g' | tr -d '"')
    fi
    
    printf "  ${GREEN}%-40s${NC} %s\n" "$name" "$path"
    if [ -n "$desc" ]; then
        printf "    └─ ${BLUE}%s${NC}\n" "$desc"
    fi
}

# Function to list all modules
list_all_modules() {
    local paths="$1"
    local found=0
    
    # Store results in associative array (requires bash 4+)
    declare -A modules
    
    # Split paths by colon and process each
    IFS=':' read -ra path_array <<< "$paths"
    
    for path in "${path_array[@]}"; do
        path=$(echo "$path" | xargs) # trim whitespace
        
        if [ -z "$path" ]; then
            continue
        fi
        
        # Expand ~ to home directory
        path="${path/#\~/$HOME}"
        
        if [ ! -d "$path" ]; then
            continue
        fi
        
        print_info "Searching in: $path"
        
        while IFS='|' read -r name module_path; do
            modules["$name"]="$module_path"
            ((found++))
        done < <(find_all_modules "$path" "")
    done
    
    if [ $found -eq 0 ]; then
        print_warn "No modules found"
        return 1
    fi
    
    echo ""
    print_success "Found $found module(s):"
    echo ""
    
    # Sort and display
    for name in $(printf '%s\n' "${!modules[@]}" | sort); do
        print_module_info "$name" "${modules[$name]}"
    done
    
    echo ""
}

# Function to find specific module
find_module() {
    local module_name="$1"
    local paths="$2"
    local found=0
    
    # Split paths by colon and process each
    IFS=':' read -ra path_array <<< "$paths"
    
    for path in "${path_array[@]}"; do
        path=$(echo "$path" | xargs) # trim whitespace
        
        if [ -z "$path" ]; then
            continue
        fi
        
        # Expand ~ to home directory
        path="${path/#\~/$HOME}"
        
        if [ ! -d "$path" ]; then
            continue
        fi
        
        while IFS='|' read -r name module_path; do
            if [ "$name" = "$module_name" ]; then
                print_success "Found module: $module_name"
                print_module_info "$name" "$module_path"
                echo ""
                ((found++))
            fi
        done < <(find_all_modules "$path" "")
    done
    
    if [ $found -eq 0 ]; then
        print_error "Module '$module_name' not found"
        return 1
    fi
}

# Main logic
main() {
    local search_path="$DEFAULT_MODULES_PATH"
    local find_mode=0
    local find_name=""
    local list_mode=0
    
    # Parse arguments
    while [ $# -gt 0 ]; do
        case "$1" in
            --find)
                find_mode=1
                find_name="$2"
                shift 2
                ;;
            --list|-l)
                list_mode=1
                shift
                ;;
            --help|-h)
                echo "Usage: $0 [OPTIONS] [PATHS]"
                echo ""
                echo "Options:"
                echo "  --find <name>      Find specific module by name"
                echo "  --list, -l         List all modules with details"
                echo "  --help, -h         Show this help message"
                echo ""
                echo "Arguments:"
                echo "  PATHS              Module search paths (default: ./modules)"
                echo "                     Multiple paths separated by colon (:)"
                echo ""
                echo "Examples:"
                echo "  $0                              # List all in ./modules"
                echo "  $0 ./custom                     # List all in ./custom"
                echo "  $0 ./path1:./path2              # List all in multiple paths"
                echo "  $0 --find python_example        # Find specific module"
                exit 0
                ;;
            *)
                search_path="$1"
                shift
                ;;
        esac
    done
    
    echo ""
    
    if [ $find_mode -eq 1 ]; then
        if [ -z "$find_name" ]; then
            print_error "Module name required for --find option"
            exit 1
        fi
        find_module "$find_name" "$search_path"
    elif [ $list_mode -eq 1 ] || [ $# -eq 0 ]; then
        list_all_modules "$search_path"
    else
        list_all_modules "$search_path"
    fi
}

main "$@"
