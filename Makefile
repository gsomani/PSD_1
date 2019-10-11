CC = ghdl
ARCHNAME = io_ctl
TBNAME = tb_io

WORKDIR = build

PKGSRC = src/array_memory.vhd src/array_memory-body.vhd
SRC+= src/reg_bank.vhd src/prog_counter.vhd src/alu.vhd src/data_bus.vhd src/decoder.vhd src/cpu.vhd src/controller.vhd src/io_ctl.vhd
SRC+= sim/tb_io.vhd

.PHONY: all
all: clean analyze elaborate
	@echo "completed"

.PHONY: analyze
analyze:
	@echo "analyzing designs"
	@mkdir $(WORKDIR)
	$(CC) -a --workdir=$(WORKDIR) $(PKGSRC)
	$(CC) -a --workdir=$(WORKDIR) $(SRC)
.PHONY: elaborate
elaborate:
	@echo "elaborating design"
	$(CC) --elab-run --workdir=$(WORKDIR) -o $(WORKDIR)/$(TBNAME).bin $(TBNAME) --vcd=tb_io.vcd --stop-time=10us

.PHONY: clean
clean:
	@echo "cleaning design"
	rm -rf $(WORKDIR)
