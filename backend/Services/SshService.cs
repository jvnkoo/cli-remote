namespace backend.Services;

using System.Text.RegularExpressions;
using System.Threading.Tasks.Dataflow;
using Renci.SshNet;

public class SshService
{
    private SshClient? _client;
    private ShellStream? _shellStream;
    private string _currentDirectory = "";
    private string? _sudoPassword;

    private string _host;
    private string _user;
    private string _pass;

    private readonly CliService _cliService;

    public SshService(CliService cliService)
    {
        _cliService = cliService;
    }

    public void SetConnectionData(string host, string user, string pass)
    {
        _host = host;
        _user = user;
        _pass = pass;

        Dispose();
        _client = null;
        _shellStream = null;
    }

    public void SetSudoPassword(string password) => _sudoPassword = password;

    private void EnsureConnected()
    {
        if (string.IsNullOrEmpty(_host) || string.IsNullOrEmpty(_user) || string.IsNullOrEmpty(_pass))
        {
            throw new InvalidOperationException("Connection data (host, user, pass) is not set.");
        }

        if (_client == null || !_client.IsConnected)
        {
            _client = new SshClient(_host, _user, _pass);
            _client.Connect();
            // Create a shell thread to maintain state (cd, sudo)
            _shellStream = _client.CreateShellStream("xterm", 80, 24, 800, 600, 1024);
        }
    }

    public async Task<string> RunCommandAsync(string command, bool useSudo = false)
    {
        try
        {
            if (!string.IsNullOrEmpty(_host)) 
            {
                EnsureConnected(); 
            }
            else 
            {
                return await _cliService.RunCommandAsync(command, useSudo, _sudoPassword, _currentDirectory);
            }

            if (command.StartsWith("cd ") || command.StartsWith("sudo cd"))
            {
                return HandleCdCommand(command, useSudo);
            }

            string result = useSudo
                ? await ExecuteSudoAsync(command)
                : await ExecuteStandartAsync(command);

            if (result.Contains("Authorization required") || result.Contains("cannot open display"))
            {
                return await _cliService.RunCommandAsync(command, useSudo, _sudoPassword, _currentDirectory);
            }

            return result;
        }
        catch (Exception ex)
        {
            return await _cliService.RunCommandAsync(command, useSudo, _sudoPassword, _currentDirectory);
        }
    }

    private string HandleCdCommand(string command, bool useSudo)
    {
        string targetPath = useSudo ? command.Substring(8).Trim() : command.Substring(3).Trim();

        if (targetPath.StartsWith("~"))
        {
            targetPath = targetPath.Replace("~", "$HOME");
        }

        SshCommand checkCmd;

        string baseDir = !string.IsNullOrEmpty(_currentDirectory) ? _currentDirectory : ".";

        if (useSudo)
        {
            string sudoCmd = $"echo '{_sudoPassword}' | sudo -S sh -c 'cd \"{baseDir}\" && cd \"{targetPath}\" && pwd'";
            checkCmd = _client.CreateCommand(sudoCmd);
        }
        else
        {
            string normalCmd = $"sh -c 'cd \"{baseDir}\" && cd \"{targetPath}\" && pwd'";
            checkCmd = _client.CreateCommand(normalCmd);
        }

        var absolutePath = checkCmd.Execute().Trim();

        if (!string.IsNullOrEmpty(absolutePath) && absolutePath.StartsWith("/"))
        {
            _currentDirectory = absolutePath;
            return $"[Changed directory to: {_currentDirectory}]";
        }

        return $"[ERROR]: Directory not found: {targetPath}";
    }

    private async Task<string> ExecuteStandartAsync(string command)
    {
        // use RunCommand for common operations(faster and easier)
        var sshCmd = _client!.CreateCommand($"cd {_currentDirectory} && sh -c '{command}'");
        var result = await Task.Factory.FromAsync(sshCmd.BeginExecute(), sshCmd.EndExecute);

        return string.IsNullOrWhiteSpace(result) && !string.IsNullOrEmpty(sshCmd.Error)
            ? $"[STDERR]: {sshCmd.Error}"
            : (string.IsNullOrWhiteSpace(result) ? "[Done]" : result);
    }

    private async Task<string> ExecuteSudoAsync(string command)
    {
        var fullCommand = $"cd {_currentDirectory} && echo '{_sudoPassword}' | sudo -S sh -c '{command}'";

        var sshCmd = _client!.CreateCommand(fullCommand);

        var result = await Task.Factory.FromAsync(sshCmd.BeginExecute(), sshCmd.EndExecute);

        if (!string.IsNullOrEmpty(sshCmd.Error))
        {
            var cleanError = sshCmd.Error.Replace($"[sudo] password for {_user}:", "").Trim();
            if (!string.IsNullOrEmpty(cleanError))
            {
                return $"[STDERR]: {cleanError}";
            }
        }

        return string.IsNullOrWhiteSpace(result) ? "[Done]" : result;
    }

    public void Dispose()
    {
        _shellStream?.Dispose();
        _shellStream = null;
        _client?.Disconnect();
        _client?.Dispose();
        _client = null;
    }
}