
echo on
REM Logs at: C:\ProgramData\Amazon\EC2-Windows\Launch\Log\UserdataExecution.log

REM Intalling chocolatey...
@"%SystemRoot%\System32\WindowsPowerShell\v1.0\powershell.exe" -NoProfile -InputFormat None -ExecutionPolicy Bypass -Command "iex ((New-Object System.Net.WebClient).DownloadString('https://chocolatey.org/install.ps1'))" && SET "PATH=%PATH%;%ALLUSERSPROFILE%\chocolatey\bin"
REM Installing curl...
choco install -y --no-progress curl

REM Getting IP address...
curl ifconfig.me
FOR /F "tokens=*" %%g IN ('curl ifconfig.me') do (SET IP=%%g)

echo "Configuring SSH banner..."
set BANNER="C:\Users\Administrator\tableau\_WELCOME_BANNER_.txt"
set SETUPLOG="C:\ProgramData\Amazon\EC2-Windows\Launch\Log\UserdataExecution.log"
echo ------------------------------------------------------ > %BANNER%
REM sudo apt-get install figlet
REM figlet "Welcome!" >> $BANNER
echo ------------------------------------------------------ > %BANNER%
echo Welcome to the Tableau Server at %IP%! >> %BANNER%
echo     TSM Config:          https://localhost:8850  /  https://%IP%:8850 >> %BANNER%
echo     Tableau Server:      http://%IP% >> %BANNER%
echo     Default Admin Acct:  tabadmin:tabadmin >> %BANNER%
echo     Setup directory:     C:\Users\Administrator\tableau >> %BANNER%
echo     Data directory:      (n/a) >> %BANNER%
echo     Tableau app path:    C:\Program Files\Tableau >> %BANNER%
echo     Tableau docs:        https://help.tableau.com/current/guides/everybody-install/en-us/everybody_admin_install.htm >> %BANNER%
echo Possible Actions: >> %BANNER%
echo     View this banner:    chrome "%BANNER%"
echo     View setup log:      %SETUPLOG% >> %BANNER%
echo     Tableau install log: C:\Users\Administrator\tableau\install_log.txt >> %BANNER%
echo     Start/stop server:   tsm start >> %BANNER%
echo                          tsm stop >> %BANNER%
echo     Register server:     tsm register --file registration.json >> %BANNER%
echo                          tsm pending-changes apply >> %BANNER%
echo                          tsm initialize >> %BANNER%
echo ------------------------------------------------------ >> %BANNER%

mkdir C:\Users\Administrator\tableau 2> NUL
cd C:\Users\Administrator\tableau

echo "Creating Startup script..."
set STARTUP="C:\ProgramData\Microsoft\Windows\Start Menu\Programs\Startup\startup.bat"
echo start chrome C:\Users\Administrator\tableau >> %STARTUP%
echo start chrome %SETUPLOG% >> %STARTUP%
echo start chrome https://localhost:8850/ >> %STARTUP%
echo start chrome http://localhost/ >> %STARTUP%
echo start chrome file:///C:/Users/Administrator/tableau/install_log.txt >> %STARTUP%
echo start chrome %BANNER% >> %STARTUP%
echo pause >> %STARTUP%

echo Installing prereqs...
REM temporary mismatch of chrome checksums
choco install -y --no-progress --ignore-checksums googlechrome
choco install -y --no-progress ^
    awscli ^
    chocolateygui ^
    vscode

REM log verbose
echo on 

echo ------------
echo Setting AWS path to avoid restart
set AWS="C:\Program Files\Amazon\AWSCLI\bin\aws"

echo ------------
echo Showing contents of S3 bucket...
%AWS% s3 ls s3://tableau-quickstart/ --no-sign-request

REM Download scripts from S3
cd C:\Users\Administrator
%AWS% s3 cp s3://tableau-quickstart/AddHostname.cmd tableau/ --no-sign-request
%AWS% s3 cp s3://tableau-quickstart/manageFirewallPorts.py tableau/ --no-sign-request
%AWS% s3 cp s3://tableau-quickstart/SilentInstaller.py tableau/ --no-sign-request
%AWS% s3 cp s3://tableau-quickstart/ScriptedInstaller.py tableau/ --no-sign-request

REM Downloading installers from S3...
%AWS% s3 cp s3://tableau-quickstart/TableauServer-64bit.exe tableau/ --no-sign-request
%AWS% s3 cp s3://tableau-quickstart/TableauServer-64bit.exe.old tableau/ --no-sign-request
%AWS% s3 cp s3://tableau-quickstart/Tableau-Server-2018.2-Beta2-x64.exe tableau/ --no-sign-request
%AWS% s3 cp s3://tableau-quickstart/Setup-Server-x64.exe tableau/ --no-sign-request
%AWS% s3 cp s3://tableau-quickstart/Setup-Worker-x64.exe tableau/ --no-sign-request

cd C:\Users\Administrator\tableau

REM Installing Tableau Server...
TableauServer-64bit.exe /VERYSILENT /ACCEPTEULA /LOG=install_log.txt

echo ------------
echo Opening firewall ports...
netsh advfirewall firewall add rule name="Tableau_Server_Custom" localport=80,443,8850 dir=in action=allow protocol=TCP

echo TSM is initialized and taking requests at: https://%IP%:8850/

copy "C:\Program Files\Tableau\Tableau Server\install_log*" tableau\*

