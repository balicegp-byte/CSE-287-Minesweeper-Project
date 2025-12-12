module draw_flag (
	input[9:0] xPixel,
	input[9:0] yPixel,
	input active_pixels,
	
	input flag_here,
		
	output reg[23:0] vga_color
	);	
	
	
	
localparam GRID_W = 16;
localparam GRID_H = 16;
localparam CELL_W = 40;
localparam CELL_H = 30;

localparam[23:0] flag_color = 24'hF5EE27;

wire [5:0] xCell   = xPixel / CELL_W;
wire [5:0] yCell   = yPixel / CELL_H;

wire [5:0] local_x = xPixel % CELL_W;
wire [5:0] local_y = yPixel % CELL_H;

wire in_board = (xCell < GRID_W) && (yCell < GRID_H);
wire is_grid_line = (local_x == 0) || (local_y == 0);

always @ (*) begin
	vga_color = 24'h000000;
		if (active_pixels && in_board && !is_grid_line)
			begin
				if(flag_here)
					begin
						vga_color = flag_color;
					end
			end
	end
endmodule
			