#!/usr/bin/env bash

# This script takes a CSV of VPN servers and creates a .mobileconfig that can
# be imported into macOS to configure the VPN.
#
# Originally created this to batch create a ton of VPN configs for
# FastestVPN servers: https://account.fastestvpn.com/server/locations
# 
# Thanks to https://chatgpt.com/share/67948164-00ec-8005-8726-3d0d500c1207 for
# helping me write this script.

# --- Adjust these to your needs ---
REMOTE_ID="jumptoserver.com"
USERNAME="someUsername"
PASSWORD="somePassword"
CSV_FILE="FastestVPN Servers.csv"
OUTPUT="my_vpn.mobileconfig"
ORG_NAME="MyOrg"

cat > "$OUTPUT" <<EOF
<?xml version="1.0" encoding="UTF-8"?>
<!DOCTYPE plist PUBLIC "-//Apple//DTD PLIST 1.0//EN"
  "http://www.apple.com/DTDs/PropertyList-1.0.dtd">
<plist version="1.0">
<dict>
  <!-- Profile metadata -->
  <key>PayloadType</key>
  <string>Configuration</string>
  <key>PayloadVersion</key>
  <integer>1</integer>

  <!-- Adding Organization helps on some macOS versions -->
  <key>PayloadOrganization</key>
  <string>${ORG_NAME}</string>

  <key>PayloadIdentifier</key>
  <string>com.yourcompany.vpn</string>
  <key>PayloadUUID</key>
  <string>$(uuidgen)</string>
  <key>PayloadDisplayName</key>
  <string>Multiple IKEv2 VPNs</string>

  <key>PayloadContent</key>
  <array>
EOF

# Skip any header row (if present) by starting from line 2
tail -n +2 "$CSV_FILE" | while IFS=, read -r NAME SERVER; do
  # Clean up any stray \r or \n
  NAME="${NAME//$'\r'/}"
  NAME="${NAME//$'\n'/}"
  SERVER="${SERVER//$'\r'/}"
  SERVER="${SERVER//$'\n'/}"

  # Skip lines that don't have valid data
  [[ -z "$NAME" || -z "$SERVER" ]] && continue

  echo "Processing: $NAME ($SERVER)"

cat >> "$OUTPUT" <<EOF
    <dict>
      <key>PayloadType</key>
      <string>com.apple.vpn.managed</string>
      <key>PayloadIdentifier</key>
      <string>com.yourcompany.vpn.$(uuidgen)</string>
      <key>PayloadUUID</key>
      <string>$(uuidgen)</string>
      <key>PayloadDisplayName</key>
      <string>${NAME}</string>
      <key>PayloadVersion</key>
      <integer>1</integer>

      <key>UserDefinedName</key>
      <string>${NAME}</string>
      <key>VPNType</key>
      <string>IKEv2</string>
      <key>IKEv2</key>
      <dict>
        <!-- Where to connect -->
        <key>RemoteAddress</key>
        <string>${SERVER}</string>
        <key>RemoteIdentifier</key>
        <string>${REMOTE_ID}</string>

        <!-- For username/password-based IKEv2 (EAP-MSCHAPv2) -->
        <key>AuthenticationMethod</key>
        <string>None</string>
        <key>ExtendedAuthEnabled</key>
        <true/>
        <key>AuthName</key>
        <string>${USERNAME}</string>
        <key>AuthPassword</key>
        <string>${PASSWORD}</string>

        <!-- Certificate chain validation required for IKEv2 -->
        <key>UseCertificateChainValidation</key>
        <true/>
      </dict>
    </dict>
EOF
done

cat >> "$OUTPUT" <<EOF
  </array>
</dict>
</plist>
EOF
