module mine_algorithm(
	input clk,
	input rst,
	
	input[15:0] random_number, //Output from LFSR
	input start,
	input[5:0] num_mines,
	
	
	output reg[5:0] mine_total, //Should output to 40 mines
	output reg done,
	output reg [7:0] mine_alg_mem_addr,
	output reg       mine_alg_mem_in,
	output reg       mine_alg_mem_wren
	);
	
	
	
	
	reg[2:0]S;
	reg[2:0]NS;
	
	parameter IDLE = 3'd0,
				 MINE_PLACE = 3'd1,
				 DONE = 3'd2,
				 ERROR = 3'd2;
				 
				 
	always @(posedge clk or negedge rst)
		if (rst == 1'b0)
			NS <= IDLE;
		else
			NS <= S;
	
	//You know what we doing by now
	always