namespace backend.Services;

public class SystemInfoService
{
    public string GetPrettyOsName()
    {
        if (File.Exists("/etc/os-release"))
        {
            var lines = File.ReadAllLines("/etc/os-release");
            var line = lines.FirstOrDefault(l => l.StartsWith("PRETTY_NAME="));
            return line?.Replace("PRETTY_NAME=", "").Trim('"');
        }

        return "N/A";
    }

    public string GetRamUsage()
    {
        var lines = File.ReadAllLines("/proc/meminfo");
        var memTotalStr = lines.FirstOrDefault(l => l.StartsWith("MemTotal"))?
            .Split(' ', StringSplitOptions.RemoveEmptyEntries)[1];
        var memAvailStr = lines.FirstOrDefault(l => l.StartsWith("MemAvailable"))?
            .Split(' ', StringSplitOptions.RemoveEmptyEntries)[1];

        if (double.TryParse(memTotalStr, out double total) && double.TryParse(memAvailStr, out double avail))
        {
            var used = (total - avail) / 1024 / 1024;
            return $"{used:F1} GB";
        }
        return "N/A";
    }

    public async Task<string> GetCpuLoadAsync()
    {
        var rawLoad = await File.ReadAllTextAsync("/proc/loadavg");
        double loadAvg = double.Parse(rawLoad.Split(' ')[0], System.Globalization.CultureInfo.InvariantCulture);

        int coreCount = Environment.ProcessorCount;

        double cpuPercentage = (loadAvg / coreCount) * 100;

        if (cpuPercentage > 100) cpuPercentage = 100;

        return $"{cpuPercentage:F1}%";
    }
}