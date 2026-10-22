using Amiasea.GitHub;
using Microsoft.Kiota.Abstractions;
using Microsoft.Kiota.Abstractions.Authentication;
using Microsoft.Kiota.Http.HttpClientLibrary;

namespace Amiasea.GitHub.IntegrationTests;

public class AuthenticatedUserTests
{
    [Fact]
    public async Task GetCurrentUser_WithGitHubToken_ReturnsAuthenticatedUser()
    {
        var token = Environment.GetEnvironmentVariable("GITHUB_TOKEN");

        Assert.False(
            string.IsNullOrWhiteSpace(token),
            "Set the GITHUB_TOKEN environment variable before running integration tests.");

        var tokenProvider = new TestAccessTokenProvider(token!);
        var authenticationProvider =
            new BaseBearerTokenAuthenticationProvider(tokenProvider);

        var adapter = new HttpClientRequestAdapter(authenticationProvider);
        var client = new GitHubApiClient(adapter);

        var response = await client.User.GetAsUserGetResponseAsync();

        Assert.NotNull(response);

        var login = response.PrivateUser?.Login
            ?? response.PublicUser?.Login;

        Assert.False(
            string.IsNullOrWhiteSpace(login),
            "GitHub returned a user response without a login.");
    }

    private sealed class TestAccessTokenProvider : IAccessTokenProvider
    {
        private readonly string _token;

        public TestAccessTokenProvider(string token)
        {
            _token = token;
            AllowedHostsValidator =
                new AllowedHostsValidator(["api.github.com"]);
        }

        public AllowedHostsValidator AllowedHostsValidator { get; }

        public Task<string> GetAuthorizationTokenAsync(
            Uri uri,
            Dictionary<string, object>? additionalAuthenticationContext = default,
            CancellationToken cancellationToken = default)
        {
            return Task.FromResult(_token);
        }
    }
}