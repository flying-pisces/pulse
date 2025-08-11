# Claude Configuration Directory

This directory contains all Claude Code related configuration files for the pulse trading app project.

## Structure

```
.claude/
├── README.md                   # This file - overview of Claude configuration
├── claude.json                 # Main Claude CLI agent configuration
├── claude_agent_config.md      # Detailed multi-agent architecture documentation
└── agents/                     # Individual agent configuration files (future)
    ├── market-researcher.md
    ├── product-strategist.md
    ├── system-architect.md
    ├── developer.md
    ├── code-reviewer.md
    ├── devops.md
    ├── qa-tester.md
    ├── analytics.md
    └── compliance.md
```

## Files

### claude.json
Main configuration file for Claude CLI multi-agent setup. Defines:
- Project metadata
- Agent definitions with contexts and responsibilities  
- Collaboration workflows
- MCP (Model Context Protocol) server configurations

### claude_agent_config.md
Comprehensive documentation of the multi-agent architecture including:
- Detailed agent responsibilities
- Example CLI invocations
- Collaboration workflows
- MCP requirements
- Best practices

## Usage

### Initialize Claude CLI
```bash
cd /Users/cyin/pulse
claude init
```

### Use Individual Agents
```bash
# Market research
claude chat --agent market-researcher "Analyze competitor trading apps"

# Development
claude chat --agent developer "Implement portfolio dashboard"

# Code review
claude chat --agent code-reviewer "Review authentication module"
```

### Agent Workflows
```bash
# Full feature development workflow
claude chat --chain "market-researcher,product-strategist,system-architect,developer,code-reviewer,qa-tester,devops"
```

## Maintenance

- Keep agent contexts updated as project structure evolves
- Update MCP server paths when moving directories
- Review and refine agent responsibilities based on project needs
- Add new agents as the project grows in complexity