# Amiasea GitHub REST API Client

A .NET client library for the GitHub REST API, generated from GitHub's OpenAPI description.

## Overview

Amiasea GitHub REST API Client provides strongly typed C# request builders and models for interacting with the GitHub REST API.

The generated client source is maintained in this repository and compiled as a .NET library. The OpenAPI description is the source for client generation; generated C# files are checked into version control so normal builds do not need to regenerate the client.

## Requirements

- .NET SDK version specified in [`global.json`](global.json).
- Access to the configured NuGet package sources to restore dependencies.
- For publishing packages, access to the configured AWS CodeArtifact repository through GitHub Actions OIDC.

## Repository structure

- `src/Amiasea.GitHub/` — generated GitHub REST API client library.
- `test/Amiasea.GitHub.Tests/` — unit tests.
- `test/Amiasea.GitHub.IntegrationTests/` — integration tests.
- `.github/workflows/` — CI/CD workflows.

## Build and test

Restore dependencies and build the solution:

```powershell
dotnet restore Amiasea.GitHub.slnx
dotnet build Amiasea.GitHub.slnx --configuration Release
```

Run unit tests:

```powershell
dotnet test test/Amiasea.GitHub.Tests/Amiasea.GitHub.Tests.csproj --configuration Release
```

Run integration tests when the required configuration and credentials are available:

```powershell
dotnet test test/Amiasea.GitHub.IntegrationTests/Amiasea.GitHub.IntegrationTests.csproj --configuration Release
```

## Client generation

The client is generated from GitHub's REST API OpenAPI description.

Generated C# source files are committed to this repository. When updating the API description or generator configuration, regenerate the client, review the resulting source changes, and commit the updated generated files.

Ensure `.gitignore` excludes only root-level build-output directories. Generated source directories such as `Logs`, `Releases`, and `Artifacts` must remain visible to Git and be included in commits.

## Continuous integration and publishing

GitHub Actions builds the solution on pushes to the `development` branch and for version tags matching `v*`.

- **Development builds** use a development package version based on the workflow run number.
- **Release builds** validate the version tag, build and test the client, and package the library.
- **Publishing** uploads the release package to the configured AWS CodeArtifact NuGet repository.

The workflows restore dependencies from the configured NuGet sources and authenticate to AWS CodeArtifact using GitHub Actions OIDC.

## Versioning

Release tags use the `v` prefix followed by the package version, for example:

```text
v1.2.3
```

The release workflow validates the tag before building and publishing the package.

## License

See the repository's license file, if present.