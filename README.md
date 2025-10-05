# Holmview School Network Project  
### Zahidul Alam Himel — Prototype Developer  

This repository presents the artefacts for the **Holmview Primary School Network Security Project**, developed as part of the Bachelor of Information Technology (Cyber Security).  
It demonstrates **network segmentation, firewall configuration, and local DNS implementation** to create a secure and scalable school network.

---

## 🔹 Project Overview  
The Holmview project focuses on designing and implementing a secure network for a newly planned primary school.  
Key security goals include network segmentation, role-based access control, DNS/DHCP configuration, and testing of network isolation policies.  
The prototype validates the group’s network design by demonstrating functional VLANs, inter-VLAN restrictions, and DNS-based content filtering.

---

## 🔹 Key Contributions  
**Firewall & VLAN Segmentation Prototype**  
- Configured VLAN gateways for Admin, Staff, Students, Guests, IoT, Servers, and Teachers using Ubuntu Server (netplan YAML).  
- Implemented nftables rules for segmentation:  
  - Admin – Full access  
  - Staff – Access to Servers + Internet  
  - Students/Guests – Internet-only  
  - IoT – DNS/NTP access only  
  - Teachers – Extended access for instructional resources  
- Validated rules using `ping`, `curl`, and `dig` tests.

**Local DNS Server**  
- Deployed dnsmasq as a local DNS with DHCP integration.  
- Configured internal domain zones (e.g., `admin.local`).  
- Integrated **OpenDNS FamilyShield** to restrict unsafe content for Students/Guests.  
- Tested A and PTR lookups successfully.

---

## 🔹 Artefacts  
| File | Description | Path |
|------|--------------|------|
| Firewall Ruleset | nftables segmentation configuration | [`firewall.sh`](./firewall.sh) |
| DNS Setup Script | Local DNS + DHCP configuration | [`updated-dns.sh`](./updated-dns.sh) |
| Firewall Rules Output | Screenshot of active nftables configuration | ![Ruleset](./nft_ruleset.png) |
| DNS Forward Lookup | `dig @localhost server1.admin.local A` result | ![DNS Forward](./dns_a_record_query.png) |
| DNS Reverse Lookup | `dig -x 192.168.10.10` reverse test | ![DNS Reverse](./dns_reverse_query.png) |

---

## 🔹 How to Reproduce
1. **Firewall VM Setup**
   ```bash
   sudo bash firewall.sh
   sudo systemctl enable --now nftables
   sudo nft list ruleset
