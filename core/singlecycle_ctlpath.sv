// RISC-V SiMPLE SV -- control path
// BSD 3-Clause License
// (c) 2017-2019, Arthur Matos, Marcus Vinicius Lamar, Universidade de Brasília,
//                Marek Materzok, University of Wrocław

`include "config.sv"
`include "constants.sv"

module singlecycle_ctlpath (
    input  [6:0] inst_opcode,
	input  [2:0] inst_funct3,
    input  inst_bit_30,             // for ALU op selection
`ifdef M_MODULE
    input  inst_bit_25,             // for multiplication op
`endif
	input  alu_result_equal_zero,

    output pc_write_enable,
    output regfile_write_enable,
    output alu_operand_a_select,
    output alu_operand_b_select,
    output data_mem_read_enable,
    output data_mem_write_enable,
    output [2:0] reg_writeback_select,
	output [4:0] alu_function,
    output [1:0] next_pc_select
);

	logic jal_enable;
	logic jalr_enable;
	logic branch_enable;
    logic [2:0] alu_op_type;

    singlecycle_control singlecycle_control(
        .inst_opcode            (inst_opcode),
        .inst_bit_30            (inst_bit_30),
    `ifdef M_MODULE
        .inst_bit_25            (inst_bit_25),
    `endif
        .pc_write_enable        (pc_write_enable),
        .regfile_write_enable   (regfile_write_enable),
        .alu_operand_a_select   (alu_operand_a_select),
        .alu_operand_b_select   (alu_operand_b_select),
        .alu_op_type            (alu_op_type),
        .jal_enable             (jal_enable),
        .jalr_enable            (jalr_enable),
        .branch_enable          (branch_enable),
        .data_mem_read_enable   (data_mem_read_enable),
        .data_mem_write_enable  (data_mem_write_enable),
        .reg_writeback_select   (reg_writeback_select)
    );

    control_transfer control_transfer (
        .branch_enable      (branch_enable),
        .jal_enable         (jal_enable),
        .jalr_enable        (jalr_enable),
        .result_equal_zero  (alu_result_equal_zero),
        .inst_funct3        (inst_funct3),
        .next_pc_select     (next_pc_select)
    );

    alu_control alu_control(
        .alu_op_type        (alu_op_type),
        .inst_funct3        (inst_funct3),
        .alu_function       (alu_function)
    );

endmodule

