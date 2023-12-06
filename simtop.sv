/* Copyright 2020 Jason Bakos, Philip Conrad, Charles Daniels */

/* Top-level module for CSCE611 RISC-V CPU, for running under simulation.  In
 * this case, the I/Os and clock are driven by the simulator. */

module simtop;

	logic clk;
	logic [6:0] HEX0,HEX1,HEX2,HEX3,HEX4,HEX5,HEX6,HEX7;
	logic [3:0] KEY;
	logic [17:0] SW;

	top dut
	(
		//////////// CLOCK //////////
		.CLOCK_50(clk),
		.CLOCK2_50(),
	    	.CLOCK3_50(),

		//////////// LED //////////
		.LEDG(),
		.LEDR(),

		//////////// KEY //////////
		.KEY(KEY),

		//////////// SW //////////
		.SW(SW),

		//////////// SEG7 //////////
		.HEX0(HEX0),
		.HEX1(HEX1),
		.HEX2(HEX2),
		.HEX3(HEX3),
		.HEX4(HEX4),
		.HEX5(HEX5),
		.HEX6(HEX6),
		.HEX7(HEX7)
	);

	logic [31:0] io0_out;
	logic [31:0] io0_in;

	cpu _cpu(clk, KEY[0], io0_in, io0_out);

	// pulse reset (active low)
	initial begin
		KEY <= 4'he;
		#10;
		KEY <= 4'hf;

		// 10 ticks = 1 clock tick
		
		for (int i=0; i<15; i++) begin
			$display("clock cycle %0d", i);

			$display("\tPC_FETCH = %0d", _cpu.PC_FETCH);
			$display("\tPC_EX = %0d", _cpu.PC_EX);
			$display("\topcode = %b", _cpu.instruction_EX[6:0]);
			$display("\tregwrite = %0b", _cpu.regwrite_EX);
			$display("\tregsel = %0d", _cpu.regsel_EX);
			$display("\tgpio_we_WB = %0b", _cpu.GPIO_we_WB);
			$display("\twritedata = %0h", _cpu.writedata);
			$display("\tR_EX = %0d", _cpu.R_EX);

			// reading registeres
			$display("\tt0: %h", _cpu._regfile.mem[5]);
			$display("\tt1: %h", _cpu._regfile.mem[6]);
			$display("\tt2: %h", _cpu._regfile.mem[7]);
			$display("\ts0: %h", _cpu._regfile.mem[8]);

			// reading the io registers
			$display("\tio0: %h", _cpu.io0_in);
			$display("\tio1: %h", _cpu.io1_in);
			$display("\tio2: %h", _cpu.io2_out);
			$display("\tio3: %h", _cpu.io3_out);

			#10; // 1 clock step
		end
	end
	
	// drive clock
	always begin
		clk <= 1'b0; #5;
		clk <= 1'b1; #5;
	end

	// assign simulated switch values
	assign SW = 18'd2;
	assign io0_in = {14'b0, SW};

endmodule

