#!/usr/bin/env python3
"""
Skill Evaluator Hook - Evaluates available skills and provides context to Claude.

Runs on UserPromptSubmit to inject skill information into the conversation.
Claude can then decide which skills are relevant to the task.
"""

import json
import sys
import os
from pathlib import Path
import re

def parse_frontmatter(content: str) -> dict:
    """Extract YAML frontmatter from markdown content."""
    match = re.match(r'^---\s*\n(.*?)\n---', content, re.DOTALL)
    if not match:
        return {}

    frontmatter = {}
    for line in match.group(1).strip().split('\n'):
        if ':' in line:
            key, value = line.split(':', 1)
            frontmatter[key.strip()] = value.strip()
    return frontmatter

def find_skills(skills_dir: Path) -> list[dict]:
    """Find all skills and extract their metadata."""
    skills = []

    if not skills_dir.exists():
        return skills

    for skill_path in skills_dir.iterdir():
        if not skill_path.is_dir():
            continue

        skill_file = skill_path / "SKILL.md"
        if not skill_file.exists():
            continue

        try:
            content = skill_file.read_text()
            meta = parse_frontmatter(content)

            if meta.get('name') and meta.get('description'):
                skills.append({
                    'name': meta['name'],
                    'description': meta['description'],
                    'path': str(skill_file),
                    'allowed_tools': meta.get('allowed-tools', '')
                })
        except Exception:
            continue

    return skills

def main():
    # Read hook input from stdin
    try:
        hook_input = json.load(sys.stdin)
    except json.JSONDecodeError:
        sys.exit(0)

    # Get the project directory
    cwd = hook_input.get('cwd', os.getcwd())

    # Find skills directory (check both relative and absolute paths)
    skills_dir = Path(cwd) / "skills"
    if not skills_dir.exists():
        skills_dir = Path(cwd) / ".claude" / "skills"

    skills = find_skills(skills_dir)

    if not skills:
        # No skills found, exit silently
        sys.exit(0)

    # Build the context message
    skill_list = "\n".join([
        f"- **{s['name']}**: {s['description']} (path: `{s['path']}`)"
        for s in skills
    ])

    context = f"""## Available Skills

The following skills are available in this project. Evaluate which ones may be helpful for the current task and read their full SKILL.md file if relevant.

{skill_list}

If a skill's description matches the user's request, read the skill file and follow its guidance."""

    # Return the context
    output = {
        "additionalContext": context
    }

    print(json.dumps(output))
    sys.exit(0)

if __name__ == "__main__":
    main()
