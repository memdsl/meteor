`include "cfg.sv"

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
    output logic [`DATA_WIDTH / 8 - 1 : 0] o_lsu_ram_wr_mask
);

    assign o_sys_valid = 1'b1;

    logic [`BYTE_WIDTH * 1 - 1 : 0] w_ram_rd_data_byt_1;
    logic [`BYTE_WIDTH * 2 - 1 : 0] w_ram_rd_data_byt_2;
    logic [`BYTE_WIDTH * 4 - 1 : 0] w_ram_rd_data_byt_4;

    assign w_ram_rd_data_byt_1 = i_ram_rd_data[ 7 : 0];
    assign w_ram_rd_data_byt_2 = i_ram_rd_data[15 : 0];
    assign w_ram_rd_data_byt_4 = i_ram_rd_data[31 : 0];

    assign o_lsu_ram_rd_en   = (o_sys_valid && i_sys_ready) ? 1'b1              :  1'b0;
    assign o_lsu_ram_rd_addr = (o_sys_valid && i_sys_ready) ? i_exu_res[31 : 0] : 32'h0;
    always_comb begin
        if (o_sys_valid && i_sys_ready) begin
            case (i_idu_ctr_ram_byt)
                `RAM_BYT_1_S: o_lsu_gpr_wr_data = {{(`DATA_WIDTH -  8){w_ram_rd_data_byt_1[ 7]}}, w_ram_rd_data_byt_1};
                `RAM_BYT_1_U: o_lsu_gpr_wr_data = {{(`DATA_WIDTH -  8){                   1'b0}}, w_ram_rd_data_byt_1};
                `RAM_BYT_2_S: o_lsu_gpr_wr_data = {{(`DATA_WIDTH - 16){w_ram_rd_data_byt_2[15]}}, w_ram_rd_data_byt_2};
                `RAM_BYT_2_U: o_lsu_gpr_wr_data = {{(`DATA_WIDTH - 16){                   1'b0}}, w_ram_rd_data_byt_2};
                `RAM_BYT_4_S: o_lsu_gpr_wr_data = {{(`DATA_WIDTH - 32){w_ram_rd_data_byt_4[31]}}, w_ram_rd_data_byt_4};
                `RAM_BYT_4_U: o_lsu_gpr_wr_data = {{(`DATA_WIDTH - 32){                   1'b0}}, w_ram_rd_data_byt_4};
                default:      o_lsu_gpr_wr_data = i_ram_rd_data;
            endcase
        end
        else begin
            o_lsu_gpr_wr_data = `DATA_ZERO;
        end
    end

    logic [`DATA_WIDTH / 8 - 1 : 0] w_ram_wr_mask_1;
    logic [`DATA_WIDTH / 8 - 1 : 0] w_ram_wr_mask_2;
    logic [`DATA_WIDTH / 8 - 1 : 0] w_ram_wr_mask_4;
    logic [`DATA_WIDTH / 8 - 1 : 0] w_ram_wr_mask_8;

    assign w_ram_wr_mask_1 = {{(`DATA_WIDTH / 8 - 1){1'b0}}, 1'h1};
    assign w_ram_wr_mask_2 = {{(`DATA_WIDTH / 8 - 2){1'b0}}, 2'h3};
    assign w_ram_wr_mask_4 = {{(`DATA_WIDTH / 8 - 4){1'b0}}, 4'hf};

    assign o_lsu_ram_wr_en   = (o_sys_valid && i_sys_ready) ? i_idu_ctr_ram_wr_en :  1'b0;
    assign o_lsu_ram_wr_addr = (o_sys_valid && i_sys_ready) ? i_exu_res[31 : 0]   : 32'h0;
    assign o_lsu_ram_wr_data = (o_sys_valid && i_sys_ready) ? i_gpr_rs2_data      : `DATA_ZERO;
    assign o_lsu_ram_wr_mask = (o_sys_valid && i_sys_ready) ?
                              ((i_idu_ctr_ram_byt === `RAM_BYT_1_U) ? w_ram_wr_mask_1  :
                               (i_idu_ctr_ram_byt === `RAM_BYT_2_U) ? w_ram_wr_mask_2  :
                               (i_idu_ctr_ram_byt === `RAM_BYT_4_U) ? w_ram_wr_mask_4  :
                                                                      w_ram_wr_mask_4) : w_ram_wr_mask_4;

endmodule
