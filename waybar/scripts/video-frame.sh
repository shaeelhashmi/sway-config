#!/bin/bash

ASSETS="$HOME/.config/waybar/frames"
CSS="$HOME/.config/waybar/CSS/Hello-kitty.css"

FRAMES=("$ASSETS"/frame_*.png)
NUM_FRAMES=${#FRAMES[@]}

idx=0
while true; do
    image=$(basename "${FRAMES[$idx]}")
    ts=$(date +%s%N)
    cat > "$CSS" <<CSSEOF
#custom-hello-kitty {
  min-width: 24px;
  min-height: 24px;
  background-image: url("file://$ASSETS/$image?ts=$ts");
  background-repeat: no-repeat;
  background-size: contain;
  background-position: center;
}
CSSEOF
    idx=$(( (idx + 1) % NUM_FRAMES ))
    sleep 0.1
done
