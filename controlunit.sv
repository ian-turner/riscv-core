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

endmodule
