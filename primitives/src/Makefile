GHDL=ghdl
GHDLFLAGS=
MODULES=\
    mux.o \
    d_flipflop.o \
    d_latch.o \
    d_register.o \
    open_collector.o \
    sr_latch.o \
    tristate_buffer.o \
    d_testbench \
    open_collector_testbench \
    sr_latch_testbench \
    tristate_buffer_testbench \
    mux_testbench \
    gray_testbench

test: $(MODULES)
	./sr_latch_testbench --vcd=sr_latch_testbench.vcd
	./d_testbench --vcd=d_testbench.vcd
	./tristate_buffer_testbench --stop-time=1ms --vcd=tristate_buffer_testbench.vcd
	./open_collector_testbench --vcd=open_collector_testbench.vcd --stop-time=500ns
	./mux_testbench --vcd=mux_testbench.vcd --stop-time=700ns
	./gray_testbench --vcd=gray_testbench.vcd --stop-time=160ns

# Binary depends on the object file
%: %.o
	$(GHDL) -e $(GHDLFLAGS) $@

# Object file depends on source
%.o: %.vhd
	$(GHDL) -a $(GHDLFLAGS) $<

clean:
	echo "Cleaning up..."
	rm -f *.o *_testbench work*.cf e*.lst
