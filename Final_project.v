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
	
//A Ton of wires to hook all my modules together	
wire clk;
wire rst;

assign clk = CLOCK_50;
assign rst = SW[0];

wire show_mines;
assign show_mines = SW[9]; //debug for showing mines
wire debug_number;
assign debug_number = SW[8];

wire go;                    
wire play_again;      
wire sel;            
wire [5:0] num_mines; 
wire game_done;
wire [1:0] cond;       

assign go = SW[1];
//assign sel = SW[2];
assign play_again = SW[3];
assign num_mines = 6'd40;


wire active_pixels;
wire[9:0]x;
wire[9:0]y;
wire[23:0] vga_color;
wire[23:0] sqr_color;
reg[23:0] final_color;

wire mine_present;
wire mine_at_cursor;
wire revealed_at_cursor;
wire flag_at_cursor;
wire cell_revealed;
wire[3:0] adj_count;
wire[8:0] reveal_safe_count;

wire mine_mem_in;
wire mine_mem_wren;

wire[7:0] flag_mem_addr;
wire flag_mem_wren;
wire flag_mem_in;

wire[7:0] ps_reveal_mem_addr;
wire ps_reveal_mem_wren;
wire ps_reveal_mem_in;

wire [23:0] flag_color;

wire sel_start;
wire place_flag;
wire sel_sqr;	
wire[7:0] cursor_addr;

wire mine_start;
wire mine_done;

localparam GRID_W = 16;
localparam GRID_H = 16;
localparam CELL_W = 40;
localparam CELL_H = 30;

wire [5:0] xCell = x / CELL_W;
wire [5:0] yCell = y / CELL_H;

wire [5:0] local_x = x % CELL_W;              // where we are inside the cell
wire [5:0] local_y = y % CELL_H;              // where we are inside the cell
wire is_grid_line = (local_x == 0) || (local_y == 0); // same rule as grid_creation
 
wire [7:0] cell_addr = {yCell[3:0], xCell[3:0]};

wire [23:0] mine_color;

wire [7:0] mine_mem_addr;

wire [23:0] result_color;
wire [1:0] result;

wire flag_present;

wire play_en;
wire start_en;
wire start_done;

wire [7:0] start_cell_addr;

wire [7:0] start_reveal_addr;
wire       start_reveal_in;
wire       start_reveal_wren;

wire [7:0] reveal_mem_addr;
wire       reveal_mem_wren;
wire       reveal_mem_in;

//VGA Driver and this Instantiation was written by Dr. Peter Jamieson
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
					.sel_sqr(sel_sqr), //Drive this to sel_module to ahve it reveal a single sqr
					.cursor_addr(cursor_addr)
					);
					


game_state gs(
    .clk(clk),
    .rst(rst),
    .go(go),
    .cond(cond),
    .play_again(play_again),
    .sel(sel_start), 
	 .start_done(start_done),
	 .cursor_addr(cursor_addr),
    .mine_done(mine_done),    
    .mine_start(mine_start),   
    .done(game_done),
	 .result(result),
	 .play_en(play_en),
	 .start_en(start_en),
	 .start_cell_addr(start_cell_addr)
);



mines_placer mp(
    .clk(clk),
    .rst(rst),
    .num_mines(num_mines),
    .start(mine_start),    //Gets this from game_state 
	 .safe_center_addr(start_cell_addr),
    .done(mine_done),       //Push this back to game_state  
	
	.mine_mem_addr(mine_mem_addr),
   .mine_mem_in(mine_mem_in),
   .mine_mem_wren(mine_mem_wren)
	
);					


start_3x3 starter(
    .clk(clk),
    .rst(rst),
    .start_en(start_en),
    .start_cell_addr(start_cell_addr),  
    .start_done(start_done),
    .reveal_mem_addr(start_reveal_addr),
    .reveal_mem_in(start_reveal_in),
    .reveal_mem_wren(start_reveal_wren)
);

