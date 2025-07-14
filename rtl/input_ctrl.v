//功能：缓存AXIS传入的数据，将其位反转重排后输出
module input_crtl (
    input          clk,
    input          rst_n,
    // AXI4-Stream Slave Interface
    input          s_axis_tvalid,
    input  [63:0]  s_axis_tdata,
    input          s_axis_tlast,
    output reg     s_axis_tready,

    // state ctrl signal
    input  load_start;
    output load_done;

    // bit_reverse output
    input [7:0]    in_x1_addr,
    input [7:0]    in_x2_addr,
    output   [63:0] out_x1,       // {imag, real} Q24.8
    output   [63:0] out_x2       // {imag, real} Q24.8
);

// counter registers
reg [7:0]  data_counter;

assign load_done = (data_counter == 255) && s_axis_tvalid && s_axis_tready;

// Input Counter
always @(posedge clk or negedge rst_n) begin
    if (!rst_n) data_counter <= 0;
    else if (load_start && s_axis_tvalid && s_axis_tready)
        data_counter <= (data_counter == 255) ? 0 : data_counter + 1;
end

// Input Data Path
always@(*)begin
    ram_wr_addr_x1 = bit_reverse(data_counter); // Bit-reversed addressing
    ram_wr_addr_x2 = 0;
    ram_wr_data_x1 = s_axis_tdata;
    ram_wr_data_x2 = 0;
    ram_wr_en_x1   = load_start && s_axis_tvalid && s_axis_tready;
    ram_wr_en_x2   = 0;;
end

// --------------------------
// Memory Interface
// --------------------------
// Data RAM (256x64-bit)
dual_port_ram #(
    .WIDTH(64),
    .DEPTH(256)
) data_ram (
    .clk(clk),
    .addr_a(ram_wr_en_x1 ? ram_wr_addr_x1 : in_x1_addr),
    .addr_b(ram_wr_en_x2 ? ram_wr_addr_x2 : in_x2_addr),
    .din_a(ram_wr_addr_x1),
    .din_b(ram_wr_addr_x2),
    .we_a(ram_wr_en_x1),
    .we_b(ram_wr_en_x2),
    .dout_a(out_x1),
    .dout_b(out_x2)
);

// --------------------------
// Helper Functions
// --------------------------
// Bit-reversal function
function automatic [7:0] bit_reverse(input [7:0] in);
bit_reverse = {in[0], in[1], in[2], in[3], in[4], in[5], in[6], in[7]};
endfunction

endmodule