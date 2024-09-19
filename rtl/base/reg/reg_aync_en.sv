module reg_aync_en #(
    parameter DATA_WIDTH = 32,
    parameter RSTN_VALUE =  0
) (
    input  logic                      i_clk,
    input  logic                      i_rst_n,
    input  logic                      i_en,
    input  logic [DATA_WIDTH - 1 : 0] i_data,
    output logic [DATA_WIDTH - 1 : 0] o_data
);

    always_ff @(posedge i_clk or negedge i_rst_n) begin
        if (!i_rst_n) begin
            o_data <= RSTN_VALUE;
        end
        else if (i_en) begin
            o_data <= i_data;
        end
        else begin
            o_data <= o_data;
        end
    end

endmodule
