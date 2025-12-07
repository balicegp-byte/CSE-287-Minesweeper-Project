module mine_lfsr(
	input clk,
	input rst,
	input [15:0] random_seed,        //starts system
	input new_random_seed,           //Goes high -> records seed
	input random_number_output,      //records number, won't change when low
	output reg [15:0] random_number
);
	
	reg [127:0] lfsr; //Linear Feedback register
	
	//Design
	always @(posedge clk or negedge rst)
	begin
		if (rst == 1'b0)
		begin
			random_number <= 16'd0;
			lfsr <= 128'd42;
		end
		else
		begin
			if (new_random_seed == 1'b1)
			begin
				lfsr <= { random_seed,
						  random_seed,
						  random_seed,
						  random_seed,
						  random_seed,
						  random_seed,
						  random_seed,
						  random_seed };
			end
			else
			begin
				if (random_number_output == 1'b1)
				begin
					random_number <= lfsr[63:48]; //picked arbitrary sequence
				end
				else
				begin
					lfsr <= {
						lfsr[126:96],
						(lfsr[0] ^ lfsr[62] ^ lfsr[120] ^ lfsr[2]),
						lfsr[62:32],
						(lfsr[3] ^ lfsr[30] ^ lfsr[111] ^ lfsr[93]),
						lfsr[30:0],
						(lfsr[7] ^ lfsr[127] ^ lfsr[112] ^ lfsr[92])
					};
				end
			end
		end
	end
	
endmodule