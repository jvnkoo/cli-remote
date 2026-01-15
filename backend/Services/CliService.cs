namespace backend.Services;

using CliWrap;
using CliWrap.Buffered;

/// <summary>
/// the old way of interacting with cli(now use ssh)
/// </summary>
public class CliService
{
    // Save current directory in memory
    private string _currentDirectory = Directory.GetCurrentDirectory();
    private string? _sudoPassword; // Save in memory only before restart
    
    public void SetSudoPassword(string password)
    {
        _sudoPassword = password;
    }
    
    public async Task<String> RunCommandAsync(string command, bool useSudo = false, string? sudoPassword = null, string? workingDirectory = null)
    {
        if (useSudo)
        {
            if (string.IsNullOrEmpty(sudoPassword))
            {
                return "[ERROR]: Sudo password not set. Use 'Set Password' first.";
            }
            command = $"echo '{sudoPassword}' | sudo -S {command}";
        }
        
        var (shell, args) = ("/bin/sh", $"-c \"{command}\"");
        
        try
        {
            var result = await Cli.Wrap(shell)
                .WithArguments(args)
                .WithWorkingDirectory(workingDirectory)
                .WithValidation(CommandResultValidation.None)
                .ExecuteBufferedAsync();

            return FormatResult(result);
        }
        catch (Exception ex)
        {
            return $"[SERVER EXCEPTION]: {ex.Message}";
        }
    }

    // private string ChangeDirectory(string command)
    // {
    //     string newPath = command.Substring(3).Trim();
    //
    //     if (newPath.StartsWith("~"))
    //     {
    //         var home = Environment.GetFolderPath(Environment.SpecialFolder.UserProfile);
    //         newPath = newPath.Replace("~", home);
    //     }
    //
    //     if (Directory.Exists(newPath))
    //     {
    //         _currentDirectory = Path.GetFullPath(newPath);
    //         return $"[Changed directory to: {_currentDirectory}]";
    //     }
    //
    //     return $"[ERROR]: Directory not found: {newPath}";
    // }
    
    private string FormatResult(BufferedCommandResult result)
    {
        string output = result.StandardOutput;
        string error = result.StandardError;

        if (string.IsNullOrWhiteSpace(output) && !string.IsNullOrWhiteSpace(error))
        {
            return $"[STDERR]: {error}";
        }

        return string.IsNullOrWhiteSpace(output) ? "[Done (no output)]" : output;
    }
}