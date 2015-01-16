.. flags: hidden
.. published: 2014-12-01


Xilinx Video DMA pipeline example
=================================

Introduction
------------

Xilinx libraries contain Video Direct Memory Access (VDMA) IP-core which can be
used to transfer AXI4-Stream protocol based video stream to DDR memory and vice versa.
Corresponding sub-components are S2MM (Stream to memory-mapped) also known as write channel and
MM2S (Memory-mapped to stream) also known as read channel.

Usecases
--------

In the beginning it may be a bit overwhelming to understand what are the most suitable
usecases for Video DMA.

.. figure:: abstract-design/ov7670-axi-stream-capture-pipeline.svg

    Video processing pipeline employing two instances of VDMA with both write and read channels enabled.
    
In the example above VDMA controller maintains a ring buffer in the DDR memory
and transfer the frame data to these buffers as the frames are received by S2MM
portion of the VDMA controller.



AXI4-Stream interface distinguishes:
tdata bit vector which contains pixel data,
tuser flag used for frame synchronization and
tkeep, tlast, tready, tvalid flags for controlling the bus behaviour.
Note that tuser flag which is part of AXI4-Stream specification replaces
fsync signal that has been used in the past by legacy applications.




    
Xilinx libraries also contain Test Pattern Generator (TPG) IP-core which can be used to
generate various 2D patterns for testing components equipped with AXI4-Stream interface.

Minimal working example
-----------------------

In this example we connect test pattern generator [#tpg]_ to VDMA [#axi-vdma]_ and attempted to
transfer generated frames from FPGA portion of the device to DDR memory.

.. figure:: abstract-design/ov7670-axi-stream-capture-pipeline.svg

    Abstract flowchart

    
.. figure:: high-level-design/ov7670-axi-stream-capture-pipeline.png

    High level block design for complete hardware pipeline


Currently we are attempting to figure out how to 
control the VDMA controller from operating system.
As starting from scratch with kernel module is time-consuming which can 
end up in a kernel panic we luckily found code samples designed to be
used from an userspace application [#arbot]_.
The examples were however not immediately usable in for our usecase.
We managed to initiate the DMA transfer but the transfer never finished.
We need to investigate further what kind of synchronization mechanisms need to
be in place in order to have successful transfers.




.. figure:: img/axi-vdma-both-address-editor.png

    Address mapping with AXI Video Direct Memory Access
    
.. [#axi-vdma] `LogiCORE IP AXI Video Direct Memory Access v6.2 <http://www.xilinx.com/support/documentation/ip_documentation/axi_vdma/v6_2/pg020_axi_vdma.pdf>`_
    
Future
------

For next steps we need to understand how to use VDMA control registers.
Once we have successful transfer from TPG to DDR we can continue
working on adapter to convert OV7670 scanlines to AXI4-Stream compatible format
which can then be fed to VDMA controller.
Final step is to implement frame grabbing in the CNN-RTE code which should be
fairly easy as there is similar mechanism already there.


.. [#zoom-pipeline] http://www.xilinx.com/support/documentation/ip_documentation/axi_videoip/v1_0/ug934_axi_videoIP.pdf

.. [#arbot] http://arbot.cz/post/2013/03/20/VDMA-on-ZedBoard.aspx
