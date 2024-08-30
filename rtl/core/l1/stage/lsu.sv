`include "../../../base/cfg.sv"

module lsu #(
    parameter DATA_WIDTH = `DATA_WIDTH
) (
    input  logic                           i_ready,
    output logic                           o_valid,

    input  logic                           i_ram_wr_en,
    input  logic [`ARGS_WIDTH - 1 : 0]     i_ram_byt,

    input  logic [ DATA_WIDTH - 1 : 0]     i_alu_res,
    input  logic [ DATA_WIDTH - 1 : 0]     i_gpr_rs2_data,

    input  logic [ DATA_WIDTH     - 1 : 0] i_ram_rd_data,
    output logic                           o_ram_rd_en,
    output logic [`ADDR_WIDTH     - 1 : 0] o_ram_rd_addr,
    output logic [ DATA_WIDTH     - 1 : 0] o_gpr_wr_data,

    output logic                           o_ctr_ram_wr_en,
    output logic [`ADDR_WIDTH     - 1 : 0] o_ram_wr_addr,
    output logic [ DATA_WIDTH     - 1 : 0] o_ram_wr_data,
    output logic [ DATA_WIDTH / 8 - 1 : 0] o_ram_wr_mask
);

    assign o_valid = 1'h1;

    logic [`BYTE_WIDTH * 1 - 1 : 0] w_ram_rd_data_byt_1;
    logic [`BYTE_WIDTH * 2 - 1 : 0] w_ram_rd_data_byt_2;
    logic [`BYTE_WIDTH * 4 - 1 : 0] w_ram_rd_data_byt_4;

    assign w_ram_rd_data_byt_1 = i_ram_rd_data[ 7 : 0];
    assign w_ram_rd_data_byt_2 = i_ram_rd_data[15 : 0];
    assign w_ram_rd_data_byt_4 = i_ram_rd_data[31 : 0];

    assign o_ram_rd_en   = 1'h1;
    assign o_ram_rd_addr = i_alu_res[31 : 0];
    always_comb begin
        case (i_ram_byt)
            `RAM_BYT_1_S: o_gpr_wr_data = {{(DATA_WIDTH -  8){w_ram_rd_data_byt_1[ 7]}}, w_ram_rd_data_byt_1};
            `RAM_BYT_1_U: o_gpr_wr_data = {{(DATA_WIDTH -  8){1'h0}},                    w_ram_rd_data_byt_1};
            `RAM_BYT_2_S: o_gpr_wr_data = {{(DATA_WIDTH - 16){w_ram_rd_data_byt_2[15]}}, w_ram_rd_data_byt_2};
            `RAM_BYT_2_U: o_gpr_wr_data = {{(DATA_WIDTH - 16){1'h0}},                    w_ram_rd_data_byt_2};
            `RAM_BYT_4_S: o_gpr_wr_data = {{(DATA_WIDTH - 32){w_ram_rd_data_byt_4[31]}}, w_ram_rd_data_byt_4};
            `RAM_BYT_4_U: o_gpr_wr_data = {{(DATA_WIDTH - 32){1'h0}},                    w_ram_rd_data_byt_4};
            default:      o_gpr_wr_data = i_ram_rd_data;
        endcase
    end

    logic [DATA_WIDTH / 8 - 1 : 0] w_ram_wr_mask_1;
    logic [DATA_WIDTH / 8 - 1 : 0] w_ram_wr_mask_2;
    logic [DATA_WIDTH / 8 - 1 : 0] w_ram_wr_mask_4;
    logic [DATA_WIDTH / 8 - 1 : 0] w_ram_wr_mask_8;

    assign w_ram_wr_mask_1 = {{(DATA_WIDTH / 8 - 1){1'h0}}, 1'h1};
    assign w_ram_wr_mask_2 = {{(DATA_WIDTH / 8 - 2){1'h0}}, 2'h3};
    assign w_ram_wr_mask_4 = {{(DATA_WIDTH / 8 - 4){1'h0}}, 4'hf};
    assign w_ram_wr_mask_8 =  {(DATA_WIDTH / 8 - 0){1'h1}};

    assign o_ctr_ram_wr_en   = i_ram_wr_en;
    assign o_ram_wr_addr = i_alu_res[31 : 0];
    assign o_ram_wr_data = i_gpr_rs2_data;
    assign o_ram_wr_mask = (i_ram_byt === `RAM_BYT_1_U) ? w_ram_wr_mask_1 :
                           (i_ram_byt === `RAM_BYT_2_U) ? w_ram_wr_mask_2 :
                           (i_ram_byt === `RAM_BYT_4_U) ? w_ram_wr_mask_4 :
                           (i_ram_byt === `RAM_BYT_8_U) ? w_ram_wr_mask_8 :
                                                             w_ram_wr_mask_1;

endmodule
