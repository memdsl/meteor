module ifu_to_idu(
    input  logic                       i_sys_clk,
    input  logic                       i_sys_rst_n,
    input  logic                       i_sys_ready,
    output logic                       o_sys_valid,

    input  logic [`ADDR_WIDTH - 1 : 0] i_ifu_pc,
    input  logic [`ADDR_WIDTH - 1 : 0] i_ifu_pc_next,
    output logic [`ADDR_WIDTH - 1 : 0] o_ifu_pc,
    output logic [`ADDR_WIDTH - 1 : 0] o_ifu_pc_next
);

    logic [`ADDR_WIDTH - 1 : 0] r_ifu_pc;
    logic [`ADDR_WIDTH - 1 : 0] r_ifu_pc_next;

    always_ff @(i_sys_clk) begin
        if (!i_sys_rst_n) begin
            r_ifu_pc      <= `ADDR_INIT;
            r_ifu_pc_next <= `ADDR_INIT;
        end
        else begin
            r_ifu_pc      <= i_ifu_pc;
            r_ifu_pc_next <= i_ifu_pc_next;
        end
    end

    assign o_ifu_pc      = r_ifu_pc;
    assign o_ifu_pc_next = r_ifu_pc_next;

endmodule
