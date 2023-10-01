module instruction_decoder(
	input logic [31:0] instructon,

	// outputs
	
	output logic [2:0] inst_type,
	output logic [6:0] opcode,

	// R-type
	output logic [6:0] funct7,
	output logic [5:0] rs2,
	output logic [5:0] rs1,
	output logic [2:0] funct3,
	output logic [4:0] rd,

	// I-type
	output logic [11:0] imm_I,
	
	// U-type
	output logic [19:0] imm_U
);

	always_comb begin
		opcode <= instruction[6:0];
		funct7 <= instruction[31:25];
		rs2 <= instruction[24:20];
		rs1 <= instruction[19:15];
		funct3 <= instruction[14:12];
		rd <= instruction[11:7];
		imm_I <= instruction[31:20];
		imm_U <= instruction[31:12];

		// determining instruction type
		inst_type = 3'b000;
		case (opcode)
			6'b0110011: inst_type <= 3'b000;
			6'b1110011: inst_type <= 3'b000;
			6'b0010011: inst_type <= 3'b001;
			6'b0110111: inst_type <= 3'b010;
		endcase
	end

endmodule
