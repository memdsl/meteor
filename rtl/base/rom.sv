`include "cfg.sv"

module rom(
    input  logic                       i_rom_rd_en,
    input  logic [`ADDR_WIDTH - 1 : 0] i_rom_rd_addr,
    output logic [`INST_WIDTH - 1 : 0] o_rom_rd_data
);

    logic [`INST_WIDTH - 1 : 0] r_rom[`ROM_SIZE - 1 : 0];
    logic [`ADDR_WIDTH - 1 : 0] w_rom_rd_addr;

    assign w_rom_rd_addr = i_rom_rd_addr;

    always_comb begin
        if (!i_rom_rd_en) begin
            o_rom_rd_data = `DATA_ZERO;
        end
        else begin
            o_rom_rd_data = r_rom[w_rom_rd_addr[`ROM_BITS + 1 : 2]];
        end
    end

endmodule
