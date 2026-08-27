# AI Hub Studio Refactor and Implementation Plan

This document is the execution plan to turn the current source under [src/AIHubStudio](src/AIHubStudio) into a clean, production-quality InterSystems IRIS / ObjectScript codebase.

It was derived from a direct review of the project structure and the current class patterns, especially the files below:

- [src/AIHubStudio/AI/Manager.cls](src/AIHubStudio/AI/Manager.cls)
- [src/AIHubStudio/AI/Agent.cls](src/AIHubStudio/AI/Agent.cls)
- [src/AIHubStudio/AI/Provider.cls](src/AIHubStudio/AI/Provider.cls)
- [src/AIHubStudio/Config.cls](src/AIHubStudio/Config.cls)
- [src/AIHubStudio/Init.cls](src/AIHubStudio/Init.cls)
- [src/AIHubStudio/Agent/Registry.cls](src/AIHubStudio/Agent/Registry.cls)
- [src/AIHubStudio/Metadata/Agent.cls](src/AIHubStudio/Metadata/Agent.cls)
- [src/AIHubStudio/Metadata/Provider.cls](src/AIHubStudio/Metadata/Provider.cls)
- [src/AIHubStudio/REST/AgentService.cls](src/AIHubStudio/REST/AgentService.cls)
- [src/AIHubStudio/REST/WebGateway.cls](src/AIHubStudio/REST/WebGateway.cls)

## Objective

Create a minimally fragile, fully working IRIS application that maintains a consistent object model, strong validation, correct startup behavior, predictable REST contracts, and safe handling of configuration and credentials.

## Core architectural issue to resolve

The code currently mixes two different persistence styles:

- persistent ObjectScript metadata classes such as [src/AIHubStudio/Metadata/Agent.cls](src/AIHubStudio/Metadata/Agent.cls) and [src/AIHubStudio/Metadata/Provider.cls](src/AIHubStudio/Metadata/Provider.cls)
- ad hoc SQL registry access such as [src/AIHubStudio/Agent/Registry.cls](src/AIHubStudio/Agent/Registry.cls) and [src/AIHubStudio/Config.cls](src/AIHubStudio/Config.cls)

This creates duplicate source-of-truth behavior, inconsistent CRUD, and brittle initialization paths. The implementation must standardize on one clean pattern.

---

## Required modifications

### 0. Debugging and root-cause workflow before patching

Action:
- Treat this as a refactor plus bug-fix pass, not a blind rewrite.
- Before changing logic, reproduce the failure states in a clean IRIS session: startup failure, duplicate entries, invalid provider creation, relationship duplication, and malformed REST responses.
- Trace each issue to a single root cause rather than layering workarounds.

Implementation details:
- verify the actual runtime error text and stack for each broken path
- inspect object state before and after `Save()` and `Delete()`
- confirm whether the issue is in the persistent class, the registry wrapper, or the REST layer
- use the IRIS Agentic Dev MCP tools to validate class metadata, storage mapping, and runtime behavior

Acceptance criteria:
- each change is tied to a reproduced bug or project defect
- the fix addresses the root cause, not just the visible symptom
- the resulting patch remains narrow and explainable

---

### 1. Standardize the persistence architecture

File(s):
- [src/AIHubStudio/Metadata/Agent.cls](src/AIHubStudio/Metadata/Agent.cls)
- [src/AIHubStudio/Metadata/Provider.cls](src/AIHubStudio/Metadata/Provider.cls)
- [src/AIHubStudio/Agent/Registry.cls](src/AIHubStudio/Agent/Registry.cls)
- [src/AIHubStudio/Config.cls](src/AIHubStudio/Config.cls)

Action:
- Choose a single persistence model for the application: either `%Persistent` classes with relationships and validation, or a database table registry layer with SQL queries.
- Do not duplicate metadata in both layers.
- If the application is meant to be metadata-driven, keep the persistent classes as the canonical source and have registry methods become thin wrappers around them.

Implementation details:
- remove or deprecate direct table management logic that does not match the object model
- unify naming conventions: `AgentID` vs `Name`, `Provider` vs `Metadata.Provider`, `AgentName` vs `Name`
- keep one consistent entity lifecycle: create -> validate -> save -> reload -> list -> update -> delete

