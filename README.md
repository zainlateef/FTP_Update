—————SYNOPSIS—————
The program is relatively simple. There is a single FTP server and multiple clients. 
The FTP server holds a single zipped update file at all times. 
The computer stores the update name in a specific text file (FTP text accompany.txt). 
Periodically, the computer will check the name of the update file on the FTP server. 
If the update file name on the server is different than the one in the computer (text file), then the computer will download the update file
All results are stored in the computers event log


—————NECESSARY CONDITIONS—————
FTP server must have a SINGLE zip file containing the current update AT ALL TIMES

Always delete the old update file on the server and replace it with the new one

Config Block must be correct

Computers to be updated must contain the Script and the accompanying text file 

After uploading the new update file and deleting the old one from the server, wait 
the allotted execution time (to be determined) and then check the server. If there is no
error text file, the file has been uploaded


—————RESET—————

A reset should clear most if not all errors not having to do with connection

Common Reset:
1. Clear all content on the accompanying text file, either manually or by entering
break>(path of file)
into the command line
2. Then run again as you normally would

Hard Reset:
1. Complete step 1 in the common reset
2. Move or rename or delete the main Update folder and the Update Archive
3. Then run again as you normally would
