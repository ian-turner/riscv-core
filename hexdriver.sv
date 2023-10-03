// CSCE 611 Lab 1 written by Ian Turner

// mapper module takes a variable input val (4 bits)
// and constant activation array (16 bits)
// which shows when the output is supposed to be on
// and outputs either 1 or 0
module mapper (input [3:0] val, input [15:0] act, output logic out);
	always_comb begin out = ~act[val]; end
endmodule
// hexdriver module converts 4 bit binary number to
// hexadecimal 7-seg display code
module hexdriver (input [3:0] val, output logic [6:0] HEX);
	// mapping input bits to desired activations
	mapper map0 (.val(val), .act(16'd55277), .out(HEX[0])); // top
	mapper map1 (.val(val), .act(16'd10143), .out(HEX[1])); // upper right side
	mapper map2 (.val(val), .act(16'd12283), .out(HEX[2])); // lower right side
	mapper map3 (.val(val), .act(16'd31085), .out(HEX[3])); // bottom
	mapper map4 (.val(val), .act(16'd64837), .out(HEX[4])); // lower left side
	mapper map5 (.val(val), .act(16'd57201), .out(HEX[5])); // upper left side
	mapper map6 (.val(val), .act(16'd61308), .out(HEX[6])); // bridge
endmodule
