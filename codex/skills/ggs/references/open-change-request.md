# Open a Pull or Merge Request

Read [provider-routing.md](provider-routing.md) before interacting with the host.

## Prepare

1. Inspect the current branch, upstream, remotes, worktree, and commit range.
2. Detect and verify the target branch; do not assume the remote default is correct
   when the work is based on another feature branch.
3. Run the repository's required local verification.
4. Confirm commits are atomic and follow repository message conventions.
5. Locate the provider's pull or merge request template and read it in full.

Common template locations include `.github/PULL_REQUEST_TEMPLATE.md`,
`.github/PULL_REQUEST_TEMPLATE/*.md`, and
`.gitlab/merge_request_templates/*.md`. Also inspect project instructions for custom
locations.

## Compose

Derive a leading ticket from the branch when present. Use a concise, imperative title:

```text
TICKET-1234: Add OAuth authentication
```

When a project template exists, preserve its headings and instructions, fill only
relevant sections, and remove optional placeholders only when the template permits it.
Do not add custom sections or generator footers.

When no template exists, use only relevant Keep-a-Changelog categories:

```markdown
### Added
- Add OAuth authentication with PKCE.

### Changed
- Route login through the new authorization flow.

### Fixed
- Prevent stale sessions after token refresh; verify with session tests.
```

Explain cause, fix, and verification for substantive bug fixes. Base the description
on the complete diff and commit range, not only the latest commit.

## Publish

Push the current branch only when remote publication is within the request. Open the
change request through the selected provider interface and set the verified target.
Create it as a draft when the provider supports drafts, unless the user or project
policy says otherwise.

Apply labels, milestones, reviewers, and assignees only when requested or required by
repository policy. Do not carry GitLab-specific assignment conventions to other hosts.

Inspect remote checks after creation. Mark the change request ready only when required
checks pass, the description is complete, and the user's requested workflow includes
the ready transition; otherwise leave it as a draft and report what remains.
