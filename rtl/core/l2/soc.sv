`timescale 1ns / 1ps

module soc(
    input logic                            i_sys_clk,
    input logic                            i_sys_rst_n,

    output logic                           o_end_flag,
    output logic [`DATA_WIDTH     - 1 : 0] o_end_data
);

    logic                           w_rom_rd_en;
    logic [`ADDR_WIDTH     - 1 : 0] w_rom_rd_addr;
    logic [`INST_WIDTH     - 1 : 0] w_rom_rd_data;

    logic                           w_ram_rd_en;
    logic [`ADDR_WIDTH     - 1 : 0] w_ram_rd_addr;
    logic [`DATA_WIDTH     - 1 : 0] w_ram_rd_data;
    logic                           w_ram_wr_en;
    logic [`ADDR_WIDTH     - 1 : 0] w_ram_wr_addr;
    logic [`DATA_WIDTH     - 1 : 0] w_ram_wr_data;

    rom u_rom(
        .i_rom_rd_en  (w_rom_rd_en  ),
        .i_rom_rd_addr(w_rom_rd_addr),
        .o_rom_rd_data(w_rom_rd_data)
    );

    ram u_ram(
        .i_sys_clk    (i_sys_clk    ),
        .i_sys_rst_n  (i_sys_rst_n  ),
        .i_ram_rd_en  (w_rom_rd_en  ),
        .i_ram_rd_addr(w_ram_rd_addr),
        .o_ram_rd_data(w_ram_rd_data),
        .i_ram_wr_en  (w_ram_wr_en  ),
        .i_ram_wr_addr(w_ram_wr_addr),
        .i_ram_wr_data(w_ram_wr_data)
    );

    cpu u_cpu(
        .i_sys_clk    (i_sys_clk    ),
        .i_sys_rst_n  (i_sys_rst_n  ),
        .i_rom_rd_data(w_rom_rd_data),
        .o_rom_rd_en  (w_rom_rd_en  ),
        .o_rom_rd_addr(w_rom_rd_addr),
        .i_ram_rd_data(w_ram_rd_data),
        .o_ram_rd_en  (w_ram_rd_en  ),
        .o_ram_rd_addr(w_ram_rd_addr),
        .o_ram_wr_en  (w_ram_wr_en  ),
        .o_ram_wr_addr(w_ram_wr_addr),
        .o_ram_wr_data(w_ram_wr_data),
        .o_end_flag   (o_end_flag   ),
        .o_end_data   (o_end_data   )
    );

endmodule
