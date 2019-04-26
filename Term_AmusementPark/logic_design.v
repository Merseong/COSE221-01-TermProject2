module logic_design(SW, CLOCK_50, HEX0, HEX1, HEX3);
	input [4:0] SW; // 4: Reset, 3: -8(drive), 2: +12, 1: +8, 0: +4
	input CLOCK_50;
	output reg [0:6] HEX0, HEX1; // count of waiting people
	output reg [0:6] HEX3; // count of how many amuse can be driven
	
	wire [1:0] convIn;
	reg [2:0] cS; // current State
	wire [2:0] nS; // next State
	
	// constant values
	parameter Seg9 = 7'b000_1100; parameter Seg8 = 7'b000_0000; parameter Seg7 = 7'b000_1111; parameter Seg6 = 7'b010_0000; parameter Seg5 = 7'b010_0100;
	parameter Seg4 = 7'b100_1100; parameter Seg3 = 7'b000_0110; parameter Seg2 = 7'b001_0010; parameter Seg1 = 7'b100_1111; parameter Seg0 = 7'b000_0001;
	parameter SegErr = 7'b111_1111;
	
	convert4to2(SW[3:0], convIn[1:0]);
	
	//assign nextState[2];
	//assign nextState[1];
	//assign nextState[0];

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
	
	always@(posedge CLOCK_50)
	begin
		cS <= nS;
	end

endmodule

module pulGen(in, clk, rst, out);
	output reg out;
	input clk, in, rst;
	reg [1:0] currstate0;
	reg [1:0] nextstate0;
	integer cnt;
	integer ncnt;
	parameter out_S0 = 2'b00; parameter out_S1 = 2'b01; parameter out_S2 = 2'b10;

	always @(posedge clk)//State Change
	begin
	if(rst)
		begin
		currstate0<=out_S0;cnt<=0;
		end
	else
		begin
		currstate0 <= nextstate0; cnt <= ncnt; 
		end
	end
	
	always @(*)
	begin
	case(currstate0)
		out_S0 : begin
			if(in) begin nextstate0 = out_S1; ncnt = 0; end
			else   begin nextstate0 = out_S0; ncnt = 0; end
		end
		out_S1 : begin 
			if(in) begin
				nextstate0 = out_S1;
				ncnt = cnt + 1;
			end
			else begin
				nextstate0 = out_S0; 
				if(cnt >= 1000)
					nextstate0 = out_S2;
				end
			end
	out_S2 : begin nextstate0 = out_S0; ncnt = 0; end
		default : nextstate0 = out_S0;
	endcase
	end

	always @(*)
	begin
		if (currstate0 == out_S2) out = 1'b1;
		else                                 out = 1'b0;
	end
		
endmodule 

// convert 4 bit input to 2 bit
module convert4to2(in, out); 
	input [3:0] in;
	output reg [1:0] out;
	
	always@(*)
	begin
		casez(in)
			4'b1???: out = 2'b11;
			4'b01??: out = 2'b10;
			4'b001?: out = 2'b01;
			4'b0001: out = 2'b00;
			default: out = 2'bzz;
		endcase
	end
endmodule