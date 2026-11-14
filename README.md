# btd5-restored-csharp <img src="godot/icon.svg" width="45" align="absbottom"/> 

The original **Flash** version of _Bloons Tower Defense 5_ ported to Godot 4!

The main goal of this project is to bring back the old vector artwork that was sadly scrapped in favor of the new png art for the Steam/mobile version of BTD5. It also aims to have some extra quality-of-life features and much better performance than the original flash version.

> [!WARNING]
> **This is the `csharp` branch: a work-in-progress rewrite in C#.** It is not playable yet.

## Why rewrite?

The GDScript version had performance issues. So much so, that it actually ran worse than the flash version (in some scenarios). Sounds crazy, but the simulation (collision grid, targeting and sorting) is too slow in GDScript during bloon rushes, especially with ceramics. ActionScript3 (what flash uses) doesn't have this issue, and neither does C#, so that's why I'm rewriting it.

## Building

- Godot 4.5+, **.NET edition**
- .NET SDK 9.0+

Open `godot/project.godot` in Godot .NET and press Build.

### Web export/limitations

Sadly, Godot doesn't officially support web export for C# projects yet. However, it *is* possible through the experimental [godot-dotnet-web-export](https://github.com/ComplexRobot/godot-dotnet-web-export) build.

Hopefully, by the time this rewrite is done/on par with the main branch, C# support will be much better. With the speed that Godot's development is moving at, this is very likely.

# Disclaimer

This is an unofficial fan project. It is not endorsed by Ninja Kiwi.
This repository **contains Ninja Kiwi's original Flash assets** (graphics & audio). They have been ripped from the Flash release using [ffdec](https://github.com/jindrapetrik/jpexs-decompiler). I do not own the rights to these assets.
