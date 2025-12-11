wire [7:0] mine_wr_addr;
wire       mine_wr_data;
wire       mine_wr_en;
wire       mine_q;

//I'm connecting this to mines_placer outputs
assign mine_wr_addr = mine_mem_addr;  
assign mine_wr_data = mine_mem_in;
assign mine_wr_en   = mine_mem_wren;


mine_mem mine_mem_inst (
    .address ( mine_wr_addr ),   
    .clock   ( clk ),            
    .data    ( mine_wr_data ),   
    .wren    ( mine_wr_en ),     
    .q       ( mine_q )          
);