Acceptance criteria:
- one canonical representation for each entity
- no duplicate records or mismatched table names
- CRUD operations use the same object layer across the app

---

### 2. Replace unsafe direct SQL setup with IRIS-safe initialization patterns

File(s):
- [src/AIHubStudio/Init.cls](src/AIHubStudio/Init.cls)
- [src/AIHubStudio/Config.cls](src/AIHubStudio/Config.cls)
- [src/AIHubStudio/Agent/Registry.cls](src/AIHubStudio/Agent/Registry.cls)

Action:
- Refactor startup code to use safe, idempotent initialization with `##class(...).%ExistsId()` checks, `%New()`, and persistent class validation instead of ad hoc SQL schema creation that is not aligned with the app’s own model.
- Ensure the app can initialize repeatedly without creating duplicate schema objects, invalid columns, or mismatched table metadata.

Implementation details:
- add explicit initialization sequence in `InitializeSystem`
- make each initializer return a proper `%Status` object, not mixed string/boolean behavior
- validate required runtime dependencies before continuing startup

Acceptance criteria:
- `InitializeSystem()` is idempotent
- startup works on a clean IRIS namespace and on a reused namespace
- no duplicate schema elements are created on restart

---

### 3. Fix naming collisions between properties and methods

File(s):
- [src/AIHubStudio/AI/Agent.cls](src/AIHubStudio/AI/Agent.cls)
- [src/AIHubStudio/AI/Provider.cls](src/AIHubStudio/AI/Provider.cls)
- [src/AIHubStudio/AI/Tool.cls](src/AIHubStudio/AI/Tool.cls)
- [src/AIHubStudio/AI/ToolSet.cls](src/AIHubStudio/AI/ToolSet.cls)

Action:
- Rename or redesign mutator methods that share the exact same name as properties, such as `Type`, `Provider`, `Model`, `APIKey`, `Enabled`.
- Prefer a clear API style such as `SetType()`, `SetProvider()`, `SetModel()`, `SetEnabled()`, or `SetAPIKey()` with explicit parameters.
- Keep the external facade API readable but non-ambiguous.

Implementation details:
- do not define a method and a property with the same name in the same class
- update all call sites accordingly
- preserve a fluent builder pattern only where it remains unambiguous

Acceptance criteria:
- no property/method name collisions remain in facade classes
- all builder methods are called consistently from initialization and examples
- class code compiles cleanly with strict naming rules

---

### 4. Rebuild the entity facade layer for consistent lifecycle semantics

File(s):
- [src/AIHubStudio/AI/Agent.cls](src/AIHubStudio/AI/Agent.cls)
- [src/AIHubStudio/AI/Provider.cls](src/AIHubStudio/AI/Provider.cls)
- [src/AIHubStudio/AI/Manager.cls](src/AIHubStudio/AI/Manager.cls)

Action:
- Standardize every facade class around the pattern: `Create()`, `Open()`, `Validate()`, `Save()`, `Delete()`, `List()`, `Exists()`.
- Make sure `Save()` behaves consistently for both new and existing objects.
- Ensure `Open()` populates all fields from the underlying metadata object and preserves the identity of the persisted object.

Implementation details:
- ensure metadata object is initialized before assigning values
- add defensive checks for null metadata
- return proper `%Status` values instead of partially constructed objects or empty strings

Acceptance criteria:
- every facade object can be created, saved, reopened, and deleted without state drift
- object state remains consistent between memory and persisted metadata

---

### 5. Normalize validation and error handling

File(s):
- [src/AIHubStudio/Metadata/Agent.cls](src/AIHubStudio/Metadata/Agent.cls)
- [src/AIHubStudio/Metadata/Provider.cls](src/AIHubStudio/Metadata/Provider.cls)
- [src/AIHubStudio/Config.cls](src/AIHubStudio/Config.cls)
- [src/AIHubStudio/REST/AgentService.cls](src/AIHubStudio/REST/AgentService.cls)

