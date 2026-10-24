# Releasing ris-ktx2 as a vcpkg port

The port lives in [`ports/ris-ktx2`](./ports/ris-ktx2). The version in `ports/ris-ktx2/vcpkg.json`,
the root `vcpkg.json` and `project(... VERSION ...)` in `CMakeLists.txt` must all match.

## 1. Cut the release

1. Bump the version in `CMakeLists.txt`, `vcpkg.json` and `ports/ris-ktx2/vcpkg.json`; update `CHANGELOG.md`.
2. Commit, push and tag: `git tag v<version> && git push origin main v<version>`.
3. Fill in the archive hash: `scripts/update_port_sha.sh <version>` and commit the change to `portfile.cmake`.

## 2. Test the port locally

```bash
vcpkg install ris-ktx2 --overlay-ports=./ports                          # static (x64-linux)
vcpkg install ris-ktx2 --overlay-ports=./ports --triplet x64-linux-dynamic  # shared
```

Consumers then use:

```cmake
find_package(ris_ktx2 CONFIG REQUIRED)
target_link_libraries(main PRIVATE ris_ktx2::ris_ktx2)
```

## 3a. Publish through your own registry (fastest, no review)

Create a git repo (e.g. `ris-vcpkg-registry`) with `ports/ris-ktx2/` and a `versions/` folder, then:

```bash
vcpkg x-add-version ris-ktx2 --x-builtin-ports-root=<registry>/ports --x-builtin-registry-versions-dir=<registry>/versions
```

Consumers add to `vcpkg-configuration.json`:

```json
{
  "registries": [
    {
      "kind": "git",
      "repository": "https://github.com/luka712/ris-vcpkg-registry",
      "baseline": "<commit sha of the registry>",
      "packages": [ "ris-ktx2" ]
    }
  ]
}
```

## 3b. Publish to the curated microsoft/vcpkg registry

1. Fork `microsoft/vcpkg`, copy `ports/ris-ktx2` into its `ports/` folder.
2. `./vcpkg format-manifest ports/ris-ktx2/vcpkg.json`
3. Commit the port, then `./vcpkg x-add-version ris-ktx2` and commit the generated `versions/` changes.
4. Open a PR titled `[ris-ktx2] add new port`. CI builds all triplets; the project needs a few real users/stars
   to be accepted, and `supports` expressions may be needed if some platforms fail.
