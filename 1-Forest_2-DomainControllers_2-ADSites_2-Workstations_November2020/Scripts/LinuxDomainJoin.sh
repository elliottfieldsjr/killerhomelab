sudo apt -y update
sudo apt -y install realmd libnss-sss libpam-sss sssd sssd-tools adcli samba-common-bin oddjob oddjob-mkhomedir packagekit
sudo apt -y upgrade

sudo hostnamectl set-hostname khl-kf-01.dir.ad.killerhomelab.com

sudo systemctl disable systemd-resolved
sudo systemctl stop systemd-resolved

sudo unlink /etc/resolv.conf

sudo tee -a /etc/resolv.conf <<EOF
domain dir.ad.killerhomelab.com
nameserver 10.1.1.101
nameserver 10.1.2.101
EOF

sudo reboot

sudo realm discover dir.ad.killerhomelab.com

sudo realm join -v -U dom-admin dir.ad.killerhomelab.com

sudo bash -c "cat > /usr/share/pam-configs/mkhomedir" <<EOF
EOF

sudo realm permit dom-admin@dir.ad.killerhomelab.com
