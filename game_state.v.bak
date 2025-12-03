module game_state(
input clk
input rst
input go
output reg done);

reg[3:0]S;
reg[3:0]NS;

//Variables that I might need
reg[1:0] cond;
reg play_again;
//Add more variables as I need them

parameter START = 3'd0,
			 INIT = 3'd1,
			 IDLE = 3'd2,
			 PLAY = 3'd3,
			 WIN = 3'd4,
			 LOSE = 3'd5,
			 ERROR = 3'd6;
			 
//FSM INIT
always @ (posedge clk or negedge rst)
begin
	if (rst == 0)
		begin
			S <= START;
		end
	else
		begin
			S <= NS;
		end
//State Transistions
always @ (*)	
begin
	NS = S;
		case(S)
			START: NS = INIT;
			INIT: NS = IDLE;
			IDLE: NS = PLAY;
			PLAY: if (cond == 2'b01)
						NS = WIN;
					else if (cond == 2'b11)
						NS = LOSE;
					else
						NS = PLAY;
			LOSE: if (play_again == 1'b1)
						NS = START;
					else
						NS = LOSE;
			WIN: if (play_agin == 1'b1)
						NS: = START;
					else
						NS = LOSE;
	endcase
end

always @ (posedge clk or negedge rst) //Hold off on this for now
			
			
			
			
			
			
			
			
			
			
			
			
			
			
			