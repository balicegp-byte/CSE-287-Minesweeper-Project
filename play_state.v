module play_state(
	input clk,
	input rst,
	
	input play_en, //Comes from Game State
	
	//Stuff from cursor square
	input sel_sqr,
	input place_flag,
	input[7:0] cursor_addr,
	
	//Stuff from mine/number/and flag mems
	input mine_at_cursor, //mine_map[cursor_addr]
	input revealed_at_cursor, //revealed_map[cursor_addr]
	input flag_at_cursor, //flag_map[cursor_addr]
	
	//win detection
	input[8:0] reveal_safe_count,
	input[5:0] num_mines,
	
	output reg [1:0] cond, //Pass into game_state to trigger win/lose
	
	//flag memory
	output reg [7:0]flag_mem_addr,
	output reg flag_mem_wren,
	output reg flag_mem_in, // 1 = set flag, 0 = clear flag
	
	//Reveal memory
	output reg [7:0] reveal_mem_addr,
	output reg       reveal_mem_wren,
	output reg       reveal_mem_in   // usually 1'b1 to mark revealed
	);
	
	
	
	//My total amount of safe cells its 256 - the number of mines
	wire[8:0] total_safe_cells = 9'd256 - {3'b000, num_mines}; //9 bit - 6 bits shouldn't cause problems
	
	reg play_en_d;                    //remember previous play_en
   wire play_en_rise = play_en & ~play_en_d; //detect start of play
	
	always@(posedge clk or negedge rst) begin
	if (rst == 1'b0) begin
		flag_mem_addr <= 8'd0;
		flag_mem_wren <= 1'b0;
		flag_mem_in <= 1'b0;
		reveal_mem_wren <= 1'b0;
		reveal_mem_in <= 1'b0;
		reveal_mem_addr <= 8'd0;
		cond <= 2'b00;
		play_en_d <= 1'b0;
	end
	else begin
		flag_mem_addr <= 8'd0;
		flag_mem_wren <= 1'b0;
		flag_mem_in <= 1'b0;
		reveal_mem_wren <= 1'b0;
		reveal_mem_in <= 1'b0;
		reveal_mem_addr <= 8'd0;
		play_en_d <= play_en;
		
		if (play_en_rise)
			begin
				cond <= 2'b00;
			end
			
			
		if (play_en) begin //Starts play_state. From here, begin checking each input to determine whether or not I should do its thing
		if (cond == 2'b00) begin
			if (place_flag && !revealed_at_cursor)
			begin
				flag_mem_addr <= cursor_addr;
				flag_mem_in   <= ~flag_at_cursor; //toggle flag
				flag_mem_wren <= 1'b1;
			end
			
			if (sel_sqr && !revealed_at_cursor) begin
					if (mine_at_cursor) begin
						cond <= 2'b10; //10 = lose
					end
					else if (!revealed_at_cursor) begin
						reveal_mem_addr <= cursor_addr;
						reveal_mem_in   <= 1'b1;
						reveal_mem_wren <= 1'b1;

						//win check: we just revealed one more safe cell
						if (reveal_safe_count + 9'd1 >= total_safe_cells) begin
							cond <= 2'b01; //01 = win
						end
					end
				end
			end
		end
	end
end

endmodule	