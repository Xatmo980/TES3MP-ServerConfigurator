#NoTrayIcon
Gui, Main:Add, GroupBox, x2 y9 w190 h140 , Guide
Gui, Main:Add, Button, gStart x12 y29 w140 h30 , Download
Gui, Main:Add, Button, gConfig x12 y69 w140 h30 , Configure
Gui, Main:Add, Button, gRun x12 y109 w140 h30 , Start
Gui, Main:Add, CheckBox, vC1 x162 y29 w20 h30 
Gui, Main:Add, CheckBox, vC2 x162 y69 w20 h30 
Gui, Main:Add, CheckBox, vC3 x162 y109 w20 h30
Gui, Main:Show, w201 h162,TES3MP-Configurator

if !FileExist(A_WorkingDir . "\TES3MpServer\7za.exe")
    {
     FileCreateDir, TES3MpServer
     FileInstall, 7za.exe, TES3MpServer/7za.exe
     GuiControl,Main: Disable, Configure
     GuiControl,Main: Disable, Start
    }
    else
    {
      GuiControl,Main:, C1, 1
      GuiControl,Main:, C2, 1
      GuiControl,Main: Disable, Download
      GuiControl,Main: Enable, Configure
    }
 GuiControl,Main: Disable, C1
 GuiControl,Main: Disable, C2
 GuiControl,Main: Disable, C3
return

Start()
{
 DownloadServer()
 Progress, Off
 SetWorkingDir % A_WorkingDir . "\TES3MpServer"
 RunWait %comspec% /c "7za x tes3mp.Win64.release.0.8.1.zip -aoa *.* -r",, HIDE
 GuiControl,Main:, C1, 1
 GuiControl,Main: Enable, Configure
}

DownloadServer()
{
 totalFileSize := 64798924
 FileSize := Round(totalFileSize/1000000)

	msg := "Please wait while download is in progress"
	Progress, 0 M FM10 FS8 WM400 WS400 ,`n,%msg%, Downloading - TES3-Server, Tahoma
	SetTimer, uProgress, 250
	UrlDownloadToFile % G := "https://github.com/TES3MP/TES3MP/releases/download/tes3mp-0.8.1/tes3mp.Win64.release.0.8.1.zip", % A_WorkingDir . "\TES3MpServer\tes3mp.Win64.release.0.8.1.zip"
	SetTimer, uProgress, off
	Progress, Off
         
  uProgress:
	FileGetSize, fs, %A_WorkingDir%\TES3MpServer\tes3mp.Win64.release.0.8.1.zip
	a := Floor(fs/totalFileSize * 100)
	b := Floor(fs/totalFileSize * 10000)/100
	SetFormat, float, 0.2
	b += 0
        f := Round(fs/1000000)
	Progress, %a%, %b%`% done (%f% MB of %FileSize% MB)
        Return
}


Config()
{
 Global Pass, EM, LL, S, I, P, M
 Gui, Con:Add, GroupBox, x2 y9 w190 h50 , Server Name
 Gui, Con:Add, Edit, vS x22 y29 w160 h20 , Name
 Gui, Con:Add, GroupBox, x2 y59 w190 h50 , Ip
 Gui, Con:Add, Edit, vI x22 y79 w160 h20 , 0.0.0.0
 Gui, Con:Add, GroupBox, x2 y109 w190 h50 , Port
 Gui, Con:Add, Edit, vP x22 y129 w160 h20 , 25565
 Gui, Con:Add, GroupBox, x2 y159 w190 h50 , Max Players
 Gui, Con:Add, Edit, vM x22 y179 w160 h20 , 100
 Gui, Con:Add, GroupBox, x2 y209 w190 h50 , Password
 Gui, Con:Add, Edit, vPass x22 y229 w160 h20 , 
 Gui, Con:Add, GroupBox, x2 y259 w190 h50 , Enable Master Server
 Gui, Con:Add, Edit, vEM x22 y279 w160 h20 , true
 Gui, Con:Add, GroupBox, x2 y309 w190 h50 , Log Level
 Gui, Con:Add, Edit, vLL x22 y329 w160 h20 , 4
 Gui, Con:Add, GroupBox, x2 y359 w190 h60 ,
 Gui, Con:Add, Button, gSaveConfig x12 y379 w170 h30 , Save
 Gui, Con:Show, w200 h434,Conf
 return
}

SaveConfig()
{
 GuiControlGet, EnableMaster,Con:, EM
 GuiControlGet, Password,Con:, Pass
 GuiControlGet, ServerName,Con:, S
 GuiControlGet, Players,Con:, M
 GuiControlGet, LogLvl,Con:, LL
 GuiControlGet, Port,Con:, P
 GuiControlGet, Ip,Con:, I
 AppendConfig(ServerName, Ip, Port, Players, Password, EnableMaster, LogLvl:=4)
 RunWait, openmw-wizard.exe
 GuiControl,Main:, C2, 1
 GuiControl,Main: Enable, Start
 Gui, Con:Destroy
}

AppendConfig(ServerName, Ip, Port, Players, Password, EnableMaster, LogLvl:=4)
{
 configText =
 (
  [General]
   # The default localAddress of 0.0.0.0
  localAddress = %Ip%
  port = %Port%
  maximumPlayers = %Players%
  hostname = %ServerName%
   # 0 - Verbose (spam), 1 - Info, 2 - Warnings, 3 - Errors, 4 - Only fatal errors
  logLevel = %LogLvl%
  password = %Password%

  [Plugins]
  home = ./server
  plugins = serverCore.lua

  [MasterServer]
  enabled = %EnableMaster%
  address = master.tes3mp.com
  port = 25561
  rate = 10000
  )
 FileDelete, tes3mp-server-default.cfg
 sleep, 1000
 FileAppend, %configText%, tes3mp-server-default.cfg
}

Run()
{
 OpenLocalFirewall()
 Run, tes3mp-server-autorestart.bat
 GuiControl,Main:, C3, 1
}

OpenLocalFirewall()
{
 Client := A_WorkingDir . "\tes3mp.exe"
 Server := A_WorkingDir . "\tes3mp-server.exe"
 Browser := A_WorkingDir . "\tes3mp-browser.exe"
 Run %comspec% /c "netsh advfirewall firewall add rule name="TES3MPClient" dir=in action=allow program="%Client%" enable=yes remoteip=any profile=any",, HIDE
 Run %comspec% /c "netsh advfirewall firewall add rule name="TES3MPClient" dir=out action=allow program="%Client%" enable=yes remoteip=any profile=any",, HIDE
 Run %comspec% /c "netsh advfirewall firewall add rule name="TES3MPServer" dir=in action=allow program="%Server%" enable=yes remoteip=any profile=any",, HIDE
 Run %comspec% /c "netsh advfirewall firewall add rule name="TES3MPServer" dir=out action=allow program="%Server%" enable=yes remoteip=any profile=any",, HIDE
 Run %comspec% /c "netsh advfirewall firewall add rule name="TES3MPBrowser" dir=in action=allow program="%Browser%" enable=yes remoteip=any profile=any",, HIDE
 Run %comspec% /c "netsh advfirewall firewall add rule name="TES3MPBrowser" dir=out action=allow program="%Browser%" enable=yes remoteip=any profile=any",, HIDE
}

MainGuiClose:
ExitApp

ConGuiClose:
 Gui, Con:Destroy
return
