module ifu(
    input  logic                       i_sys_clk,
    input  logic                       i_sys_rst_n,

    input  logic                       i_wbu_valid,
    output logic                       o_ifu_ready,
    input  logic                       i_i2i_ready,
    output logic                       o_ifu_valid,

    input  logic                       i_exu_jmp_en,
    input  logic [`ADDR_WIDTH - 1 : 0] i_exu_jmp_pc,
    output logic [`ADDR_WIDTH - 1 : 0] o_ifu_pc,
    output logic [`ADDR_WIDTH - 1 : 0] o_ifu_pc_next
);

    assign o_ifu_ready = 1'b1;
    assign o_ifu_valid = 1'b1;

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
