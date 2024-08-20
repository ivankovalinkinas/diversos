#===============================================================================================#
#  https://learn.microsoft.com/en-us/dotnet/api/system.net.sockets.socket?view=net-8.0#methods  #
#===============================================================================================#
# Descrição: Script básico em powershell para verificar portas TCP abertas.                     #
# Desenvolvido por: Ivan Barbosa Kovalinkinas                                                   #
# Versão: 1.0.0 Beta                                                                            #
# Data: 20/08/2024                                                                              #
#===============================================================================================#
$server = 'www.google.com' # Endereço Destino
$ports = 1..1023 + 8080 # Range de portas (1 até 1023 e 8080)
$timeOut = 50 # Valor em milisegundos 

foreach( $port in $ports ){

    $tcp = New-Object System.Net.Sockets.TcpClient
    $tcp.ConnectAsync($server,$port).Wait($timeOut) | Out-Null
    
    if($tcp.Connected){
        Write-Output "Porta Aberta: $port"
    }

    $tcp.Close()
}
