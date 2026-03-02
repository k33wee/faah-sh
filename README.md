# faah-sh

Terminal shell error alerts inspired by [Faah](https://github.com/kiron0/faah)

Plays the Faah sound on command failure, with cooldown and quiet hours features to avoid alert fatigue.

https://github.com/user-attachments/assets/4a917b3e-aab5-40ef-961e-a0ef75433622

![FAAH](https://i.kym-cdn.com/entries/icons/original/000/055/255/fahcover.jpg)

## Language choice

This MVP is implemented in **Bash** so it works by sourcing one file, with no runtime dependency beyond common shell tools.

## Install

```bash
git clone https://github.com/k33wee/faah-sh.git
cd faah-sh
chmod +x install.sh
./install.sh
```

Then restart your shell.

## Uninstall

```bash
./install.sh --uninstall
```

Then restart your shell.

## Usage

```bash
faah status # show current config and state
faah on
faah off
faah toggle
faah test # play sound without checking command status
faah cooldown 10 # set cooldown duration in minutes
faah quiet 23:00-07:00 # set quiet hours window
faah quiet off
faah snooze 30 # snooze for 30 minutes
faah clear-snooze # clear snooze state
faah sound /path/to/sound.wav # set custom sound file
```

## Behavior

- Alerts on non-zero command exit code
- Cooldown to avoid repeated alerts
- Snooze until a future timestamp
- Quiet hours window (`HH:MM-HH:MM`)
- Defaults to `res/media_faah.wav` when present
- Plays configured audio file when possible, otherwise terminal bell

## Project structure

- `faah.sh`: loader/entrypoint
- `lib/faah/core.sh`: config/state/sound logic
- `lib/faah/hooks.sh`: Bash/Zsh hook wiring
- `lib/faah/cli.sh`: `faah` command handlers
- `install.sh`: installer entrypoint
- `lib/install/rc_lines.sh`: rc-file add/remove helpers
