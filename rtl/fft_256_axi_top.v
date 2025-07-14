// AXIS接口的蝶形FFT算法IP
module fft_256_axi_top (
    input          clk,
    input          rst_n,
    // AXI4-Stream Slave Interface
    input          s_axis_tvalid,
    output reg     s_axis_tready,
    input   [63:0] s_axis_tdata,
    input          s_axis_tlast,
    // AXI4-Stream Master Interface
    output         m_axis_tvalid,
    input          m_axis_tready,
    output  [63:0] m_axis_tdata,
    output         m_axis_tlast
);

    // FFT Control States
    typedef enum {
        IDLE,
        LOAD,
        CALC,
        UNLOAD
    } state_t;
    
    state_t current_state, next_state;

    // ctrl signal
    wire        load_start,calc_start,unload_start,bfly_valid;
    wire        load_done, calc_done, unload_done;

    // data 
    wire [63:0] twiddle_data;
    
    // Address
    wire [7:0]  idx1, idx2;
    wire [7:0]  twiddle_addr;
    
    // --------------------------
    // Control State Machine
    // --------------------------
    always@(posedge clk or negedge rst_n) begin
        if (!rst_n) current_state <= IDLE;
        else current_state <= next_state;
    end

    always@(*)begin
        next_state = current_state;
        case (current_state)
            IDLE:   if (s_axis_tvalid) next_state = LOAD;
            LOAD:   if (load_done)      next_state = CALC;
            CALC:   if (calc_done)      next_state = UNLOAD;
            UNLOAD: if (unload_done)    next_state = IDLE;
        endcase
    end

    always@(*)begin
        case (current_state)
            LOAD:    load_start = 1'b1;
            CALC:    calc_start = 1'b1;
            UNLOAD:  unload_start = 1'b1;
        endcase
    end
    
    // --------------------------
    // input_crtl 
    // --------------------------
    input_crtl  u_input_crtl (
    .clk                     ( clk             ),
    .rst_n                   ( rst_n           ),
    .s_axis_tvalid           ( s_axis_tvalid   ),
    .s_axis_tdata            ( s_axis_tdata    ),
    .s_axis_tlast            ( s_axis_tlast    ),
    .s_axis_tready           ( s_axis_tready   ),

    .load_start              ( load_start      ),
    .load_done               ( load_done       ),
    .out_x1_addr             ( idx1            ),
    .out_x2_addr             ( idx2            ),

    .out_x1                  ( in_x1           ),
    .out_x2                  ( in_x2           )
);
    
    // --------------------------
    // addr_ctrl
    // --------------------------
    addr_ctrl #(
        .N ( 256 ))
    u_addr_ctrl (
        .clk                     ( clk          ),
        .rst_n                   ( rst_n        ),
        .calc_start              ( calc_start   ),
        .bfly_valid              ( bfly_valid   ),
        .CALC_done               ( calc_done    ),

        .idx1                    ( idx1         ),
        .idx2                    ( idx2         ),
        .twiddle_addr            ( twiddle_addr )
    );

    // --------------------------
    // Butterfly Unit
    // --------------------------
    butterfly_unit  u_butterfly_unit (
    .clk                     ( clk          ),
    .rst_n                   ( rst_n        ),
    .calc_start              ( calc_start   ),
    .idx1                    ( idx1         ),
    .idx2                    ( idx2         ),
    .in_x1                   ( in_x1        ),
    .in_x2                   ( in_x2        ),
    .twiddle                 ( twiddle_data ),

    .out_x1_reg              ( out_x1       ),
    .out_x2_reg              ( out_x2       ),
    .out_idx1                ( out_idx1     ),
    .out_idx2                ( out_idx2     ),
    .out_valid               ( bfly_valid   )
);

output_crtl  u_output_crtl (
    .clk                     ( clk             ),
    .rst_n                   ( rst_n           ),
    .out_x1                  ( out_x1          ),
    .out_x2                  ( out_x2          ),
    .out_idx1                ( out_idx1        ),
    .out_idx2                ( out_idx2        ),
    .calc_start              ( calc_start      ),
    .in_valid                ( bfly_valid      ),
    .unload_start            ( unload_start    ),
    .unload_done             ( unload_done     ),

    .m_axis_tready           ( m_axis_tready   ),
    .m_axis_tvalid           ( m_axis_tvalid   ),
    .m_axis_tdata            ( m_axis_tdata    ),
    .m_axis_tlast            ( m_axis_tlast    )
);
    // --------------------------
    // Twiddle Factor ROM
    // --------------------------
    twiddle_rom tw_rom (
        .clk(clk),
        .addr(twiddle_addr),
        .data(twiddle_data)
    );

endmodule