#!/usr/bin/env bash
# Script um alle Thumbnails und Resized Bilder zu erzeugen, orientiert sich
# an der alten Galerie.
# (c) Christian Mayer, 2019

# Zielgrößen:
# Thumbnail: max 128x128, Qualität 80
g_sThumbnailXSize=128
g_sThumbnailYSize=128
g_sThumbnailQuality=80
g_sThumbnailPath="_thm"   # Subfolder name with thumbnails
g_sThumbnailPrefix="thm_" # prefix for created thumbnails

# Resized:   max 50000x600, Qualität 80 (d.h. X = disable)
g_sResizedXSize=50000
g_sResizedYSize=600
g_sResizedQuality=80
g_sResizedPrefix="res_"
g_sResizedPath="_res"

g_sConvertPath=`which convert`

g_sThumbnailImArg="$g_sConvertPath -filter Lanczos -quality ${g_sThumbnailQuality} "
g_sThumbnailImArg+="-resize ${g_sThumbnailXSize}x${g_sThumbnailYSize} "
g_sThumbnailImArg+="-sharpen 2 +profile APP1"

g_sResizedImArg="$g_sConvertPath -filter Lanczos -quality ${g_sResizedQuality} "
g_sResizedImArg+="-resize ${g_sResizedXSize}x${g_sResizedYSize} "
g_sResizedImArg+="-sharpen 2 +profile APP1"

ALL=0

for i in "$@"
do
case $i in
    -h|--help)
    echo "Erzeuge alle Thumbnails. Normalerweise nur die fehlenden."
    echo "Optionen:"
    echo "  --all"
    echo "    Erzeuge alle Thumbnails neu"
    exit
    ;;
    --all)
    ALL=1
    shift # past argument=value
    ;;
    *)
          # unknown option
    ;;
esac
done

# Iteriere über alle Bilder
find . -iname "*.jpg" -not \( -path "*/_thm/*" -o -path "*/_res/*" \)  -print0 | while IFS= read -r -d '' Original
do
  ThumbnailDir=`find "$Original" -printf %h/$g_sThumbnailPath`
  Thumbnail=`find "$Original" -printf %h/$g_sThumbnailPath/$g_sThumbnailPrefix%f`
  ResizedDir=`find "$Original" -printf %h/$g_sResizedPath`
  Resized=`find "$Original" -printf %h/$g_sResizedPath/$g_sResizedPrefix%f`

  if [[ ! -f $Thumbnail ]] || [[ $ALL == 1 ]]; then
    mkdir -p "$ThumbnailDir"
    (set -x ; $g_sThumbnailImArg "$Original" "$Thumbnail" )
  fi

  if [[ ! -f $Resized ]] || [[ $ALL == 1 ]]; then
    mkdir -p "$ResizedDir"
    (set -x ; $g_sResizedImArg "$Original" "$Resized" )
  fi
done

echo done