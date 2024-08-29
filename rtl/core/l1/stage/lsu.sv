`include "../../../base/cfg.sv"

module lsu #(
    parameter DATA_WIDTH = `DATA_WIDTH
) (
    input  logic                           i_ready,
    output logic                           o_valid,

    input  logic                           i_ram_wr_en,
    input  logic [`ARGS_WIDTH - 1 : 0]     i_ram_wr_byt,

    input  logic [ DATA_WIDTH - 1 : 0]     i_alu_res,
    input  logic [ DATA_WIDTH - 1 : 0]     i_gpr_rs2_data,

    input  logic [ DATA_WIDTH     - 1 : 0] i_ram_rd_data,
    output logic                           o_ram_rd_en,
    output logic [`ADDR_WIDTH     - 1 : 0] o_ram_rd_addr,
    output logic [ DATA_WIDTH     - 1 : 0] o_gpr_wr_data,

    output logic                           o_ram_wr_en,
    output logic [`ADDR_WIDTH     - 1 : 0] o_ram_wr_addr,
    output logic [ DATA_WIDTH     - 1 : 0] o_ram_wr_data,
    output logic [ DATA_WIDTH / 8 - 1 : 0] o_ram_wr_mask
);



    logic [DATA_WIDTH / 8 - 1 : 0] w_ram_wr_mask_1;
    logic [DATA_WIDTH / 8 - 1 : 0] w_ram_wr_mask_2;
    logic [DATA_WIDTH / 8 - 1 : 0] w_ram_wr_mask_4;
    logic [DATA_WIDTH / 8 - 1 : 0] w_ram_wr_mask_8;

    assign w_ram_wr_mask_1 = {{(DATA_WIDTH / 8 - 1){1'h0}}, 1'h1};
    assign w_ram_wr_mask_2 = {{(DATA_WIDTH / 8 - 2){1'h0}}, 2'h3};
    assign w_ram_wr_mask_4 = {{(DATA_WIDTH / 8 - 4){1'h0}}, 4'hf};
    assign w_ram_wr_mask_8 =  {(DATA_WIDTH / 8 - 0){1'h1}};

    assign o_ram_wr_en   = i_ram_wr_en;
    assign o_ram_wr_addr = i_alu_res[31 : 0];
    assign o_ram_wr_data = i_gpr_rs2_data;
    assign o_ram_wr_mask = (i_ram_wr_byt === `RAM_BYT_1_U) ? w_ram_wr_mask_1 :
                           (i_ram_wr_byt === `RAM_BYT_2_U) ? w_ram_wr_mask_2 :
                           (i_ram_wr_byt === `RAM_BYT_4_U) ? w_ram_wr_mask_4 :
                           (i_ram_wr_byt === `RAM_BYT_8_U) ? w_ram_wr_mask_8 :
                                                             w_ram_wr_mask_1;

endmodule
