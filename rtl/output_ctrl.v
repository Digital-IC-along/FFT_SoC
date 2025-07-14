//功能：将计算后的FFT结果以AXIS接口输出
module output_crtl (
    input          clk,
    input          rst_n,
    // Calculated result and address
    input   [63:0] out_x1,      // {imag, real} Q24.8
    input   [63:0] out_x2,      // {imag, real} Q24.8
    input   [7:0] out_idx1,       // {imag, real} Q24.8
    input   [7:0] out_idx2,       // {imag, real} Q24.8

    // state ctrl signal
    input  calc_start,
    input  in_valid,
    input  unload_start,
    output unload_done,

    // AXI4-Stream Master Interface
    input              m_axis_tready,
    output reg         m_axis_tvalid,
    output reg [63:0]  m_axis_tdata,
    output reg         m_axis_tlast
);

// counter registers
reg  [7:0]   data_counter;
wire [63:0]  tdata;

// ctrl signal
assign en = calc_start && in_valid;
assign load_done = (data_counter == 255) && m_axis_tvalid && m_axis_tready;

// output Counter
always @(posedge clk or negedge rst_n) begin
    if (!rst_n) data_counter <= 0;
    else if (m_axis_tvalid && m_axis_tready)
        data_counter <= (data_counter == 255) ? 0 : data_counter + 1;
end

// AXIS OUT
always @(posedge clk or negedge rst_n) begin
    if(!rst_n) begin
        m_axis_tdata <= 0;
        m_axis_tvalid <= 0;
    end
    else if(unload_start) begin
        m_axis_tdata <= tdata;
        m_axis_tvalid <= 1;
    end
    else if(unload_done)begin
        m_axis_tdata <= 0;
        m_axis_tvalid <= 0;
    end
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
    .addr_a(en?out_idx1:data_counter),
    .addr_b(out_idx2),
    .din_a(out_x1),
    .din_b(out_x2),
    .we_a(en),
    .we_b(en),
    .dout_a(tdata),
    .dout_b()
);

endmodule