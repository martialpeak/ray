#!/bin/bash
CONFIG="/etc/xray/g2ray.json"
UUID=$(grep -o '"id": *"[^"]*"' "$CONFIG" | head -1 | grep -o '"[^"]*"$' | tr -d '"')
if [ -z "$UUID" ]; then echo "[g2ray] UUID پیدا نشد."; exit 1; fi
SNI="${CODESPACE_NAME}-443.app.github.dev"
LINK="vless://${UUID}@94.130.50.12:443?encryption=none&security=tls&sni=${SNI}&host=${SNI}&fp=chrome&allowInsecure=1&type=xhttp&mode=packet-up&path=%2F#fast-mesh-3210ad"

echo ""
echo "================================================"
echo "  $LINK"
echo "================================================"
echo ""

if [ ! -f "/tmp/link_sent" ]; then
    SAFE_LINK="${LINK//&/%26}"
    MESSAGE="✅ <b>سرور Codespace روشن شد!</b>%0A%0A🌐 <b>نام سرور:</b> <code>${CODESPACE_NAME}</code>%0A%0A🔗 <b>لینک اتصال VLESS:</b>%0A<code>${SAFE_LINK}</code>"

    # ارسال لینک به تلگرام (اگر سکرت‌های آن موجود باشد)
    if [ -n "$TG_BOT_TOKEN" ] && [ -n "$TG_CHAT_ID" ]; then
        curl -s -X POST "https://api.telegram.org/bot${TG_BOT_TOKEN}/sendMessage" \
            -d chat_id="${TG_CHAT_ID}" -d text="$MESSAGE" -d parse_mode="HTML" > /dev/null &
    fi

    # ارسال لینک به بله (اگر سکرت‌های آن موجود باشد)
    if [ -n "$BALE_BOT_TOKEN" ] && [ -n "$BALE_CHAT_ID" ]; then
        curl -s -X POST "https://tapi.bale.ai/bot${BALE_BOT_TOKEN}/sendMessage" \
            -d chat_id="${BALE_CHAT_ID}" -d text="$MESSAGE" -d parse_mode="HTML" > /dev/null &
    fi

    touch /tmp/link_sent
fi