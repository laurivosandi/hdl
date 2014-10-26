GHDL=ghdl
GHDLFLAGS=
MODULES=\
    alu.o \
    carry_ripple_adder.o \
    d_flipflop.o \
    d_latch.o \
    d_register.o \
    full_adder.o \
    open_collector.o \
    sr_latch.o \
    tristate_buffer.o \
    \
    alu_testbench \
    carry_ripple_adder_testbench \
    d_testbench \
    full_adder_testbench \
    open_collector_testbench \
    sr_latch_testbench \
    tristate_buffer_testbench

test: $(MODULES)
	./full_adder_testbench --vcd=full_adder_testbench.vcd
	./carry_ripple_adder_testbench --vcd=carry_ripple_adder_testbench.vcd
	./alu_testbench --vcd=alu_testbench.vcd
	./sr_latch_testbench --vcd=sr_latch_testbench.vcd
	./d_testbench --vcd=d_testbench.vcd
	./tristate_buffer_testbench --stop-time=1ms --vcd=tristate_buffer_testbench.vcd
	./open_collector_testbench --vcd=open_collector_testbench.vcd --stop-time=500ns

# Binary depends on the object file
%: %.o
	$(GHDL) -e $(GHDLFLAGS) $@

# Object file depends on source
%.o: %.vhd
	$(GHDL) -a $(GHDLFLAGS) $<

clean:
	echo "Cleaning up..."
	rm -f *.o *_testbench full_adder carry_ripple_adder
