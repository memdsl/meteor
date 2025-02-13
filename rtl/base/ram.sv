module ram (
    input  logic                           i_sys_clk,
    input  logic                           i_sys_rst_n,

    input  logic                           i_ram_rd_en,
    input  logic [`ADDR_WIDTH     - 1 : 0] i_ram_rd_addr,
    output logic [`DATA_WIDTH     - 1 : 0] o_ram_rd_data,
    input  logic                           i_ram_wr_en,
    input  logic [`ADDR_WIDTH     - 1 : 0] i_ram_wr_addr,
    input  logic [`DATA_WIDTH     - 1 : 0] i_ram_wr_data
);

    logic [`INST_WIDTH - 1 : 0] r_ram[`ROM_SIZE - 1 : 0];

    logic [`ROM_BITS - 1 : 0] w_ram_rd_addr;
    logic [`ROM_BITS - 1 : 0] w_ram_wr_addr;

    assign w_ram_rd_addr = i_ram_rd_addr[`ROM_BITS + 1 : 2];
    assign w_ram_wr_addr = i_ram_wr_addr[`ROM_BITS + 1 : 2];

    always_comb begin
        if (i_ram_rd_en) begin
            o_ram_rd_data = r_ram[w_ram_rd_addr];
        end
        else begin
            o_ram_rd_data = `DATA_ZERO;
        end
    end

    always_ff @(posedge i_sys_clk) begin
        if (i_ram_wr_en) begin
            r_ram[w_ram_wr_addr] <= i_ram_wr_data;
        end
        else begin
            r_ram[w_ram_wr_addr] <= r_ram[w_ram_wr_addr];
        end
    end

endmodule
