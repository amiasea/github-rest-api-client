using Amiasea.GitHub;
using Microsoft.Kiota.Abstractions;
using Microsoft.Kiota.Abstractions.Authentication;
using Microsoft.Kiota.Http.HttpClientLibrary;
using Xunit;

namespace Amiasea.GitHub.Tests.Attestations;

public class OrganizationAttestationsTests
{
  [Fact]
  public void DeleteById_UsesAttestationIdRoute()
  {
    var adapter = new HttpClientRequestAdapter(
        new AnonymousAuthenticationProvider())
    {
      BaseUrl = "https://api.github.com"
    };

    var client = new GitHubApiClient(adapter);

    var request = client.Orgs["example-org"]
        .Attestations[12345]
        .ToDeleteRequestInformation();

    Assert.Equal(Method.DELETE, request.HttpMethod);
    Assert.Equal(
        "https://api.github.com/orgs/example-org/attestations/12345",
        request.URI.AbsoluteUri);
  }

  [Fact]
  public void DeleteBySubjectDigest_UsesDigestRoute()
  {
    var adapter = new HttpClientRequestAdapter(
        new AnonymousAuthenticationProvider())
    {
      BaseUrl = "https://api.github.com"
    };

    var client = new GitHubApiClient(adapter);

    const string digest = "sha256:0123456789abcdef";

    var request = client.Orgs["example-org"]
        .Attestations.Digest[digest]
        .ToDeleteRequestInformation();

    Assert.Equal(Method.DELETE, request.HttpMethod);
    Assert.Equal(
      "https://api.github.com/orgs/example-org/attestations/digest/sha256%3A0123456789abcdef",
      request.URI.AbsoluteUri);
  }
}