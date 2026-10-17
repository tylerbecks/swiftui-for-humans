#!/bin/zsh
# Makes the website's hero board tiles from the app's `-heroReel` screen
# (App/HeroReel.swift), in light and dark, saved to website/images/hero/:
# - still tiles as .webp
# - animated tiles as a 6-second .mp4 that starts at rest, changes at about
#   1.5 s, and changes back at about 4.5 s, so 0 and 3 seconds in are both
#   resting frames, plus stills of both: <name>-<mode>.webp (0 s) and
#   <name>-<mode>-b.webp (3 s)
# - tiles.js, the list the page builds the board from
#
# usage: scripts/hero-reel.sh <path to "SwiftUI for Humans.app"> <iPad simulator udid>
# Use an 11-inch iPad simulator (820×1180 points) that isn't your everyday one.
# Needs ffmpeg, ImageMagick, and jq (brew install ffmpeg imagemagick jq).
set -e
APP=$1; DEV=$2
BUNDLE=com.swiftuiforhumans.app
OUT=${0:A:h}/../website/images/hero
TMP=$(mktemp -d)
SCALE=2 W=240

xcrun simctl boot $DEV 2>/dev/null || true
xcrun simctl bootstatus $DEV -b >/dev/null
xcrun simctl install $DEV "$APP"

launch() {  # page
  xcrun simctl terminate $DEV $BUNDLE 2>/dev/null || true
  xcrun simctl launch $DEV $BUNDLE -heroReel $1 >/dev/null
  sleep 3
}

# The app saves the layout when the reel opens.
launch 0
LAYOUT=$(xcrun simctl get_app_container $DEV $BUNDLE data)/Documents/heroReel.json
PAGES=$(jq '[.[].page] | max' $LAYOUT)
rm -rf $OUT && mkdir -p $OUT

for MODE in light dark; do
  xcrun simctl ui $DEV appearance $MODE
  for PAGE in $(seq 0 $PAGES); do
    launch $PAGE
    xcrun simctl io $DEV screenshot $TMP/shot.png >/dev/null 2>&1
    xcrun simctl io $DEV recordVideo --codec h264 --force $TMP/rec.mov >/dev/null 2>&1 &
    REC=$!
    sleep 16
    kill -INT $REC; wait $REC 2>/dev/null || true

    jq -r --argjson p $PAGE '.[] | select(.page == $p) | "\(.name) \(.x) \(.y) \(.height) \(.animated)"' $LAYOUT |
    while read NAME X Y H ANIMATED; do
      CROP="$(( W * SCALE )):$(( H * SCALE )):$(( X * SCALE )):$(( Y * SCALE ))"
      if [[ $ANIMATED == true ]]; then
        ffmpeg -loglevel error -y -i $TMP/rec.mov -vf "crop=$CROP,fps=30" \
          -an -c:v libx264 -crf 18 -pix_fmt yuv420p $TMP/tile.mp4 </dev/null
        if [[ $NAME == spinner ]]; then
          START=4  # Always moving; the page loops it.
        else
          # The tile changes every 3 seconds. Start in the middle of a
          # resting stretch, so 0 s and 3 s into the clip are both at rest.
          START=$(ffmpeg -i $TMP/tile.mp4 -vf "freezedetect=n=0.002:d=0.8" -map 0:v -f null - 2>&1 </dev/null |
            awk -F': ' '/freeze_start/ {s=$NF} /freeze_end/ {m=(s+$NF)/2; if (m >= 1 && m + 6 <= 15 && !found) {print m; found=1}}')
          [[ -z $START ]] && { echo "No resting stretch found for $NAME ($MODE)"; exit 1; }
        fi
        ffmpeg -loglevel error -y -ss $START -i $TMP/tile.mp4 -t 6 -an -c:v libx264 -preset slow -crf 28 \
          -pix_fmt yuv420p -movflags +faststart $OUT/$NAME-$MODE.mp4 </dev/null
        ffmpeg -loglevel error -y -i $OUT/$NAME-$MODE.mp4 -frames:v 1 $TMP/a.png </dev/null
        ffmpeg -loglevel error -y -ss 3 -i $OUT/$NAME-$MODE.mp4 -frames:v 1 $TMP/b.png </dev/null
        magick $TMP/a.png -quality 82 $OUT/$NAME-$MODE.webp
        magick $TMP/b.png -quality 82 $OUT/$NAME-$MODE-b.webp
      else
        IFS=: read CW CH CX CY <<< $CROP
        magick $TMP/shot.png -crop ${CW}x${CH}+$CX+$CY +repage -quality 82 $OUT/$NAME-$MODE.webp
      fi
    done
  done
done

{
  echo "// Made by scripts/hero-reel.sh. The hero board's tiles; board.js reads it."
  echo "window.heroTiles = $(jq -c '[.[] | {name, title, height, animated}]' $LAYOUT);"
} > $OUT/tiles.js
xcrun simctl terminate $DEV $BUNDLE 2>/dev/null || true
rm -rf $TMP
echo "Saved $(jq length $LAYOUT) tiles to $OUT"
