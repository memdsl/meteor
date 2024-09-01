`include "./cfg.sv"

module GPR #(
    parameter DATA_WIDTH = `DATA_WIDTH
) (
    input  logic                       i_sys_clk,
    input  logic                       i_sys_rst_n,

    input  logic [`GPRS_WIDTH - 1 : 0] i_gpr_rd_rs1_id,
    input  logic [`GPRS_WIDTH - 1 : 0] i_gpr_rd_rs2_id,
    input  logic [`GPRS_WIDTH - 1 : 0] i_gpr_rd_end_id,
    output logic [ DATA_WIDTH - 1 : 0] o_gpr_rd_rs1_data,
    output logic [ DATA_WIDTH - 1 : 0] o_gpr_rd_rs2_data,
    output logic [ DATA_WIDTH - 1 : 0] o_gpr_rd_end_data,

    input  logic                       i_gpr_wr_en,
    input  logic [`GPRS_WIDTH - 1 : 0] i_gpr_wr_id,
    input  logic [ DATA_WIDTH - 1 : 0] i_gpr_wr_data
);

    logic [DATA_WIDTH - 1 : 0] r_gpr[31 : 0];

    assign o_gpr_rd_rs1_data = r_gpr[i_gpr_rd_rs1_id];
    assign o_gpr_rd_rs2_data = r_gpr[i_gpr_rd_rs2_id];
    assign o_gpr_rd_end_data = r_gpr[i_gpr_rd_end_id];

    always_ff @(posedge i_sys_clk) begin
        if (i_sys_rst_n) begin
            for (int i = 0; i < 32; i++) begin
                r_gpr[i] = 32'h0;
            end
        end
        else begin
            if (i_gpr_wr_en && i_gpr_wr_id !== 5'h0) begin
                r_gpr[i_gpr_wr_id] <= i_gpr_wr_data;
            end
            else begin
                r_gpr[i_gpr_wr_id] <=  r_gpr[i_gpr_wr_id];
            end
        end
    end

endmodule
