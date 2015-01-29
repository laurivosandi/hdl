.. tags: ZYBO, Xilinx, Xillinux, Zynq, FPGA, ARM, Debian, Ubuntu
.. title: Vivado 2014.1 vs ZYBO
.. date: 2014-06-11

Vivado 2014.1 vs ZYBO
=====================

Introduction
------------

ZYBO is a Zynq-7000 SoC based board from Digilent.
It's among the cheapest boards. This is a little HOWTO for getting started
with ZYBO. When purchasing ZYBO board there usually is an option to get
voucher which you can exchange for license key on the.

General workflow
----------------

There are many-many ways you can set up Zynq-7000.
In this case we're taking the easiest path to use Vivado to design simple hello world for any Zynq-7000 SoC.
The design is primarily composed of:

* High level block design
* Low level VHDL design for programmable logic, this is basically the FPGA part of the SoC
  that is programmable by the user either in Verilog or VHDL
* VHDL wrapper which interfaces custom VHDL code with AXI bus
* C code which interfaces with the VHDL wrapper via AXI bus
* Board support package
* Linux kernel module
* Userspace application

To simplify further you can use:

* With Vivado use **zybo_base_system/source/vivado/hw/zybo_bsd/zybo_bsd.xpr** from
  `ZYBO base system <http://www.digilentinc.com/Data/Products/ZYBO/zybo_base_system.zip>`_ as the starting point for high level block design,
  as it already contains connections for on-board buttons, switches, LED-s and HDMI output.
  Open the file up with Vivado and press **Generate Bitstream** in the left-hand panel, the file will be written to
  **zybo_base_system/source/vivado/hw/zybo_bsd/zybo_bsd.runs/impl_1/system_wrapper.bit**





Creating a project for ZYBO
---------------------------

In order to work with ZYBO board on Vivado 2014.1 several not so obvious steps have to be taken:

* Open main menu **File** → **New project**
* Click **Next**
* Give your project a name, click **Next**
* Select **RTL Project**, click **Next**
* Under **Add Sources** just click **Next**
* Under **Add Extisting IP** click **Next**
* Under **Add Constraints** click **Add Files**, locate **ZYBO_Master.xdc** and click **OK**
* Under **Default Part** the ZYBO board is not currently located,
  you have to manually set **Family** to **Zynq-7000**,
  **Package** to **clg400**, **Speed grade** to **-1** or directly
  locate Part number **xc7z010clg400-1**
* Click **Next**
* On the final wizard page click **Finish**

Configuring high level blocks
-----------------------------

At this point you have blank project with ZYBO constraints but no configured
high level blocks.

* On the left hand side panel click on **Create Block Design** under **IP Integrator**
* Enter design name, any random string will do and click **OK**
* Click on **Add IP** button on the diagrams toolbar
* Filter search and select **ZYNQ7 Processing System**
* Double click on the diagram element that just appeared,
  **Re-customize IP** window should appear
* Click on **Import XPS Settings** button on the toolbar and locate 
  **ZYBO_zynq_def.xml**, this should automatically connect
  I2C controller, UART controller, SD-card controller, USB host controller and ethernet controller.
  Note that ARM controller is connected to those peripherial devices via
  programmable logic.
  
At this point you have configured your PL in a way which Linux should see the peripherial
devices. Of course we're far from being done.

AXI bus
-------

AXI is part of AMBA 3 specification which is a bus designed for ARM SoC-s
very much like PCI was for x86 architectures.

AXI4 defines three main types of AXI interfaces which all come in
master and slave flavour.

* AXI4 (Full) - High-performance memory-mapped requirements
* AXI4-Lite - 4 registers which can be written and read
* AXI4-Stream - High-speed streaming data

Note that AXI peripherial device can either be master or slave or both
depending on what it has to do:

* Master interface of peripherial can be used to write **to** the DDR3 memory
* Slave interface exposes 64 to 1024 bytes which other master components can write

Zynq-7000 processing system which implemented in hardware includes:

* Two AXI master interfaces
* Two AXI slave interfaces

Now to connect AXI peripherial devices to Zynq-7000 processing system 
you need AXI4 Interconnect which is basically glue component
implemented in PL. AXI4 Interconnect has configurable number of interfaces:

* From 1 to 16 AXI master interfaces
* From 1 to 16 AXI slave interfaces




Connecting custom IP to Zynq-7000 via AXI4 bus
-----------------------------------------------

For the sake of simplicity we'll focus here on implementing piece of hardware
that sits on AXI bus:

* From the main menu select **Tools** →  **Create and Package IP**
* Click **Next**
* Select **Create a new AXI4 peripheral**, click **Next**
* Optionally modify **IP Location**, click **Next**
* Under **Add Interfaces**, click **Next**
* Click **Finish**


This by default gives you a component with AXI Lite interface.
That means you can communicate with this block via limited number of registers.
This is perfectly okay for reading button presses and blinking LED-s
but more serious business you need

Adding custom IP to the high level design
-----------------------------------------

Next step is to add that piece of hardware to the high level block design:

* Click on **Add IP** button on the diagrams toolbar
* Locate the IP core you just added, it is by default named **myip_v1.0**

Connect high level blocks
-------------------------

At this point you should have **ZYNQ7 Processing System** and **myip_v1.0 (Pre-Production)**
visible on the **Diagram** view.
To interconnect high level blocks and fill in gaps:

* Click on **Run Connect Automaton** in the high level design toolbar
* In the dialog leave **Clock Connection** as is **Auto**

Now you should have four components visible in the high level design:

* Zynq-7000 processing system which represents the dual-core ARM processor of the SoC: **processing_system_7_0**
* **rst_processing_system7_0_100M**
* **processing_system7_0_axi_periph**
* Block that represents your custom IP: **myip_0**

Creating HDL wrapper
--------------------

At this point you have created high level block for your IP core,
by default named **myip_0**.
Next step is to create VHDL wrapper for it:

* Under **Sources** panel select **Libraries** subsection
* Right click on the **Design Sources** → **Block Designs** → **design_1** and click on **Create HDL wrapper...**
* In the dialog select **Let Vivado manage wrapper and auto-update**

Editing custom IP
-----------------

Now to add actual VHDL code to your custom IP core,
in the high level block design view right click on your IP core **myip_0**
and click on **Edit in IP Packager**. This should open up the
source code of the the VHDL/Verilog component that is indended to be
customized by the user, you can identify the lines by
**Add user logic here**.



Switching to SDK
----------------

At this point you should be finished with the hardware design for you custom IP core.
To transfer the bitstream to the SD-card use:

* Open main menu **File**
* Select **Export**
* Click on **Export Bitstream file**

Final step in Vivado is to export the hardware design to SDK:

* From main menu open **File**
* Select **Export**
* Click on **Export Hardware for SDK**

Creating board support package
------------------------------

TODO

Creating device tree
--------------------

TODO




http://www.aldec.com/en/support/resources/documentation/articles/1585/
