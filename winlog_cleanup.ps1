$servers = Get-Content C:\servers.txt

foreach($server in $servers)
{
    
    if( Get-Service -ComputerName $server -Name "logstash-forwarder-master.exe" -ErrorAction SilentlyContinue)
    {
        $i = Get-WmiObject -ComputerName $server win32_logicaldisk | where { $_.DeviceId -match "L:" } | select FreeSpace
        $before = $i.FreeSpace.ToString()
        Write-Host "Before $server disk freespace is $before"
        sc.exe \\$server stop logstash-forwarder | Out-Null
        sleep 5
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

        $z = Get-WmiObject -ComputerName $server win32_logicaldisk | where { $_.DeviceId -match "L:" } | select FreeSpace
        $after = $z.FreeSpace.ToString()
        Write-Host "After $server disk freespace is $after"
        $gained = $after - $before
        Write-Host "$server space gained $gained"
        sc.exe \\$server start logstash-forwarder | Out-Null
    }
    else
    {
        $i = Get-WmiObject -ComputerName $server win32_logicaldisk | where { $_.DeviceId -match "L:" } | select FreeSpace
        $before = $i.FreeSpace.ToString()
        Write-Host "Before $server disk freespace is $before"

        $files = Get-ChildItem -Path "\\$server\l$\IISLOG" -Filter *.log -Recurse
    
        foreach ($file in $files)
        {
            Remove-Item -Path $file.FullName -Force -ErrorAction SilentlyContinue
        }

        $z = Get-WmiObject -ComputerName $server win32_logicaldisk | where { $_.DeviceId -match "L:" } | select FreeSpace
        $after = $z.FreeSpace.ToString()
        Write-Host "After $server disk freespace is $after"
        $gained = $after - $before
        Write-Host "$server space gained $gained"

    }
}
