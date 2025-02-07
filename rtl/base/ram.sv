`include "cfg.sv"

module ram (
    input  logic                           i_sys_clk,
    input  logic                           i_sys_rst_n,

    input  logic                           i_ram_rd_en,
    input  logic [`ADDR_WIDTH     - 1 : 0] i_ram_rd_addr,
    output logic [`DATA_WIDTH     - 1 : 0] o_ram_rd_data,
    input  logic                           i_ram_wr_en,
    input  logic [`ADDR_WIDTH     - 1 : 0] i_ram_wr_addr,
    input  logic [`DATA_WIDTH     - 1 : 0] i_ram_wr_data,
    input  logic [`DATA_WIDTH / 8 - 1 : 0] i_ram_wr_mask
);

    logic [`BYTE_WIDTH - 1 : 0] r_ram_bank_0[`ROM_SIZE - 1 : 0];
    logic [`BYTE_WIDTH - 1 : 0] r_ram_bank_1[`ROM_SIZE - 1 : 0];
    logic [`BYTE_WIDTH - 1 : 0] r_ram_bank_2[`ROM_SIZE - 1 : 0];
    logic [`BYTE_WIDTH - 1 : 0] r_ram_bank_3[`ROM_SIZE - 1 : 0];

    logic [`ADDR_WIDTH - 1 : 0] w_ram_rd_addr_t;
    logic [`ADDR_WIDTH - 1 : 0] w_ram_wr_addr_t;

    assign w_ram_rd_addr_t = i_ram_rd_addr - `ADDR_INIT;
    assign w_ram_wr_addr_t = i_ram_wr_addr - `ADDR_INIT;

    logic [`ROM_BITS - 1 : 0] w_ram_rd_addr = w_ram_rd_addr_t[`ROM_BITS + 1 : 2];
    logic [`ROM_BITS - 1 : 0] w_ram_wr_addr = w_ram_wr_addr_t[`ROM_BITS + 1 : 2];

    always_comb begin
        if (!i_ram_rd_en) begin
            o_ram_rd_data = `DATA_ZERO;
        end
        else begin
            o_ram_rd_data = {r_ram_bank_3[w_ram_rd_addr],
                             r_ram_bank_2[w_ram_rd_addr],
                             r_ram_bank_1[w_ram_rd_addr],
                             r_ram_bank_0[w_ram_rd_addr]};
        end
    end

    always_ff @(posedge i_sys_clk) begin
        if (i_ram_wr_en) begin
            if (i_ram_wr_mask[3]) begin
                r_ram_bank_3[w_ram_wr_addr] <= i_ram_wr_data[31 : 24];
            end
            if (i_ram_wr_mask[2]) begin
                r_ram_bank_2[w_ram_wr_addr] <= i_ram_wr_data[23 : 16];
            end
            if (i_ram_wr_mask[1]) begin
                r_ram_bank_1[w_ram_wr_addr] <= i_ram_wr_data[15 : 08];
            end
            if (i_ram_wr_mask[0]) begin
                r_ram_bank_0[w_ram_wr_addr] <= i_ram_wr_data[07 : 00];
            end
        end
    end

endmodule
