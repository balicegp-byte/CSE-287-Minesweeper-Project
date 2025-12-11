module game_state(
    input        clk,
    input        rst,
    input        go,
	 
	 input [1:0] cond,
    input play_again,
	 input sel,
	 
	 input mine_done,
	 output reg mine_start,
	 
    output reg   done
);

    reg [3:0] S;
    reg [3:0] NS;

 
    // Add more variables as you need them

    parameter START = 4'd0,
				  WAIT_SEL = 4'd1,
				  MINE_PLACE = 4'd2,
				  PLAY = 4'd3,
				  LOSE_S = 4'd4,
				  WIN_S = 4'd5,
				  IF_PLAY_AGAIN = 4'd6,
				  RST_BOARD = 4'd7,
				  ERROR = 4'd8;

    // FSM state register
    always @(posedge clk or negedge rst) begin
        if (rst == 1'b0) begin
            S <= START;
        end else begin
            S <= NS;
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
										NS = PLAY; //Places the mines
								else
										NS = MINE_PLACE;
				
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

    // Simple placeholder for 'done' so it has a defined value
    always @(*) begin
        mine_start = 1'b0;                 
        done       = 1'b0;                 

		  case (S)
				MINE_PLACE: mine_start = 1'b1; 
				WIN_S:      done = 1'b1;       
				LOSE_S:     done = 1'b1;
		  endcase
    end

endmodule	