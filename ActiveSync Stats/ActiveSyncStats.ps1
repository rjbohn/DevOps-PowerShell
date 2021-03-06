<#
	This report will use exchange cmdlets to get data about activesync stats.
	Once the active sync counters are found we format them properly to make a report.
	
	Example report is in HTML file.
	
	LAST modified 11/30/10 GF
#>
	#Add exchange 2010 snapin
	Add-PSSnapin Microsoft.Exchange.Management.PowerShell.E2010 -ErrorAction:SilentlyContinue
	
	#Declare array to hold devices found 
	[array]$BASKET=$null
	
	$Domain = [System.DirectoryServices.ActiveDirectory.Domain]::GetCurrentDomain()

				$allDevices = Get-ActiveSyncDevice 
			
					foreach ($device in $allDevices)
						{
							if ($device.DeviceAccessSTate -eq "Allowed")
								{
									$BASKET += $device
								}
						}
			
			
		#Format my results to include only unique ones and count similiar objects
		$formattedDT = $BASKET | Group-Object -Property DeviceType -NoElement | sort Count -Descending
		$formattedUA = $BASKET | Group-Object -Property DeviceUserAgent -NoElement | sort Count -Descending
		
		#HTML TABLE
		$date = Get-Date
		
		if($BASKET.count)
			{
				$count = $BASKET.Count
			}
		else
			{
				$count = 0
			}
		
		$HTML = "
				<html xmlns='http://www.w3.org/1999/xhtml'>
				<head>
				<meta http-equiv='Content-Type' content='text/html; charset=iso-8859-1' />
				<title>CAS Report</title>
				<link href='styles.css' rel='stylesheet' type='text/css' />
				</head>
				<H1><font color=green>ActiveSync Report</font></H2>
				<body><font face='verdana' size='3'>
				This report ran on $date
				<BR>I found <B>$count</B> ActiveSync devices in your environment<BR><BR><CENTER>
				<H2>Active Devices By Device Type </H2>
				<table id='mytable' cellspacing='0' border='2' >`
				  <tr bgcolor=#666666>`
				    <th><FONT COLOR=white>Name</font></th>`
				    <th><FONT COLOR=white>Count</font></th>`
				  </tr>
				  "
			
		#Add DeviceType
		foreach ($entry in $formattedDT)
			{
				$HTML+="<TR><TD bgcolor=#cccccc>"+$entry.Name+"</TD><TD>"+$entry.Count+"</TD></TR>"		
			}
			
		#Finish Table
		$HTML += "</table>"
			
		#ADD user agent
		$HTML += "<BR><H2>Active Devices By User Agent </H2>
				<table id='mytable' cellspacing='0' border='2' >`
				  <tr bgcolor=#666666>`
				    <th><FONT COLOR=white>Name</font></th>`
				    <th><FONT COLOR=white>Count</font></th>`
				  </tr>"
		
		#ADD user agent
		foreach ($entry in $formattedUA)
			{
				$HTML+="<TR><TD bgcolor=#cccccc>"+$entry.Name+"</TD><TD>"+$entry.Count+"</TD></TR>"		
			}
			
		#Finish Table
		$HTML += "</table>"
			
		#Export HTML
		$HTML+= "</HTML>"
		
		#Get file ready and export!
		$dateFormatted = $date.Year.tostring()+"-"+$date.Month.tostring()+"-"+$date.Day.ToString()
		$filename="ActiveSyncStats-$dateFormatted"
		$HTML | Out-File c:\temp\$filename.html
	