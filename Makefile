#TOOL INPUT
SRC = hdl/Router/*.v hdl/router.v
TESTBENCH = test/router_tb.v
TBOUTPUT = router_tb.vcd


#TOOLS

COMPILER = iverilog
SIMULATOR = vvp
VIEWER = Scansion

#TOOL OPTIONS
COFLAGS = -v -o
SFLAGS = -v

#TOOL OUTPUT
COUTPUT = router.out         

###############################################################################


	
simulate: $(COUTPUT)

	$(SIMULATOR) $(SFLAGS) $(COUTPUT) 

display: 
	open -a $(VIEWER) $(TBOUTPUT) 

$(COUTPUT): $(TESTBENCH) $(SRC)
	$(COMPILER) $(COFLAGS) $(COUTPUT) $(TESTBENCH) $(SRC) 

clean:
	rm *.vcd
	rm *.out