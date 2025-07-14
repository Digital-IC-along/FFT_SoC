module twiddle_rom (
    input          clk,
    input   [7:0]  addr,
    output  [63:0] data
);

    reg [63:0] rom[0:255];

    // Initialize ROM with precomputed twiddle factors
    initial begin
        for (int n = 0; n < 256; n++) begin
            real theta = -2.0 * 3.141592653589793 * n / 256.0;
            real real_part = $cos(theta);
            real imag_part = $sin(theta);
            // Convert to Q24.8 format
            rom[n] = {
                $shortrealtobits(real_part),  // Real part
                $shortrealtobits(imag_part)   // Imaginary part
            };
        end
    end

    always@(posedge clk) begin
        data <= rom[addr];
    end

endmodule