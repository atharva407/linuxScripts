free -m
mkdir -p /var/_swap_
cd /var/_swap_
#Here, 1M * 2000 ~= 2GB of swap memory
dd if=/dev/zero of=swapfile bs=1M count=4000
mkswap swapfile
chmod 600 swapfile
swapon swapfile
echo "/var/_swap_/swapfile none swap sw 0 0" >> /etc/fstab
#cat /proc/meminfo
free -m