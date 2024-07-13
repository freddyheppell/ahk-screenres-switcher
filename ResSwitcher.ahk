#Requires AutoHotkey v2.0
#SingleInstance

resolutions := Array()
ini_path := A_ScriptDir "\resolutions.ini"

first_load := False

; Helper to check if in array
InArray(needle, haystack)
{
    for item in haystack
    {
        if (item = needle)
        {
            return True
        }
    }
    return False
}

; Load resolutions from the config
; or if none are found, load the default resolutions
; and ensure the current resolution is in the list
LoadResolutions()
{
    global resolutions
    pos := 1
    while (res := IniRead(ini_path, "Resolutions", pos, False))
    {
        resolutions.Push(res)
        pos++
    }

    if (resolutions.Length = 0)
    {
        global first_load := True
        resolutions.Push(GetCurrentScreenRes())
    }
}

; Save the possible resolutions to the config
SaveResolutions()
{
    global resolutions
    IniDelete(ini_path, "Resolutions")
    for i, res in resolutions
    {
        IniWrite(res, ini_path, "Resolutions", i)
    }
}

; Load active resolution from the config
LoadActiveResolution()
{
    global resolutions
    if (active := IniRead(ini_path, "Active", "active", False))
    {
        ; Ensure the active resolution is in the list to avoid breaking things
        if (InArray(active, resolutions) = False)
        {
            MsgBox("Active resolution not found in list, adding")
            resolutions.Push(active)
        }

        ParseAndChangeResolution(active)
        SetResActive(active, False)
    } else {
        SetResActive()
    }
}

; Save the active resolution to the config
SaveActiveResolution(ActiveRes)
{
    IniDelete(ini_path, "Active", "active")
    IniWrite(ActiveRes, ini_path, "Active", "active")
}

; Get the current resolution as a string
GetCurrentScreenRes()
{
    Device_Mode := Buffer(156, 0)
    NumPut("UShort", 156, Device_Mode, 36)
    DllCall("EnumDisplaySettingsA", "UInt",0, "UInt",-1, "Ptr",Device_Mode)
    Width := NumGet(Device_Mode, 108, "UInt")
    Height := NumGet(Device_Mode, 112, "UInt")
    Rate := NumGet(Device_Mode, 120, "UInt")
    Return Width "x" Height "@" Rate
}

; Set the active resolution in the tray menu and save to config
SetResActive(ActiveRes := GetCurrentScreenRes(), UpdateConfig := True)
{
    for res in resolutions
    {
        if (res = ActiveRes)
        {
            A_TrayMenu.Check(res)
        } else {
            A_TrayMenu.Uncheck(res)
        }
    }

    if (UpdateConfig) {
        SaveActiveResolution(ActiveRes)
    }
}

; Change screen resolution
; https://www.reddit.com/r/AutoHotkey/comments/11w816x/autohotkey_v2_code_to_change_screen_resolution/
ChangeResolution(Screen_Width := 1920, Screen_Height := 1080, Color_Depth := 32, Refresh_Rate := 60)
{
    Device_Mode := Buffer(156, 0)
    NumPut("UShort", 156, Device_Mode, 36)
    DllCall("EnumDisplaySettingsA", "UInt",0, "UInt",-1, "Ptr",Device_Mode)
    NumPut("UInt", 0x5c0000, Device_Mode, 40)
    NumPut("UInt", Color_Depth, Device_Mode, 104)
    NumPut("UInt", Screen_Width, Device_Mode, 108)
    NumPut("UInt", Screen_Height, Device_Mode, 112)
    NumPut("UInt", Refresh_Rate, Device_MOde, 120)
    Return DllCall( "ChangeDisplaySettingsA", "Ptr",Device_Mode, "UInt",0 )
}

; Parse a resolution string and set the current resolution to it
ParseAndChangeResolution(Res)
{
    current := GetCurrentScreenRes()

    if (current = Res)
    {
        return
    }

    ResRate := StrSplit(Res, "@")

    Res := StrSplit(ResRate[1], "x")
    Rate := ResRate[2]

    ; ChangeResolution(Res[1], Res[2], 32, Rate)
    MsgBox("Would change resolution to " Res[1] "x" Res[2] "@" Rate)
}

; Handle resolution selection
ResCallback(ItemName, ItemPos, MyMenu)
{
    ParseAndChangeResolution(ItemName)
    SetResActive(ItemName)
}


; Set tray icon to an ironic classic icon
TraySetIcon("compstui.dll", 17)

; Load list of resolutions from config or default
LoadResolutions()
; Save the current resolution list in case it was the default
SaveResolutions()

; Populate the menu
A_TrayMenu.Add()
for res in resolutions
    A_TrayMenu.Add(res, ResCallback, "Radio") 

; Load the active resolution
LoadActiveResolution()

if (first_load)
{
    dg_resp := MsgBox("No resolutions found, added current resolution to list. Open config file for editing?", "ResSwitcher", "YN Icon?")

    if (dg_resp = "Yes")
    {
        Run(ini_path)
    }
}

; Remain open
Persistent
