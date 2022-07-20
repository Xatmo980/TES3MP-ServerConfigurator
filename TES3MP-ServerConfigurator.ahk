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
 Loop, 30
    {
     GuiControlGet, Adv%A_Index%,Adv:,Adv%A_Index%
    }
AdvancedTemplate1 =
 (
  config = {}

config.dataPath = tes3mp.GetDataPath()
config.gameMode = "Default"
config.loginTime = %Adv1%
config.maxClientsPerIP = %Adv2%
config.difficulty = %Adv3%
config.gameSettings = {
    { name = "best attack", value = false },
    { name = "prevent merchant equipping", value = false },
    { name = "enchanted weapons are magical", value = true },
    { name = "rebalance soul gem values", value = false },
    { name = "barter disposition change is permanent", value = false },
    { name = "strength influences hand to hand", value = 0 },
    { name = "use magic item animations", value = false },
    { name = "normalise race speed", value = false },
    { name = "uncapped damage fatigue", value = false },
    { name = "NPCs avoid collisions", value = false },
    { name = "swim upward correction", value = false },
    { name = "trainers training skills based on base skill", value = true },
    { name = "always allow stealing from knocked out actors", value = false }
}
config.vrSettings = {
    { name = "realistic combat minimum swing velocity", value = 1.0 },
    { name = "realistic combat maximum swing velocity", value = 4.0 }
}
config.defaultTimeTable = { year = 427, month = 7, day = 16, hour = 9,
    daysPassed = 1, dayTimeScale = 30, nightTimeScale = 40 }
config.chatWindowInstructions = color.White .. "Use " .. color.Yellow .. "Y" .. color.White .. " by default to chat or change it" ..
    " from your client config.\nType in " .. color.Yellow .. "/help" .. color.White .. " to see the commands" ..
    " available to you.\nType in " .. color.Yellow .. "/invite <pid>" .. color.White .. " to invite a player to become " ..
    "your ally so their followers don't react to your friendly fire.\nUse " .. color.Yellow .. "F2" .. color.White ..
    " by default to hide the chat window or use the " .. color.Yellow .. "Chat Window Mode" .. color.White .. " button from " ..
    "your left controller menu if you're in VR.\n"
config.startupScriptsInstructions = color.Red .. "Warning: " .. color.White .. " For some actors and objects to have their correct" ..
    " initial states, an admin needs to run the " .. color.Yellow .. "/runstartup" .. color.White .. " command.\n"
config.worldStartupScripts = {"Startup", "BMStartUpScript"}
config.playerStartupScripts = {"VampireCheck", "WereCheckScript"}
)
AdvancedTemplate2 =
 (
config.passTimeWhenEmpty = %Adv4%
config.nightStartHour = %Adv5%
config.nightEndHour = %Adv6%
config.allowConsole = %Adv7%
config.allowBedRest = %Adv8%
config.allowWildernessRest = %Adv9%
config.allowWait = %Adv10%
config.shareJournal = %Adv11%
config.shareFactionRanks = %Adv12%
config.shareFactionExpulsion = %Adv13%
config.shareFactionReputation = %Adv14%
config.shareTopics = %Adv15%
config.shareBounty = %Adv16%
config.shareReputation = %Adv17%
config.shareMapExploration = %Adv18%
config.shareVideos = %Adv19%
)
AdvancedTemplate3 =
 (

config.disabledClientScriptIds = {
    -- original character generation's scripts
    "CharGenRaceNPC", "CharGenClassNPC", "CharGenStatsSheet", "CharGenDoorGuardTalker",
    "CharGenBed", "CharGenStuffRoom", "CharGenFatigueBarrel", "CharGenDialogueMessage",
    "CharGenDoorEnterCaptain", "CharGenDoorExitCaptain", "CharGenJournalMessage",
    -- OpenMW's default blacklist
    "Museum", "MockChangeScript", "doortestwarp", "WereChange2Script", "wereDreamScript2",
    "wereDreamScript3"
}
config.synchronizedClientScriptIds = {
    -- mechanisms
    "GG_OpenGate1", "GG_OpenGate2", "Arkn_doors", "nchuleftingthWrong1", "nchuleftingthWrong2",
    "nchulfetingthRight", "Akula_innerdoors", "Dagoth_doors", "SothaLever1", "SothaLever2",
    "SothaLever3", "SothaLever4", "SothaLever5", "SothaLever6", "SothaLever7", "SothaLever8",
    "SothaLever9", "SothaLever10", "SothaLever11", "SothaOilLever", "LocalState",
    -- quest stages and timers
    "helsethScript", "KarrodMovement"
}
config.useInstancedSpawn = true
config.instancedSpawn = {
    cellDescription = "Seyda Neen, Census and Excise Office",
    position = {1130.3388671875, -387.14947509766, 193},
    rotation = {0.09375, 1.5078122615814},
    text = "Multiplayer skips several minutes of the game's introduction and places you at the first quest giver." ..
        "\n\nYou will be able to meet other players only after you leave this room.",
    items = {{refId = "chargen statssheet", count = 1, charge = -1, enchantmentCharge = -1, soul = ""}}    
}
config.noninstancedSpawn = {
    cellDescription = "-3, -2",
    position = {-23894.0, -15079.0, 505},
    rotation = {0, 1.2},
    text = "Multiplayer skips over the original character generation." ..
        "\n\nAs a result, you start out with Caius Cosades' package.",
    items = {{refId = "bk_a1_1_caiuspackage", count = 1, charge = -1, enchantmentCharge = -1, soul = ""}}
}
config.defaultRespawn = {
    cellDescription = "Balmora, Temple",
    position = {4700.5673828125, 3874.7416992188, 14758.990234375},
    rotation = {0.25314688682556, 1.570611000061}
}
)
AdvancedTemplate4 =
 (

config.respawnAtImperialShrine = %Adv20%
config.respawnAtTribunalTemple = %Adv21%
config.forbiddenCells = { "ToddTest" }
config.maxAttributeValue = %Adv22%
config.maxSpeedValue = %Adv23%
config.maxSkillValue = %Adv24%
config.maxAcrobaticsValue = %Adv25%
config.ignoreModifierWithMaxSkill = false
config.bannedEquipmentItems = { "helseth's ring" }
config.playersRespawn = %Adv26%
config.deathTime = %Adv27%
config.deathPenaltyJailDays = %Avd28%
config.bountyResetOnDeath = %Adv29%
config.bountyDeathPenalty = %Adv30%
)
AdvancedTemplate5 =
 (

config.allowSuicideCommand = true
config.allowFixmeCommand = true
config.fixmeInterval = 30
config.rankColors = { serverOwner = color.Orange, admin = color.Red, moderator = color.Green }
config.customMenuIds = { menuHelper = 9001, confiscate = 9002, recordPrint = 9003 }
config.menuHelperFiles = { "help", "defaultCrafting", "advancedExample" }
config.pingDifferenceRequiredForAuthority = 40
config.enforcedLogLevel = -1
config.physicsFramerate = 60
config.allowOnContainerForUnloadedCells = false
config.enablePlayerCollision = true
config.enableActorCollision = true
config.enablePlacedObjectCollision = false
config.enforcedCollisionRefIds = { "misc_uni_pillow_01", "misc_uni_pillow_02" }
config.useActorCollisionForPlacedObjects = false
config.disallowedActivateRefIds = {}
config.disallowedDeleteRefIds = { "m'aiq" }
config.disallowedCreateRefIds = {}
config.disallowedLockRefIds = {}
config.disallowedTrapRefIds = {}
config.disallowedStateRefIds = {}
config.disallowedDoorStateRefIds = {}
config.maximumObjectScale = 20
config.generatedRecordIdPrefix = "$custom"
)
AdvancedTemplate6 =
 (

config.recordStoreLoadOrder = {
    { "cell" },
    { "gamesetting", "script", "spell", "potion", "enchantment", "bodypart", "armor", "clothing",
      "book", "weapon", "ingredient", "apparatus", "lockpick", "probe", "repair", "light",
      "miscellaneous", "creature", "npc", "container", "door", "activator", "static", "sound" }
}
config.enchantableRecordTypes = { "armor", "book", "clothing", "weapon" }
config.carriableRecordTypes = { "spell", "potion", "armor", "book", "clothing", "weapon", "ingredient",
    "apparatus", "lockpick", "probe", "repair", "light", "miscellaneous" }
config.unplaceableRecordTypes = { "spell", "cell", "script", "gamesetting" }
config.validRecordSettings = {
    activator = { "baseId", "id", "name", "model", "script" },
    apparatus = { "baseId", "id", "name", "model", "icon", "script", "subtype", "weight", "value",
        "quality" },
    armor = { "baseId", "id", "name", "model", "icon", "script", "enchantmentId", "enchantmentCharge",
        "subtype", "weight", "value", "health", "armorRating" },
    bodypart = { "baseId", "id", "subtype", "part", "model", "race", "vampireState", "flags" },
    book = { "baseId", "id", "name", "model", "icon", "script", "enchantmentId", "enchantmentCharge",
        "text", "weight", "value", "scrollState", "skillId" },
    cell = { "baseId", "id" },
    clothing = { "baseId", "id", "name", "model", "icon", "script", "enchantmentId", "enchantmentCharge",
        "subtype", "weight", "value" },
    container = { "baseId", "id", "name", "model", "script", "weight", "flags" },
    creature = { "baseId", "id", "name", "model", "script", "scale", "bloodType", "subtype", "level",
        "health", "magicka", "fatigue", "soulValue", "damageChop", "damageSlash", "damageThrust",
        "aiFight", "aiFlee", "aiAlarm", "aiServices", "flags" },
    door = { "baseId", "id", "name", "model", "openSound", "closeSound", "script" },
    enchantment = { "baseId", "id", "subtype", "cost", "charge", "flags", "effects" },
    gamesetting = { "baseId", "id", "intVar", "floatVar", "stringVar" },
    ingredient = { "baseId", "id", "name", "model", "icon", "script", "weight", "value" },
    light = { "baseId", "id", "name", "model", "icon", "sound", "script", "weight", "value", "time",
        "radius", "color", "flags" },
    lockpick = { "baseId", "id", "name", "model", "icon", "script", "weight", "value", "quality", "uses" },
    miscellaneous = { "baseId", "id", "name", "model", "icon", "script", "weight", "value", "keyState" },
    npc = { "baseId", "inventoryBaseId", "id", "name", "script", "flags", "gender", "race", "model", "hair",
        "head", "class", "faction", "level", "health", "magicka", "fatigue", "aiFight", "aiFlee", "aiAlarm",
        "aiServices", "autoCalc" },
    potion = { "baseId", "id", "name", "model", "icon", "script", "weight", "value", "autoCalc" },
    probe = { "baseId", "id", "name", "model", "icon", "script", "weight", "value", "quality", "uses" },
    repair = { "baseId", "id", "name", "model", "icon", "script", "weight", "value", "quality", "uses" },
    script = { "baseId", "id", "scriptText" },
    spell = { "baseId", "id", "name", "subtype", "cost", "flags", "effects" },
    static = { "baseId", "id", "model" },
    weapon = { "baseId", "id", "name", "model", "icon", "script", "enchantmentId", "enchantmentCharge",
        "subtype", "weight", "value", "health", "speed", "reach", "damageChop", "damageSlash", "damageThrust",
        "flags" },
    sound = { "baseId", "id", "sound", "volume", "pitch" }
}
)
AdvancedTemplate7 =
 (

config.requiredRecordSettings = {
    activator = { "name", "model" },
    apparatus = { "name", "model" },
    armor = { "name", "model" },
    bodypart = { "subtype", "part", "model" },
    book = { "name", "model" },
    cell = { "id" },
    clothing = { "name", "model" },
    container = { "name", "model" },
    creature = { "name", "model" },
    door = { "name", "model" },
    enchantment = {},
    gamesetting = { "id" },
    ingredient = { "name", "model" },
    light = { "model" },
    lockpick = { "name", "model" },
    miscellaneous = { "name", "model" },
    npc = { "name", "race", "class" },
    potion = { "name", "model" },
    probe = { "name", "model" },
    repair = { "name", "model" },
    script = { "id" },
    spell = { "name" },
    static = { "model" },
    weapon = { "name", "model" },
    sound = { "sound" }
}
config.mutuallyExclusiveRecordSettings = {
    gamesetting = { "intVar", "floatVar", "stringVar" }
}
config.numericalRecordSettings = { "subtype", "charge", "cost", "value", "weight", "quality", "uses",
    "time", "radius", "health", "armorRating", "speed", "reach", "scale", "part", "bloodType", "level",
    "magicka", "fatigue", "soulValue", "aiFight", "aiFlee", "aiAlarm", "aiServices", "autoCalc", "gender",
    "flags", "enchantmentCharge", "intVar", "floatVar" }
config.booleanRecordSettings = { "scrollState", "keyState", "vampireState" }
config.minMaxRecordSettings = { "damageChop", "damageSlash", "damageThrust" }
config.rgbRecordSettings = { "color" }
config.cellPacketTypes = { "delete", "place", "spawn", "lock", "trap", "scale", "state", "miscellaneous",
    "doorState", "clientScriptLocal", "container", "equipment", "ai", "death", "actorList", "position",
    "statsDynamic", "spellsActive", "cellChangeTo", "cellChangeFrom" }
config.enforceDataFiles = true
config.ignoreScriptErrors = false
config.databaseType = "json"
config.databasePath = config.dataPath .. "/database.db" -- Path where database is stored
config.disallowedNameStrings = { "bitch", "blowjob", "blow job", "cocksuck", "cunt", "ejaculat",
    "faggot", "fellatio", "fuck", "gas the ", "Hitler", "jizz", "nigga", "nigger", "smegma", "vagina", "whore" }
config.playerKeyOrder = { "login", "name", "passwordHash", "passwordSalt", "timestamps", "settings",
    "character", "customClass", "location", "stats", "fame", "shapeshift", "attributes",
    "attributeSkillIncreases", "skills", "skillProgress", "recordLinks", "equipment", "inventory",
    "spellbook", "books", "factionRanks", "factionReputation", "factionExpulsion", "mapExplored",
    "ipAddresses", "customVariables", "admin", "difficulty", "enforcedLogLevel", "physicsFramerate",
    "consoleAllowed", "bedRestAllowed", "wildernessRestAllowed", "waitAllowed", "gender", "race",
    "head", "hair", "class", "birthsign", "cell", "posX", "posY", "posZ", "rotX", "rotZ", "healthBase",
    "healthCurrent", "magickaBase", "magickaCurrent", "fatigueBase", "fatigueCurrent" }
config.cellKeyOrder = { "packets", "entry", "lastVisit", "recordLinks", "objectData", "refId", "count",
    "charge", "enchantmentCharge", "location", "actorList", "ai", "summon", "stats", "cellChangeFrom",
    "cellChangeTo", "container", "death", "delete", "doorState", "equipment", "inventory", "lock",
    "place", "position", "scale", "spawn", "state", "statsDynamic", "trap" }
config.recordstoreKeyOrder = { "general", "permanentRecords", "generatedRecords", "recordLinks",
    "id", "baseId", "name", "subtype", "gender", "race", "hair", "head", "class", "faction", "cost",
    "value", "charge", "weight", "autoCalc", "flags", "icon", "model", "script", "attribute", "skill",
    "rangeType", "area", "duration", "magnitudeMax", "magnitudeMin", "effects", "players", "cells", "global" }
config.worldKeyOrder = { "general", "time", "topics", "kills", "journal", "customVariables", "type",
    "index", "quest", "actorRefId", "year", "month", "day", "hour", "daysPassed", "timeScale" }

return config
}
)
 SetWorkingDir % A_WorkingDir . "\TES3MpServer"
 FileDelete, % A_WorkingDir .  "\server\scripts\config.lua"
 sleep, 1000
 Loop, 7
    FileAppend, % AdvancedTemplate%A_Index%, % A_WorkingDir . "\server\scripts\config.lua"
}

MainGuiClose:
ExitApp

AdvGuiClose:
 Gui, Adv:Destroy
return

ConGuiClose:
 Gui, Con:Destroy
return
