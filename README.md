# 🐝 WorkerBees Swarm Skills

WorkerBees is a collection of advanced, zero-trust System Prompts ("Skills") for Large Language Models (LLMs). By providing these skills to your LLM, you grant it the architectural knowledge to operate as a **Swarm Lead**—decomposing complex tasks, delegating to sub-agents, and ruthlessly auditing their work.

## 🌟 Included Skills

### 1. `SWARM_LEAD_SKILL.md` (Engineering & Building)
Designed for complex software engineering tasks. Instructs the LLM on:
- **Task Decomposition:** Formulating tasks into a Directed Acyclic Graph (DAG) to prevent write-collisions.
- **Git Worktree Isolation:** Using physical Git worktrees to isolate parallel sub-agents.
- **Zero-Trust Auditing:** A 5-phase binary checklist for auditing sub-agent code before integration.

### 2. `INVESTIGATION_LEAD_SKILL.md` (Debugging & Incident Response)
Designed for root-cause analysis across complex ecosystems (Salesforce, AWS, etc.). Instructs the LLM on:
- **Capability Negotiation:** Dynamically discovering if it has access to querying tools (like SOQL or Splunk) before acting.
- **Search-Space Decomposition:** Dispatching parallel sub-agents to read logs and telemetry.
- **Evidence-Based Synthesis:** Forcing sub-agents to provide "Hard Telemetry" (actual logs) rather than inferences.

---

## 🚀 Installation

These skills are just raw Markdown files. You can copy-paste them directly into ChatGPT, Claude, or your Custom GPTs. 

To automatically install them into your agentic IDEs, run the installer:

```bash
./install.sh
```

The installer currently supports:
- **Antigravity:** Installs globally to `~/.gemini/config/skills/`
- **Cursor IDE:** Installs locally to your current project's `.cursor/rules/` directory.

