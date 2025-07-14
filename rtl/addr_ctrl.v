module addr_ctrl#(
    parameter N = 256
)(
    input          clk,
    input          rst_n,

    // state ctrl signal
    input  calc_start,
    input  bfly_valid,
    output calc_done,

    // output idx1 and idx2
    output  [7:0]  idx1, 
    output  [7:0]  idx2,
    output  [7:0]  twiddle_addr

);

reg [2:0]  stage;
reg [7:0]  group_idx;
reg [7:0]  bfly_idx;

// ctrl signal
assign calc_done = (stage = 7) && (group_idx == (N - 1)) && (bfly_idx == (1<<stage-1)-1);

// Address Generation
assign idx1 = group_idx + bfly_idx;
assign idx2 = group_idx + bfly_idx + 1<<(stage-1);
assign twiddle_addr = bfly_idx >> stage;

// Calculation Control
always@(posedge clk or negedge rst_n) begin
    if (!rst_n) begin
        stage     <= 0;
        group_idx <= 0;
        bfly_idx  <= 0;
    end
    else if (calc_start) begin
        if (bfly_valid) begin
            if (bfly_idx == (1<<stage-1)-1 ) begin
                bfly_idx <= 0;
                if (group_idx == (N - 1))
                    group_idx <= 0;
                else
                    group_idx <= group_idx + (1<<stage);
                
                if (group_idx == (N - 1) && bfly_idx == (1<<stage-1)-1) begin
                    stage <= stage + 1;
                end
            end
            else begin
                bfly_idx <= bfly_idx + 1;
            end
        end
    end
    else begin
        stage     <= 0;
        group_idx <= 0;
        bfly_idx  <= 0;
    end
end


endmodule