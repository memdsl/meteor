`include "../../../base/cfg.sv"

module exu #(
    parameter DATA_WIDTH = `DATA_WIDTH
) (
    input  logic                       i_ready,
    output logic                       o_valid,

    input  logic [`ARGS_WIDTH - 1 : 0] i_alu_type,
    input  logic [ DATA_WIDTH - 1 : 0] i_rs1_data,
    input  logic [ DATA_WIDTH - 1 : 0] i_rs2_data,
    output logic [ DATA_WIDTH - 1 : 0] o_alu_res,
    output logic                       o_alu_zero,
    output logic                       o_alu_over,
    output logic                       o_alu_nega
);

    assign o_valid = 1'h1;

    logic [DATA_WIDTH - 1 : 0] w_alu_res;
    logic                      w_alu_zero;
    logic                      w_alu_over;
    logic                      w_alu_nega;

    alu #(
        .DATA_WIDTH(DATA_WIDTH)
    ) alu_inst(
        .i_type    (i_alu_type),
        .i_rs1_data(i_rs1_data),
        .i_rs2_data(i_rs2_data),
        .o_res     (w_alu_res),
        .o_zero    (w_alu_zero),
        .o_over    (w_alu_over),
        .o_nega    (w_alu_nega)
    );

    assign o_alu_res  = (o_valid && i_ready) ? w_alu_res  : {DATA_WIDTH{1'h0}};
    assign o_alu_zero = (o_valid && i_ready) ? w_alu_zero : 1'h0;
    assign o_alu_over = (o_valid && i_ready) ? w_alu_over : 1'h0;
    assign o_alu_naga = (o_valid && i_ready) ? w_alu_nega : 1'h0;

endmodule