Action:
- Add centralized validation for required values, enabled state, correct provider/type combinations, endpoint rules, credentials, and model names.
- Replace broad silent fallback behavior with explicit `%Status` errors and meaningful messages.
- Return REST errors in a consistent JSON envelope with proper status codes.

Implementation details:
- validate `Name` and essential provider/model fields before save
- reject invalid provider models early
- convert errors to `$$$ERROR` with descriptive text and `Set sc = ex.AsStatus()` where needed

Acceptance criteria:
- invalid input fails fast with actionable messages
- no silent fallbacks or empty-save behavior
- API clients receive predictable error payloads

---

### 6. Correct the relationship model and tool enrollment logic

File(s):
- [src/AIHubStudio/Metadata/Agent.cls](src/AIHubStudio/Metadata/Agent.cls)
- [src/AIHubStudio/Metadata/Tool.cls](src/AIHubStudio/Metadata/Tool.cls)
- [src/AIHubStudio/Metadata/ToolSet.cls](src/AIHubStudio/Metadata/ToolSet.cls)
- [src/AIHubStudio/Metadata/AgentTool.cls](src/AIHubStudio/Metadata/AgentTool.cls)
- [src/AIHubStudio/Metadata/AgentToolSet.cls](src/AIHubStudio/Metadata/AgentToolSet.cls)

Action:
- Make agent-to-tool and agent-to-toolset relationships deterministic and deduplicated.
- Avoid querying relationship objects by field value in ambiguous ways; use persistent object identities and explicit checks.
- Make the relationship methods idempotent so repeated calls do not create duplicates.

Implementation details:
- create helper methods that check for existing relationship rows before insert
- ensure `AddTool()` and `AddToolSet()` return success when the association already exists
- ensure `RemoveTool()` and `RemoveToolSet()` behave correctly if the association is missing

Acceptance criteria:
- no duplicate relationship entries
- tools from toolsets are included once in the effective tool list
- the final effective agent configuration is stable and deterministic

---

### 7. Make REST APIs return real REST responses

File(s):
- [src/AIHubStudio/REST/AgentService.cls](src/AIHubStudio/REST/AgentService.cls)
- [src/AIHubStudio/REST/ConfigService.cls](src/AIHubStudio/REST/ConfigService.cls)
- [src/AIHubStudio/REST/ToolService.cls](src/AIHubStudio/REST/ToolService.cls)
- [src/AIHubStudio/REST/SkillService.cls](src/AIHubStudio/REST/SkillService.cls)
- [src/AIHubStudio/REST/WebGateway.cls](src/AIHubStudio/REST/WebGateway.cls)

Action:
- Replace raw `write` statements used as ad hoc JSON responses with a consistent `%CSP.REST` API contract.
- Set explicit response codes, `Content-Type`, and JSON payload structure.
- Add a standard success/error envelope to all endpoints.

Implementation details:
- return `%Status` from class methods and use standard REST status handling
- define a consistent envelope such as `{ "status": "ok", "data": ... }` or `{ "status": "error", "error": ... }`
- keep route methods consistent with URL templates in the `XData UrlMap`

Acceptance criteria:
- endpoint calls return valid JSON and correct HTTP status codes
- clients can consume responses consistently without parsing mixed text/error strings
- preflight CORS handling remains correct

---

### 8. Define authoritative configuration and secret handling

File(s):
- [src/AIHubStudio/Config.cls](src/AIHubStudio/Config.cls)
- [src/AIHubStudio/Metadata/Provider.cls](src/AIHubStudio/Metadata/Provider.cls)

Action:
- Implement a single secret strategy: either environment-based credentials, credential store, or persisted secure fields, but not all three with mixed semantics.
- Remove unsafe direct storage of API keys in plain, easily exposed config objects unless explicitly marked as development-only.
- Ensure provider validation checks environment-backed credentials before accepting runtime configuration.

Implementation details:
- use a dedicated credential source and a clear API such as `GetResolvedAPIKey()`
- avoid exposing secret values in list endpoints or JSON responses
- separate configuration metadata from actual credential data

