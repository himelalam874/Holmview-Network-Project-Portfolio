# Holmview School Network Project
**Zahidul Alam Himel — Prototype Developer**

This repository presents the artefacts for the Holmview Primary School Network design and prototype.  
It highlights **VLAN segmentation**, **firewall policy enforcement with nftables**, and a **local DNS server**.

---

## 🔹 Project Overview
- Designed and validated a segmented network for a new school build.
- Implemented VLAN gateways for **Admin, Staff, Students, Guests, IoT, Servers, Teachers**.
- Enforced inter-VLAN policy using **nftables** on Ubuntu Server.
- Built a **local DNS** service with forward/reverse zones (e.g., `admin.local`) and tested A/PTR lookups.

## 🔹 Artefacts
| Type | Description | Path |
|---|---|---|
| Firewall ruleset | nftables segmentation with NAT/forward policies | [`02_Prototype/firewall.sh`](./02_Prototype/firewall.sh) |
| DNS setup script | Local DNS service setup/configuration | [`02_Prototype/uodated-dns.sh`](./02_Prototype/setup-dns.sh) |
| Test evidence – rules | `sudo nft list ruleset` output screenshot | [`03_TestEvidence/nft_ruleset.png`](./03_TestEvidence/nft_ruleset.png) |
| Test evidence – DNS A | `dig @localhost server1.admin.local A` | [`03_TestEvidence/dns_a_record_query.png`](./03_TestEvidence/dns_a_record_query.png) |
| Test evidence – DNS PTR | `dig -x 192.168.10.10` reverse lookup | [`03_TestEvidence/dns_reverse_query.png`](./03_TestEvidence/dns_ptr_query.png) |

> Add additional configs or screenshots (e.g., `netplan` YAMLs, Packet Tracer diagrams) as the project evolves.

##🔹 Tools Used

Ubuntu Server • nftables • BIND/dnsmasq (per script) • VirtualBox • Wireshark • draw.io

##🔹 Author

Zahidul Alam Himel
Bachelor of IT (Cyber Security) — CQU

## 🔹 Quick Re-run (Lab)
1) **Firewall VM** (Ubuntu Server 22.04)
```bash
sudo bash 02_Prototype/firewall.sh
sudo systemctl enable --now nftables
sudo nft list ruleset

