# Releasing ris-ktx2 as a vcpkg port

The port source lives in [`ports/ris-ktx2`](./ports/ris-ktx2) and is published to the registry
[`luka712/ris-vcpkg-registry`](https://github.com/luka712/ris-vcpkg-registry) by GitHub Actions
([`publish.yml`](./.github/workflows/publish.yml)).

| Push to | GitHub release | Registry branch | vcpkg version |
| --- | --- | --- | --- |
| `develop` | pre-release `v<version>-dev.<run>` | `develop` | `<version>-dev.<run>` |
| `main` | release `v<version>` | `main` | `<version>` |

One-time setup: add a repository secret `REGISTRY_TOKEN` (fine-grained PAT, *Contents: read & write* on the registry repo).

## Releasing

1. Bump the version in `CMakeLists.txt`, `vcpkg.json` and `ports/ris-ktx2/vcpkg.json` (all three must match) and update `CHANGELOG.md`.
2. Merge the feature branch into `develop`. A pre-release is published automatically. Try it (see below).
3. Merge `develop` into `main`. The release `v<version>` is published. The workflow fails if that tag already exists, so always bump first.

## Using the registry

`vcpkg-configuration.json` of a consumer project:

```json
{
  "registries": [
    {
      "kind": "git",
      "repository": "https://github.com/luka712/ris-vcpkg-registry",
      "reference": "main",
      "baseline": "<commit sha of the registry>",
      "packages": [ "ris-ktx2" ]
    }
  ]
}
```

Use `"reference": "develop"` to consume pre-releases. Then add `"ris-ktx2"` to the project's `vcpkg.json`
dependencies and use `find_package(ris_ktx2 CONFIG REQUIRED)` / `ris_ktx2::ris_ktx2`.

## Testing the port locally

```bash
vcpkg install ris-ktx2 --overlay-ports=./ports                              # static (x64-linux)
vcpkg install ris-ktx2 --overlay-ports=./ports --triplet x64-linux-dynamic  # shared
```

(This needs a pushed tag matching the version; the placeholder SHA512 in the repo copy of the portfile is
replaced by `scripts/publish_to_registry.sh` during publishing.)

## Submitting to the curated microsoft/vcpkg registry (optional, later)

Copy `ports/ris-ktx2` into a fork of `microsoft/vcpkg`, run `vcpkg format-manifest`, `vcpkg x-add-version ris-ktx2`,
and open a PR titled `[ris-ktx2] add new port`.
