FRONTLINE: OBJECTIVE v9.22.0
SPATIAL AUDIO + SURFACE FOOTSTEPS + VEHICLE ENGINE SOUND

NEW INCLUDED AUDIO ASSETS
This build now includes lightweight WAV assets directly in /audio:
- rifle_fire.wav
- pistol_fire.wav
- world_gunshot.wav
- explosion.wav
- reload.wav
- dry_click.wav
- hit_confirm.wav
- headshot_confirm.wav
- ground/gravel/stone/wood/metal footsteps
- Jeep/Tank/Aircraft engine loops

This means the existing optional audio-loading code now has actual fallback
sounds even if no external sound pack is installed.

SURFACE FOOTSTEPS
Footstep raycasts already identified surface type. v9.22 now maps that result
to different actual sounds:
- ground
- gravel
- stone/brick
- wood
- metal

Remote player footsteps also play spatially on clients.

LOW/LAPTOP
Remote footsteps beyond roughly 14m are skipped.

BALANCED/HIGH
Remote footstep range extends to roughly 21m.

WORLD GUNFIRE
Remote gunfire now creates capped AudioStreamPlayer3D reports.

The shooter's own close-range sound is not duplicated because shots within
2.5m of the listening camera skip the world report.

Approximate gunfire ranges:
- Low ~38m
- Balanced ~62m
- High ~82m

Audio player count is capped:
- Low 6
- Balanced 12
- High 18

VEHICLE ENGINES
Jeep, tank and aircraft now have separate lightweight looped engine sounds.

Pitch/volume respond to movement/throttle:
- stationary occupied vehicles idle quietly
- acceleration raises pitch/volume
- tanks remain lower pitched
- aircraft use the highest pitch/range
- destroyed vehicles fade nearly silent

PERFORMANCE
- mono 22.05 kHz WAV assets
- no convolution/reverb processing
- distance attenuation
- capped transient world audio
- no new physics or networking
- no GPU cost

PRESERVED
- v9.21 visual effect budgets
- v9.20 spawn safety / U unstuck
- v9.19 visibility/route readability
- first-person/HUD/combat fixes
- destructible streets
- all vehicle and aircraft gameplay
- F6/F8
- --bots 0 / --bots=0 / --no-bots

Build: 9.22.0
Protocol: 341
