#!/bin/bash

get_temp() {
    local sensor_name="$1"
    local label_match="$2"
    for hw in /sys/class/hwmon/hwmon*; do
        if [ "$(cat "$hw/name" 2>/dev/null)" = "$sensor_name" ]; then
            if [ -n "$label_match" ]; then
                for label_file in "$hw"/temp*_label; do
                    if [ -f "$label_file" ] && grep -qi "$label_match" "$label_file"; then
                        input_file="${label_file/_label/_input}"
                        cat "$input_file"
                        return
                    fi
                done
            else
                cat "$hw/temp1_input"
                return
            fi
        fi
    done
    echo 0
}

cpu_raw=$(get_temp "coretemp" "Package id 0")
gpu_raw=$(get_temp "amdgpu" "")

cpu_c=$((cpu_raw / 1000))
gpu_c=$((gpu_raw / 1000))

echo "{\"text\": \"CPU ${cpu_c}°C  GPU ${gpu_c}°C\", \"tooltip\": \"CPU: ${cpu_c}°C\nGPU: ${gpu_c}°C\"}"