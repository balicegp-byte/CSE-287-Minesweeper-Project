module cursor_sqr(
	 input  [9:0] xPixel,
    input  [9:0] yPixel,
    input        active_pixels,

    // packed RGB {R,G,B}
    output reg [23:0] vga_color
	 );
	 
	 
localparam GRID_W = 16;
localparam GRID_H = 16;

localparam CELL_W = 40; // 640 / 40 = 16
localparam CELL_H = 30; // 480 / 30 = 16

// What cell am I in
wire [5:0] xCell   = xPixel / CELL_W;  // 0..15
wire [5:0] yCell   = yPixel / CELL_H;  // 0..15

// Where am I in the cell
wire [5:0] local_x = xPixel % CELL_W;  // 0..39
wire [5:0] local_y = yPixel % CELL_H;  // 0..29

reg[5:0] cursor_x;
reg[5:0] cursor_y;

wire in_board = (xCell < GRID_W) && (yCell < GRID_H);

wire is_grid_line = (local_x == 0) || (local_y == 0);



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
			if (xCell == 0 && yCell == 0)
				vga_color = 24'hF54927;
			else
				vga_color = 24'h878080;
		end
	end
end


endmodule