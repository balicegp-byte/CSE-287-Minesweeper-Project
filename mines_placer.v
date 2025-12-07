module mines_placer(
	input clk,
	input rst,
	input[5:0] num_mines, //Number of mines 40
	input start, //Driven from game_state.v to begin the mine placing process
	
	
	output reg done
	);
	//simple 3 state FSM to place mines. Start will instantiated through the game_state module
	reg[1:0]S;
	reg[1:0]NS;
	
	//Memory Signals
	reg[7:0] mine_mem_addr;
	wire mine_mem_out;
	reg mine_mem_in;
	reg mine_mem_wren;
	
	//Other variables
	reg[5:0] mines_placed;
	wire[15:0] rand_num;
	reg begin_place;
	
	
	
	//Rng for mines
	mine_lfst rng( .clk(clk),
						.rst(rst),
						.random_number(rand_num));
	//Mine placing algorithm					
	mine_algorithm alg( .clk(clk),
						     .rst(rst),
							  
						     .start(begin_place),
							  .num_mines(num_mines),
							       
						     .mine_mem_out(mine_alg_mem_out),
						     .mine_mem_in(mine_alg_mem_in),
						     .mine_mem_wren(mine_alg_mem_wren),
						   );
	//FSM States
	parameter IDLE = 2'd0,
				 PLACE = 2'd1,
				 DONE = 2'd2,
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
			PLACE: NS = DONE;
			DONE: NS = DONE;
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
			done <= 1'b0;
			end
		else begin
			case (S)
				PLACE: begin_place <= 1'b1;// starts the mine_algorithm module		
				DONE: done <= 1'b1;
				default: done <= 1'b0;
		endcase
	end
end
endmodule	