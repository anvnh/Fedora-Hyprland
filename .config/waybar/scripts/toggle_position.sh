#!/bin/bash

CONFIG_FILE="$HOME/.config/waybar/config.jsonc"
TEMP_FILE="$HOME/.config/waybar/config.jsonc.tmp"

# Sao lưu file gốc
cp "$CONFIG_FILE" "$CONFIG_FILE.bak"

# Đọc dòng thứ 3 để lấy giá trị position
POSITION_LINE=$(sed -n '3p' "$CONFIG_FILE")

# Kiểm tra giá trị hiện tại của position (top hoặc bottom)
if echo "$POSITION_LINE" | grep -q '"position": "top"'; then
    CURRENT_POSITION="top"
    NEW_POSITION="bottom"
else
    CURRENT_POSITION="bottom"
    NEW_POSITION="top"
fi

# Thay đổi dòng thứ 3 với giá trị mới
sed "3s/\"position\": \"$CURRENT_POSITION\"/\"position\": \"$NEW_POSITION\"/" "$CONFIG_FILE" > "$TEMP_FILE" && mv "$TEMP_FILE" "$CONFIG_FILE"

# Khởi động lại Waybar để áp dụng thay đổi
pkill waybar && waybar &
