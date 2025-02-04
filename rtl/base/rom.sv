`include "cfg.sv"

module rom (
    input  logic                       i_rom_rd_en,
    input  logic [`ADDR_WIDTH - 1 : 0] i_rom_rd_addr,
    output logic [`INST_WIDTH - 1 : 0] o_rom_rd_data
);

    logic [`INST_WIDTH - 1 : 0] r_rom[`ROM_32_16KB - 1 : 0];

    always_comb begin
        if (!i_rom_rd_en) begin
            o_rom_rd_data = `DATA_ZERO;
        end
        else begin
            o_rom_rd_data = r_rom[(i_rom_rd_addr - `ADDR_INIT) / 4];
        end
    end

endmodule
