# Zmienna domeny
$domain = "test-test.pl"

# Grupa, której członkowie mają zachować ActiveSync
$allowedGroup = "00TG-ActiveSyncUserGroup"

# Pobieranie wszystkich użytkowników z domeny
$allUsers = Get-Mailbox -ResultSize Unlimited | Where-Object {$_.PrimarySmtpAddress -like "*@$domain"}

# Filtrowanie użytkowników, którzy nie są w grupie
$usersToDisable = $allUsers | Where-Object { $_.SamAccountName -notIn (Get-ADGroupMember $allowedGroup -Recursive).SamAccountName }

# Wyłączanie ActiveSync dla wybranych użytkowników i przygotowywanie logów
$enabledUsersLog = @()
foreach ($user in $allUsers) {
    if ($user.SamAccountName -in (Get-ADGroupMember $allowedGroup -Recursive).SamAccountName) {
        # Dodawanie użytkowników z włączonym ActiveSync do logu
        $enabledUsersLog += $user | Select DisplayName, ActiveSyncEnabled
    } else {
        # Wyłączanie ActiveSync dla użytkowników niebędących w grupie
        Set-CASMailbox -Identity $user.Identity -ActiveSyncEnabled $false
    }
}

# Zapisywanie logu z datą
$logFileName = "C:\Logs\ExchangeActiveSyncLog_" + (Get-Date -Format "yyyyMMdd") + ".txt"
$enabledUsersLog | Export-Csv -Path $logFileName -NoTypeInformation

# Wypisanie logu
Write-Host "Log zapisany w pliku: $logFileName"

exit 
