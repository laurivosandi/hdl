.. tags: VHDL, KTH, Gray, Stibitz, mux

Gray code
=========

Truth table for 3-bit Gray encoder.

+--------+--------+--------+--------+--------+--------+--------+--------+
| in     | in(2)  | in(1)  | in(0)  | out    | out(2) | out(1) | out(0) |
+--------+--------+--------+--------+--------+--------+--------+--------+
| **0**  | 0      | 0      | 0      | **0**  | 0      | 0      | 0      |
+--------+--------+--------+--------+--------+--------+--------+--------+
| **1**  | 0      | 0      | 1      | **1**  | 0      | 0      | 1      |
+--------+--------+--------+--------+--------+--------+--------+--------+
| **2**  | 0      | 1      | 0      | **3**  | 0      | 1      | 1      |
+--------+--------+--------+--------+--------+--------+--------+--------+
| **3**  | 0      | 1      | 1      | **2**  | 0      | 1      | 0      |
+--------+--------+--------+--------+--------+--------+--------+--------+
| **4**  | 1      | 0      | 0      | **6**  | 1      | 1      | 0      |
+--------+--------+--------+--------+--------+--------+--------+--------+
| **5**  | 1      | 0      | 1      | **7**  | 1      | 1      | 1      |
+--------+--------+--------+--------+--------+--------+--------+--------+
| **6**  | 1      | 1      | 0      | **5**  | 1      | 0      | 1      |
+--------+--------+--------+--------+--------+--------+--------+--------+
| **7**  | 1      | 1      | 1      | **4**  | 1      | 0      | 0      |
+--------+--------+--------+--------+--------+--------+--------+--------+

.. figure:: dia/gray-triplet-decoder-mux.svg

    3-bit gray encoder implemented with two 4:1 muxes
    
    
Truth table for 4-bit Gray encoder

+--------+--------+--------+--------+--------+--------+--------+--------+--------+--------+
| in     | in(3)  | in(2)  | in(1)  | in(0)  | out    | out(3) | out(2) | out(1) |out(0)  |
+--------+--------+--------+--------+--------+--------+--------+--------+--------+--------+
| **0**  | 0      | 0      | 0      | 0      | **0**  | 0      | 0      | 0      | 0      |
+--------+--------+--------+--------+--------+--------+--------+--------+--------+--------+
| **1**  | 0      | 0      | 0      | 1      | **1**  | 0      | 0      | 0      | 1      |
+--------+--------+--------+--------+--------+--------+--------+--------+--------+--------+
| **2**  | 0      | 0      | 1      | 0      | **3**  | 0      | 0      | 1      | 1      |
+--------+--------+--------+--------+--------+--------+--------+--------+--------+--------+
| **3**  | 0      | 0      | 1      | 1      | **2**  | 0      | 0      | 1      | 0      |
+--------+--------+--------+--------+--------+--------+--------+--------+--------+--------+
| **4**  | 0      | 1      | 0      | 0      | **6**  | 0      | 1      | 1      | 0      |
+--------+--------+--------+--------+--------+--------+--------+--------+--------+--------+
| **5**  | 0      | 1      | 0      | 1      | **7**  | 0      | 1      | 1      | 1      |
+--------+--------+--------+--------+--------+--------+--------+--------+--------+--------+
| **6**  | 0      | 1      | 1      | 0      | **5**  | 0      | 1      | 0      | 1      |
+--------+--------+--------+--------+--------+--------+--------+--------+--------+--------+
| **7**  | 0      | 1      | 1      | 1      | **4**  | 0      | 1      | 0      | 0      |
+--------+--------+--------+--------+--------+--------+--------+--------+--------+--------+
| **8**  | 1      | 0      | 0      | 0      | **c**  | 1      | 1      | 0      | 0      |
+--------+--------+--------+--------+--------+--------+--------+--------+--------+--------+
| **9**  | 1      | 0      | 0      | 1      | **d**  | 1      | 1      | 0      | 1      |
+--------+--------+--------+--------+--------+--------+--------+--------+--------+--------+
| **a**  | 1      | 0      | 1      | 0      | **f**  | 1      | 1      | 1      | 1      |
+--------+--------+--------+--------+--------+--------+--------+--------+--------+--------+
| **b**  | 1      | 0      | 1      | 1      | **e**  | 1      | 1      | 1      | 0      |
+--------+--------+--------+--------+--------+--------+--------+--------+--------+--------+
| **c**  | 1      | 1      | 0      | 0      | **a**  | 1      | 0      | 1      | 0      |
+--------+--------+--------+--------+--------+--------+--------+--------+--------+--------+
| **d**  | 1      | 1      | 0      | 1      | **b**  | 1      | 0      | 1      | 1      |
+--------+--------+--------+--------+--------+--------+--------+--------+--------+--------+
| **e**  | 1      | 1      | 1      | 0      | **9**  | 1      | 0      | 0      | 1      |
+--------+--------+--------+--------+--------+--------+--------+--------+--------+--------+
| **f**  | 1      | 1      | 1      | 1      | **8**  | 1      | 0      | 0      | 0      |
+--------+--------+--------+--------+--------+--------+--------+--------+--------+--------+

.. figure:: dia/gray-nibble-decoder-mux.svg

    4-bit gray encoder implemented with three 4:1 muxes

