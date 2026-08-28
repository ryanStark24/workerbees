# Managed Legacy and DataPack Lane

Use this lane for `MANAGED_LEGACY`; use it as a separate lane within `MIXED`. Legacy configuration is stored through namespaced managed-package custom objects and commonly serialized as DataPack JSON. Do not mistake either representation for runtime input/output data JSON.

## Object and JSON evidence

Resolve the installed namespace first; examples below require that verified prefix:

| Concern | Legacy custom-object family example |
|---|---|
| OmniScript | `<ns>__OmniScript__c`, `<ns>__Element__c` |
| compiled/definition or saved state | `<ns>__OmniScriptDefinition__c`, `<ns>__OmniScriptInstance__c` where present |
| DataRaptor / Data Mapper | `<ns>__DRBundle__c`, `<ns>__DRMapItem__c` |
| FlexCard | `<ns>__VlocityCard__c` and related configuration such as `<ns>__GeneralSettings__c` where present |
| deployment-bundle discovery | `<ns>__VlocityDataPack__c` where installed; evidence of a package record, not proof that an export is complete or executable |

Package generation and cloud can alter the installed namespace and available objects. Describe before querying. Persisted configuration JSON inside fields, an exported DataPack document, and runtime data JSON have different schemas, identifiers, ordering, and safe-handling requirements. Preserve the raw authoritative export, tool version, project manifest, namespace, and hashes before parsing or normalizing it.

## DataPack lane

For authoritative legacy DataPack assets, use the supported OmniStudio Build Tool path (formerly the Vlocity Build Tool) and pin its version. Dependency plans must use stable DataPack keys and explicitly account for version/activation relationships. Export success does not prove completeness; import success does not prove active runtime behavior.

Do not send standard-object metadata to the DataPack lane merely because Managed Package Runtime is enabled. Do not send legacy custom-object configuration to Metadata API merely because a similarly named standard metadata type exists.

## Official sources and freshness

Checked 2026-08-28; re-check for the installed package and target Salesforce release:

- Salesforce Developers, [Migrate From Managed Package Runtime to the OmniStudio Standard Runtime](https://developer.salesforce.com/blogs/2026/08/migrate-from-managed-package-runtime-to-the-omnistudio-standard-runtime)
- Salesforce Developers, [OmniStudio Deployments Made Easier](https://developer.salesforce.com/blogs/2026/02/omnistudio-deployments-made-easier-whats-coming-on-the-salesforce-roadmap)
- Salesforce Help, [OmniStudio Frequently Asked Questions](https://help.salesforce.com/s/articleView?id=xcloud.os_frequently_asked_questions.htm&language=en_US&type=5)
- Salesforce Help, [Managed-Package OmniStudio sObject Descriptions](https://help.salesforce.com/s/articleView?id=sf.os_omnistudio_for_vlocity_sobject_descriptions.htm&language=en_US&type=5)

The object names are discovery aids, not proof that a given package installs them. Verify the namespace, package version, object describe results, and record access in the target org.
