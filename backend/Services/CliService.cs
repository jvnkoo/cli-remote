namespace backend.Services;

using CliWrap;
using CliWrap.Buffered;

public class CliService
{
    public async Task<String> RunCommandAsync(string command)
    {
        List<String> commandArguments = command.Split(' ').ToList();
        
        string binary = commandArguments[0];
        
        commandArguments.RemoveAt(0);

        var result = await Cli.Wrap(binary)
            .WithArguments(commandArguments)
            .ExecuteBufferedAsync();

        return result.StandardOutput;
    }
}