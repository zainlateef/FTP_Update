#Author: Zain Lateef Email:zlateefwps@gmail.com


#Config Block: These values must be configured correctly-------------------------------------------------

#MAIN SETTINGS

$up_path='C:\Users\DMG\Downloads\' #where the main update folder will exist on the computer (target for file upload)

$up_dir='Update' #name of the main update folder 

$server='ftp.divmedia.net' #ftp server domain name

$UserName="zlateef" #ftp server username

$Password="four44"  #ftp server password

$e='ERROR.txt' #name of the error text file

$path_of_txt='C:\Users\DMG\Documents\FTP text accompany.txt' #path of the accompanying text file

$temp_address=$up_path+$e# a temporary path to upload a file and subsequently delete the file (can be any valid path)

#OPTIONAL SETTINGS

$uph='Update Log.txt' #name of update history file on the ftp server

$upa='Update Archive' #name of update archive on the computer

$LogN='DivUpdate'#event log name

$mill=(Get-Date).Millisecond #symbol which makes error messages in the event log different, so that many can be uploaded without entanglement

$EL_Source="($mill)DivMedia" #event log source name

$EL_Num=1 #event log ID number

$date=Get-Date -format "h:mm:ss M/dd/yy" #date format

$identity=$env:COMPUTERNAME #property used to distinguish between multiple players

$err1="Err1($mill)-$date" #name of error to throw when the file has already been uploaded onto the computer

$err2="Err2($mill)-$date"

$err3="Err3($mill)-$date"

$err4="Err4($mill)-$date"

$err_ftp=$ftp+$e
#--------------------------------------------------------------------------------------------------------

Function Get-EndInt
{
Param
([string]$a)
Process
{
$len=$a.length 
$chars=$a.ToCharArray()
$count=0
$check=$true
$targ=""
while($check)
{
$count++
$temp=[int][char]$chars[($len-$count)]
  if($temp -in 48..57)
   {
    $targ=$targ+$chars[($len-$count)]
   }
  else
   {
    $check=$false
   }
}
$temp=$targ.ToCharArray()
[array]::Reverse($temp)
$result=-join$temp
"$result"
}
}

Function Delete-FTPFile
{
Param
([string]$ftp)
Process
{
$uri = New-Object System.Uri($ftp) 
$ftprequest = [System.Net.FtpWebRequest]::create($uri)
$ftprequest.Method  = [System.Net.WebRequestMethods+Ftp]::DeleteFile
$ftprequest.GetResponse()
}

}

Function Upload-Txt
{
Param
([string]$ftp,[string]$text)
Process
{
$file=New-Item $temp_address -Type File
Set-Content $temp_address $text
$uri= New-Object System.Uri($ftp)
$webclient.UploadFile($uri,$file)
Remove-Item $temp_address
}
}

Function Super-EventLog
{
Param
([string]$ET,[int]$Id,[string]$Message)
Process
{
$LN=$LogN
$S=$EL_Source
$logFileExists = Get-EventLog -list | Where-Object {$_.logdisplayname -eq $LogN} 
if (!$logFileExists) 
{
   New-EventLog -LogName $LN -Source $S
}
New-EventLog -LogName $LN -Source $S
Write-EventLog -LogName $LN -Source $S -EntryType $ET -EventId $Id -Message $Message
}
}

#Delete Error file if it is found on the server
<#$eftp = "ftp://${Username}:$Password@$server/$e"
Delete-FTPFile $eftp#>

#Get the name of the file(s) on the server
if((Get-Content $path_of_txt).Length -eq 0)
{$FileonComp='/////'}
else
{$FileonComp=Get-Content $path_of_txt}
$ftp="ftp://${Username}:$Password@$server/"
$uri=New-Object System.Uri($ftp)
$webclient=New-Object System.Net.WebClient;
$WR=[system.net.webrequest]::createdefault($ftp)
$WR.method=[system.net.webrequestmethods+ftp]::listdirectory
$res=$WR.getresponse()
$str=$res.getresponsestream()
$rdr=new-object system.io.streamreader($str,'ascii')
$Update=($rdr.readtoend())
$str.Close()
$str.Dispose()

