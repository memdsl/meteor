module lsu(
    input  logic                           i_sys_ready,
    output logic                           o_sys_valid,

    input  logic [`ARGS_WIDTH     - 1 : 0] i_idu_ctr_ram_byt,
    input  logic [`DATA_WIDTH     - 1 : 0] i_exu_res,

    input  logic [`DATA_WIDTH     - 1 : 0] i_ram_rd_data,
    output logic                           o_lsu_ram_rd_en,
    output logic [`ADDR_WIDTH     - 1 : 0] o_lsu_ram_rd_addr,
    output logic [`DATA_WIDTH     - 1 : 0] o_lsu_gpr_wr_data,

    input  logic                           i_idu_ctr_ram_wr_en,
    input  logic [`DATA_WIDTH     - 1 : 0] i_gpr_rs2_data,
    output logic                           o_lsu_ram_wr_en,
    output logic [`ADDR_WIDTH     - 1 : 0] o_lsu_ram_wr_addr,
    output logic [`DATA_WIDTH     - 1 : 0] o_lsu_ram_wr_data,

    input  logic [`ARGS_WIDTH     - 1 : 0] i_idu_ctr_inst_type,
    output logic                           o_lsu_pc_en
);

    assign o_sys_valid = 1'b1;

    logic [`BYTE_WIDTH * 1 - 1 : 0] w_ram_rd_byt_1_0;
    logic [`BYTE_WIDTH * 1 - 1 : 0] w_ram_rd_byt_1_1;
    logic [`BYTE_WIDTH * 1 - 1 : 0] w_ram_rd_byt_1_2;
    logic [`BYTE_WIDTH * 1 - 1 : 0] w_ram_rd_byt_1_3;
    logic [`BYTE_WIDTH * 2 - 1 : 0] w_ram_rd_byt_2_0;
    logic [`BYTE_WIDTH * 2 - 1 : 0] w_ram_rd_byt_2_2;
    logic [`BYTE_WIDTH * 4 - 1 : 0] w_ram_rd_byt_4_0;

    assign w_ram_rd_byt_1_0 = i_ram_rd_data[ 7 :  0];
    assign w_ram_rd_byt_1_1 = i_ram_rd_data[15 :  8];
    assign w_ram_rd_byt_1_2 = i_ram_rd_data[23 : 16];
    assign w_ram_rd_byt_1_3 = i_ram_rd_data[31 : 24];
    assign w_ram_rd_byt_2_0 = i_ram_rd_data[15 :  0];
    assign w_ram_rd_byt_2_2 = i_ram_rd_data[31 : 16];
    assign w_ram_rd_byt_4_0 = i_ram_rd_data[31 :  0];

    assign o_lsu_ram_rd_en   = (o_sys_valid && i_sys_ready) ? 1'b1              :  1'b0;
    assign o_lsu_ram_rd_addr = (o_sys_valid && i_sys_ready) ? i_exu_res[31 : 0] : 32'h0;
    always_comb begin
        if (o_sys_valid && i_sys_ready) begin
            case (i_idu_ctr_ram_byt)
                `RAM_BYT_1_S: begin
                    case (o_lsu_ram_rd_addr[1 : 0])
                        2'b00:   o_lsu_gpr_wr_data = `SIGN_EXTEND(w_ram_rd_byt_1_0, `DATA_WIDTH);
                        2'b01:   o_lsu_gpr_wr_data = `SIGN_EXTEND(w_ram_rd_byt_1_1, `DATA_WIDTH);
                        2'b10:   o_lsu_gpr_wr_data = `SIGN_EXTEND(w_ram_rd_byt_1_2, `DATA_WIDTH);
                        2'b11:   o_lsu_gpr_wr_data = `SIGN_EXTEND(w_ram_rd_byt_1_3, `DATA_WIDTH);
                        default: o_lsu_gpr_wr_data = `SIGN_EXTEND(w_ram_rd_byt_1_0, `DATA_WIDTH);
                    endcase
                end
                `RAM_BYT_1_U: begin
                    case (o_lsu_ram_rd_addr[1 : 0])
                        2'b00:   o_lsu_gpr_wr_data = `ZERO_EXTEND(w_ram_rd_byt_1_0, `DATA_WIDTH);
                        2'b01:   o_lsu_gpr_wr_data = `ZERO_EXTEND(w_ram_rd_byt_1_1, `DATA_WIDTH);
                        2'b10:   o_lsu_gpr_wr_data = `ZERO_EXTEND(w_ram_rd_byt_1_2, `DATA_WIDTH);
                        2'b11:   o_lsu_gpr_wr_data = `ZERO_EXTEND(w_ram_rd_byt_1_3, `DATA_WIDTH);
                        default: o_lsu_gpr_wr_data = `ZERO_EXTEND(w_ram_rd_byt_1_0, `DATA_WIDTH);
                    endcase
                end
                `RAM_BYT_2_S: begin
                    case (o_lsu_ram_rd_addr[1 : 0])
                        2'b00:   o_lsu_gpr_wr_data = `SIGN_EXTEND(w_ram_rd_byt_2_0, `DATA_WIDTH);
                        2'b10:   o_lsu_gpr_wr_data = `SIGN_EXTEND(w_ram_rd_byt_2_2, `DATA_WIDTH);
                        default: o_lsu_gpr_wr_data = `SIGN_EXTEND(w_ram_rd_byt_2_0, `DATA_WIDTH);
                    endcase
                end
                `RAM_BYT_2_U: begin
                     case (o_lsu_ram_rd_addr[1 : 0])
                        2'b00:   o_lsu_gpr_wr_data = `ZERO_EXTEND(w_ram_rd_byt_2_0, `DATA_WIDTH);
                        2'b10:   o_lsu_gpr_wr_data = `ZERO_EXTEND(w_ram_rd_byt_2_2, `DATA_WIDTH);
                        default: o_lsu_gpr_wr_data = `ZERO_EXTEND(w_ram_rd_byt_2_0, `DATA_WIDTH);
                    endcase
                end
                `RAM_BYT_4_S: o_lsu_gpr_wr_data = w_ram_rd_byt_4_0;
                `RAM_BYT_4_U: o_lsu_gpr_wr_data = w_ram_rd_byt_4_0;
                default:      o_lsu_gpr_wr_data = w_ram_rd_byt_4_0;
            endcase
        end
        else begin
            o_lsu_gpr_wr_data = `DATA_ZERO;
        end
    end

    logic [`BYTE_WIDTH * 1 - 1 : 0] w_ram_wr_byt_1;
    logic [`BYTE_WIDTH * 2 - 1 : 0] w_ram_wr_byt_2;
    logic [`BYTE_WIDTH * 4 - 1 : 0] w_ram_wr_byt_4;

    assign w_ram_wr_byt_1 = i_gpr_rs2_data[ 7 : 0];
    assign w_ram_wr_byt_2 = i_gpr_rs2_data[15 : 0];
    assign w_ram_wr_byt_4 = i_gpr_rs2_data[31 : 0];

    assign o_lsu_ram_wr_en   = (o_sys_valid && i_sys_ready) ? i_idu_ctr_ram_wr_en :  1'b0;
    assign o_lsu_ram_wr_addr = (o_sys_valid && i_sys_ready) ? i_exu_res[31 : 0]   : 32'h0;
    always_comb begin
        if (o_sys_valid && i_sys_ready) begin
            case (i_idu_ctr_ram_byt)
                `RAM_BYT_1_U: begin
                    case (o_lsu_ram_wr_addr[1 : 0])
                        2'b00:   o_lsu_ram_wr_data = {i_ram_rd_data[31 :  8], w_ram_wr_byt_1};
                        2'b01:   o_lsu_ram_wr_data = {i_ram_rd_data[31 : 16], w_ram_wr_byt_1, i_ram_rd_data[ 7 : 0]};
                        2'b10:   o_lsu_ram_wr_data = {i_ram_rd_data[31 : 24], w_ram_wr_byt_1, i_ram_rd_data[15 : 0]};
                        2'b11:   o_lsu_ram_wr_data = {                        w_ram_wr_byt_1, i_ram_rd_data[23 : 0]};
                        default: o_lsu_ram_wr_data = {i_ram_rd_data[31 :  8], w_ram_wr_byt_1};
                    endcase
                end
                `RAM_BYT_2_U: begin
                    case (o_lsu_ram_wr_addr[1 : 0])
                        2'b00:   o_lsu_ram_wr_data = {i_ram_rd_data[31 : 16], w_ram_wr_byt_2};
                        2'b10:   o_lsu_ram_wr_data = {                        w_ram_wr_byt_2, i_ram_rd_data[15 : 0]};
                        default: o_lsu_ram_wr_data = {i_ram_rd_data[31 : 16], w_ram_wr_byt_2};
                    endcase
                end
                `RAM_BYT_4_U: o_lsu_ram_wr_data = w_ram_wr_byt_4;
                default:      o_lsu_ram_wr_data = w_ram_wr_byt_4;
            endcase
        end
        else begin
            o_lsu_ram_wr_data = `DATA_ZERO;
        end
    end

    assign o_lsu_pc_en = (i_idu_ctr_inst_type == `INST_TYPE_STOR) ? 1'b1 : 1'b0;

endmodule