Acceptance criteria:
- API-key fields are not exposed by default
- secrets are resolved from a single trusted source
- runtime configuration remains safe in production contexts

---

### 9. Fix startup/wiring across all service classes

File(s):
- [src/AIHubStudio/Init.cls](src/AIHubStudio/Init.cls)
- [src/AIHubStudio/AI/Manager.cls](src/AIHubStudio/AI/Manager.cls)
- [src/AIHubStudio/REST/WebGateway.cls](src/AIHubStudio/REST/WebGateway.cls)

Action:
- Verify that each initialization call references an actual class in the project and a valid runtime dependency chain.
- Make managers and services explicitly initialize their backing metadata, registries, and example objects when the namespace loads or when the API starts.

Implementation details:
- check all classes referenced in the init flow exist in the project package
- avoid hard-coded registry names that do not correspond to the actual persistent classes
- add startup smoke checks for each major subsystem

Acceptance criteria:
- application startup completes without class resolution errors
- all manager/service entry points can be invoked safely after initialization
- no initializer references missing or inconsistent class names

---

### 10. Create a canonical JSON contract and reusable serialization helpers

File(s):
- [src/AIHubStudio/Metadata/Agent.cls](src/AIHubStudio/Metadata/Agent.cls)
- [src/AIHubStudio/Metadata/Provider.cls](src/AIHubStudio/Metadata/Provider.cls)
- [src/AIHubStudio/AI/Manager.cls](src/AIHubStudio/AI/Manager.cls)
- [src/AIHubStudio/REST/AgentService.cls](src/AIHubStudio/REST/AgentService.cls)

Action:
- Replace ad hoc `obj.%ToJSON()` usage with a consistent, documented JSON contract for entities.
- Add helper methods that normalize optional fields, timestamps, and arrays of names.
- Ensure all list endpoints return arrays and all single-resource endpoints return objects.

Implementation details:
- define consistent keys such as `name`, `provider`, `model`, `enabled`, `createdAt`, `updatedAt`, `tools`, `toolSets`
- use a single helper method to render entity payloads consistently

Acceptance criteria:
- JSON output is predictable across all endpoints and management methods
- clients can parse objects without guessing field names or types

---

### 11. Add a proper status/reporting layer

File(s):
- [src/AIHubStudio/Status.cls](src/AIHubStudio/Status.cls)
- [src/AIHubStudio/REST/StatusService.cls](src/AIHubStudio/REST/StatusService.cls)

Action:
- Build a clean status model that reports initialization state, counts, enabled providers, active classes, and backend health.
- Ensure this status layer reflects the real metadata layer instead of separate unrelated counters.

Implementation details:
- compute counts from the real persistent classes
- include initialization status, entity counts, and dependency health
- surface meaningful operational checks, not just static values

Acceptance criteria:
- status endpoints reflect system reality
- startup, persistence, and entity counts are verifiable from one status report

---

### 12. Make the codebase match IRIS ObjectScript conventions and style

File(s):
- all files under [src/AIHubStudio](src/AIHubStudio)

Action:
- Remove ad hoc patterns that do not follow InterSystems best practice.
- Standardize indentation, return types, method naming, `%Status` usage, and comments.

Implementation details:
- use `Set sc = $$$OK` patterns consistently
- avoid mixing `write` and `Return` in the same method when building REST endpoints
- prefer a single method naming convention for mutators and accessors
- keep comments concise and accurate

Acceptance criteria:
- code is easier to review and extend
- method signatures are consistent and readable
- the project reads like a coherent IRIS application rather than a prototype

---

### 13. Add test coverage around the real behavior

File(s):
- [src/AIHubStudio/Tests](src/AIHubStudio/Tests)

Action:
- Add a focused `%UnitTest` suite covering:
  - initialization idempotence
  - provider create/validate/save/open
  - agent create/save/open
  - tool/toolset relationship deduplication
  - REST route status and error responses

Implementation details:
- test the actual persistent behavior, not mock-only behavior
- validate with real data writes and reads in a test namespace
- keep tests small, behavior-oriented, and deterministic

Acceptance criteria:
- a clean test suite proves the framework is functional
- new refactor work can be validated without manual inspection alone

