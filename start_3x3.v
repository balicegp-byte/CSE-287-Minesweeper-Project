module start_3x3(
			input clk,
			input rst,
			
			input start_en,
			
			input [7:0] start_cell_addr,
			
			output reg start_done,
			
			output reg [7:0] reveal_mem_addr,
			output reg reveal_mem_in,
			output reg reveal_mem_wren
			);
			
localparam GRID_W = 16;
localparam GRID_H = 16;

parameter  IDLE = 2'd0,
			  RUN = 2'd1,
			  DONE = 2'd2;
			  
reg[1:0] S, NS;

//our x and y positions when we start
reg [3:0] start_x;
reg [3:0] start_y;

//offsets like for -1 0 and + 1
reg [1:0] off_x;
reg [1:0] off_y;

reg signed[4:0] nx, ny;

always @(posedge clk or negedge rst)
	if (rst == 1'b0)
		S <= IDLE;
	else
		S <= NS;
		
always @(*) begin
    NS = S;
    case (S)
        IDLE: begin
            if (start_en)
                NS = RUN;
        end

        RUN: begin
            // Once we've visited the (off_x, off_y) = (2,2) slot,
            // we consider the 3x3 pass done.
            if (off_x == 2'd2 && off_y == 2'd2)
                NS = DONE;
        end

        DONE: begin
            // We can just sit here; game_state will move on
            NS = DONE;
        end

        default: NS = IDLE;
    endcase
end

//Updates the offset
always @ (posedge clk or negedge rst) begin
	if (rst == 1'b0) begin
		start_x <= 4'd0;
		start_y <= 4'd0;
		off_x <= 2'd0;
		off_y <= 2'd0;
	end
	else begin
		
		 if (S == IDLE && start_en) begin
            // latch starting cell when we first begin
            start_x <= start_cell_addr[3:0];
            start_y <= start_cell_addr[7:4];
            off_x   <= 2'd0;
            off_y   <= 2'd0;
        end
        else if (S == RUN) begin
            // walk 3x3 cha cha: (off_x, off_y) = 0..2
            if (off_x == 2'd2) begin
                off_x <= 2'd0;              // wrap to next column
                if (off_y != 2'd2)
                    off_y <= off_y + 2'd1;  // advance row until (2,2)
            end
            else begin
                off_x <= off_x + 2'd1;      // move to next column in same row
            end
        end
    end
end

always @(*) begin
	reveal_mem_addr = 8'd0;
	reveal_mem_in = 1'b0;
	reveal_mem_wren = 1'b0;
	start_done = 1'b0;
	
	case (S) 
		RUN: begin
			 nx = ({1'b0, start_x}) + ({1'b0, off_x}) - 1; // start_x + (off_x-1)
          ny = ({1'b0, start_y}) + ({1'b0, off_y}) - 1; // start_y + (off_y-1)
			 
			 
			 if(nx >= 0 && nx <= GRID_W && ny >= 0 && ny < GRID_H) begin
				reveal_mem_addr = {ny[3:0], nx[3:0]};
				reveal_mem_in = 1'b1;
				reveal_mem_wren = 1'b1;
				end
			end
			
			
			DONE: begin
				start_done = 1'b1;
				end
			endcase
		end
endmodule	