// if start_3x3 is writing, give it priority; otherwise use play_state
assign reveal_mem_addr = start_reveal_wren ? start_reveal_addr : ps_reveal_mem_addr;
assign reveal_mem_in   = start_reveal_wren ? start_reveal_in   : ps_reveal_mem_in;
assign reveal_mem_wren = start_reveal_wren | ps_reveal_mem_wren;

draw_mines dm(
		.xPixel(x),
		.yPixel(y),
		.active_pixels(active_pixels),
		.mine_present(mine_present),
		
		.show_mines(show_mines),
		.reveal(game_done),
		.vga_color(mine_color)
		);



	
play_state ps (
			.clk(clk),
			.rst(rst),
			.play_en(play_en),
			.sel_sqr(sel_sqr),
			.place_flag(place_flag),
			.cursor_addr(cursor_addr),
			
			.mine_at_cursor(mine_at_cursor),
			.revealed_at_cursor(revealed_at_cursor),
			.flag_at_cursor(flag_at_cursor),
			
			.reveal_safe_count(reveal_safe_count),
			.num_mines(num_mines),
			.cond(cond),
			
			.flag_mem_addr(flag_mem_addr),
			.flag_mem_wren(flag_mem_wren),
			.flag_mem_in(flag_mem_in),
			
			.reveal_mem_addr(ps_reveal_mem_addr),
			.reveal_mem_wren(ps_reveal_mem_wren),
			.reveal_mem_in(ps_reveal_mem_in)
			);
			
			
draw_flag df(
		.xPixel(x),
		.yPixel(y),
		.active_pixels(active_pixels),
		.flag_here(flag_present),
		.vga_color(flag_color)
		);


board_state bs( //for bullshit hardy har har
			.clk(clk),
			.rst(rst),
			.debug_number(debug_number),
			.mine_wr_addr(mine_mem_addr),
			.mine_wr_data(mine_mem_in),
			.mine_wr_en(mine_mem_wren),

			.flag_wr_addr(flag_mem_addr),
			.flag_wr_data(flag_mem_in),
			.flag_wr_en(flag_mem_wren),

			.reveal_wr_addr(reveal_mem_addr),
			.reveal_wr_data(reveal_mem_in),
			.reveal_wr_en(reveal_mem_wren),

			.xCell(xCell),
			.yCell(yCell),
			.cursor_addr(cursor_addr),

			.mine_present(mine_present),
			.mine_at_cursor(mine_at_cursor),
		   .revealed_at_cursor(revealed_at_cursor),
			.flag_at_cursor(flag_at_cursor),
			.cell_revealed(cell_revealed),
			.adj_count(adj_count),
			.reveal_safe_count(reveal_safe_count),
			.flag_present(flag_present)
		);
		
win_or_lose wio(
	.result(cond),
	.vga_color(result_color)
	);

//Handles VGA RGB Values for the final colors
always @(*)
	begin
		{VGA_R, VGA_G, VGA_B} = final_color;
	end

	
	
	
/*Debug*/
assign LEDR[0] = play_en; 
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
	
	//I love colors !!11!1!!11!!11!!1    !!!!
	if (cell_revealed && !mine_present && !is_grid_line) begin
    case (adj_count)
        4'd0: final_color = 24'hFFFFFF; // 0 //For some reason I had this set to grey???????
        4'd1: final_color = 24'h0000FF; // 1
        4'd2: final_color = 24'h008000; // 2
        4'd3: final_color = 24'hFF0000; // Red is a menance. I WANT PICTURES OF RED. GET ME PICTURES OF THE RED MENANCE
        4'd4: final_color = 24'h000080; // 4
        4'd5: final_color = 24'h800000; // 5
        4'd6: final_color = 24'h008080; // 6 
        4'd7: final_color = 24'h000000; // 7
        4'd8: final_color = 24'h808080; // 8
        default: final_color = 24'hFFFFFF;
    endcase
end
	
	if (!cell_revealed && flag_color != 24'h000000)
		begin
			final_color = flag_color;
		end
		
	if (sqr_color != 24'h000000)
		begin
			final_color = sqr_color;
		end
	if(result_color != 24'h000000)
		begin
			final_color = result_color;
		end
end
endmodule