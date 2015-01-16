.. tags:  KTH, Xilinx, VGA, FPGA

Connecting test pattern generator to VGA output on ZYBO
=======================================================

Introduction
------------

Test pattern generator can be directly connected to AXI4-Stream to Video Out component:

.. figure:: abstract-design/tpg-to-video-output-pipeline.svg

    Test pattern generator driving video outputs directly
    
To be precise:

    
.. figure:: high-level-design/tpg-to-video-output-pipeline.png

    High level block design for the abstract flowchart above
    
    
.. [#tpg] `Test Pattern Generator v6.0 <http://www.xilinx.com/support/documentation/ip_documentation/v_tpg/v6_0/pg103-v-tpg.pdf>`_
