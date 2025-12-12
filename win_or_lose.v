module win_or_lose(
			input [1:0] result,
			output reg [23:0] vga_color
			);


			
always @(*) begin
	vga_color = 24'h000000;
	if (result == 2'd1) begin
		vga_color = 24'h27F52A;
	end
	else if (result == 2'd2)
		vga_color = 24'h820C0C;
end
endmodule
			