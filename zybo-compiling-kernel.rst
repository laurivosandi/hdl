.. tags: ZYBO, Xilinx, Xillinux, Zynq, FPGA, ARM, Debian, Ubuntu, VHDL
.. title: Compiling kernel for ZYBO
.. date: 2014-06-04

Compiling kernel for ZYBO
=========================

Introduction
------------

Xillinux 1.3 is a good starting point for ZYBO because out-of-the-box it provides:

* Verilog/VHDL design for PL which enables video and audio outputs
* First stage bootloader which uploads bitstream to PL
* Ubuntu 12.04 armhf based root filesystem
* Device tree definition

So why should you want to recompile the kernel?
There are various reasons, for instance I happened to buy a USB WiFi dongle
that did not work out of the box.
If you're attempt to compile a kernel module then you're also in need
of a prepared kernel source tree.


About kernel development generally
----------------------------------

The kernel development flow for Xillinux 1.3 and ZYBO should approximately adhere to following:

* Linux kernel upstream [#torvalds-linux]_
* Xilinx downstream for Zynq-7000 boards [#xilinx-linux]_
* Digilent downstream for this particular board [#digilent-linux]_
* Xillybus downstream patches against 3.12 which are sitting under /usr/src/xillinux/kernel-patches/

You may fetch the source using Git:

.. code:: bash

   git clone https://github.com/digilent/linux-Digilent-Dev
   
If you want to retain working video/audio drivers I suggest you checkout 
particular kernel version against which Xillinux 1.3 kernel was compiled:

.. code:: bash

   git checkout 7ad8e6023d969336961312ef751228cbb8874752

Then fetch the patches from /usr/src/xillinux/kernel-patches/ and apply them one-by-one.
You can get the patches from my web server aswell [#lauri-vosandi-zynq-7000]_:

.. code:: bash
    
    patch -p1 < 0001-.config-file-added-to-tree.patch
    patch -p1 < 0002-Makefile-Added-xillinux-1.3-extra-version-to-kernel-.patch
    patch -p1 < 0003-usb-core-hub.c-Export-usb_port_suspend-because-phy-z.patch
    patch -p1 < 0004-mmc-sdhci-add-quirk-for-broken-write-protect-detecti.patch
    patch -p1 < 0005-Xillybus-drivers-in-the-kernel-tree-updated-to-match.patch
    patch -p1 < 0006-Added-xillyvga-driver-to-kernel-tree.patch
    patch -p1 < 0007-HP2-AXI-bus-width-set-to-32-bits-in-VGA-driver.patch
    patch -p1 < 0008-Added-Xillybus-Lite-to-the-kernel.patch
   
Run menuconfig and tweak the kernel further, for instance I needed to enable
RTL8188EU wireless chipset support under Staging drivers to get my USB dongle working.
You probably want to add something to General setup -> Local version so once you
install the kernel modules they won't overwrite the Xillinux kernel modules and
in case of emergency you would still have to option to boot the older kernel:

.. code:: bash

   make ARCH=arm menuconfig

.. [#torvalds-linux] `Linux kernel source tree <https://github.com/torvalds/linux>`_
.. [#xilinx-linux] `The official Linux kernel from Xilinx <https://github.com/Xilinx/linux-xlnx>`_
.. [#digilent-linux] `Linux Kernel Repository for Digilent FPGA Boards <https://github.com/digilent/linux-Digilent-Dev>`_
.. [#lauri-vosandi-zynq-7000] http://lauri.vosandi.com/shared/Zynq-7000/


Compiling on a PC
-----------------

To compile the kernel I suggest using a x86 based laptop because compiling kernel
on ZYBO itselt takes hours, besides since ZYBO does not have an hardware clock
it could mess up the whole kernel compilation process.
If you're on Ubuntu first install *gcc-4.7-armhf-cross* package.
For Debian use Emdebian testing/unstable toolchain [#emdebian-toolchain]_ and install the
same package from there:

.. code:: bash

    make  ARCH=arm UIMAGE_LOADADDR=0x8000 CROSS_COMPILE=arm-linux-gnueabihf- uImage modules -j32

If you already have Xilinx SDK installed you may want to use that instead to save some time:

.. code:: bash

    source /path/to/Xilinx/SDK/2014.1/settings64.sh
    make  ARCH=arm UIMAGE_LOADADDR=0x8000 CROSS_COMPILE=arm-xilinx-linux-gnueabi- uImage modules -j32

You can install the modules to a temporary directory as following:

.. code:: bash

    make ARCH=arm INSTALL_MOD_PATH=/tmp/ modules_install

In ZYBO you probably want to mount the boot partition of SD card and keep a copy of working kernel:

.. code:: bash

    mount /dev/mmcblk0p1 /boot
    cp -v /boot/uImage /boot/uImage-$(uname -r)

Next step is to copy crosscompiled kernel and modules to ZYBO via ethernet cable:

.. code:: bash

    scp arch/arm/boot/uImage  root@192.168.81.3:/boot/uImage
    rsync -avz -e ssh /tmp/lib/modules/ root@192.168.81.3:/lib/modules/
    
Alternatively you just may copy them to root filesystem's /lib/modules directory.

If module dependency tracking is messed up you may want to run following on ZYBO:

.. code:: bash

    depmod -a
    
.. [#emdebian-toolchain] `Emdebian / Cross-development toolchains <http://www.emdebian.org/crosstools.html>`_


Compiling on ZYBO
-----------------

Compiling on ZYBO is of course more straightforward:

.. code:: bash

    make UIMAGE_LOADADDR=0x8000 uImage modules -2
    make modules_install
    mount /dev/mmcblk0p1 /boot
    cp -v /boot/uImage /boot/uImage-$(uname -r)
    cp arch/arm/boot/uImage /boot/
    reboot

