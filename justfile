# 所有簡報放在 slides/ 下，任意層級，葉節點為一個含 slides.md 的資料夾
# 用法：just dev samples

deck_root := "slides"
bin := "bun " + justfile_directory() / "node_modules/@slidev/cli/bin/slidev.mjs"

_default:
    @just --list --unsorted

# 列出所有簡報（相對 slides/ 的路徑）
list:
    @find {{deck_root}} -name slides.md -printf '%h\n' 2>/dev/null \
        | sed 's|^{{deck_root}}/||' | sort

# 開發模式：just dev samples
dev deck *ARGS:
    {{bin}} {{deck_root}}/{{deck}}/slides.md --open {{ARGS}}

# 新建一份簡報骨架：just new report/20260801
new deck:
    #!/usr/bin/env bash
    set -euo pipefail
    dir="{{deck_root}}/{{deck}}"
    if [ -e "$dir/slides.md" ]; then
        echo "已存在：$dir/slides.md" >&2; exit 1
    fi
    mkdir -p "$dir/public"
    cat > "$dir/slides.md" <<'EOF'
    ---
    theme: default
    title: {{deck}}
    ---

    # {{deck}}

    ---

    # 第二頁
    EOF
    echo "已建立 $dir/slides.md"
