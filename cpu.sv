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

	// holding decoded instruction fields
	logic [11:0] imm_I;
	logic [11:0] imm_I_WB;
	logic [19:0] imm_U;
	logic [19:0] imm_U_WB;
	logic zero;

	// holding output of control unit
	logic alusrc_EX;
	logic regwrite_EX;
	logic [2:0] regsel_EX;
	logic [3:0] aluop_EX;
	logic GPIO_we;

	// glue registers for register file
	logic [31:0] readdata1;
	logic [31:0] readdata2;
	logic [1:0] regsel_WB;
	logic [4:0] regdest_WB;
	logic [31:0] readdata1_EX;

	// glue registers for control unit
	logic regwrite_WB;
	logic GPIO_we_WB;
	logic [31:0] GPIO_out_WB;

	// glue registers for regsel mux
	logic [31:0] GPIO_in_WB;
	logic [31:0] writedata;
	logic [31:0] R_WB;

	// glue registers for ALU
	logic [31:0] R_EX;
	logic [31:0] B_EX;

	// fetching logic
	logic [11:0] PC_FETCH;
	logic [11:0] PC_EX;
	logic [11:0] PC_NEXT;
	logic [11:0] PC1;
	logic [31:0] instruction_EX;
	logic [19:0] jal_offset_EX;
	logic [11:0] jal_addr_EX;
	logic [11:0] jalr_offset;
	logic [11:0] jalr_addr;
	logic [12:0] branch_offset;
	logic [11:0] branch_addr;
	logic stall_EX;
	logic [1:0] pcsrc_EX;

	// connecting the register file
	regfile _regfile (
		.clk(clk),
		.we(regwrite_WB),
		.readaddr1(instruction_EX[19:15]),
		.readaddr2(instruction_EX[24:20]),
		.writeaddr(regdest_WB),
		.writedata(writedata),
		.readdata1(readdata1),
		.readdata2(readdata2)
	);

	// connecting the control unit
	controlunit _controlunit (
		.opcode(instruction_EX[6:0]),
		.funct3(instruction_EX[14:12]),
		.funct7(instruction_EX[31:25]),
		.csr(instruction_EX[31:20]),
		.alusrc(alusrc_EX),
		.regwrite(regwrite_EX),
		.regsel(regsel_EX),
		.aluop(aluop_EX),
		.gpio_we(GPIO_we),
		.stall(stall_EX),
		.pcsrc(pcsrc_EX)
	);
 
	// connecting the ALU
	alu _alu (.A(readdata1), .B(B_EX), .R(R_EX), .op(aluop_EX), .zero(zero));

	// input mux
	assign B_EX = (alusrc_EX==1'b0) ? readdata2 : {{20{imm_I[11]}}, imm_I};
	always_comb begin
		case (regsel_WB)
			2'd0 : writedata = GPIO_in_WB;
			2'd1 : writedata = {imm_U_WB, 12'b0};
			2'd2 : writedata = R_WB;
			2'd3 : writedata = {18'd0, PC_EX, 2'd0}; // for jumps
		endcase
	end

	// jump logic
	assign jal_offset_EX = {instruction_EX[31], instruction_EX[19:12],
		instruction_EX[20], instruction_EX[30:21], 1'b0};
	assign jal_addr_EX = PC_EX + jal_offset_EX[13:2];
	assign jalr_offset = instruction_EX[31:20];
	assign jalr_addr = readdata1[13:2] + {{2{jalr_offset[11]}},jalr_offset[11:2]};
	assign branch_offset = {instruction_EX[31], instruction_EX[7],
		instruction_EX[30:25], instruction_EX[11:8], 1'b0};
	assign branch_addr = PC_EX + {branch_offset[12], branch_offset[12:2]};

	// fetching logic
	assign imm_I = instruction_EX[31:20];
	assign imm_U = instruction_EX[31:12];
	assign PC1 = PC_FETCH + 12'd1;
	assign PC_NEXT = (pcsrc_EX==2'd0) ? PC1
			: (pcsrc_EX==2'd1) ? jal_addr_EX
			: (pcsrc_EX==2'd2) ? jalr_addr
			: 12'd0;

	// clock cycle
	always_ff @(posedge clk) begin
		if (~rst_n) begin // starting at 0
			PC_FETCH <= 12'd0;
		end else begin
			// reading next instruction
			PC_FETCH <= PC_NEXT;
			PC_EX <= PC_FETCH;
			instruction_EX <= (stall_EX==1'b1) ? 32'd0 : inst_ram[PC_FETCH];

			// copying execute registers to writeback registers
			regdest_WB <= instruction_EX[11:7];
			readdata1_EX <= readdata1;
			regwrite_WB <= regwrite_EX;
			regsel_WB <= regsel_EX;
			GPIO_we_WB <= GPIO_we;
			GPIO_out_WB <= readdata1;
			R_WB <= R_EX;
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
