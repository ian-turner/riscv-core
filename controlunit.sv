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
	output logic [3:0] aluop,	
	output logic [1:0] pcsrc_EX,
	input logic stall_EX,
	output logic stall_FETCH,
	output logic gpio_we		// enables writing to the output register
);

	// combinational logic block
	always_comb begin
		// default values
		alusrc=1'd0;
		regwrite=1'd0;
		regsel=2'd0;
		aluop=4'd0;
		gpio_we=1'd0;
		pcsrc_EX=2'd0;
		stall_FETCH=1'd0;

		if (~stall_EX) begin

			// csrrw instruction
			if (opcode==7'b1110011 && funct3==3'b001) begin
				gpio_we=1'd1; // enable io output
				regwrite = 1'd1; // enable writeback
			end

			// R-type instructions
			if (opcode==7'b0110011) begin
				regwrite = 1'd1;
				regsel=2'd2;
				if (funct7==7'b0000000) begin
					if (funct3==3'b000) aluop=4'b0011; // add
					if (funct3==3'b111) aluop=4'b0000; // and
					if (funct3==3'b110) aluop=4'b0001; // or
					if (funct3==3'b100) aluop=4'b0010; // xor
					if (funct3==3'b001) aluop=4'b1000; // sll
					if (funct3==3'b101) aluop=4'b1001; // srl
					if (funct3==3'b010) aluop=4'b1100; // slt
					if (funct3==3'b011) aluop=4'b1101; // sltu
				end else if (funct7==7'b0100000) begin
					if (funct3==3'b000) aluop=4'b0100; // sub
					if (funct3==3'b101) aluop=4'b1010; // sra
				end else if (funct7==7'b0000001) begin
					if (funct3==3'b000) aluop=4'b0101; // mul
					if (funct3==3'b001) aluop=4'b0110; // mulh
					if (funct3==3'b011) aluop=4'b0111; // mulhu
				end
			end

			// I-type instructions
			else if (opcode==7'b0010011) begin
				regwrite = 1'd1;
				alusrc=1'd1;
				regsel=2'd2;
				if (funct3==3'b000) aluop=4'b0011; // addi
				if (funct3==3'b111) aluop=4'b0000; // andi
				if (funct3==3'b110) aluop=4'b0001; // ori
				if (funct3==3'b100) aluop=4'b0010; // xori
				if (funct3==3'b001) aluop=4'b1000; // slli
				if (funct3==3'b101) aluop=4'b1010; // srai
				if (funct3==3'b101) aluop=4'b1001; // srli
			end

			// U-type instructions
			else if (opcode==7'b0110111) begin
				regwrite=1'd1;
				regsel=2'd1;
			end

			// jal
			else if (opcode==7'b1101111) begin
				regwrite=1'd1;
				regsel=2'd3;
				pcsrc_EX=2'd1;
				stall_FETCH=1'd1;
			end
		end
	end

endmodule
