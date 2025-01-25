# VPN Profile Generator for macOS

This script generates a `.mobileconfig` file to bulk-add IKEv2 VPN configurations to macOS.

## Features
- Parses a CSV file containing VPN server names and addresses.
- Generates a configuration profile that can be installed on macOS.
- Supports IKEv2 with username/password authentication (EAP-MSCHAPv2).

## Prerequisites
- macOS (Tested on latest versions)
- Bash (pre-installed on macOS)

## Usage

1. Clone the repository:
   ```bash
   git clone https://github.com/yourusername/vpn-profile-generator.git
   cd vpn-profile-generator