#Format name of the file to be stored in a string
$Update=$Update -replace "$uph","";
$temp_up=$Update
$temp_up | ? {$_.trim() -ne ""}| Out-File $temp_address
$temp_up=Get-Content $temp_address
Remove-Item $temp_address
$num=$temp_up | Measure-Object -Line | Select -ExpandProperty Lines
$Update=$Update -replace "`t|`r|`n","";
$without_ext=$Update -replace ".zip",""

if($num -eq 0)
{Exit}

#If the update does not contain a zip file, upload error text file
if(!$Update.Contains(".zip"))
{
<#
Upload-Txt -ftp $err_ftp -text $err3mess
#>
$err3mess="Error3 on $identity : $Update is not a zip file. FTP Update Directory must contain a single zip file"
Super-EventLog -ET Error -Id $EL_Num -Message $err3mess
Exit
}

#If the number of files on the server is not 1, upload error text file
if($num -ne 1)
{
<#Upload-Txt -ftp $err_ftp -text $err2mess#>
$err2mess="Error2 on $identity : Too many files on the server. FTP Update Directory must contain a single zip file"
Super-EventLog -ET Error  -Id $EL_Num -Message $err2mess
Exit
}

#If the name of the file on the server is not equal to the name of the file on the computer, then begin update process
if(!$FileonComp.Equals($Update))
{



#If the files are not in numerical order, upload error text file
if($FileonComp -eq "/////")
{}
else
{
$p=$FileonComp -replace ".zip",""
$c=$without_ext
$prev=Get-EndInt $p
$curr=Get-EndInt $c
if($prev -ne $curr-1)
{
<#Upload-Txt -ftp $err_ftp -text $err4mess#>
$err4mess="Error4 on $identity : File succession does not follow numerical order. The number on $without_ext must be the next number in line"
Super-EventLog -ET Error -Id $EL_Num -Message $err4mess
Exit
}
}

<#Obliterate old Update file: OPTIONAL
$file_delete=$FileonComp -replace ".zip$",""
$file_delete=$up_path+$file_delete
Remove-Item $file_delete -force -recurse#>

#If the update already exists on the computer, upload error text file
$arch_path=$up_path+$upa
$a=$arch_path+'\'+$without_ext
if(Test-Path $a)
{
Set-Content path_of_txt ""
<#Upload-Txt -ftp $err_ftp -text $err1mess#>
$err1mess="Error1 on $identity : $without_ext already exists on the computer. If you would like to re-download the content, rename the zip file (for example:${without_ext}1) and try again"
Super-EventLog -ET Error -Id $EL_Num -Message $err1mess
Exit
}

<#Delete Update History file if it is found on the server
$uftp = "ftp://${Username}:$Password@$server/$uph"
Delete-FTPFile $uftp#>

#Download new update zip file
$up_ftp=$ftp+$Update
$up_uri=New-Object System.Uri($up_ftp)
$up_target=$up_path+$Update
$webclient.DownloadFile($up_uri,$up_target);
Set-Content $path_of_txt "$Update"

#Extract content to a folder of the same name and location as the zip
$up_file=$up_target -replace ".zip$",""
"$up_file"
New-Item $up_file -type Directory
$shell = new-object -com shell.application
$zip = $shell.NameSpace($up_target)
if($zip -ne $null)
{
foreach($item in $zip.items())
{
$shell.Namespace($up_file).copyhere($item) 
}
}

#Archive file
$test=Test-Path $arch_path
if($test -eq $false)
{
New-Item $arch_path -type directory
}
Copy-Item $up_file $arch_path
$y=$up_path+$up_dir
$test=test-path $y
if($test -eq $true)
{Remove-Item $y -force -recurse}
Rename-Item $up_file $up_dir

#Get content from Update Archive, copy to a text file, and upload to ftp server as $uph
$temp_add_arch=$temp_address+$uph
$history_string=Get-ChildItem $arch_path | Select -Property Name,LastWriteTime | Sort-Object -Descending -Property LastWriteTime | Out-String 
$arch_ftp=$ftp+$uph
<#Upload-Txt -ftp $arch_ftp -text $history_string#>

#Create an event in the event log if the file exists in the update archive (upload succesful)
if(Test-Path $a)
{
$EL_Message="$without_ext uploaded to $identity to $identity at $y" #event log message
Super-EventLog -ET Information -Id $EL_Num -Message $EL_Message
}

#Obliterate zip file
Remove-Item $up_target 
}

Get-EventLog "DivUpdate" -Newest 1 | Format-List
