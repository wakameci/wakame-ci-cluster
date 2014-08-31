disk_filename=box-disk2.raw

sudo qemu-img create -f raw                        ${disk_filename} $((1024 * 10))M
sudo mkfs.ext4 -F -E lazy_itable_init=1 -L jenkins ${disk_filename}
sudo tune2fs -c 0 -i 0                             ${disk_filename}

# sudo mount /dev/sdb /mnt/
# sudo rsync -avx /var/www/html/ /mnt/
# sudo rm -rf /var/www/html/*
# sudo umount /mnt/
# sudo mount /dev/sdb /var/www/html/

# sudo vi /etc/fstab
# > LABEL=root              /               ext4    defaults        1 1
# > LABEL=yum-repo          /var/www/html   ext4    defaults        1 1
