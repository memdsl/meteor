module exu(
    input  logic                       i_sys_ready,
    output logic                       o_sys_valid,

    input  logic [`ADDR_WIDTH - 1 : 0] i_idu_pc,

    input  logic [`ARGS_WIDTH - 1 : 0] i_idu_ctr_alu_type,
    input  logic [`DATA_WIDTH - 1 : 0] i_idu_rs1_data,
    input  logic [`DATA_WIDTH - 1 : 0] i_idu_rs2_data,
    output logic [`DATA_WIDTH - 1 : 0] o_exu_res,

    input  logic [`ARGS_WIDTH - 1 : 0] i_idu_ctr_jmp_type,
    input  logic [`DATA_WIDTH - 1 : 0] i_idu_jmp_or_reg_data,
    output logic                       o_exu_jmp_en,
    output logic [`ADDR_WIDTH - 1 : 0] o_exu_jmp_pc,

    input  logic [`ARGS_WIDTH - 1 : 0] i_idu_ctr_inst_type,
    output logic                       o_exu_pc_en
);

    assign o_sys_valid = 1'b1;

    logic [`DATA_WIDTH - 1 : 0] w_exu_res;

    alu u_alu(
        .i_alu_type    (i_idu_ctr_alu_type),
        .i_alu_rs1_data(i_idu_rs1_data    ),
        .i_alu_rs2_data(i_idu_rs2_data    ),
        .o_alu_res     (w_exu_res         )
    );

    assign o_exu_res  = (o_sys_valid && i_sys_ready) ? w_exu_res : `DATA_ZERO;

    always_comb begin
        case (i_idu_ctr_jmp_type)
            `JMP_J: begin
                o_exu_jmp_en = 1'b1;
                o_exu_jmp_pc = o_exu_res;
            end
            `JMP_B: begin
                if (o_exu_res === 32'h1) begin
                    o_exu_jmp_en = 1'b1;
                    o_exu_jmp_pc = i_idu_pc + i_idu_jmp_or_reg_data;
                end
                else begin
                    o_exu_jmp_en =  1'b0;
                    o_exu_jmp_pc = 32'h0;
                end
            end
            `JMP_E: begin
                o_exu_jmp_en =  1'b1;
                o_exu_jmp_pc = 32'h0;
            end
            default: begin
                o_exu_jmp_en =  1'b0;
                o_exu_jmp_pc = 32'h0;
            end
        endcase
    end

    assign o_exu_pc_en = (i_idu_ctr_inst_type == `INST_TYPE_BRH) : 1'b0 : 1'h0;

endmodule
