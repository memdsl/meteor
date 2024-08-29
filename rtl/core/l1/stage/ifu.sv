`define ADDR_WIDTH 32
`define ADDR_INIT  32'h8000_0000

module ifu #(
    parameter ADDR_WIDTH = `ADDR_WIDTH
) (
    input  logic                      i_clk,
    input  logic                      i_rst_n,
    input  logic                      i_ready,
    output logic                      o_valid,

    input  logic                      i_jmp_en,
    input  logic [ADDR_WIDTH - 1 : 0] i_jmp_pc,
    output logic [ADDR_WIDTH - 1 : 0] o_pc,
    output logic [ADDR_WIDTH - 1 : 0] o_pc_next
);

    assign o_valid   = 1'h1;

    logic [ADDR_WIDTH - 1 : 0] r_pc;
    logic [ADDR_WIDTH - 1 : 0] w_pc_next;

    always_ff @(posedge i_clk) begin
        if (!i_rst_n) begin
            r_pc <= `ADDR_INIT;
        end
        else begin
            if (i_ready && o_valid) begin
                r_pc <= w_pc_next;
            end
            else begin
                r_pc <= r_pc;
            end
        end
    end

    assign w_pc_next = i_jmp_en ? i_jmp_pc : (r_pc + 32'h4);

    assign o_pc      = r_pc;
    assign o_pc_next = w_pc_next;

endmodule