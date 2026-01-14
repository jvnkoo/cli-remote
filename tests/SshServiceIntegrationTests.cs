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
        _sshService = new SshService();
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
        // Step 1: Change directory
        await _sshService.RunCommandAsync("cd /var");
        
        // Step 2: Check current directory in a separate call
        var result = await _sshService.RunCommandAsync("pwd");

        // Assert
        Assert.Equal("/var", result.Trim());
    }

    [Fact]
    public async Task ChangeSettings_ShouldReconnectWithNewData()
    {
        // Test that we can change credentials on the fly
        _sshService.SetConnectionData("127.0.0.1", "wrong_user", "wrong_pass");
        
        var result = await _sshService.RunCommandAsync("ls");

        // Assert: It should fail because of wrong credentials
        Assert.Contains("[SSH EXCEPTION]", result);
    }

    public void Dispose()
    {
        // Clean up resources after each test
        _sshService.Dispose();
    }
}