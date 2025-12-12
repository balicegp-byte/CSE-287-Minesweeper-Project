module grid_creation(
	 input  [9:0] xPixel,
    input  [9:0] yPixel,
    input        active_pixels,

    // packed RGB {R,G,B}
    output reg [23:0] vga_color
);

    localparam GRID_W = 16;
    localparam GRID_H = 16;

    localparam CELL_W = 40; // 640/ 8
    localparam CELL_H = 30; // 480 / 8

    // What cell am I in
    wire [5:0] xCell   = xPixel / CELL_W;  // 0..15
    wire [5:0] yCell   = yPixel / CELL_H;  // 0..15

    // Where am I in the cell
    wire [5:0] local_x = xPixel % CELL_W;  // 0..39
    wire [5:0] local_y = yPixel % CELL_H;  // 0..29

    // Check to see if I'm in the board
    wire in_board = (xCell < GRID_W) && (yCell < GRID_H);

    // Grid edge
    wire is_grid_line = (local_x == 0) || (local_y == 0);

    always @(*) begin
        // black background if nothing happened
        vga_color = 24'h000000;

        if (active_pixels && in_board) begin
            if (is_grid_line) begin
                // grid lines white
                vga_color = 24'h000000;
            end else begin
                // cell color is grey
                vga_color = 24'h878080;
            end
        end
    end

endmodule