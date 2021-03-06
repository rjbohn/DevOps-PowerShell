<#
	This script is meant to export a public folder from outlook into a PST.
	It requires that you have outlook installed on a machine AND have a configured exchange profile.

	last updated: 05/14/2013 Gil
#>

param ($pstPath = "C:\temp", $topFolderName="GilsPFs")

#define location of PST
	$pstFQDN = $pstPath + "\" + $topFolderName + ".pst"

#Open up outlook
	[Reflection.Assembly]::LoadWithPartialname("Microsoft.Office.Interop.Outlook") | out-null
	$Outlook = New-Object -comobject Outlook.Application
	$olFolders = "Microsoft.Office.Interop.Outlook.OlDefaultFolders" -as [type]
	$namespace = $Outlook.GetNameSpace("MAPI")

#add pst path to outlook
	$namespace.AddStore($pstFQDN)
	$pstFolder = $namespace.Session.Folders.GetLast()

#Grab the PFs and save it
	$folders = $namespace.getDefaultFolder($olFolders::olPublicFoldersAllPublicFolders)
	$pfFolders = $folders.Folders.Item($domain)
	$pfFolders.CopyTo($pstFolder)
	$pstFolder.Name = "$domain PF dump"

#Attach PST to new profile
	$namespace.AddStore($pstFQDN)
	$pstFolder = $namespace.Session.Folders.GetLast()

#Grab content from PST
	$folders = $namespace.getDefaultFolder($olFolders::olPublicFoldersAllPublicFolders)
	$pfFolders = $folders.Folders.Item($domain)	 #this should probably be root.
	$pstFolder = $pstFolder.Folders.Item($domain)
	$pstFolder.CopyTo($pfFolders)