`include "./cfg.sv"

module alu #(
    parameter DATA_WIDTH = `DATA_WIDTH
) (
    input  logic [`ARGS_WIDTH - 1 : 0] i_type,
    input  logic [ DATA_WIDTH - 1 : 0] i_rs1_data,
    input  logic [ DATA_WIDTH - 1 : 0] i_rs2_data,
    output logic [ DATA_WIDTH - 1 : 0] o_res,
    output logic                       o_zero,
    output logic                       o_over,
    output logic                       o_nega
);

    logic [DATA_WIDTH - 1 : 0] w_mask;

    assign w_mask = {{(DATA_WIDTH - 1){1'h1}}, 1'h0};

    logic [DATA_WIDTH - 1 : 0] w_u_rs1_data;
    logic [DATA_WIDTH - 1 : 0] w_u_rs2_data;
    logic [DATA_WIDTH - 1 : 0] w_s_rs1_data;
    logic [DATA_WIDTH - 1 : 0] w_s_rs2_data;
    logic [5 : 0]              w_u_rs2_data_shift;

    assign w_u_rs1_data       = i_rs1_data;
    assign w_u_rs2_data       = i_rs2_data;
    assign w_s_rs1_data       = $signed(i_rs1_data);
    assign w_s_rs2_data       = $signed(i_rs2_data);
    assign w_u_rs2_data_shift = (DATA_WIDTH === 32 ?
                                {1'h0, w_u_rs2_data[4 : 0]} :
                                       w_u_rs2_data[5 : 0]);

    always_comb begin
        case (i_type)
            `ALU_TYPE_SLL:  o_res = w_u_rs1_data <<  w_u_rs2_data_shift;
            `ALU_TYPE_SRL:  o_res = w_u_rs1_data >>  w_u_rs2_data_shift;
            `ALU_TYPE_SRA:  o_res = w_u_rs1_data >>> w_u_rs2_data_shift;
            `ALU_TYPE_ADD:  o_res = w_u_rs1_data +   w_u_rs2_data;
            `ALU_TYPE_SUB:  o_res = w_u_rs1_data -   w_u_rs2_data;
            `ALU_TYPE_XOR:  o_res = w_u_rs1_data ^   w_u_rs2_data;
            `ALU_TYPE_OR:   o_res = w_u_rs1_data |   w_u_rs2_data;
            `ALU_TYPE_AND:  o_res = w_u_rs1_data &   w_u_rs2_data;
            `ALU_TYPE_SLT:  o_res = {(DATA_WIDTH){(w_s_rs1_data <   w_s_rs2_data)}};
            `ALU_TYPE_SLTU: o_res = {(DATA_WIDTH){(w_u_rs1_data <   w_u_rs2_data)}};
            `ALU_TYPE_BEQ:  o_res = {(DATA_WIDTH){(w_u_rs1_data === w_u_rs2_data)}};
            `ALU_TYPE_BNE:  o_res = {(DATA_WIDTH){(w_u_rs1_data !== w_u_rs2_data)}};
            `ALU_TYPE_BLT:  o_res = {(DATA_WIDTH){(w_s_rs1_data <   w_s_rs2_data)}};
            `ALU_TYPE_BGE:  o_res = {(DATA_WIDTH){(w_s_rs1_data >=  w_s_rs2_data)}};
            `ALU_TYPE_BLTU: o_res = {(DATA_WIDTH){(w_u_rs1_data <   w_u_rs2_data)}};
            `ALU_TYPE_BGEU: o_res = {(DATA_WIDTH){(w_u_rs1_data >=  w_u_rs2_data)}};
            `ALU_TYPE_JALR: o_res = (w_u_rs1_data +  w_u_rs2_data) + w_mask;
            default:        o_res = {DATA_WIDTH{1'h0}};
        endcase
    end

    assign o_zero = (o_res === {(DATA_WIDTH){1'h0}}) ? 1'h1 : 1'h0;

    logic w_rs1_data_sign;
    logic w_rs2_data_sign;
    logic w_res_sign;

    assign w_rs1_data_sign = i_rs1_data[`DATA_WIDTH - 1];
    assign w_rs2_data_sign = i_rs2_data[`DATA_WIDTH - 1];
    assign w_res_sign      = o_res[`DATA_WIDTH - 1];

    assign o_over = ((i_type == `ALU_TYPE_ADD) && ( w_rs1_data_sign & w_rs2_data_sign & ~w_res_sign)) ||
                    ((i_type == `ALU_TYPE_SUB) && (~w_rs1_data_sign & w_rs2_data_sign &  w_res_sign));
    assign o_nega = w_res_sign;

endmodule
