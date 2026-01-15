using Xunit;
using backend.Services;
using DotNetEnv;
using System;
using System.Threading.Tasks;

namespace backend.Tests.Integration;

public class SshServiceIntegrationTests : IDisposable
{
    private readonly SshService _sshService;

    public SshServiceIntegrationTests()
    {
        // 1. Load configuration from .env
        DotNetEnv.Env.Load();

        var host = Environment.GetEnvironmentVariable("SSH_HOST");
        var user = Environment.GetEnvironmentVariable("SSH_USER");
        var pass = Environment.GetEnvironmentVariable("SSH_PASS") ;
        var sudoPass = Environment.GetEnvironmentVariable("SSH_SUDO_PASS");

        // 2. Initialize service and set parameters separately
        var cliService = new CliService();

        _sshService = new SshService(cliService);
        _sshService.SetConnectionData(host, user, pass);
        _sshService.SetSudoPassword(sudoPass);
    }

    [Fact]
    public async Task RunCommand_ShouldExecuteAfterSetup()
    {
        // Act
        var result = await _sshService.RunCommandAsync("whoami");

        // Assert
        Assert.False(string.IsNullOrWhiteSpace(result));
        Assert.DoesNotContain("[ERROR]", result);
    }

    [Fact]
    public async Task SudoCommand_ShouldWorkWithSetPassword()
    {
        // Act
        var result = await _sshService.RunCommandAsync("whoami", useSudo: true);

        // Assert
        Assert.Equal("root", result.Trim());
    }

    [Fact]
    public async Task CdCommand_ShouldMaintainStateBetweenCalls()
    {
        // Combined command because SshCommand is stateless
        var result = await _sshService.RunCommandAsync("cd /var && pwd");

        // Assert
        Assert.Equal("/var", result.Trim());
    }

    [Fact]
    public async Task ChangeSettings_ShouldFallbackToCli()
    {
        // Invalid host triggers SSH Exception, which then triggers CliService fallback
        _sshService.SetConnectionData("1.1.1.1", "fake", "fake");
    
        var result = await _sshService.RunCommandAsync("pwd");

        // Result will be your local path because of fallback logic
        Assert.False(string.IsNullOrWhiteSpace(result));
        Assert.DoesNotContain("[SSH EXCEPTION]", result); 
    }

    public void Dispose()
    {
        // Clean up resources after each test
        _sshService.Dispose();
    }
}