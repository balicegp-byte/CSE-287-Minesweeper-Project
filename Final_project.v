module Final_project( 	//////////// ADC //////////
	//output		          		ADC_CONVST,
	//output		          		ADC_DIN,
	//input 		          		ADC_DOUT,
	//output		          		ADC_SCLK,

	//////////// Audio //////////
	//input 		          		AUD_ADCDAT,
	//inout 		          		AUD_ADCLRCK,
	//inout 		          		AUD_BCLK,
	//output		          		AUD_DACDAT,
	//inout 		          		AUD_DACLRCK,
	//output		          		AUD_XCK,

	//////////// CLOCK //////////
	//input 		          		CLOCK2_50,
	//input 		          		CLOCK3_50,
	//input 		          		CLOCK4_50,
	input 		          		CLOCK_50,

	//////////// SDRAM //////////
	//output		    [12:0]		DRAM_ADDR,
	//output		     [1:0]		DRAM_BA,
	//output		          		DRAM_CAS_N,
	//output		          		DRAM_CKE,
	//output		          		DRAM_CLK,
	//output		          		DRAM_CS_N,
	//inout 		    [15:0]		DRAM_DQ,
	//output		          		DRAM_LDQM,
	//output		          		DRAM_RAS_N,
	//output		          		DRAM_UDQM,
	//output		          		DRAM_WE_N,

	//////////// I2C for Audio and Video-In //////////
	//output		          		FPGA_I2C_SCLK,
	//inout 		          		FPGA_I2C_SDAT,

	//////////// SEG7 //////////
	output		     [6:0]		HEX0,
	output		     [6:0]		HEX1,
	output		     [6:0]		HEX2,
	output		     [6:0]		HEX3,
	//output		     [6:0]		HEX4,
	//output		     [6:0]		HEX5,

	//////////// IR //////////
	//input 		          		IRDA_RXD,
	//output		          		IRDA_TXD,

	//////////// KEY //////////
	input 		     [3:0]		KEY,

	//////////// LED //////////
	output		     [9:0]		LEDR,

	//////////// PS2 //////////
	//inout 		          		PS2_CLK,
	//inout 		          		PS2_CLK2,
	//inout 		          		PS2_DAT,
	//inout 		          		PS2_DAT2,

	//////////// SW //////////
	input 		     [9:0]		SW,

	//////////// Video-In //////////
	//input 		          		TD_CLK27,
	//input 		     [7:0]		TD_DATA,
	//input 		          		TD_HS,
	//output		          		TD_RESET_N,
	//input 		          		TD_VS,

	//////////// VGA //////////
	output		          		VGA_BLANK_N,
	output reg	     [7:0]		VGA_B,
	output		          		VGA_CLK,
	output reg	     [7:0]		VGA_G,
	output		          		VGA_HS,
	output reg	     [7:0]		VGA_R,
	output		          		VGA_SYNC_N,
	output		          		VGA_VS

	//////////// GPIO_0, GPIO_0 connect to GPIO Default //////////
	//inout 		    [35:0]		GPIO_0,

	//////////// GPIO_1, GPIO_1 connect to GPIO Default //////////
	//inout 		    [35:0]		GPIO_1

);

// Turn off all displays.
	assign	HEX0		=	7'h00;
	assign	HEX1		=	7'h00;
	assign	HEX2		=	7'h00;
	assign	HEX3		=	7'h00;
	
wire clk;
wire rst;

assign clk = CLOCK_50;
assign rst = SW[0];

wire show_mines;
assign show_mines = SW[9]; //debug for showing mines
wire debug_number;
assign debug_number = SW[8];

wire go;              
wire [1:0] cond;      
wire play_again;      
wire sel;            
wire [5:0] num_mines; 
wire game_done;       

assign go = SW[1];
assign cond = 2'd0; //replace this later?
//assign sel = SW[2];
assign play_again = SW[3];
assign num_mines = 6'd40;


wire active_pixels;
wire[9:0]x;
wire[9:0]y;
wire[23:0] vga_color;
wire[23:0] sqr_color;
reg[23:0] final_color;


//This section was written by Dr. Peter Jamieson
vga_driver the_vga(
.clk(clk),
.rst(rst),

.vga_clk(VGA_CLK),

.hsync(VGA_HS),
.vsync(VGA_VS),

.active_pixels(active_pixels),

.xPixel(x),
.yPixel(y),

.VGA_BLANK_N(VGA_BLANK_N),
.VGA_SYNC_N(VGA_SYNC_N)
);



grid_creation grid(.xPixel(x), 
						 .yPixel(y), 
						 .active_pixels(active_pixels), 
						 .vga_color(vga_color));

