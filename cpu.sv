module cpu(input logic clk /* clock */, input logic rst_n /* reset signal */);

	logic [31:0] inst_ram [4095:0]; // declaring ram
	initial $readmemh("program.rom", inst_ram); // reading program into memory

	logic [11:0] PC_FETCH = 12'd0;
	logic [31:0] instruction_EX;

	always_ff @(posedge clk) begin
		if (~rst_n) begin // starting at 0
			PC_FETCH <= 12'd0;
			instruction_EX <= 32'd0;
		end else begin // fetching the next instruction
			PC_FETCH <= PC_FETCH + 1'b1;
			instruction_EX <= inst_ram[PC_FETCH];
		end
	end
endmodule
