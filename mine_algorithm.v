module mine_algorithm(
	input clk,
	input rst,
	
	input[15:0] random_number, //Output from LFSR
	input start,
	input[5:0] num_mines,
	
	input [7:0] safe_center_addr,
	
	output reg[5:0] mine_total, //Should output to 40 mines
	output reg alg_done,
	output reg [7:0] mine_alg_mem_addr,
	output reg mine_alg_mem_in,
	output reg mine_alg_mem_wren
	
	);      

	
	
	
	
	
	
	reg[1:0]S; 
	
	reg[1:0]NS;
	
	reg[5:0] mines_placed;
	wire[7:0] addr = random_number[7:0] ^ random_number[15:8];
	
	reg[255:0] used_map; //Not getting a guranteed 40 mines when generating the grid, so using this to prevent dupicates
	
	wire [3:0] ax = addr[3:0];   // candidate x
   wire [3:0] ay = addr[7:4];   // candidate y
	
	wire [3:0] sx = safe_center_addr[3:0];   // safe center x
   wire [3:0] sy = safe_center_addr[7:4];   // safe center y
	
	// signed deltas to check -1..+1
	wire signed [4:0] dx = $signed({1'b0, ax}) - $signed({1'b0, sx});
   wire signed [4:0] dy = $signed({1'b0, ay}) - $signed({1'b0, sy});
	
	// inside 3x3 region centered at (sx,sy)
    wire in_forbidden_3x3 = (dx >= -1 && dx <= 1) && (dy >= -1 && dy <= 1);
	
	parameter IDLE = 2'd0,
				 MINE_PLACE = 2'd1,
				 DONE = 2'd2,
				 ERROR = 2'd3;
				 
				 
	always @(posedge clk or negedge rst)
		if (rst == 1'b0)
			S <= IDLE;
		else
			S <= NS;
	
	//You know what we doing by now
	always @(*) begin
		NS = S;
		case(S)
		IDLE: if (start == 1'b1)
					NS = MINE_PLACE;
				else
					NS = IDLE;
		MINE_PLACE: if(mines_placed >= num_mines)
							NS = DONE;
						else
							NS = MINE_PLACE;
		DONE: NS = DONE;
		default: NS = ERROR;		
	   endcase
	end
always @(posedge clk or negedge rst) begin
		if (rst == 1'b0) begin
			mines_placed <= 6'd0;
			mine_total <= 6'd0;
			alg_done <= 1'b0;
			used_map <= 256'd0;
			mine_alg_mem_addr <= 8'd0;
			mine_alg_mem_wren <= 1'b0;
			mine_alg_mem_in <= 1'b0;
		end
		else begin
		mine_alg_mem_wren <= 1'b0;
		case(S)
			IDLE: begin
			alg_done <= 1'b0;
				if (start == 1'b1) begin
					mines_placed <= 6'd0;
					mine_total <= 6'd0;
					end
				end
			MINE_PLACE: begin 
				if (mines_placed < num_mines) 
						begin
						if(!used_map[addr] && !in_forbidden_3x3) begin
								mine_alg_mem_wren <= 1'b1;
								mine_alg_mem_addr <= addr; 
								mine_alg_mem_in <=1'b1;
								
								used_map[addr] <= 1'b1;
								mines_placed <= mines_placed + 1'b1;
								mine_total <= mines_placed + 1'b1;
							end
						end
					end
				
			DONE: alg_done <= 1'b1;
	endcase
	end
	end
endmodule
					
					
			