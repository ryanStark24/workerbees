#!/bin/bash
echo "🐝 Installing WorkerBees Skills..."

# 1. Antigravity Global Install
AGY_DIR="$HOME/.gemini/config/skills"
if [ -d "$HOME/.gemini" ]; then
    mkdir -p "$AGY_DIR/workerbees"
    cp workerbees_skills/*.md "$AGY_DIR/workerbees/"
    echo "✅ Installed globally to Antigravity ($AGY_DIR/workerbees/)"
fi

# 2. Cursor Local Install
echo ""
read -p "Install to local Cursor project (.cursor/rules)? (y/n) " -n 1 -r
echo
if [[ $REPLY =~ ^[Yy]$ ]]; then
    mkdir -p .cursor/rules
    cp workerbees_skills/*.md .cursor/rules/
    echo "✅ Installed to .cursor/rules/"
fi

echo "Done! Your LLM now has Swarm Lead capabilities."
