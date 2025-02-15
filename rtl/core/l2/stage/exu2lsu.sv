module exu2lsu(
    input  logic                           i_sys_clk,
    input  logic                           i_sys_rst_n,
    input  logic                           i_sys_ready,
    output logic                           o_sys_valid,

    input  logic [`ADDR_WIDTH     - 1 : 0] i_exu_pc;
    output logic [`ADDR_WIDTH     - 1 : 0] o_exu_pc;

    input  logic [`ARGS_WIDTH     - 1 : 0] i_idu_ctr_ram_byt,
    input  logic [`DATA_WIDTH     - 1 : 0] i_exu_res,
    output logic [`ARGS_WIDTH     - 1 : 0] o_idu_ctr_ram_byt,
    output logic [`DATA_WIDTH     - 1 : 0] o_exu_res,

    input  logic [`DATA_WIDTH     - 1 : 0] i_ram_rd_data,
    output logic [`DATA_WIDTH     - 1 : 0] o_ram_rd_data,

    input  logic                           i_idu_ctr_ram_wr_en,
    input  logic [`DATA_WIDTH     - 1 : 0] i_gpr_rs2_data,
    output logic                           o_idu_ctr_ram_wr_en,
    output logic [`DATA_WIDTH     - 1 : 0] o_gpr_rs2_data,

    input  logic [`ARGS_WIDTH     - 1 : 0] i_idu_ctr_inst_type,
    output logic [`ARGS_WIDTH     - 1 : 0] o_idu_ctr_inst_type
);

    assign o_sys_valid = 1'b1;

    logic [`ADDR_WIDTH     - 1 : 0] r_exu_pc;
    logic [`ARGS_WIDTH     - 1 : 0] r_idu_ctr_ram_byt;
    logic [`DATA_WIDTH     - 1 : 0] r_exu_res;
    logic [`DATA_WIDTH     - 1 : 0] r_ram_rd_data;
    logic                           r_idu_ctr_ram_wr_en;
    logic [`DATA_WIDTH     - 1 : 0] r_gpr_rs2_data;
    logic [`ARGS_WIDTH     - 1 : 0] r_idu_ctr_inst_type;

    always_ff @(posedge i_sys_clk) begin
        if (!i_sys_rst_n) begin
            r_exu_pc <= `ADDR_INIT;
        end
        else if (o_sys_valid && i_sys_ready) begin
            r_exu_pc <= i_exu_pc;
        end
        else begin
            r_exu_pc <= r_exu_pc;
        end
    end

    always_ff @(posedge i_sys_clk) begin
        if (!i_sys_rst_n) begin
            r_idu_ctr_ram_byt = `RAM_BYT_X;
            r_exu_res         = `DATA_ZERO;
        end
        else if (o_sys_valid && i_sys_ready) begin
            r_idu_ctr_ram_byt = i_idu_ctr_ram_byt;
            r_exu_res         = i_exu_res;
        end
        else begin
            r_idu_ctr_ram_byt = r_idu_ctr_ram_byt;
            r_exu_res         = r_exu_res;
        end
    end


    always_ff @(posedge i_sys_clk) begin
        if (!i_sys_rst_n) begin
            r_ram_rd_data <= `DATA_ZERO;
        end
        else if (o_sys_valid && i_sys_ready) begin
            r_ram_rd_data <= i_ram_rd_data;
        end
        else begin
            r_ram_rd_data <= r_ram_rd_data;
        end
    end

    always_ff @(posedge i_sys_clk) begin
        if (!i_sys_rst_n) begin
            r_idu_ctr_ram_wr_en <= 1'b0;
            r_gpr_rs2_data      <= `DATA_ZERO;
        end
        else if (o_sys_valid && i_sys_ready) begin
            r_idu_ctr_ram_wr_en <= i_idu_ctr_ram_wr_en;
            r_gpr_rs2_data      <= i_gpr_rs2_data;
        end
        else begin
            r_idu_ctr_ram_wr_en <= r_idu_ctr_ram_wr_en;
            r_gpr_rs2_data      <= r_gpr_rs2_data;
        end
    end

    always_ff @(posedge i_sys_clk) begin
        if (!i_sys_rst_n) begin
            r_idu_ctr_inst_type <= `INST_TYPE_X;
        end
        else if (o_sys_valid && i_sys_ready) begin
            r_idu_ctr_inst_type <= i_idu_ctr_inst_type;
        end
        else begin
            r_idu_ctr_inst_type <= r_idu_ctr_inst_type;
        end
    end

    assign o_exu_pc            =  r_exu_pc;
    assign o_idu_ctr_ram_byt   =  r_idu_ctr_ram_byt;
    assign o_exu_res           =  r_exu_res;
    assign o_ram_rd_data       =  r_ram_rd_data;
    assign o_idu_ctr_ram_wr_en =  r_idu_ctr_ram_wr_en;
    assign o_gpr_rs2_data      =  r_gpr_rs2_data;
    assign o_idu_ctr_inst_type =  r_idu_ctr_inst_type;
    assign o_idu_ctr_inst_type =  r_idu_ctr_inst_type;

endmodule
