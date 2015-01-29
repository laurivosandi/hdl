.. tags:  Sigrok

Signal analysis using Sigrok
============================

Introduction
------------

Sigrok is an open-source software suite of signal analysis tools compromised of
signal capture, protocol decoders and graphical tools.
Sigrok's hardware support is pretty extensive and it's growing [#sigrok-hardware-support]_.


Installing
----------

To install Sigrok on Ubuntu 14.04, enable their PPA repository:

.. code:: bash

    sudo add-apt-repository ppa:jorik-kippendief/sigrok
    sudo apt-get install pulseview


PulseView
---------
    
Sigrok has command-line utilities for signal capture, but for newbies
there is PulseView tool:

.. figure:: http://sigrok.org/wimg/e/ee/PulseView_I2C_DS1307_Decode.png

    PulseView can parse various protocols such as I²C, SPI, UART etc.


Salea logic analyzer clones
---------------------------

Salea logic analyzer is a Cypress FX2 chipset based logic analyzer which 
can record up to 8 channels at 24MHz ranging from 0V to 5V.

.. figure:: http://sigrok.org/wimg/0/02/Mcu123_saleae_logic_clone_package_contents.jpg

    Salea logic analyzer can sample 8 channels at 24MHz.

It has been discontinued by Salea but its clones are still available,
anything with that particular chipset works.
In order to use that chipset with Sigrok tools firmware for the logic analyzer
has to be installed, otherwise you get "Firmware upload failed" once
you fire up PulseView:

.. code:: bash
    
    sudo apt-get install sigrok-firmware-fx2lafw
    
Salea logic analyzer clones can be purchased at eBay for less than 8€ per item [#ebay-salea-logic-analyzer]_.

.. [#ebay-salea-logic-analyzer] http://www.ebay.com/itm/251637912969
    

Summary
-------

Sigrok tools in conjunction with Salea logic analyzer clone can be used
to interface FPGA design with already existing hardware and debug the design.
    
.. [#sigrok-hardware-support] http://sigrok.org/wiki/Supported_hardware
