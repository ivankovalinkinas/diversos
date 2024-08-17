#===============================================================================================#
# https://learn.microsoft.com/pt-br/dotnet/api/system.net.http.httpclient?view=netframework-4.5 #
#===============================================================================================#
# Descrição: Script básico em powershell destinado ao estudo de enumeração de sites.            #
# Desenvolvido por: Ivan Barbosa Kovalinkinas                                                   #
# Versão: 1.0.0 Beta                                                                            #
# Data: 17/08/2024                                                                              #
#===============================================================================================#

Add-Type -AssemblyName 'System.Net.Http'
$requisicao = New-Object System.Net.Http.HttpClient
$fuzz = $null
# "CAMINHO_PARA_O_DICIONARIO" > Exemplo: C:\Temp\common.txt"
$dicionario = Get-Content "CAMINHO_PARA_O_DICIONARIO"
# Site alvo para os testes
$site = 'http://site.com.br/'

foreach( $fuzz in $dicionario ){
    $uri = $site + $fuzz
    [int]$statusCode = (($requisicao.GetAsync($uri).Result).StatusCode).value__
    if( $statusCode -eq 404 ){
        continue
    } else {
        Write-Output "$uri - StatusCode: $statusCode"
    }
}
