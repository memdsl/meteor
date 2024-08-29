`include "./cfg.sv"

module ram #(
    parameter DATA_WIDTH = `DATA_WIDTH
) (
    input  logic                           i_clk,
    input  logic                           i_rst_n,

    input  logic                           i_rd_en,
    input  logic [`ADDR_WIDTH     - 1 : 0] i_rd_addr,
    output logic [ DATA_WIDTH     - 1 : 0] o_rd_data,

    input  logic                           i_wr_en,
    input  logic [`ADDR_WIDTH     - 1 : 0] i_wr_addr,
    input  logic [ DATA_WIDTH     - 1 : 0] i_wr_data,
    input  logic [ DATA_WIDTH / 8 - 1 : 0] i_wr_mask
);

    logic [DATA_WIDTH - 1 : 0] r_ram[(2 ^ `ADDR_WIDTH - 1) : 0];

    assign o_rd_data = (i_rd_en) ? r_ram[i_rd_addr] : {DATA_WIDTH{1'h0}};

    always_ff @(posedge i_clk) begin
        if (!i_rst_n) begin
        end
        else begin
            if (i_wr_en) begin
                for (int i = 0; i < DATA_WIDTH / 8; i = i + 1) begin
                    if (i_wr_mask[i]) begin
                        r_ram[i_wr_addr][i * 8 +: 8] <= i_wr_addr[i * 8 +: 8];
                    end
                end
            end
            else begin
            end
        end
    end

endmodule