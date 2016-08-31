include config.mk

all: testroot pickled.img

testroot:
	@if [ "$$(whoami)" != "root" ]; then echo "Must be root. Run with sudo."; exit 1; fi

kernel-qemu:
	wget http://xecdesign.com/downloads/linux-qemu/kernel-qemu

raspbian.zip:
	wget http://downloads.raspberrypi.org/raspbian_latest -O raspbian.zip

raspbian.img: raspbian.zip
	unzip raspbian.zip
	mv ????-??-??-raspbian.img raspbian.img
	touch raspbian.img

pickled.img: raspbian.img kernel-qemu
	cp raspbian.img pickled.img
	
	# mount filesystems:
	mkdir -p workboot
	mkdir -p work
	mount -o loop,offset=4194304 pickled.img workboot
	mount -o loop,offset=62914560 -t ext4 pickled.img work
	
	# run pre-install scripts
	for F in ${FEATURES}; do . features/$$F/pre-install.sh; done
		
	# add our install script to .bashrc.
	# since we are auto logging in on serial interface,
	# it will run at boot.
	cp work/home/pi/.bashrc work/home/pi/.bashrc-backup
	echo "#!/bin/bash" >work/home/pi/.bashrc
	chmod a+x work/home/pi/.bashrc
	for F in ${FEATURES}; do cat features/$$F/install.sh >>work/home/pi/.bashrc; done
	echo '' >>work/home/pi/.bashrc
	echo 'sudo sync' >>work/home/pi/.bashrc
	echo 'sudo reboot' >>work/home/pi/.bashrc
	
	# start virtual machine to run install script:
	sync
	umount -l workboot
	umount -l work
	rmdir workboot
	rmdir work
	qemu-system-arm -kernel kernel-qemu -cpu arm1176 -m 256 -M versatilepb -no-reboot -serial stdio -append "root=/dev/sda2 panic=1 rootfstype=ext4 rw" -hda pickled.img -nographic
	mkdir -p workboot
	mkdir -p work
	mount -o loop,offset=4194304 pickled.img workboot
	mount -o loop,offset=62914560 -t ext4 pickled.img work
	
	# remove install script:
	cp work/home/pi/.bashrc-backup work/home/pi/.bashrc
	rm work/home/pi/.bashrc-backup
	
	# run post-install scripts
	for F in ${FEATURES}; do . features/$$F/post-install.sh; done
	
	# finish
	sync
	umount -l workboot
	umount -l work
	rmdir workboot
	rmdir work
	chmod 444 pickled.img
