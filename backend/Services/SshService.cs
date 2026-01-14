namespace backend.Services;

using System.Text.RegularExpressions;
using Renci.SshNet;

public class SshService
{
    private SshClient? _client;
    private ShellStream? _shellStream;
    private string _currentDirectory = "";
    private string? _sudoPassword;

    private readonly string _host;
    private readonly string _user;
    private readonly string _pass;

    public void SetSudoPassword(string password) => _sudoPassword = password;

    private void EnsureConnected()
    {
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
            EnsureConnected();

            if (command.StartsWith("cd ") || command.StartsWith("sudo cd"))
            {
                return HandleCdCommand(command, useSudo);
            }

            if (useSudo)
            {
                if (string.IsNullOrEmpty(_sudoPassword))
                    return "[ERROR]: Sudo password not set.";
                
                return await ExecuteSudoAsync(command);
            }

            return await ExecuteStandartAsync(command);
        }
        catch (Exception ex)
        {
            return $"[SSH EXCEPTION]: {ex.Message}";
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
        }        var absolutePath = checkCmd.Execute().Trim();
        
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
        _client?.Disconnect();
        _client?.Dispose();
    }
}