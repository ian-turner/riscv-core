module cpu(
	input logic clk, // clock
	input logic rst_n, // reset signal
	input logic [31:0] io0_in, // input signal
	input logic [31:0] io1_in, // input signal
	output logic [31:0] io2_out, // output signal
	output logic [31:0] io3_out // output signal
);

	logic [31:0] inst_ram [4095:0]; // declaring ram
	initial $readmemh("instmem.dat", inst_ram); // reading program into memory

	logic [11:0] PC_FETCH;
	logic [11:0] PC_EX;
	logic [31:0] instruction_EX;

	// holding decoded instruction fields
	logic [6:0] opcode;
	logic [6:0] funct7;
	logic [4:0] rs2;
	logic [4:0] rs1;
	logic [2:0] funct3;
	logic [4:0] rd;
	logic [11:0] imm_I;
	logic [11:0] imm_I_WB;
	logic [19:0] imm_U;

	// holding output of control unit
	logic alusrc_EX;
	logic regwrite_EX;
	logic [2:0] regsel_EX;
	logic [3:0] aluop_EX;
	logic GPIO_we;

	// glue registers for register file
	logic [31:0] readdata1;
	logic [31:0] readdata2;
	logic [2:0] regsel_WB;
	logic [4:0] regdest_WB;

	// glue registers for control unit
	logic regwrite_WB;
	logic GPIO_we_WB;
	logic [31:0] GPIO_out_WB;

	// glue registers for regsel mux
	logic [31:0] GPIO_in_WB;
	logic [19:0] imm_U_WB;
	logic [31:0] writedata;
	logic [31:0] R_WB;

	// glue registers for ALU
	logic [31:0] R_EX;
	logic [31:0] ALU_INP_B;

	// glue logic for jumps
	logic [31:0] jal_addr_EX;
	logic [31:0] jalr_addr_EX;
	logic [20:0] jal_offset_EX;
	logic [31:0] branch_addr_EX;
	logic [1:0] pcsrc_EX;
	logic stall_EX;
	logic stall_FETCH;

	// connecting the decoder
	decoder _decoder (
		.instruction(instruction_EX),
		.funct3(funct3),
		.funct7(funct7),
		.rs1(rs1),
		.rs2(rs2),
		.rd(rd),
		.imm_I(imm_I),
		.imm_U(imm_U),
		.opcode(opcode)
	);

	// connecting the register file
	regfile _regfile (
		.clk(clk),
		.we(regwrite_WB),
		.readaddr1(rs1),
		.readaddr2(rs2),
		.writeaddr(regdest_WB),
		.writedata(writedata),
		.readdata1(readdata1),
		.readdata2(readdata2)
	);

	// connecting the control unit
	controlunit _controlunit (
		.opcode(opcode),
		.funct3(funct3),
		.funct7(funct7),
		.csr(imm_I),
		.alusrc(alusrc_EX),
		.regwrite(regwrite_EX),
		.regsel(regsel_EX),
		.aluop(aluop_EX),
		.gpio_we(GPIO_we),
		.pcsrc(pcsrc_EX),
		.stall_EX(stall_EX),
		.stall_FETCH(stall_FETCH)
	);
 
	// connecting the ALU
	alu _alu (
		.A(readdata1),
		.B(ALU_INP_B),
		.R(R_EX),
		.op(aluop_EX)
	);

	// jump logic
	assign jal_offset_EX = {
		instruction_EX[31],
		instruction_EX[19:12],
		instruction_EX[20],
		instruction_EX[30:21],
		1'b0
	};

	assign jal_addr_EX = PC_EX + jal_offset_EX[13:2];

	always_comb begin
		case (regsel_WB)
			2'd0 : writedata = GPIO_in_WB;
			2'd1 : writedata = {imm_U_WB, 12'b0};
			2'd2 : writedata = R_WB;
			2'd3 : writedata = {20'b0, PC_EX};
			default: writedata = 32'b0;
		endcase

		case (alusrc_EX)
			1'b1 : ALU_INP_B = {{20{imm_I[11]}}, imm_I};
			1'b0 : ALU_INP_B = readdata2;
		endcase
	end

	always_ff @(posedge clk) begin
		if (~rst_n) begin // starting at 0
			PC_FETCH <= 12'd0;
			instruction_EX <= 32'd0;
		end else begin
			// fetching the next instruction
			instruction_EX <= inst_ram[PC_FETCH];
			PC_EX <= PC_FETCH;
			case (pcsrc_EX)
				2'd0 : PC_FETCH <= PC_FETCH + 1;
				2'd1 : PC_FETCH <= jal_addr_EX;
				2'd2 : PC_FETCH <= jalr_addr_EX;
				2'd3 : PC_FETCH <= branch_addr_EX;
			endcase

			// copying execute registers to writeback registers
			regdest_WB <= rd;
			regwrite_WB <= regwrite_EX;
			regsel_WB <= regsel_EX;
			
			GPIO_we_WB <= GPIO_we;
			GPIO_out_WB <= readdata1;
			R_WB <= R_EX;

			stall_EX <= stall_FETCH;
			imm_U_WB <= imm_U;
			imm_I_WB <= imm_I;

			// reading from io
			case (imm_I) 
				12'hf00 : GPIO_in_WB <= io0_in;
				12'hf01 : GPIO_in_WB <= io1_in;
			endcase

			// writing to io
			if (GPIO_we_WB) begin
				case (imm_I_WB)
					12'hf02 : io2_out <= GPIO_out_WB;
					12'hf03 : io3_out <= GPIO_out_WB;
				endcase
			end
		end
	end

endmodule
