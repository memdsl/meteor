`include "../../../base/cfg.sv"

module exu #(
    parameter DATA_WIDTH = `DATA_WIDTH
) (
    input  logic                       i_sys_ready,
    output logic                       o_sys_valid,

    input  logic [`ADDR_WIDTH - 1 : 0] i_ifu_pc,

    input  logic [`ARGS_WIDTH - 1 : 0] i_alu_type,
    input  logic [ DATA_WIDTH - 1 : 0] i_alu_rs1_data,
    input  logic [ DATA_WIDTH - 1 : 0] i_alu_rs2_data,
    output logic [ DATA_WIDTH - 1 : 0] o_alu_res,
    output logic                       o_alu_zero,
    output logic                       o_alu_over,
    output logic                       o_alu_neg,

    input  logic [`ARGS_WIDTH - 1 : 0] i_ctr_jmp_type,
    input  logic [ DATA_WIDTH - 1 : 0] i_idu_jmp_or_gpr_data,
    output logic                       o_exu_jmp_en,
    output logic [`ADDR_WIDTH - 1 : 0] o_exu_jmp_pc
);

    assign o_sys_valid = 1'h1;

    logic [DATA_WIDTH - 1 : 0] w_alu_res;
    logic                      w_alu_zero;
    logic                      w_alu_over;
    logic                      w_alu_neg;

    alu #(
        .DATA_WIDTH(DATA_WIDTH)
    ) u_alu(
        .i_alu_type    (i_alu_type),
        .i_alu_rs1_data(i_alu_rs1_data),
        .i_alu_rs2_data(i_alu_rs2_data),
        .o_alu_res     (w_alu_res),
        .o_alu_zero    (w_alu_zero),
        .o_alu_over    (w_alu_over),
        .o_alu_neg     (w_alu_neg)
    );

    assign o_alu_res  = (o_sys_valid && i_sys_ready) ? w_alu_res  : {DATA_WIDTH{1'h0}};
    assign o_alu_zero = (o_sys_valid && i_sys_ready) ? w_alu_zero : 1'h0;
    assign o_alu_over = (o_sys_valid && i_sys_ready) ? w_alu_over : 1'h0;
    assign o_alu_neg  = (o_sys_valid && i_sys_ready) ? w_alu_neg  : 1'h0;

    always_comb begin
        case (i_ctr_jmp_type)
            `JMP_J: begin
                o_exu_jmp_en = 1'h1;
                o_exu_jmp_pc = o_alu_res;
            end
            `JMP_B: begin
                if (o_alu_res === 32'h1) begin
                    o_exu_jmp_en = 1'h1;
                    o_exu_jmp_pc = i_ifu_pc + i_idu_jmp_or_gpr_data;
                end
                else begin
                    o_exu_jmp_en =  1'h0;
                    o_exu_jmp_pc = 32'h0;
                end
            end
            `JMP_E: begin
                o_exu_jmp_en =  1'h1;
                o_exu_jmp_pc = 32'h0;
            end
            default: begin
                o_exu_jmp_en =  1'h0;
                o_exu_jmp_pc = 32'h0;
            end
        endcase
    end

endmodule
