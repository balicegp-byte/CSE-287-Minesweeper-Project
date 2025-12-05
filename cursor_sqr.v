module cursor_sqr(
	 input[9:0] xPixel,
    input[9:0] yPixel,
    input active_pixels,
	 input rst,
	 input clk,
	 input[3:0] KEY,

    // packed RGB {R,G,B}
    output reg [23:0] vga_color
	 );
	 
	 
localparam GRID_W = 16;
localparam GRID_H = 16;

localparam CELL_W = 40; // 640 / 40 = 16
localparam CELL_H = 30; // 480 / 30 = 16

//Cursor teleports to the other side instantly without this
localparam MOVE_TICK = 24'd10_000_000;

reg move_tick;
reg[23:0] cnt;

// What cell am I in
wire [5:0] xCell   = xPixel / CELL_W;  // 0..15
wire [5:0] yCell   = yPixel / CELL_H;  // 0..15

// Where am I in the cell
wire [5:0] local_x = xPixel % CELL_W;  // 0..39
wire [5:0] local_y = yPixel % CELL_H;  // 0..29

reg[5:0] cursor_x;
reg[5:0] cursor_y;

//Board border
wire in_board = (xCell < GRID_W) && (yCell < GRID_H);

//Cell border
wire is_grid_line = (local_x == 0) || (local_y == 0);

//delay thingy
always @(posedge clk or negedge rst)
	if (rst == 1'b0)
	begin
		move_tick <= 1'b0;
		cnt <= 24'd0;
	end
	else 
		begin
			if(cnt == MOVE_TICK)
			begin
				cnt <= 24'd0;
				move_tick = 1'b1;
			end
			else
			begin
				cnt <= cnt + 1'b1;
				move_tick <= 1'b0;
			end
		end

//controls the movement in the x direction
//Rambling Comment: I don't really like how messy this code is, but hey it works
always @(posedge clk or negedge rst)
begin
	if(rst == 1'b0)
		begin
			cursor_x <= 6'd0;
			cursor_y <= 6'd0;
		end 
		
		else 
		begin 
		if (move_tick == 1'b1)
		begin
			if (KEY[0] == 1'b0 && cursor_x < 6'd15)
			cursor_x <= cursor_x +1'b1;
		//AGAIN
		else if (KEY[1] == 1'b0 && cursor_x > 6'd0)
			cursor_x <= cursor_x - 1'b1;
		//AND AGAIN
		else if (KEY[2] == 1'b0 && cursor_y > 6'd0)
			cursor_y <= cursor_y - 1'b1;
		//AND AGAIN AND AGAIN
		else if (KEY[3] == 1'b0 && cursor_y < 6'd15)
			cursor_y <= cursor_y + 1'b1;
		//AND FINISH
		end
		
	end
end			
			
//makes the block actually appear
always @(*)
begin
	vga_color = 24'h000000;
	if(active_pixels && in_board) 
	begin
		if(is_grid_line) 
		begin
			//Keep the white lines
			vga_color = 24'hFFFFFF;
		end
		else 
		begin
			//Make the first grid red
			if (xCell == cursor_x && yCell == cursor_y)
				vga_color = 24'hF54927;
			else
				vga_color = 24'h878080;
		end
	end
end


endmodule