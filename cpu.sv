module cpu(
	input logic clk, // clock
	input logic rst_n, // reset signal
	input logic [31:0] io0_in, // input signal
	output logic [31:0] io0_out // output signal
);

	logic [31:0] inst_ram [4095:0]; // declaring ram
	initial $readmemh("program.rom", inst_ram); // reading program into memory

	logic [11:0] PC_FETCH = 12'd0;
	logic [31:0] instruction_EX;

	// values to hold instruction fields
	logic [2:0] instruction_type;
	logic [6:0] opcode;
	// R-type
	logic [6:0] funct7;
	logic [5:0] rs2;
	logic [5:0] rs1;
	logic [2:0] funct3;
	logic [4:0] rd;
	// I-type
	logic [11:0] imm_I;
	// U-type
	logic [19:0] imm_U;
	
	// holding output of control unit
	logic alusrc;
	logic regwrite;
	logic [2:0] regsel;
	logic [4:0] aluop;
	logic gpio_we;

	// connecting the decoder
	decoder _decoder (
		.instruction(instruction_EX),
		.instruction_type(instruction_type),
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
		.we(regwrite),
		.readaddr1(rs1),
		.readaddr2(rs2),
		.writeaddr(rd),
//		.writedata() // comes from regsel MUX
	);

	// connecting the control unit
	controlunit _controlunit (
		.alusrc(alusrc),
		.regwrite(regwrite),
		.regsel(regsel),
		.aluop(aluop),
		.gpio_we(gpio_we)
	);

	always_ff @(posedge clk) begin
		if (~rst_n) begin // starting at 0
			PC_FETCH <= 12'd0;
			instruction_EX <= 32'd0;
		end else begin
			// fetching the next instruction
			PC_FETCH <= PC_FETCH + 1'b1;
			instruction_EX <= inst_ram[PC_FETCH];
		end
	end

endmodule