---

### 14. Remove duplicate or dead experimental API paths

File(s):
- [src/AIHubStudio/Agent/Registry.cls](src/AIHubStudio/Agent/Registry.cls)
- [src/AIHubStudio/AI/Manager.cls](src/AIHubStudio/AI/Manager.cls)
- [src/AIHubStudio/REST/WebGateway.cls](src/AIHubStudio/REST/WebGateway.cls)

Action:
- Identify parallel APIs that do the same job in different styles and keep only the canonical one.
- Eliminate confusing overlap between metadata objects, registry classes, and REST wrappers.

Implementation details:
- keep one public API surface for each domain
- move helper logic into shared methods instead of duplicated code paths

Acceptance criteria:
- the project has one clear way to create, update, list, and delete core entities
- less ambiguity for downstream AI agents and human developers

---

### 15. Final integration pass and smoke validation

File(s):
- whole [src/AIHubStudio](src/AIHubStudio)

Action:
- Run a full compile and smoke-test pass at the end of the refactor.
- Verify that the application initializes, creates a provider, creates an agent, saves metadata, lists entities, and exposes status/REST endpoints without errors.

Implementation details:
- compile classes in the target namespace
- invoke initialization
- create example objects using real data
- check list, save, and delete flows
- confirm REST calls return valid JSON and status codes

Acceptance criteria:
- the app bootstraps successfully in a clean namespace
- key product flows work end-to-end
- the code can be passed to another AI coding agent without requiring speculative rework

---

### 16. Best-practice engineering rules for the follow-up agent

Action:
- Keep the patch minimal, disciplined, and reviewable.
- Prefer a single fix per root cause instead of stacking opportunistic changes.
- Preserve existing working behavior while eliminating broken assumptions.

Required standards:
- no silent swallowing of errors; always capture and return meaningful `%Status`
- no direct use of ad hoc SQL schema management where persistent classes already exist
- no duplicate source-of-truth objects or duplicate identity layers
- no exposing API keys in list endpoints or response bodies
- no reliance on fragile string-based comparisons where object identities are available
- no broad rename/refactor without updating all call sites and tests
- no use of mocked behavior as validation; tests must exercise real IRIS persistence and REST behavior

Implementation details:
- patch in small, verifiable steps
- validate each step with compile or runtime checks before moving on
- if a fix fails, revert to root-cause analysis and patch again
- keep comments aligned with the actual logic, not aspirational intent

Acceptance criteria:
- future changes are easy to reason about
- refactor does not increase architectural drift
- the code is maintainable by another developer or AI agent without hidden assumptions

---

### 17. Bug-fix checklist for the agent doing the work

Action:
- Use this checklist before marking any patch complete.

Checklist:
- Is there a reproduced bug or failing behavior?
- Is the root cause identified and written down?
- Is the fix targeted to the root cause and not a workaround?
- Did the patch preserve the surrounding valid behavior?
- Did the change compile or run without new errors?
- Did validation covers the primary scenario that failed?
- Did the code remain consistent with IRIS best practices?
- Is there no duplicate persistence layer or conflicting API contract?
- Are secrets and config values handled safely?
- Are tests or smoke checks proving the outcome?

Acceptance criteria:
- every major change passes this checklist
- no fix is considered complete without evidence from a real compile/run or targeted test

---

## Recommended implementation order

1. Standardize persistence layer
2. Fix validation and state management
3. Resolve property/method naming collisions
4. Repair startup and dependency wiring
5. Normalize REST contracts
6. Add tests and smoke validation

This order reduces rework. If the persistence model is corrected first, the rest of the framework becomes much easier to implement safely.

## Final note

The current project is close to a good IRIS app blueprint, but it is not yet a fully reliable production-quality ObjectScript implementation because it mixes metadata objects, SQL registry code, and facade APIs that do not share one consistent contract. The plan above is the minimum safe path to make it coherent, maintainable, and genuinely operational.

This should be treated as both a refactor plan and a bug-fix playbook: the agent must repair the concrete defects in the project while also reshaping the code toward a clean, maintainable InterSystems IRIS architecture.
