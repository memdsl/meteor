`include "cfg.sv"

module imm(
    input  logic [`INST_WIDTH -  1 : 0] i_imm_inst,
    input  logic [`INST_WIDTH - 26 : 0] i_imm_opcode,
    output logic [`DATA_WIDTH -  1 : 0] o_imm_data
);

    always_comb begin
        case (i_imm_opcode)
            // I Type
            7'b1100111,
            7'b0000011,
            7'b0010011:
                o_imm_data = {{(`DATA_WIDTH - 12){i_imm_inst[31]}},
                              i_imm_inst[31 : 20]};
            // S Type
            7'b0100011:
                o_imm_data = {{(`DATA_WIDTH - 12){i_imm_inst[31]}},
                              i_imm_inst[31 : 25],
                              i_imm_inst[11 :  7]};
            // B Type
            7'b1100011:
                o_imm_data = {{(`DATA_WIDTH - 13){i_imm_inst[31]}},
                              i_imm_inst[31     ],
                              i_imm_inst[ 7     ],
                              i_imm_inst[30 : 25],
                              i_imm_inst[11 :  8],
                              1'h0};
            // U Type
            7'b0110111,
            7'b0010111:
                o_imm_data = {{(`DATA_WIDTH - 32){i_imm_inst[31]}},
                              i_imm_inst[31 : 12], 12'h0};
            // J Type
            7'b1101111:
                o_imm_data = {{(`DATA_WIDTH - 21){i_imm_inst[31]}},
                              i_imm_inst[31     ],
                              i_imm_inst[19 : 12],
                              i_imm_inst[20     ],
                              i_imm_inst[30 : 21],
                              1'h0};
            default:
                o_imm_data = `DATA_ZERO;
        endcase
    end

endmodule
