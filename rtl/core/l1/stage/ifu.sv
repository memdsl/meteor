`include "cfg.sv"

module ifu(
    input  logic                       i_sys_clk,
    input  logic                       i_sys_rst_n,
    input  logic                       i_sys_ready,
    output logic                       o_sys_valid,

    input  logic                       i_exu_jmp_en,
    input  logic [`ADDR_WIDTH - 1 : 0] i_exu_jmp_pc,
    output logic [`ADDR_WIDTH - 1 : 0] o_ifu_pc,
    output logic [`ADDR_WIDTH - 1 : 0] o_ifu_pc_next
);

    assign o_sys_valid = 1'h1;

    logic [`ADDR_WIDTH - 1 : 0] r_ifu_pc;
    logic [`ADDR_WIDTH - 1 : 0] w_ifu_pc_next;

    reg_sync_en #(
        .DATA_WIDTH(32),
        .RSTN_VALUE(`ADDR_INIT)
    ) u_reg_sync_en(
        .i_clk  (i_sys_clk),
        .i_rst_n(i_sys_rst_n),
        .i_en   (i_sys_ready && o_sys_valid),
        .i_data (w_ifu_pc_next),
        .o_data (r_ifu_pc)
    );

    assign w_ifu_pc_next = i_exu_jmp_en ? i_exu_jmp_pc : (r_ifu_pc + 32'h4);

    assign o_ifu_pc      = r_ifu_pc;
    assign o_ifu_pc_next = w_ifu_pc_next;

endmodule
