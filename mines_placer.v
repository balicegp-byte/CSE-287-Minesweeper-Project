module mines_placer(
	input clk,
	input rst,
	input[5:0] num_mines, //Number of mines 40
	input start, //Driven from game_state.v to begin the mine placing process
	
	input [7:0] safe_center_addr, // {start_y[3:0], start_x[3:0]}
	
	output reg done,
	
	output reg[7:0] mine_mem_addr,
	output reg mine_mem_in,
	output reg mine_mem_wren
	
	);
	//simple 3 state FSM to place mines. Start will instantiated through the game_state module
	reg[1:0]S;
	reg[1:0]NS;
	
	//Memory Signals
	wire mine_mem_out;
	
	
	//Other variables
	reg[5:0] mines_placed;
	wire[15:0] rand_num;
	reg begin_place;
	
	//stuff for mine_alg
	wire[5:0] mine_total;
	wire alg_done;
	wire [7:0] mine_alg_mem_addr;
	wire mine_alg_mem_in;
	wire mine_alg_mem_wren;
	
	//Rng for mines
	mine_lfsr rng( .clk(clk),
						.rst(rst),
						.random_seed(16'h1A2B),
						.new_random_seed(1'b0),
						.random_number_output(1'b1),
						.random_number(rand_num)
						);
	//Mine placing algorithm					
	mine_algorithm alg( .clk(clk),
						     .rst(rst),
							  
							  .random_number(rand_num),
						     .start(begin_place),
							  .num_mines(num_mines),
							  
							  .safe_center_addr(safe_center_addr),
							  
							  .mine_total(mine_total),
							  .alg_done(alg_done),
							       
						     .mine_alg_mem_addr(mine_alg_mem_addr),
						     .mine_alg_mem_in(mine_alg_mem_in),
						     .mine_alg_mem_wren(mine_alg_mem_wren)
						   );
	//FSM States
	parameter IDLE = 2'd0,
				 PLACE = 2'd1,
				 DONES = 2'd2,
				 ERROR = 2'd3;
				 
	always @(posedge clk or negedge rst) begin
        if (rst == 1'b0) begin
            S <= IDLE;
        end else begin
            S <= NS;
        end
    end
	 
	 always @(*) begin
	 NS = S;
		case(S)
			IDLE: if(start == 1'b0)
						NS = IDLE;
					else
						NS = PLACE;
			PLACE: if (alg_done == 1'b1)
							NS = DONES;
					 else
							NS = PLACE;
			DONES: NS = DONES;
			default: NS = ERROR;
		endcase
	end	
	//Place mines
	always @(posedge clk or negedge rst) begin
		if (rst == 1'b0) begin
			mines_placed <= 6'd0;
			mine_mem_addr <= 8'd0;
			mine_mem_in <= 1'b0;
			mine_mem_wren <= 1'b0;
			begin_place <= 1'b0;
			done <= 1'b0;
			end
		else begin
			begin_place <= 1'b0;
			mine_mem_wren <= 1'b0;
			done <= 1'b0;    
			case (S)
				PLACE: begin
					begin_place <= 1'b1;// starts the mine_algorithm module		
					mine_mem_addr <= mine_alg_mem_addr;
					mine_mem_in <= mine_alg_mem_in;
					mine_mem_wren <= mine_alg_mem_wren;
					mines_placed <= mine_total;
					end
				DONES: done <= 1'b1;
				default: done <= 1'b0;
		endcase
	end
end
endmodule	