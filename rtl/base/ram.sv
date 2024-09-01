`include "./cfg.sv"

module ram #(
    parameter DATA_WIDTH = `DATA_WIDTH
) (
    input  logic                           i_sys_clk,
    input  logic                           i_sys_rst_n,

    input  logic                           i_ram_rd_inst_en,
    input  logic [`ADDR_WIDTH     - 1 : 0] i_ram_rd_inst_addr,
    output logic [ DATA_WIDTH     - 1 : 0] o_ram_rd_inst_data,

    input  logic                           i_ram_rd_data_en,
    input  logic [`ADDR_WIDTH     - 1 : 0] i_ram_rd_data_addr,
    output logic [ DATA_WIDTH     - 1 : 0] o_ram_rd_data_data,

    input  logic                           i_ram_wr_data_en,
    input  logic [`ADDR_WIDTH     - 1 : 0] i_ram_wr_data_addr,
    input  logic [ DATA_WIDTH     - 1 : 0] i_ram_wr_data_data,
    input  logic [ DATA_WIDTH / 8 - 1 : 0] i_ram_wr_data_mask
);

    // 32bit: 64KB, 64bit: 128KB
    logic [DATA_WIDTH - 1 : 0] r_ram[2 ** 14 - 1: 0];

    assign o_ram_rd_inst_data = (i_ram_rd_inst_en) ?
                                r_ram[i_ram_rd_inst_addr[15 : 2]] : {DATA_WIDTH{1'h0}};
    assign o_ram_rd_data_data = (i_ram_rd_data_en) ?
                                r_ram[i_ram_rd_data_addr[15 : 2]] : {DATA_WIDTH{1'h0}};

    always_ff @(posedge i_sys_clk) begin
        if (!i_sys_rst_n) begin
        end
        else begin
            if (i_ram_wr_data_en) begin
                for (int i = 0; i < DATA_WIDTH / 8; i = i + 1) begin
                    if (i_ram_wr_data_mask[i]) begin
                        r_ram[i_ram_wr_data_addr[15 : 2]][i * 8 +: 8] <= i_ram_wr_data_data[i * 8 +: 8];
                    end
                end
            end
            else begin
            end
        end
    end

endmodule