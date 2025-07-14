//功能：进行蝶形计算
module butterfly_unit (
    input          clk,
    input          rst_n,
    input          calc_start,
    input   [7:0]  idx1,       // {imag, real} Q24.8
    input   [7:0]  idx2,       // {imag, real} Q24.8
    input   [63:0] in_x1,       // {imag, real} Q24.8
    input   [63:0] in_x2,       // {imag, real} Q24.8
    input   [63:0] twiddle,     // {imag, real} Q24.8
    output reg  [63:0] out_x1_reg,      // {imag, real} Q24.8
    output reg  [63:0] out_x2_reg,      // {imag, real} Q24.8
    output      [7:0]  out_idx1,       // {imag, real} Q24.8
    output      [7:0]  out_idx2,       // {imag, real} Q24.8
    output             out_valid
);

    // Stage registers
    reg  [63:0] in_x1_reg, in_x2_reg, twiddle_reg;
    wire [31:0] real_x1, imag_x1, real_x2, imag_x2;
    wire [31:0] real_w, imag_w;
    
    // Pipeline registers
    wire [63:0] mult_real, mult_imag;
    reg  [63:0] mult_real_reg, mult_imag_reg;
    wire [31:0] wb_real, wb_imag;
    wire [31:0] wb_real, wb_imag;
    reg  [2:0]  valid_pipe;
    reg  [23:0] idx1_pipe;
    reg  [23:0] idx2_pipe;

    // Input decomposition
    assign real_x1 = in_a_reg[63:32];
    assign imag_x1 = in_a_reg[31:0];
    assign real_x2 = in_b_reg[63:32]; 
    assign imag_x2 = in_b_reg[31:0];
    assign real_w = twiddle_reg[63:32];
    assign imag_w = twiddle_reg[31:0];

    // Complex multiplication: (real_b + j*imag_b) * (real_w + j*imag_w)
    // real = real_b*real_w - imag_b*imag_w
    // imag = real_b*imag_w + imag_b*real_w
    assign mult_real = (real_x2 * real_w) - (imag_x2 * imag_w);
    assign mult_imag = (real_x2 * imag_w) + (imag_x2 * real_w);
    
    // Truncate to Q24.8 format (take middle 32 bits)
    assign wb_real = mult_real_reg[39:8];
    assign wb_imag = mult_imag_reg[39:8];

    // Butterfly operations
    // X = A + WB
    // Y = A - WB
    assign out_x1 = {imag_a + wb_imag, real_a + wb_real};
    assign out_x2 = {imag_a - wb_imag, real_a - wb_real};

    // Pipeline control
    always@(posedge clk or negedge rst_n) begin
        if (!rst_n) begin
            in_x1_reg      <= 0;
            in_x2_reg      <= 0;
            twiddle_reg   <= 0;
            mult_real_reg <= 0;
            mult_imag_reg <= 0;
            out_x1_reg     <= 0;
            out_x2_reg     <= 0;
            valid_pipe    <= 0;
        end
        else begin
            // Stage 0: Register inputs
            if (calc_start) begin
                in_x1_reg    <= in_x1;
                in_x2_reg    <= in_x1;
                twiddle_reg <= twiddle;
            end
            
            // Stage 1: Register multiplication results
            mult_real_reg <= mult_real;
            mult_imag_reg <= mult_imag;
            
            // Stage 2: Register final outputs
            out_x1_reg <= out_x1;
            out_x2_reg <= out_x2;
            
            // Valid signal pipeline
            valid_pipe <= {valid_pipe[1:0], start};

            // idx1 and idx2 signal pipeline
            idx1_pipe <= {idx1_pipe[15:0], idx1};
            idx2_pipe <= {idx2_pipe[15:0], idx2};
        end
    end

    assign out_valid = valid_pipe[2];
    assign out_idx1 = idx1_pipe[23:16];
    assign out_idx2 = idx2_pipe[23:16];

endmodule