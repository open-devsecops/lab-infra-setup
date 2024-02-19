#!/bin/bash
public_ip="54.176.111.12"

echo "Generating Client's Public-Private Key pair"
ssh -i topic-2-cicd-lab-key.pem ubuntu@${public_ip} /bin/bash << EOF
    sudo bash -c "wg genkey | tee /home/ubuntu/privatekey | wg pubkey > /home/ubuntu/publickey"
    sudo bash -c "chmod go= /home/ubuntu/privatekey; chmod go= /home/ubuntu/publickey"  
EOF

client_pub_key=$(ssh -i topic-2-cicd-lab-key.pem ubuntu@${public_ip} 'sudo cat /home/ubuntu/publickey')
client_private_key=$(ssh -i topic-2-cicd-lab-key.pem ubuntu@${public_ip} 'sudo cat /home/ubuntu/privatekey')
server_pub_key=$(ssh -i topic-2-cicd-lab-key.pem ubuntu@${public_ip} 'sudo cat /etc/wireguard/public.key')

find_available_ip() {
    # Extract all IPs from the config file and sort them
    local used_ips=($(ssh -i topic-2-cicd-lab-key.pem ubuntu@${public_ip} sudo grep "AllowedIPs" /etc/wireguard/wg0.conf | cut -d '=' -f2 | cut -d '/' -f1 | sort -V))
    local base_ip="192.168.77."
    
    # Check each IP from .2 to .254
    for i in {2..254}; do
        local check_ip="${base_ip}${i}"
        if [[ ! " ${used_ips[@]} " =~ " ${check_ip} " ]]; then
            echo "$check_ip"
            return 0
        fi
    done
    
    echo "No available IP addresses." >&2
    exit 1
}

echo "Finding available IP..."
client_ip=$(find_available_ip)
echo "${client_ip} available!"

echo "Setting up Wireguard config..."
ssh -i topic-2-cicd-lab-key.pem ubuntu@${public_ip} /bin/bash << EOF
    sudo bash -c 'echo -e "\n[Peer]\nPublicKey = ${client_pub_key}\nAllowedIPs = ${client_ip}/32" >> /etc/wireguard/wg0.conf'
    sudo systemctl restart wg-quick@wg0.service
EOF


client_conf=$(cat <<EOF
[Interface]
PrivateKey = ${client_private_key}
Address = ${client_ip}/32
DNS = 192.168.77.1

[Peer]
PublicKey = ${server_pub_key}
AllowedIPs = 0.0.0.0/0
Endpoint = ${public_ip}:21210
EOF)

echo "$client_conf" > open-devsecops-vpn.conf
echo "Done"