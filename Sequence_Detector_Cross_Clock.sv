
//FSM With Multiple Clock Domains
//Design a Synchronizer and FSM to detect 1011 on an asynchronous input signal async_in.

module sequence_detector_cross_clk(
  input clk_ext,
  input clk_sys,
  input async_in,
  input reset,
  output reg detected
);
  reg sync_ff1,sync_ff2;
  
  always @(posedge clk_sys or negedge reset) begin
    if(reset) begin
      sync_ff1<=0;
      sync_ff2<=0;
    end else begin
      sync_ff1<=async_in;
      sync_ff2<=sync_ff1;
    end  
  end
  
  wire sync_in=sync_ff2;
  
    parameter S0 = 3'b000;
    parameter S1 = 3'b001;
    parameter S2 = 3'b010;
    parameter S3 = 3'b011;
    parameter S4 = 3'b100;

    reg [2:0] state, next_state;

    // State register
  always @(posedge clk_sys or posedge reset) begin
        if (!reset)
            state <= S0;
        else
            state <= next_state;
    end

    // Next-state logic
    always @(*) begin
        case (state)
          S0: next_state = (sync_in == 1) ? S1 : S0;
          S1: next_state = (sync_in == 0) ? S2 : S1;
          S2: next_state = (sync_in == 1) ? S3 : S0;
          S3: next_state = (sync_in == 1) ? S4 : S2;
          S4: next_state = (sync_in == 1) ? S1 : S2;
            default: next_state = S0;
        endcase
    end

    // Output logic (Moore)
  always @(posedge clk_sys or negedge reset) begin
    if (!reset)
            detected<=0;
        else
          detected<= (state==S4);
    end

endmodule
