module mux #(
    parameter KEY_NUM   = 2,
    parameter KEY_WIDTH = 1,
    parameter VAL_WIDTH = 1,
    parameter HAS_DEF   = 0) (
    input  logic [KEY_WIDTH                         - 1 : 0] i_key,
    input  logic [VAL_WIDTH                         - 1 : 0] i_val_def,
    input  logic [KEY_NUM * (KEY_WIDTH + VAL_WIDTH) - 1 : 0] i_lut,
    output logic [VAL_WIDTH                         - 1 : 0] o_val
);

    localparam MAP_WIDTH = KEY_WIDTH + VAL_WIDTH;

    logic [MAP_WIDTH - 1 : 0] w_map [KEY_NUM - 1 : 0];
    logic [KEY_WIDTH - 1 : 0] w_key [KEY_NUM - 1 : 0];
    logic [VAL_WIDTH - 1 : 0] w_val [KEY_NUM - 1 : 0];

    genvar n;
    generate
        for (n = 0; n < KEY_NUM; n = n + 1) begin
            assign w_map[n] = i_lut[MAP_WIDTH * (n + 1) - 1 : MAP_WIDTH * n];
            assign w_val[n] = w_map[n][VAL_WIDTH - 1 : 0];
            assign w_key[n] = w_map[n][MAP_WIDTH - 1 : VAL_WIDTH];
        end
    endgenerate

    reg [VAL_WIDTH - 1 : 0] r_lut;
    reg                   r_hit;

    always @(*) begin
        r_lut = 0;
        r_hit = 0;
        for (integer i = 0; i < KEY_NUM; i = i + 1) begin
            r_lut = r_lut | ({VAL_WIDTH{i_key == w_key[i]}} & w_val[i]);
            r_hit = r_hit | (i_key == w_key[i]);
        end
        if (!HAS_DEF) begin
            o_val = r_lut;
        end
        else begin
            o_val = (r_hit ? r_lut : i_val_def);
        end
    end
endmodule

module mux_key #(
    parameter KEY_NUM   = 2,
    parameter KEY_WIDTH = 1,
    parameter VAL_WIDTH = 1
) (
    input  logic [KEY_WIDTH                         - 1 : 0] i_key,
    input  logic [KEY_NUM * (KEY_WIDTH + VAL_WIDTH) - 1 : 0] i_lut,
    output logic [VAL_WIDTH                         - 1 : 0] o_val
);

    mux #(
        .KEY_NUM  (KEY_NUM),
        .KEY_WIDTH(KEY_WIDTH),
        .VAL_WIDTH(VAL_WIDTH),
        .HAS_DEF  (0)
    ) u_mux(
        .i_key    (i_key),
        .i_val_def({VAL_WIDTH{1'h0}}),
        .i_lut    (i_lut),
        .o_val    (o_val)
    );

endmodule

module mux_key_def #(
    parameter KEY_NUM   = 2,
    parameter KEY_WIDTH = 1,
    parameter VAL_WIDTH = 1
) (
    input  [KEY_WIDTH                         - 1 : 0] i_key,
    input  [VAL_WIDTH                         - 1 : 0] i_val_def,
    input  [KEY_NUM * (KEY_WIDTH + VAL_WIDTH) - 1 : 0] i_lut,
    output [VAL_WIDTH                         - 1 : 0] o_val
);

    mux #(
        .KEY_NUM  (KEY_NUM),
        .KEY_WIDTH(KEY_WIDTH),
        .VAL_WIDTH(VAL_WIDTH),
        .HAS_DEF  (1)
    ) u_mux(
        .i_key    (i_key),
        .i_val_def(i_val_def),
        .i_lut    (i_lut),
        .o_val    (o_val)
    );

endmodule

module mux_2to1 #(
    parameter DATA_WIDTH = 32
) (
    input  logic                      i_key,
    input  logic [DATA_WIDTH - 1 : 0] i_val_a,
    input  logic [DATA_WIDTH - 1 : 0] i_val_b,
    output logic [DATA_WIDTH - 1 : 0] o_val
);

    mux_key_def #(
        .KEY_NUM  (2),
        .KEY_WIDTH(1),
        .VAL_WIDTH(DATA_WIDTH)
    ) u_mux_key_def(
        .i_key    (i_key),
        .i_val_def({DATA_WIDTH{1'h0}}),
        .i_lut    ({
            1'b0, i_val_a,
            1'b1, i_val_b
        }),
        .o_val    (o_val)
    );

endmodule

module mux_4to1 #(
    parameter DATA_WIDTH = 32
) (
    input  logic        [1              : 0] i_key,
    input  logic [3 : 0][DATA_WIDTH - 1 : 0] i_val,
    output logic        [DATA_WIDTH - 1 : 0] o_val
);

    mux_key_def #(
        .KEY_NUM  (4),
        .KEY_WIDTH(2),
        .VAL_WIDTH(DATA_WIDTH)
    ) u_mux_key_def(
        .i_key    (i_key),
        .i_val_def({DATA_WIDTH{1'h0}}),
        .i_lut    ({
            2'b00, i_val[0],
            2'b01, i_val[1],
            2'b10, i_val[2],
            2'b11, i_val[3]
        }),
        .o_val    (o_val)
    );

endmodule
