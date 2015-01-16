.. tags: latch, VHDL, SR latch, KTH

Gated SR latch
==============

Gated SR latch, also known as *clocked SR latch* or *synchronous SR latch* or
*SR flip-flop* can be used as register [#kth]_:

.. figure:: dia/gated-sr-latch-symbol-explained.svg

    Gated/clocked SR latch

.. figure:: dia/gated-sr-latch-internals.svg

    Gated SR latch constructed with four NAND gates

Again corresponding VHDL snippet:

.. listing:: src/sr_latch.vhd

For instance single SR latch could be implemented using single SN7400N [#sn7400n]_ integrated circuit:

.. figure:: http://quarndon.co.uk/images2/components/7400_dil_pin.gif

    SN7400N integrated circuit contains four NAND gates



.. [#kth] http://www.it.kth.se/courses/IL2217/F4_2.pdf
.. [#sn7400n] http://quarndon.co.uk/index.php?main_page=product_info&products_id=12966
.. [#data_latch] http://www.play-hookey.com/digital/sequential/d_nand_latch.html

