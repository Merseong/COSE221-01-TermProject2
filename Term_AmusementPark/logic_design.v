module logic_design(SW, CLOCK_50, HEX0, HEX1, HEX3);
	input [4:0] SW; // 4: Reset, 3: -8(drive), 2: +12, 1: +8, 0: +4
	input CLOCK_50;
	output reg [0:6] HEX0, HEX1; // count of waiting people
	output reg [0:6] HEX3; // count of how many amuse can be driven
	
	wire newclock; // slowed clock
	wire noInput; // if there are no input, this is 1
	reg stayIn; // check if there have same input with before
	wire [1:0] in; // converted Input
	reg [2:0] cS; // current State
	reg [2:0] nextState; // next State
	
	// constant values
	parameter Seg9 = 7'b000_1100; parameter Seg8 = 7'b000_0000; parameter Seg7 = 7'b000_1111; parameter Seg6 = 7'b010_0000; parameter Seg5 = 7'b010_0100;
	parameter Seg4 = 7'b100_1100; parameter Seg3 = 7'b000_0110; parameter Seg2 = 7'b001_0010; parameter Seg1 = 7'b100_1111; parameter Seg0 = 7'b000_0001;
	parameter SegErr = 7'b111_1111;
	
	convert4to2(SW[3:0], in[1:0], noInput);
	newClk(CLOCK_50, newclock);
	
	initial 
	begin
		cS = 3'b000; // inital state
		stayIn = 1'b0;
	end
	
	always@(*)
	begin // nextState made with current State and input
		nextState[2] <= cS[2]&~in[1] | cS[2]&~in[0] | cS[1]&~in[1]&in[0] | cS[1]&cS[0]&~in[1] | ~cS[1]&cS[0]&in[1]&~in[0] | cS[1]&~cS[0]&in[1]&~in[0];
		nextState[1] <= cS[2]&in[1]&in[0] | ~cS[2]&~cS[1]&~in[1]&in[0] | ~cS[2]&~cS[1]&cS[0]&~in[1] | cS[1]&~cS[0]&~in[1]&~in[0] | cS[1]&cS[0]&in[1]&~in[0] | ~cS[2]&~cS[1]&~cS[0]&in[1]&~in[0];
		nextState[0] <= cS[0]&in[0] | cS[2]&cS[0] | ~cS[2]&~cS[0]&~in[0] | ~cS[0]&~in[1]&~in[0] | cS[1]&in[1]&~in[0];
	end

	always@(*)
	begin
		case(cS) // make output(HEX3) to be decided by currentState.
			0: begin HEX0 = Seg0; HEX1 = SegErr; HEX3 = Seg0; end // 0
			1: begin HEX0 = Seg4; HEX1 = SegErr; HEX3 = Seg0; end // 4
			2: begin HEX0 = Seg8; HEX1 = SegErr; HEX3 = Seg1; end // 8
			3: begin HEX0 = Seg2; HEX1 = Seg1; HEX3 = Seg1; end   // 12
			4: begin HEX0 = Seg6; HEX1 = Seg1; HEX3 = Seg2; end   // 16
			5: begin HEX0 = Seg0; HEX1 = Seg2; HEX3 = Seg2; end   // 20
			default: begin HEX0 = SegErr; HEX1 = SegErr; HEX3 = SegErr; end // error
		endcase;
	end
	
	always@(posedge newclock)
	begin
		if (SW[4]) begin // reset
			cS <= 3'b000;
		end
		else if (!noInput & !stayIn) begin
			cS <= nextState;
			stayIn <= 1'b1;
		end
		else if (stayIn & noInput) stayIn <= 1'b0; // switch downed
	end

endmodule

// slow clock
module newClk(in, out);
	input in;
	output reg out;
	reg [23:0] nclk;
	
	always@(posedge in)
	begin
		nclk <= nclk + 1;
		out <= nclk[23];
	end
	
endmodule

// convert 4 bit input to 2 bit
module convert4to2(in, out, err); 
	input [3:0] in;
	output reg [1:0] out;
	output reg err;
	
	always@(*)
	begin
		case(in)
			4'b1000: begin err = 1'b0; out = 2'b11; end
			4'b0100: begin err = 1'b0; out = 2'b10; end
			4'b0010: begin err = 1'b0; out = 2'b01; end
			4'b0001: begin err = 1'b0; out = 2'b00; end
			default: begin err = 1'b1; out = 2'b00; end // input was 0000 or other
		endcase
	end
endmodule