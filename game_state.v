module game_state(
    input        clk,
    input        rst,
    input        go,
    output reg   done
);

    reg [3:0] S;
    reg [3:0] NS;

    // Variables that you might need later
    reg [1:0] cond;
    reg       play_again;
    // Add more variables as you need them

    parameter START = 3'd0,
              INIT  = 3'd1,
              IDLE  = 3'd2,
              PLAY  = 3'd3,
              WIN   = 3'd4,
              LOSE  = 3'd5,
              ERROR = 3'd6;

    // FSM state register
    always @(posedge clk or negedge rst) begin
        if (rst == 1'b0) begin
            S <= START;
        end else begin
            S <= NS;
        end
    end

    // State transitions (next-state logic)
    always @(*) begin
        NS = S;  // default: stay in same state
        case (S)
            START: NS = INIT;

            INIT:  NS = IDLE;

            IDLE:  NS = PLAY;

            PLAY: begin
                if (cond == 2'b01)
                    NS = WIN;
                else if (cond == 2'b11)
                    NS = LOSE;
                else
                    NS = PLAY;
            end

            LOSE: begin
                if (play_again == 1'b1)
                    NS = START;
                else
                    NS = LOSE;
            end

            WIN: begin
                if (play_again == 1'b1)
                    NS = START;
                else
                    NS = WIN;   // just stay in WIN for now
            end

            default: NS = ERROR;
        endcase
    end

    // Simple placeholder for 'done' so it has a defined value
    always @(*) begin
        done = (S == WIN) || (S == LOSE);
    end

endmodule
			
			
			
			
			
			
			
			
			
			
			