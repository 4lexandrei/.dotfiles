#!/bin/bash

# ┌─────────────┐
# │ fzf-preview │
# └─────────────┘

item="$1"

if [[ ! -e "$item" ]]; then
  printf "File not found: %s\n" "$item"
  exit 1
fi

# Determine file type
type=$(file --brief --dereference --mime "$item")

# Directories
if [[ -d "$item" ]]; then
  if command -v eza >/dev/null; then
    eza --tree --icons --color=always "$item"
  else
    ls -al --color=always "$item"
  fi

# Files (non-binary)
elif [[ ! "$type" =~ binary ]]; then
  if command -v bat >/dev/null; then
    bat -n --color=always "$item"
  else
    cat "$item"
  fi

# Images
elif [[ "$type" =~ image/ ]]; then
  if command -v kitten >/dev/null; then
    # Default columns to 80 and lines to 24 if undefined
    dim=${FZF_PREVIEW_COLUMNS:-80}x${FZF_PREVIEW_LINES:-24}
    kitten icat --clear --transfer-mode=memory --stdin=no --unicode-placeholder --place="$dim@0x0" "$item"
  else
    printf "Image preview requires 'kitten' (from kitty terminal)\n"
  fi

# PDFs
elif [[ "$type" == application/pdf* ]]; then
  if command -v kitten >/dev/null; then
    dim=${FZF_PREVIEW_COLUMNS:-80}x${FZF_PREVIEW_LINES:-24}
    pdftoppm -f 1 -l 1 -singlefile "$item" |
      kitten icat --clear --transfer-mode=stream --unicode-placeholder --place="$dim@0x0"
  else
    printf "PDF preview requires 'kitten' (from kitty terminal)\n"
  fi

# Binary files
else
  printf "No preview available (binary file)\n"
fi
