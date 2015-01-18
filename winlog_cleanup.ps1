$servers = Get-Content C:\servers.txt
$logstashService = "logstash-forwarder-master.exe"

Function ServiceActions($server, $action, $servicename)
{
    SC.EXE \\$server $action $servicename | Out-Null
    sleep 5
}

Function GetDiskSpaceWmi ($server, $servicename)
{
    $i = Get-WmiObject -ComputerName $server win32_logicaldisk | where { $_.DeviceId -match "L:" } | select FreeSpace
    $freeSpaceInDrive = $i.FreeSpace.ToString()
    Write-Host "Before $server disk freespace is $freeSpaceInDrive"
    return $freeSpaceInDrive
}

Function DeleteLogs($server)
{
    $files = Get-ChildItem -Path "\\$server\l$\IISLOG" -Filter *.log -Recurse
    
    foreach ($file in $files)
    {
        Remove-Item -Path $file.FullName -Force -ErrorAction SilentlyContinue
    }


    $files = Get-ChildItem -Path "\\$server\l$" -Filter *.txt -Recurse
    
    foreach ($file in $files)
    {
        Remove-Item -Path $file.FullName -Force -ErrorAction SilentlyContinue
    }
}

foreach($server in $servers)
{
    
    if( Get-Service -ComputerName $server -Name $logstashService -ErrorAction SilentlyContinue)
    {
        $before = GetDiskSpaceWmi($server,$logstashService)
        ServiceActions($server, "stop", $logstashService)
        DeleteLogs($server)
        $after = GetDiskSpaceWmi($server,$logstashService)
        $gained = $after - $before
        Write-Host "$server space gained $gained"
        ServiceActions($server, "start", $logstashService)
    }
    else
    {
        $before = GetDiskSpaceWmi($server,$logstashService)
        DeleteLogs($server)
        $after = GetDiskSpaceWmi($server,$logstashService)
        $gained = $after - $before
        Write-Host "$server space gained $gained"
    }
}
