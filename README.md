# faah-sh

Terminal shell error alerts inspired by [Faah](https://github.com/kiron0/faah)
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
faah status
faah on
faah off
faah toggle
faah test
faah cooldown 10
faah quiet 23:00-07:00
faah quiet off
faah snooze 30
faah clear-snooze
faah sound /path/to/sound.wav
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
