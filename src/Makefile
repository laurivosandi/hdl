GHDL=ghdl
GHDLFLAGS=
MODULES=\
    carry_ripple_adder.o \
    alu.o \
    full_adder.o \
    alu_testbench \
    carry_ripple_adder_testbench \
    full_adder_testbench


test: $(MODULES)
	./full_adder_testbench --vcd=full_adder_testbench.vcd
	./carry_ripple_adder_testbench --vcd=carry_ripple_adder_testbench.vcd
	./alu_testbench --vcd=alu_testbench.vcd

# Binary depends on the object file
%: %.o
	$(GHDL) -e $(GHDLFLAGS) $@

# Object file depends on source
%.o: %.vhd
	$(GHDL) -a $(GHDLFLAGS) $<

clean:
	echo "Cleaning up..."
	rm -f *.o *_testbench full_adder carry_ripple_adder work*.cf e*.lst
