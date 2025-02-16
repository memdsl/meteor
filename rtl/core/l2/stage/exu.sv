module exu(
    input  logic                       i_i2e_valid,
    output logic                       o_exu_ready,
    input  logic                       i_e2l_ready,
    output logic                       o_exu_valid,

    input  logic [`ADDR_WIDTH - 1 : 0] i_i2e_pc,
    output logic [`ADDR_WIDTH - 1 : 0] o_exu_pc,

    input  logic                       i_i2e_ctr_reg_wr_en,
    input  logic [`ARGS_WIDTH - 1 : 0] i_i2e_ctr_reg_wr_src,
    input  logic [`GPRS_WIDTH - 1 : 0] i_i2e_gpr_rd_id,
    output logic                       o_exu_ctr_reg_wr_en,
    output logic [`ARGS_WIDTH - 1 : 0] o_exu_ctr_reg_wr_src,
    output logic [`GPRS_WIDTH - 1 : 0] o_exu_gpr_rd_id,

    input  logic [`ARGS_WIDTH - 1 : 0] i_i2e_ctr_inst_type,
    input  logic [`ARGS_WIDTH - 1 : 0] i_i2e_ctr_ram_byt,
    input  logic                       i_i2e_ctr_ram_wr_en,
    output logic [`ARGS_WIDTH - 1 : 0] o_exu_ctr_inst_type,
    output logic [`ARGS_WIDTH - 1 : 0] o_exu_ctr_ram_byt,
    output logic                       o_exu_ctr_ram_wr_en,

    input  logic [`ARGS_WIDTH - 1 : 0] i_i2e_ctr_alu_type,
    input  logic [`DATA_WIDTH - 1 : 0] i_i2e_rs1_data,
    input  logic [`DATA_WIDTH - 1 : 0] i_i2e_rs2_data,
    output logic [`DATA_WIDTH - 1 : 0] o_exu_res,
    output logic [`DATA_WIDTH - 1 : 0] o_exu_rs2_data,

    input  logic [`ARGS_WIDTH - 1 : 0] i_i2e_ctr_jmp_type,
    input  logic [`DATA_WIDTH - 1 : 0] i_i2e_jmp_or_reg_data,
    output logic                       o_exu_jmp_en,
    output logic [`ADDR_WIDTH - 1 : 0] o_exu_jmp_pc,

    output logic                       o_exu_pc_en
);

    assign o_exu_ready = 1'b1;
    assign o_exu_valid = 1'b1;

    assign o_exu_pc = (i_i2e_valid && o_exu_ready) ? i_i2e_pc : `ADDR_ZERO;

    assign o_exu_ctr_reg_wr_en  = (i_i2e_valid && o_exu_ready) ? i_i2e_ctr_reg_wr_en  : 1'b0;
    assign o_exu_ctr_reg_wr_src = (i_i2e_valid && o_exu_ready) ? i_i2e_ctr_reg_wr_src : `REG_WR_SRC_X;
    assign o_exu_gpr_rd_id      = (i_i2e_valid && o_exu_ready) ? i_i2e_gpr_rd_id      : `GPRS_ZERO;

    assign o_exu_ctr_inst_type = (i_i2e_valid && o_exu_ready) ? i_i2e_ctr_inst_type : `INST_TYPE_X;
    assign o_exu_ctr_ram_byt   = (i_i2e_valid && o_exu_ready) ? i_i2e_ctr_ram_byt   : `RAM_BYT_X;
    assign o_exu_ctr_ram_wr_en = (i_i2e_valid && o_exu_ready) ? i_i2e_ctr_ram_wr_en : 1'b0;

    logic [`DATA_WIDTH - 1 : 0] w_exu_res;

    alu u_alu(
        .i_alu_type    (i_i2e_ctr_alu_type),
        .i_alu_rs1_data(i_i2e_rs1_data    ),
        .i_alu_rs2_data(i_i2e_rs2_data    ),
        .o_alu_res     (w_exu_res         )
    );

    assign o_exu_res      = (i_i2e_valid && o_exu_ready) ? w_exu_res      : `DATA_ZERO;
    assign o_exu_rs2_data = (i_i2e_valid && o_exu_ready) ? i_i2e_rs2_data : `DATA_ZERO;

    always_comb begin
        if (i_i2e_valid && o_exu_ready) begin
            case (i_i2e_ctr_jmp_type)
                `JMP_J: begin
                    o_exu_jmp_en = 1'b1;
                    o_exu_jmp_pc = o_exu_res;
                end
                `JMP_B: begin
                    if (o_exu_res === 32'h1) begin
                        o_exu_jmp_en = 1'b1;
                        o_exu_jmp_pc = i_i2e_pc + i_i2e_jmp_or_reg_data;
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
        else begin
            o_exu_jmp_en =  1'b0;
            o_exu_jmp_pc = 32'h0;
        end
    end

    always_comb begin
        if (i_i2e_valid && o_exu_ready) begin
            if (i_i2e_ctr_inst_type == `INST_TYPE_BRH) begin
                o_exu_pc_en = 1'b1;
            end
            else begin
                o_exu_pc_en = 1'b0;
            end
        end
        else begin
            o_exu_pc_en = 1'b0;
        end
    end

endmodule
