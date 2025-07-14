module dual_port_ram #(
    parameter WIDTH = 64,
    parameter DEPTH = 256
)(
    input                  clk,
    input   [$clog2(DEPTH)-1:0] addr_a,
    input   [$clog2(DEPTH)-1:0] addr_b,
    input   [WIDTH-1:0]    din_a,
    input   [WIDTH-1:0]    din_b,
    input                  we_a,
    input                  we_b,
    output reg [WIDTH-1:0]    dout_a,
    output reg [WIDTH-1:0]    dout_b
);

    logic [WIDTH-1:0] mem [0:DEPTH-1];

    // Port A
    always@(posedge clk) begin
        if (we_a) mem[addr_a] <= din_a;
        dout_a <= mem[addr_a];
    end

    // Port B
    always@(posedge clk) begin
        if (we_b) mem[addr_b] <= din_b;
        dout_b <= mem[addr_b];
    end

endmodule