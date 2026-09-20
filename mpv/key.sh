#!/bin/bash

# Rofi theme
rofi_theme="$HOME/.config/rofi/themes/clipboard.rasi" # Make sure this path is correct for your system
msg='** MPV Keybinds ** 🎬 Search or press Enter to copy'

# Check if rofi is already running
if pidof rofi > /dev/null; then
  pkill rofi
fi

# Format & show via rofi
# The sed command removes everything before the '# # MPV_KEYBINDS # #' marker.
# It then pipes the hardcoded keybinds to rofi.
sed '1,/^# # MPV_KEYBINDS # #$/d' "$0" | \
rofi -i -dmenu -mesg "$msg" -config "$rofi_theme" | \
awk '{print $1}' | \
wl-copy

exit

# # MPV_KEYBINDS # #
⏯️ Playback Control
SPACE                           : toggle pause/playback mode
p                               : toggle pause/playback mode
.                               : advance one frame and pause
,                               : go back by one frame and pause
q                               : quit
Q                               : exit and remember playback position
Control+c                       : quit (force)
PLAY                            : toggle pause/playback mode (Media Key)
PAUSE                           : toggle pause/playback mode (Media Key)
PLAYPAUSE                       : toggle pause/playback mode (Media Key)
PLAYONLY                        : unpause (Media Key)
PAUSEONLY                       : pause (Media Key)
STOP                            : quit (Media Key)

⏩ Seeking & Chapters
RIGHT                           : seek 5 seconds forward
LEFT                            : seek 5 seconds backward
UP                              : seek 1 minute forward
DOWN                            : seek 1 minute backward
Shift+RIGHT                     : seek exactly 1 second forward (no OSD)
Shift+LEFT                      : seek exactly 1 second backward (no OSD)
Shift+UP                        : seek exactly 5 seconds forward (no OSD)
Shift+DOWN                      : seek exactly 5 seconds backward (no OSD)
PGUP                            : seek to the next chapter
PGDWN                           : seek to the previous chapter
Shift+PGUP                      : seek 10 minutes forward
Shift+PGDWN                     : seek 10 minutes backward
<                               : skip to the previous file
>                               : skip to the next file
ENTER                           : skip to the next file
NEXT                            : skip to the next file (Media Key)
PREV                            : skip to the previous file (Media Key)
Shift+BS                        : undo the previous (or marked) seek
Shift+Control+BS                : mark the position for revert-seek

🔊 Volume & Audio
9                               : decrease volume by 2
/                               : decrease volume by 2
0                               : increase volume by 2
* : increase volume by 2
m                               : toggle mute
Control++                       : delay audio by 100 ms
Control+-                       : shift audio earlier by 100 ms
SHARP (#)                       : switch audio track
VOLUME_UP                       : increase volume by 2 (Media Key)
VOLUME_DOWN                     : decrease volume by 2 (Media Key)
MUTE                            : toggle mute (Media Key)

🅰️ Subtitles
Control+LEFT                    : seek to the previous subtitle
Control+RIGHT                   : seek to the next subtitle
Control+Shift+LEFT              : change subtitle timing (prev subtitle)
Control+Shift+RIGHT             : change subtitle timing (next subtitle)
z                               : shift subtitles 100 ms earlier
Z                               : delay subtitles by 100 ms
x                               : delay subtitles by 100 ms
Shift+g                         : increase subtitle font size
Shift+f                         : decrease subtitle font size
r                               : move subtitles up
R                               : move subtitles down
t                               : move subtitles down
v                               : hide or show subtitles
Alt+v                           : hide or show secondary subtitles
V                               : toggle stretching SSA/ASS subtitles
u                               : toggle overriding SSA/ASS subtitle styles
j                               : switch subtitle track
J                               : switch subtitle track backwards

🖼️ Video & Display
Alt+left                        : move video right (pan)
Alt+right                       : move video left (pan)
Alt+up                          : move video down (pan)
Alt+down                        : move video up (pan)
Alt++                           : zoom in video
Alt+-                           : zoom out video
Alt+BS                          : reset zoom and pan settings
d                               : toggle deinterlacing filter
_                               : switch video track
T                               : toggle video on top of other windows
f                               : toggle fullscreen
ESC                             : leave fullscreen
Alt+0                           : halve window size
Alt+1                           : reset window size
Alt+2                           : double window size
w                               : decrease panscan
W                               : shrink black bars by cropping video
e                               : shrink black bars by cropping video
A                               : cycle video aspect ratio
Control+h                       : toggle hardware decoding

⚙️ Adjustments & Info
1                               : decrease contrast
2                               : increase contrast
3                               : decrease brightness
4                               : increase brightness
5                               : decrease gamma
6                               : increase gamma
7                               : decrease saturation
8                               : increase saturation
O                               : toggle OSD display level
o                               : show playback progress
P                               : show playback progress
i                               : display information and statistics
I                               : toggle information and statistics display
`                               : open the console
l                               : set/clear A-B loop points
L                               : toggle infinite looping
E                               : switch edition
F8                              : show the playlist
F9                              : show the list of video, audio, and sub tracks
s                               : take screenshot (original resolution, with subs)
S                               : take screenshot (original resolution, no subs)
Control+s                       : take screenshot (window, with OSD/subs)
Alt+s                           : automatically screenshot every frame (toggle)
