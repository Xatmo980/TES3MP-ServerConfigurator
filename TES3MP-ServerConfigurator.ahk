#NoTrayIcon

Menu, MainMenu, Add, &Advanced Config, Advanced
Gui, Main:Menu, MainMenu

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
     Menu, MainMenu, ToggleEnable, &Advanced Config
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
 SetWorkingDir % A_WorkingDir . "\TES3MpServer"
 msg := "Please wait while Extraction is in progress"
 Progress, 0 M FM10 FS8 WM400 WS400 ,`n,%msg%, Extracting - TES3-Server..., Tahoma
 Progress, 100
 RunWait %comspec% /c "7za x tes3mp.Win64.release.0.8.1.zip -aoa *.* -r",, HIDE
 Progress, Off
 GuiControl,Main:, C1, 1
 GuiControl,Main: Enable, Configure
 Menu, MainMenu, ToggleEnable, &Advanced Config
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

Advanced:
 Gui, Adv:Add, GroupBox, x12 y9 w140 h50 , Max Allowed Login Time
 Gui, Adv:Add, Edit, vAdv1 x22 y29 w120 h20 , 60
 Gui, Adv:Add, GroupBox, x152 y9 w140 h50 , Max Clients Per IP
 Gui, Adv:Add, Edit, vAdv2 x162 y29 w120 h20 , 3
 Gui, Adv:Add, GroupBox, x292 y9 w140 h50 , Difficulty
 Gui, Adv:Add, Edit, vAdv3 x302 y29 w120 h20 , 0
 Gui, Adv:Add, GroupBox, x12 y59 w140 h50 , Pass Time When Empty
 Gui, Adv:Add, Edit, vAdv4 x22 y79 w120 h20 , false
 Gui, Adv:Add, GroupBox, x152 y59 w140 h50 , Night Start Hour
 Gui, Adv:Add, Edit, vAdv5 x162 y79 w120 h20 , 20
 Gui, Adv:Add, GroupBox, x292 y59 w140 h50 , Night End Hour
 Gui, Adv:Add, Edit, vAdv6 x302 y79 w120 h20 , 6
 Gui, Adv:Add, GroupBox, x12 y109 w140 h50 , Allow Console
 Gui, Adv:Add, Edit, vAdv7 x22 y129 w120 h20 , false
 Gui, Adv:Add, GroupBox, x152 y109 w140 h50 , Allow Bed Rest
 Gui, Adv:Add, Edit, vAdv8 x162 y129 w120 h20 , true
 Gui, Adv:Add, GroupBox, x292 y109 w140 h50 , Allow Wilderness Rest
 Gui, Adv:Add, Edit, vAdv9 x302 y129 w120 h20 , true
 Gui, Adv:Add, GroupBox, x12 y159 w140 h50 , Allow Wait
 Gui, Adv:Add, Edit, vAdv10 x22 y179 w120 h20 , true
 Gui, Adv:Add, GroupBox, x152 y159 w140 h50 , Share Journal
 Gui, Adv:Add, Edit, vAdv11 x162 y179 w120 h20 , true
 Gui, Adv:Add, GroupBox, x292 y159 w140 h50 , Share Faction Ranks
 Gui, Adv:Add, Edit, vAdv12 x302 y179 w120 h20 , true
 Gui, Adv:Add, GroupBox, x12 y209 w140 h50 , Share Faction Expulsion
 Gui, Adv:Add, Edit, vAdv13 x22 y229 w120 h20 , false
 Gui, Adv:Add, GroupBox, x152 y209 w140 h50 , Share Faction Reputation
 Gui, Adv:Add, Edit, vAdv14 x162 y229 w120 h20 , true
 Gui, Adv:Add, GroupBox, x292 y209 w140 h50 , Share Topics
 Gui, Adv:Add, Edit, vAdv15 x302 y229 w120 h20 , true
 Gui, Adv:Add, GroupBox, x12 y259 w140 h50 , Share Bounty
 Gui, Adv:Add, Edit, vAdv16 x22 y279 w120 h20 , false
 Gui, Adv:Add, GroupBox, x152 y259 w140 h50 , Share Reputation
 Gui, Adv:Add, Edit, vAdv17 x162 y279 w120 h20 , true
 Gui, Adv:Add, GroupBox, x292 y259 w140 h50 , Share Map Exploration
 Gui, Adv:Add, Edit, vAdv18 x302 y279 w120 h20 , false
 Gui, Adv:Add, GroupBox, x12 y309 w140 h50 , Share Videos
 Gui, Adv:Add, Edit, vAdv19 x22 y329 w120 h20 , true
 Gui, Adv:Add, GroupBox, x152 y309 w140 h50 , Respawn At Imperial Shrine
 Gui, Adv:Add, Edit, vAdv20 x162 y329 w120 h20 , true
 Gui, Adv:Add, GroupBox, x292 y309 w140 h50 , Respawn At Tribunal Temple
 Gui, Adv:Add, Edit, vAdv21 x302 y329 w120 h20 , true
 Gui, Adv:Add, GroupBox, x12 y359 w140 h50 , Max Attribute Value
 Gui, Adv:Add, Edit, vAdv22 x22 y379 w120 h20 , 200
 Gui, Adv:Add, GroupBox, x152 y359 w140 h50 , Max Speed Value
 Gui, Adv:Add, Edit, vAdv23 x162 y379 w120 h20 , 365
 Gui, Adv:Add, GroupBox, x292 y359 w140 h50 , Max Skill Value
 Gui, Adv:Add, Edit, vAdv24 x302 y379 w120 h20 , 200
 Gui, Adv:Add, GroupBox, x12 y409 w140 h50 , Max Acrobatics Value
 Gui, Adv:Add, Edit, vAdv25 x22 y429 w120 h20 , 1200
 Gui, Adv:Add, GroupBox, x152 y409 w140 h50 , Players Respawn
 Gui, Adv:Add, Edit, vAdv26 x162 y429 w120 h20 , true
 Gui, Adv:Add, GroupBox, x292 y409 w140 h50 , Death Time
 Gui, Adv:Add, Edit, vAdv27 x302 y429 w120 h20 , 5
 Gui, Adv:Add, GroupBox, x12 y459 w140 h50 , Death Penalty Jail Days
 Gui, Adv:Add, Edit, vAdv28 x22 y479 w120 h20 , 5
 Gui, Adv:Add, GroupBox, x152 y459 w140 h50 , Bounty Reset On Death
 Gui, Adv:Add, Edit, vAdv29 x162 y479 w120 h20 , false
 Gui, Adv:Add, GroupBox, x292 y459 w140 h50 , Bounty Death Penalty
 Gui, Adv:Add, Edit, vAdv30 x302 y479 w120 h20 , false
 Gui, Adv:Add, GroupBox, x12 y509 w420 h50 , 
 Gui, Adv:Add, Button, gAdvSave x22 y519 w400 h30 , Save
 Gui, Adv:Show, w443 h572,Advanced Config
 return

AdvSave()
{
SetWorkingDir % A_WorkingDir . "\TES3MpServer"
 Loop, 30
    {
     GuiControlGet, Adv%A_Index%,Adv:,Adv%A_Index%
    }
config := ["config.loginTime","config.maxClientsPerIP","config.difficulty","config.passTimeWhenEmpty","config.nightStartHour","config.nightEndHour","config.allowConsole","config.allowBedRest","config.allowWildernessRest","config.allowWait","config.shareJournal","config.shareFactionRanks","config.shareFactionExpulsion","config.shareFactionReputation","config.shareTopics","config.shareBounty","config.shareReputation","config.shareMapExploration","config.shareVideos","config.respawnAtImperialShrine","config.respawnAtTribunalTemple","config.maxAttributeValue","config.maxSpeedValue","config.maxSkillValue","config.maxAcrobaticsValue","config.playersRespawn","config.deathTime","config.deathPenaltyJailDays","config.bountyResetOnDeath","config.bountyDeathPenalty"]

FileRead, ConfigContent, % A_WorkingDir . "\server\scripts\config.lua"
sleep, 500
FileDelete, % A_WorkingDir . "\server\scripts\config.lua"
Loop, parse, ConfigContent, `n, `r
{
T = 1
 Loop % config.Length()
  {
    Val := Adv%A_Index%
    if InStr(A_LoopField, config[A_Index])
       {
        Content .= StrReplace(A_LoopField, A_LoopField, config[A_Index] . " = " . Val) . "`n"
        T = 0
       }
  }
       if T
       {
        Content .= A_LoopField . "`n"
        T = 1
       }
}
FileAppend, % Content, % A_WorkingDir . "\server\scripts\config.lua"
MsgBox % "Saved"
}

MainGuiClose:
ExitApp

AdvGuiClose:
 Gui, Adv:Destroy
return

ConGuiClose:
 Gui, Con:Destroy
return
