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
		
		for (int i=0; i<10; i++) begin
			#10;

			$display("PC_FETCH: %d, instruction: %b", _cpu.PC_FETCH, _cpu.instruction_EX);

			// read register file
			for (int i=0; i<32; i++) begin
				$display("register %d: 0x%h", i, _cpu._regfile.mem[i]);
			end
		end

		// reading the io registers
		$display("io0: %d", _cpu.io0_in);
		$display("io1: %d", _cpu.io1_in);
		$display("io2: %d", _cpu.io2_out);
		$display("io3: %d", _cpu.io3_out);
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

