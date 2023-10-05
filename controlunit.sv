module controlunit(
	// inputs
	input logic [6:0] opcode,
	input logic [2:0] funct3,
	input logic [6:0] funct7,
	input logic [11:0] csr,

	// outputs
	output logic alusrc,		// chooses between readdata2 and imm for
					// ALU input
	output logic regwrite,
	output logic [2:0] regsel, 	// selects between GPIO_in / imm_I/U or ALU 
				   	// output as input for write data in regfile
	output logic [4:0] aluop,	
	output logic gpio_we		// enables writing to the output register
);

	// combinational logic block
	always_comb begin
		// default values
		alusrc=1'd0;
		regwrite=1'd0;
		regsel=3'd0;
		aluop=5'd0;
		gpio_we=1'd0;

		// csrrw instruction
		if (opcode==7'b1110011 && funct3==3'b001) begin
			gpio_we=1'd1; // enable io output
			regwrite=1'd1; // enable writeback
		end

		// I-type instructions
		if (opcode==7'b0010011) begin
			regwrite=1'd1;
			// addi
			if (funct3==3'b000) begin
				aluop=4'b0011;
				alusrc=1'd1;
				regsel=2'd2;
			end
		end
	end

endmodule
