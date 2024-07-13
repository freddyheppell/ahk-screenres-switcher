**A small AutoHotkey v2 script to add a resolution switcher to the taskbar.**

Upon first run, a config file will be created with just the current screen resolution and you'll be asked if you want to edit it.
This config file is located in the same directory as the script and is named `resolutions.ini`.

Here's an example file for an ultrawide 120Hz 3440x1440 monitor, which lets you switch to a 16:9 resolution:

```ini
[Active]
active=3440x1440@120
[Resolutions]
1=3440x1440@120
2=2560x1440@120
```

Resolutions are in the format `WIDTHxHEIGHT@REFRESH_RATE`. The key in the `Resolutions` section has no effect and is just to make this work in the ini format.

Be aware that this script will probably let you set bad resolutions which won't actually work!