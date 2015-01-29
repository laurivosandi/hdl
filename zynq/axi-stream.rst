.. flags: hidden

Arbitrary data streams
======================

Introduction
------------

AMBA interface specification is published by ARM Ltd [#amba-specifications]_.
AXI4-Stream one of many AMBA protocols designed to transport data streams
of arbitrary width in hardware.
Most usually 32-bit bus width is used, which means that
4 bytes get transferred during one cycle.
At 100MHz of programmable logic frequency on FPGA-s this yields throughput of
magnitude of hundreds of megabytes per second
depending on memory management unit capabilities and configuration.

.. [#amba-specifications] http://www.arm.com/products/system-ip/amba-specifications.php


AXI4-Stream
-----------

AXI4-Stream is a protocol designed to transport arbitrary unidirectional data streams.

.. figure:: dia/axi-stream.svg

    AXI4-Stream handshake
    
In AXI4-Stream TDATA width of bits is transferred per clock cycle.
The transfer is started once sender signals TVALID and received responds with TREADY.
TLAST signals the last byte of the stream.

.. figure:: img/axi-stream-valid-handshake.png

    Example of READY/VALID Handshake, Start of a New Frame

AXI4-Stream has additional optional features: sending positional
data with TKEEP and TSTRB ports which make it possible to multiplex 
both data position and data itself on TDATA lines;
routing streams by TID and TDIST which roughly corresponds to stream identifier
and stream destination identifier [#fpganotes]_

.. [#fpganotes] http://wiki.fpganotes.com/doku.php/ip:bus:axi4_stream


AXI4-Stream Video
-----------------

AXI4-Stream Video is a subset of AXI4-Stream designed for transporting
video frames.
AXI4-Stream Video is compatible with AXI4-Stream components, it simply
has conventions for the use of ports already defined by AXI4-Stream:

* The TLAST signal designates the last pixel of each line, and is also known as
  end of line (EOL).
* The TUSER signal designates the first pixel of a frame and is known as
  start of frame (SOF).

These two flags are necessary to identify pixel locations on the AXI4
stream interface because there are no sync or blank signals. [#axi-stream-to-video-out]_.
Video DMA component makes use of the TUSER signal to synchronize frame buffering.
Note that TUSER flag which is part of AXI4-Stream specification replaces
FSYNC signal that has been used in the past by legacy applications.


.. [#axi-stream-to-video-out] http://www.xilinx.com/support/documentation/ip_documentation/v_axi4s_vid_out/v1_0/pg044_v_axis_vid_out.pdf
