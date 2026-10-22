# Amiasea.GitHub

A strongly typed .NET client for the [GitHub REST API](https://docs.github.com/en/rest).

## Installation

Install the package from your configured NuGet feed:

```powershell
dotnet add package Amiasea.GitHub
```

## Features

- Strongly typed request builders for GitHub REST API endpoints.
- Generated C# models for API requests and responses.
- Integration with the .NET ecosystem through Microsoft Kiota.
- Support for configuring authentication, HTTP transport, and request behavior through the Kiota abstractions.

## Usage

Create a client with a configured request adapter, then use its request builders to call GitHub API endpoints.

For example, once you have configured a `GitHub` client instance:

```csharp
var repositories = await gitHubClient.User
    .Repositories
    .GetAsync();
```

The client must be configured with an appropriate request adapter and authentication provider before making authenticated API calls. Consult the [GitHub REST API documentation](https://docs.github.com/en/rest) for endpoint behavior, permissions, and authentication requirements.

## Authentication and permissions

GitHub API access may require a personal access token, GitHub App authentication, or another supported authentication mechanism. Configure credentials securely, following GitHub's guidance:

- [Authenticating to the REST API](https://docs.github.com/en/rest/authentication/authenticating-to-the-rest-api)
- [REST API permissions](https://docs.github.com/en/rest/overview/permissions-required-for-fine-grained-personal-access-tokens)

Grant only the permissions required for the operations your application performs.

## Documentation

- [GitHub REST API reference](https://docs.github.com/en/rest)
- [Microsoft Kiota documentation](https://learn.microsoft.com/en-us/openapi/kiota/)