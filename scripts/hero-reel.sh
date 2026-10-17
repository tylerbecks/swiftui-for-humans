#!/bin/zsh
# Makes the website's hero marquee tiles from the app's `-heroReel` screen
# (App/HeroReel.swift). Still tiles become .webp, animated ones a 6-second
# .mp4 that starts at rest, changes at about 1.5 s, and changes back at about
# 4.5 s, so 0 and 3 seconds in are both resting frames. Light and dark, saved
# to website/images/hero/.
#
# usage: scripts/hero-reel.sh <path to "SwiftUI for Humans.app"> <iPad simulator udid>
# Use an 11-inch iPad simulator (820×1180 points) that isn't your everyday one.
# Needs ffmpeg and ImageMagick (brew install ffmpeg imagemagick).
set -e
APP=$1; DEV=$2
OUT=${0:A:h}/../website/images/hero
TMP=$(mktemp -d)
mkdir -p $OUT

# Keep in sync with HeroReel and HeroTile in App/HeroReel.swift.
TILES=(toggle glassMorph slider segmented buttons progress symbolSwap stepper
       chart glassTabs gauge typography textField spinner settingsRow glassButtons
       datePicker tags colors sheet)
ANIMATED=(toggle glassMorph slider segmented progress symbolSwap chart glassTabs spinner sheet)
W=240 H=150 X0=12 Y0=12 GAP=12 COLS=3 SCALE=2

xcrun simctl boot $DEV 2>/dev/null || true
xcrun simctl bootstatus $DEV -b >/dev/null
xcrun simctl install $DEV "$APP"

for MODE in light dark; do
  xcrun simctl ui $DEV appearance $MODE
  xcrun simctl terminate $DEV com.gobimaps.SwiftUIForHumans 2>/dev/null || true
  xcrun simctl launch $DEV com.gobimaps.SwiftUIForHumans -heroReel >/dev/null
  sleep 3
  xcrun simctl io $DEV screenshot $TMP/$MODE.png >/dev/null 2>&1
  xcrun simctl io $DEV recordVideo --codec h264 --force $TMP/$MODE.mov >/dev/null 2>&1 &
  REC=$!
  sleep 16
  kill -INT $REC; wait $REC 2>/dev/null || true

  for i in {1..$#TILES}; do
    NAME=$TILES[$i]
    COL=$(( (i - 1) % COLS )); ROW=$(( (i - 1) / COLS ))
    X=$(( (X0 + COL * (W + GAP)) * SCALE )); Y=$(( (Y0 + ROW * (H + GAP)) * SCALE ))
    CW=$(( W * SCALE )); CH=$(( H * SCALE ))
    if (( ${ANIMATED[(Ie)$NAME]} )); then
      ffmpeg -loglevel error -y -i $TMP/$MODE.mov -vf "crop=$CW:$CH:$X:$Y,fps=30" \
        -an -c:v libx264 -crf 18 -pix_fmt yuv420p $TMP/tile.mp4
      if [[ $NAME == spinner ]]; then
        START=4  # Always moving; the page loops it.
      else
        # The tile changes every 3 seconds. Start in the middle of a resting
        # stretch, so the clip begins and ends (and is still at 3 s) at rest.
        START=$(ffmpeg -i $TMP/tile.mp4 -vf "freezedetect=n=0.002:d=0.8" -map 0:v -f null - 2>&1 |
          awk -F': ' '/freeze_start/ {s=$NF} /freeze_end/ {m=(s+$NF)/2; if (m >= 1 && m + 6 <= 15 && !found) {print m; found=1}}')
        [[ -z $START ]] && { echo "No resting stretch found for $NAME ($MODE)"; exit 1; }
      fi
      ffmpeg -loglevel error -y -ss $START -i $TMP/tile.mp4 -t 6 -an -c:v libx264 -preset slow -crf 28 \
        -pix_fmt yuv420p -movflags +faststart $OUT/$NAME-$MODE.mp4
      # The resting first frame doubles as the still.
      ffmpeg -loglevel error -y -i $OUT/$NAME-$MODE.mp4 -frames:v 1 $TMP/poster.png
      magick $TMP/poster.png -quality 82 $OUT/$NAME-$MODE.webp
    else
      magick $TMP/$MODE.png -crop ${CW}x${CH}+$X+$Y +repage -quality 82 $OUT/$NAME-$MODE.webp
    fi
  done
done

xcrun simctl terminate $DEV com.gobimaps.SwiftUIForHumans 2>/dev/null || true
rm -rf $TMP
echo "Saved tiles to $OUT"
