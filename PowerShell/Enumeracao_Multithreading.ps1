#===============================================================================================#
# https://learn.microsoft.com/en-us/dotnet/api/system.management.automation.runspaces           #
# https://learn.microsoft.com/en-us/dotnet/api/system.management.automation.powershell          #
#===============================================================================================#
# Descrição: Script powershell destinado ao estudo de enumeração de sites utilizando multiplas  #
# instâncias de execução aproveitando melhor a capacidade da CPU e lagura de banda da internet. #
# Desenvolvido por: Ivan Barbosa Kovalinkinas                                                   #
# Versão: 1.0.0 Beta                                                                            #
# Data: 26/08/2024                                                                              #
#===============================================================================================#
[datetime]$startScript = Get-Date

Add-Type -AssemblyName System.Management.Automation

# "CAMINHO_PARA_O_DICIONARIO" > Exemplo: C:\Temp\common.txt"
[string]$arquivo = 'C:\Temp\common.txt'

# Quantidade de partes que o dicionário será fragmentado 
[int]$numParts = 500

function Run_Spaces {
    param (
        [array]$dicionario
    )

    $scriptPowershell = {
        param($words)
        Add-Type -AssemblyName System.Net.Http
        $requisicao = New-Object System.Net.Http.HttpClient
        
        # SITE ALVO PARA OS TESTES
        [string]$site = 'https://www.<SITE>.com/'
        
        foreach ($fuzz in $words) {
            $uri = $site + $fuzz
            [int]$statusCode = (($requisicao.GetAsync($uri).Result).StatusCode).value__
            if( ($statusCode -eq 404) -or ($statusCode -eq 0) ){
                continue
            } else {
                Write-Output "$uri - StatusCode: $statusCode"
            }
        }
    }

    $runSpace = [runspaceFactory]::CreateRunspace()
    $runSpace.Open()
    $powershell = [PowerShell]::Create()
    $powershell.Runspace = $runSpace
    $powershell.AddScript($scriptPowershell).AddArgument($dicionario) | Out-Null
    $resultado = $powershell.BeginInvoke()

    return @{
        Runspace = $runSpace
        PowerShell = $powershell
        AsyncResult = $resultado
    }
}

$content = Get-Content -Path $arquivo

$partSize = [Math]::Ceiling($content.Count / $numParts)
$parts = @()

for ($i = 0; $i -lt $numParts; $i++) {
    $start = $i * $partSize
    $end = [Math]::Min(($i + 1) * $partSize, $content.Count)
    $part = $content[$start..($end-1)]
    $parts += ,$part
}

$jobs = @()
for ($i = 0; $i -lt $parts.Count; $i++) {
    $job = Run_Spaces -dicionario $parts[$i]
    $jobs += $job
}

$results = @()
foreach ($job in $jobs) {
    $results += $job.PowerShell.EndInvoke($job.AsyncResult)
    $job.Runspace.Close()
    $job.Runspace.Dispose()
    $job.PowerShell.Dispose()
}

$results | ForEach-Object { $_ }

[datetime]$endScript = Get-Date
[int]$tempoExecucao = (($endScript - $startScript).Seconds)
Write-Output "O tempo total de execução foi de $tempoExecucao segundos."
