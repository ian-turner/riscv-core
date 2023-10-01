module controlunit(
	// inputs
	input logic [6:0] opcode,
	input logic [2:0] funct3,
	input logic [6:0] funct7,
	input logic [11:0] csr,

	// outputs
	output logic alusrc,
	output logic regwrite,
	output logic [2:0] regsel,
	output logic [4:0] aluop,
	output logic gpio_we
);

endmodule
