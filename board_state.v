module board_state (
    input        clk,
    input        rst,
    input        debug_number,   // This is Sw[8] for debug 

    // comes from da mine_placer
    input  [7:0] mine_wr_addr,
    input        mine_wr_data,
    input        mine_wr_en,

    // comes from play_state
    input  [7:0] flag_wr_addr,
    input        flag_wr_data,
    input        flag_wr_en,

    // Comes from play_state
    input  [7:0] reveal_wr_addr,
    input        reveal_wr_data,
    input        reveal_wr_en,

    //my usual cursor shenanigans (Is that how you spell it?)
    input  [5:0] xCell,         // from top (current pixel cell)
    input  [5:0] yCell,         // from top
    input  [7:0] cursor_addr,   // from cursor_sqr (cursor position encoded)

    //send this crap to the drawing logic
    output       mine_present,        // mine at current (xCell,yCell)
    output       mine_at_cursor,      // mine at cursor_addr
    output       revealed_at_cursor,  // revealed_map[cursor_addr]
    output       flag_at_cursor,      // flag_map[cursor_addr]
    output       cell_revealed,       // revealed for current (xCell,yCell) or debug
    output reg [3:0] adj_count,       // number adjacent mines for current cell
    output reg [8:0] reveal_safe_count,
	 output flag_present
);

	 reg mine_map     [0:255];
    reg flag_map     [0:255];
    reg revealed_map [0:255];

    localparam GRID_W = 16;
    localparam GRID_H = 16;
	 
	 wire [7:0]vga_addr = {yCell[3:0], xCell[3:0]};
	 assign flag_present = flag_map[vga_addr];
	 
    wire [7:0] cell_addr = { yCell[3:0], xCell[3:0] };

    //stuff for the brain
   

    integer i;

    // mine_map write (from mines_placer module)
    always @(posedge clk or negedge rst) begin
        if (rst == 1'b0) begin
            for (i = 0; i < 256; i = i + 1)
                mine_map[i] <= 1'b0;
        end else begin
            if (mine_wr_en) begin
                mine_map[mine_wr_addr] <= mine_wr_data;
            end
        end
    end

    //flag_map write (comes from play_state modulolololo)
    integer k;
    always @(posedge clk or negedge rst) begin
        if (rst == 1'b0) begin
            for (k = 0; k < 256; k = k + 1)
                flag_map[k] <= 1'b0;
        end else begin
            if (flag_wr_en) begin
                flag_map[flag_wr_addr] <= flag_wr_data;
            end
        end
    end

    //revealed_map write (from play_state + debug) 
    integer j;
    always @(posedge clk or negedge rst) begin
        if (rst == 1'b0) begin
            for (j = 0; j < 256; j = j + 1)
                revealed_map[j] <= 1'b0;
        end else begin
            if (debug_number) begin
                // reveal everything in debug mode
                for (j = 0; j < 256; j = j + 1)
                    revealed_map[j] <= 1'b1;
            end else if (reveal_wr_en) begin
                revealed_map[reveal_wr_addr] <= reveal_wr_data;
            end
        end
    end

    // increments when you reveal a NEW safe cell
    always @(posedge clk or negedge rst) begin
        if (rst == 1'b0) begin
            reveal_safe_count <= 9'd0;
        end else begin
            if (reveal_wr_en &&
                reveal_wr_data == 1'b1 &&       // we mark as revealed
                !mine_map[reveal_wr_addr] &&    // safe cell
                !revealed_map[reveal_wr_addr])  // wasn't already revealed
            begin
                reveal_safe_count <= reveal_safe_count + 9'd1;
            end
        end
    end

    // simple read signals
    assign mine_present = mine_map[cell_addr];
    assign mine_at_cursor = mine_map[cursor_addr];
    assign revealed_at_cursor = revealed_map[cursor_addr];
    assign flag_at_cursor = flag_map[cursor_addr];

    assign cell_revealed = debug_number ? 1'b1 : revealed_map[cell_addr];

    // adjacent mine count for current (xCell,yCell)
    integer dx, dy;
    integer ix, iy;
	 
    always @(*) begin
        adj_count = 4'd0;
        for (dx = -1; dx <= 1; dx = dx + 1) begin
            for (dy = -1; dy <= 1; dy = dy + 1) begin
                ix = $signed({1'b0, xCell}) + dx;
                iy = $signed({1'b0, yCell}) + dy;
					 
					 //This is a cry for help
                if (!(dx == 0 && dy == 0)) begin
                    if (ix >= 0 && ix < GRID_W && iy >= 0 && iy < GRID_H) begin
                        if (mine_map[{iy[3:0], ix[3:0]}]) begin
                            adj_count = adj_count + 1'b1;
                        end
                    end
                end
            end
        end
    end

endmodule