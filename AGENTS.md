# Faceted Depths — Agent Notes

Godot 4.7 project (`superchill/faceted_depths`). The one rule that matters is the process timeout below; everything else is quick context.

## Verification test
```
cd /home/inxeoz/Work/tries/superchill
godot --headless --path . -s game_test.gd
```
Success = exit code 0 and the final output line `game_test: ok`. Anything else (non-zero exit, logged error) is a failure to investigate.

## Hard process timeout: 15s default, raise only if genuinely needed
Always run the headless Godot test (and any headless Godot process) under a **hard 15-second timeout**:

- shell: `timeout 15s godot --headless --path . -s game_test.gd`
- Python: `subprocess.run([...], timeout=15)` or `proc.communicate(timeout=15)`

1. Start at **15s**. The test suite is small and normally finishes in a few seconds.
2. If the process hasn't finished within 15s, **kill it** (`proc.kill()` / the `timeout` kill) and treat the run as hung — do not leave it running or keep re-launching it.
3. Only **increase** the timeout (e.g., 30s/60s) if a legitimately heavier run needs more time. Never bypass the timeout.

## Housekeeping
- Scratch `check_*.gd` scripts also generate a matching `*.gd.uid` — delete both when done.
- Headless Godot cannot render, so UI/drawing changes must be confirmed in the editor; the headless suite only validates game logic.
