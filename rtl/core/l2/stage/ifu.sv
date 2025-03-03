module ifu(
    input  logic                       i_sys_clk,
    input  logic                       i_sys_rst_n,


    input  logic                       i_wbu_valid,
    output logic                       o_ifu_ready,
    input  logic                       i_idu_ready,
    output logic                       o_ifu_valid,

    input  logic                       i_exu_jmp_en,
    input  logic [`ADDR_WIDTH - 1 : 0] i_exu_jmp_pc,
    output logic [`ADDR_WIDTH - 1 : 0] o_ifu_pc,
    output logic [`ADDR_WIDTH - 1 : 0] o_ifu_pc_next
);


    localparam S_IDLE = 0;
    localparam S_WAIT = 1;

    logic s_1;
    logic s_1_next;

    always_ff @(posedge i_sys_clk) begin
        if (!i_sys_rst_n) begin
            s_1 <= S_IDLE;
        end
        else begin
            s_1 <= s_1_next;
        end
    end

    always_comb begin
        case (s_1)
            S_IDLE:  s_1_next = o_ifu_valid ? S_WAIT : S_IDLE;
            S_WAIT:  s_1_next = i_idu_ready ? S_IDLE : S_WAIT;
            default: s_1_next = S_IDLE;
        endcase
    end

    assign o_ifu_valid = i_wbu_valid && ;
    assign o_ifu_ready = (s_1 == S_IDLE) ? 1'b1 : 1'b0;









    logic [`ADDR_WIDTH - 1 : 0] r_ifu_pc;
    logic [`ADDR_WIDTH - 1 : 0] w_ifu_pc_next;

    always_ff @(posedge i_sys_clk) begin
        if (!i_sys_rst_n) begin
            r_ifu_pc <= `ADDR_INIT;
        end
        else if (i_wbu_valid && o_ifu_ready) begin
            r_ifu_pc <= w_ifu_pc_next;
        end
        else begin
            r_ifu_pc <= r_ifu_pc;
        end
    end

    assign w_ifu_pc_next = i_exu_jmp_en ? i_exu_jmp_pc : (r_ifu_pc + 32'h4);

    assign o_ifu_pc      = r_ifu_pc;
    assign o_ifu_pc_next = w_ifu_pc_next;

endmodule
