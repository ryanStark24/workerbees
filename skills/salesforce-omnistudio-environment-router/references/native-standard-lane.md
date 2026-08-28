# Native and Standard-Object Lane

Use this lane for `STANDARD_NATIVE` and `MANAGED_STANDARD_MODEL`. A managed-package runtime does not prove legacy storage: Salesforce documents a managed runtime with either the custom data model or standard data model.

## Object and configuration evidence

Check exact API names and access rather than display labels:

| Concern | Standard object/configuration family |
|---|---|
| OmniScript or Integration Procedure | `OmniProcess`, with elements in `OmniProcessElement` |
| compiled OmniScript | `OmniProcessCompilation` |
| saved OmniScript session | `OmniScriptSavedSession` / the org's exposed OmniScript Saved Session object label |
| Data Mapper | `OmniDataTransform` and its supported item representation |
| FlexCard | `OmniUiCard` |
| interaction configuration | `OmniInteractionConfig` |

Record describe/query permissions and caps. Absence from a result is not absence from the org when access or pagination is incomplete.

## Metadata lane

Salesforce documents OmniStudio Metadata support for `OmniProcess`, `OmniDataTransform`, and `OmniUiCard` standard objects. Enabling it is an explicit, irreversible administrative action according to the cited Help page, and an apparent initial enablement can later fail. Observe the final state; never enable it merely to complete an investigation.

When the affected standard-object asset has a successfully enabled Metadata setting and authoritative metadata source, use supported Salesforce CLI/Metadata API or packaging. Keep generated Lightning Web Components, FlexiPages, permission sets, Apex, and other dependencies in the manifest where applicable.

For standard runtime user checks, verify the documented baseline grants: Omni Process Compilation **Read and Edit**, Omni Data Transformation **Read**, and OmniScript Saved Sessions **Read and Edit**, plus the OmniStudio permission-set license. Re-check exact object and field permissions for the target release, then apply least privilege per persona. For non-admin authors, verify the configuration BPO permissions documented for `OmniUiCardConfig`, `OmniScriptConfig`, `OmniIntegrationProcConfig`, and `OmniDataTransformConfig`.

## Official sources and freshness

Checked 2026-08-28; re-check for the target Salesforce release:

- Salesforce Help, [Enable OmniStudio Metadata API Support](https://help.salesforce.com/s/articleView?id=sf.os_enable_omnistudio_metadata_api_support.htm&language=en_US&type=5)
- Salesforce Help, [Standard OmniStudio Content and Runtime](https://help.salesforce.com/s/articleView?id=xcloud.os_standard_omnistudio_content_and_runtime.htm&language=en_US&type=5)
- Salesforce Help, [OmniStudio Security Updates Overview](https://help.salesforce.com/s/articleView?id=xcloud.os_omnistudio_security_updates_overview.htm&language=en_US&type=5)
- Salesforce Help, [Tool Considerations for Deploying OmniStudio Components](https://help.salesforce.com/s/articleView?id=xcloud.os_deploy_recommended_tool.htm&language=en_US&type=5)
- Salesforce Developers, [Migrate From Managed Package Runtime to the OmniStudio Standard Runtime](https://developer.salesforce.com/blogs/2026/08/migrate-from-managed-package-runtime-to-the-omnistudio-standard-runtime)

The names above guide discovery, not blind queries. Verify exact API availability with the target org and current reference documentation.
