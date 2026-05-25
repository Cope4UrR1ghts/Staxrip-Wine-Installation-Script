# Staxrip-Wine-Installation-Script

## What is this?
Linux script to install popular video encoding GUI [Staxrip](https://github.com/staxrip/staxrip) on Linux with the help of Wine.

## How to use?
Prerequisites:
Make sure you have Wine and winetricks installed. You can install them via your favourite package manager.

Example:
```bash
sudo pacman -S wine winetricks
```

1. Clone this repo
```bash
git clone https://github.com/Cope4UrR1ghts/Staxrip-Wine-Installation-Script.git
```

2. Make script executable and run
```bash
chmod +x install_staxrip.sh
./install_staxrip.sh
```

3. Run Staxrip from App Menu

## Known Bugs
Editing anything in RichTextBoxes cause the Program to crash. I have yet to figure out why this happens.
NVIDIA and AMD Hardware encoders straight up don't work. I am guessing Staxrip can't use DXVK to utilize the GPU.

## Possible Issues
Avisynth may not work. Just use VapourSynth and you should be fine.