wire sel_start;
wire place_flag;
wire sel_sqr;						 
cursor_sqr sqr(.xPixel(x), 
					.yPixel(y), 
					.active_pixels(active_pixels),
					.rst(rst),
					.clk(clk),
					.KEY(KEY),
					.switch(SW[2]),
					.vga_color(sqr_color),
					.sel_start(sel_start), //Drive this to sel_module and game_start to place mines and start game
					.place_flag(place_flag), //Drive this to flag_placer
					.sel_sqr(sel_sqr) //Drive this to sel_module to ahve it reveal a single sqr
					);
					
wire mine_start;
wire mine_done;

game_state gs(
    .clk(clk),
    .rst(rst),
    .go(go),
    .cond(cond),
    .play_again(play_again),
    .sel(sel_start), 
    .mine_done(mine_done),    
    .mine_start(mine_start),   
    .done(game_done)
);

wire[7:0] mine_mem_addr;
wire mine_mem_in;
wire mine_mem_wren;

mines_placer mp(
    .clk(clk),
    .rst(rst),
    .num_mines(num_mines),
    .start(mine_start),    //Gets this from game_state    
    .done(mine_done),       //Push this back to game_state  
	
	.mine_mem_addr(mine_mem_addr),
   .mine_mem_in(mine_mem_in),
   .mine_mem_wren(mine_mem_wren)
	
);					

localparam GRID_W = 16;
localparam GRID_H = 16;
localparam CELL_W = 40;
localparam CELL_H = 30;

wire [5:0] xCell = x / CELL_W;
wire [5:0] yCell = y / CELL_H;

    
wire [7:0] cell_addr = {yCell[3:0], xCell[3:0]};



reg mine_map [0:255];
integer ii;
always @(posedge clk or negedge rst) begin
	if (rst == 1'b0)
		begin
		for (ii = 0; ii < 256; ii = ii + 1)
			mine_map[ii] <= 1'b0;
		end
		else begin
			if (mine_mem_wren) begin
				mine_map[mine_mem_addr] <= mine_mem_in;
			end
			
			/*Hard debug for testing
			if (show_mines)
				mine_map[8'h00] <= 1'b1;
				*/
		end
	end

//Code for adding the numbers	
reg revealed_map [0:255];
integer jj;
always @(posedge clk or negedge rst) begin
    if (rst == 1'b0) begin
        for (jj = 0; jj < 256; jj = jj + 1)
            revealed_map[jj] <= 1'b0; // clear reveals on reset
    end else begin
        // debug: reveal everything when debug_numbers is ON
        if (debug_number) begin
            for (jj = 0; jj < 256; jj = jj + 1)
                revealed_map[jj] <= 1'b1; // show all cells
        end
        // later: when you hook sel_sqr to a selector, you'll set revealed_map[cursor_addr] <= 1 here
    end
end


wire [23:0] mine_color;
wire [7:0] mine_addr = {yCell[3:0], xCell[3:0]};
wire mine_present = mine_map[mine_addr];
wire cell_revealed = debug_number || revealed_map[mine_addr]; // show numbers when debugging or when this cell is revealed

reg [3:0] adj_count;
integer dx, dy;
integer ix, iy;

always @(*) begin
    adj_count = 4'd0;
    for (dx = -1; dx <= 1; dx = dx + 1) begin
        for (dy = -1; dy <= 1; dy = dy + 1) begin
            ix = $signed({1'b0, xCell}) + dx;  // signed temp index
            iy = $signed({1'b0, yCell}) + dy;  // signed temp index

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

draw_mines dm(
		.xPixel(x),
		.yPixel(y),
		.active_pixels(active_pixels),
		.mine_present(mine_present),
		
		.show_mines(show_mines),
		.reveal(game_done),
		.vga_color(mine_color)
		);

//Handles VGA RGB Values for the final colors
always @(*)
	begin
		{VGA_R, VGA_G, VGA_B} = final_color;
	end

	
	
	
/*Debug*/ 
assign LEDR[0] = mine_start; 
assign LEDR[1] = mine_done; 
assign LEDR[2] = mine_mem_wren; 
assign LEDR[3] = show_mines; 
assign LEDR[4] = game_done;

//Picks what color should be appearing on the grid
always @(*)
begin
	final_color = vga_color;
	
	
	if(mine_color != 24'h000000)
	begin
		final_color = mine_color;
	end
	
	if (cell_revealed && !mine_present) begin
    case (adj_count)
        4'd0: final_color = 24'h878080; // 0
        4'd1: final_color = 24'h0000FF; // 1
        4'd2: final_color = 24'h008000; // 2
        4'd3: final_color = 24'hFF0000; // 3
        4'd4: final_color = 24'h000080; // 4
        4'd5: final_color = 24'h800000; // 5
        4'd6: final_color = 24'h008080; // 6
        4'd7: final_color = 24'h000000; // 7
        4'd8: final_color = 24'h808080; // 8
        default: final_color = 24'hFFFFFF;
    endcase
end
	
	if (sqr_color != 24'h000000)
		begin
			final_color = sqr_color;
		end
end
endmodule