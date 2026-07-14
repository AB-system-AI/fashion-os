# Workflow Designer

## Overview

The workflow designer lets tenants build approval and automation flows as versioned templates with steps, variables, and conditions.

## Core engine

`WorkflowDesignerEngine` (`lib/core/business/engines/workflow/workflow_designer_engine.dart`) provides pure logic for:

- Draft / publish / archive version lifecycle
- Template validation
- Clone and import/export bundles
- Dry-run simulation with condition evaluation

## Domain model

| Entity | Table | Purpose |
|--------|-------|---------|
| `WorkflowTemplate` | `wf_templates` | Top-level template metadata |
| `WorkflowVersion` | `wf_template_versions` | Versioned step definitions |
| `WorkflowCategory` | `wf_categories` | Grouping |
| `WorkflowVariable` | `wf_variables` | Runtime context fields |
| `WorkflowCondition` | embedded in version | Branching rules |
| `WorkflowAction` | embedded in version | Step + nested actions |

## Service

`WorkflowDesignerService` handles permissions, repository persistence, publish, simulate, and export.

## UI

`/workflows/designer` — list-based step builder (visual designer can replace the list UI later).

## Simulation

`/workflows/simulator` — dry-run via `WorkflowDesignerEngine.simulate()` without persisting executions.
