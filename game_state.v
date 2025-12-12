module game_state(
    input        clk,
    input        rst,
    input        go,
	 
	 input [1:0] cond,
    input play_again,
	 input sel,
	 input mine_done,
	 
	 input start_done,
	 input [7:0] cursor_addr,
	 
	 output reg mine_start,
	 
    output reg done,
	 output reg [1:0] result, //this goes to win/lose module to flash green or red depending on if player loses or not
	 output reg play_en,
	 output reg start_en,
	 output reg [7:0] start_cell_addr
);
	 
	 //Tis big because I may need more parameters
    reg [3:0] S;
    reg [3:0] NS;

 
    

    parameter START = 4'd0,
				  WAIT_SEL = 4'd1,
				  SEL_START = 4'd2,
				  MINE_PLACE = 4'd3,
				  PLAY = 4'd4,
				  LOSE_S = 4'd5,
				  WIN_S = 4'd6,
				  IF_PLAY_AGAIN = 4'd7,
				  RST_BOARD = 4'd8,
				  ERROR = 4'd9;
				  

    // FSM state register
    always @(posedge clk or negedge rst) begin
        if (rst == 1'b0) begin
            S <= START;
        end else begin
            S <= NS;
        end
    end
	// latch where the player chose to start
		always @(posedge clk or negedge rst) begin
			 if (rst == 1'b0) begin
				  start_cell_addr <= 8'd0;
			 end else begin
				  // while waiting for first selection
				  if (S == WAIT_SEL && sel == 1'b1) begin
						start_cell_addr <= cursor_addr;
				  end
			 end
		end
    // State transitions (next-state logic)
    always @(*) begin
		  NS = S;
        case (S)
				START: if (go == 1'b0)
							NS = START;
						 else
							NS = WAIT_SEL;
							
				WAIT_SEL: if (sel == 1'b0)  //Waits until user has picked the start local
								NS = WAIT_SEL;
							 else
								NS = MINE_PLACE;
				MINE_PLACE: if (mine_done == 1'b1)
										NS = SEL_START; //Places the mines
								else
										NS = MINE_PLACE;
				SEL_START: if(start_done) NS = PLAY;
							  else NS = SEL_START;
				PLAY: if (cond == 2'd0)
							NS = PLAY;
						else if (cond == 2'd1)
							NS = WIN_S;
						else if (cond == 2'd2)
							NS = LOSE_S;
						else
							NS = PLAY;
							
							
				WIN_S: NS = IF_PLAY_AGAIN;
				
				LOSE_S: NS = IF_PLAY_AGAIN;
				
				IF_PLAY_AGAIN: if (play_again == 1'b0)
										NS = IF_PLAY_AGAIN;
									else
										NS = RST_BOARD;
				RST_BOARD: NS = WAIT_SEL;
				
				default: NS = ERROR;
			endcase
    end

    // Output declarations
    always @(*) begin
        mine_start = 1'b0;                 
        done       = 1'b0;                 
		  result = 2'd0;
		  play_en = 1'b0;
		  start_en = 1'b0;
		  case (S)
				MINE_PLACE: mine_start = 1'b1; 
				SEL_START: start_en = 1'b1;
				PLAY: play_en = 1'b1;
				WIN_S:  begin
				done = 1'b1;
				result = 2'd1;
				end
				LOSE_S: begin
				done = 1'b1;
				result = 2'd2;
				end
		  endcase
    end

endmodule	