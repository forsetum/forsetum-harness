# Upstream Compatibility & Patch Management Policy — {{PROJECT_NAME}}

## 1. Upstream Compatibility Strategy

The host application `{{HOST_APPLICATION}}` operates under the source model: `{{SOURCE_MODEL}}`.
When new releases, upstream security patches, or vendor updates are deployed, all local customizations must remain intact and functional.

## 2. Surgical Patch Management

If a bug fix must touch upstream code due to the absence of appropriate hooks:

1. **Standard Patch Format:** All upstream changes must be exported to standalone patch files:
   ```bash
   git diff upstream/main > patches/0001-fix-critical-bug.patch
   ```
2. **Automated Re-apply:** Provide an automated verification step to re-apply patches post-update:
   ```bash
   git apply --check patches/0001-fix-critical-bug.patch
   ```
3. **Patch Documentation:** Document the patch rationale, issue tracker ID, and upstream issue link.

## 3. Third-Party Dependency Isolation

- New libraries required by custom modules must not downgrade or conflict with core dependencies required by `{{HOST_APPLICATION}}`.
- Utilize isolated environments, module-local vendor directories, or containerized namespaces.
