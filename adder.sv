// RISC-V SiMPLE SV -- adder module
// BSD 3-Clause License
// (c) 2017-2019, Arthur Matos, Marcus Vinicius Lamar, Universidade de Brasília,
//                Marek Materzok, University of Wrocław

`ifndef CONFIG_AND_CONSTANTS
    `include "config.sv"
`endif

module adder #(
    parameter  WIDTH = 32 ) (
        input  [WIDTH-1:0] operand_a,
        input  [WIDTH-1:0] operand_b,
        output reg [WIDTH-1:0] result
);

always @ (*) begin
    result = operand_a + operand_b;
end

endmodule

