`timescale 1ns / 1ps

`include "cfg.sv"

module soc_tb();

parameter CYCLE = 10;

logic                       r_clk;
logic                       r_rst_n;
logic                       w_end_flag;
logic [`DATA_WIDTH - 1 : 0] w_end_data;

always #(CYCLE / 2) r_clk = ~r_clk;

initial begin
    $readmemh("inst.hex", u_soc.u_rom.r_rom);
end

initial begin
    r_clk   = 1'h0;
    r_rst_n = 1'h0;
    #(CYCLE * 1);
    r_rst_n = 1'h1;
end

always @(posedge r_clk) begin
    if (w_end_flag == 1'b1) begin
        if (w_end_data == 32'h1) begin
            $display("FAIL");
            $finish;
        end
        else begin
            $display("PASS");
            $finish;
        end
    end
end

soc u_soc(
    .i_sys_clk  (r_clk     ),
    .i_sys_rst_n(r_rst_n   ),
    .o_end_flag (w_end_flag),
    .o_end_data (w_end_data)
);

endmodule
