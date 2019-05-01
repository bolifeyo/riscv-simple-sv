// RISC-V SiMPLE SV -- data memory interface
// BSD 3-Clause License
// (c) 2017-2019, Arthur Matos, Marcus Vinicius Lamar, Universidade de Brasília,
//                Marek Materzok, University of Wrocław

`include "config.sv"
`include "constants.sv"

module data_memory_interface (
    input  clock,
    input  read_enable,
    input  write_enable,
    input  [2:0]  data_format,
    input  [31:0] address,
    input  [31:0] write_data,
    output [31:0] data_fetched
);

    logic [31:0] fetched;
    logic [31:0] position_fix;
    logic [31:0] sign_fix;
    logic [3:0]  translated_byte_enable;
    logic        is_data_memory;
    
    assign is_data_memory = (address >= `DATA_BEGIN) && (address <= `DATA_END);
    
    data_memory data_memory(
        .address    (address[16:2]),
        .byteena    (translated_byte_enable),
        .clock      (clock),
        .data       (write_data),
        .wren       (write_enable),
        .q          (fetched)
    );
    
    // calculate byte enable
    always_comb begin
       translated_byte_enable = 4'b0000;
       case (data_format[1:0])
           2'b00:   translated_byte_enable = 4'b0001 << address[1:0];
           2'b01:   translated_byte_enable = 4'b0011 << address[1:0];
           2'b10:   translated_byte_enable = 4'b1111 << address[1:0];
           default: translated_byte_enable = 4'b0000;
       endcase
    end
    
    // correct for unaligned accesses
    always_comb begin
       position_fix = fetched >> address[1:0];
    end
    
    // sign-extend if necessary
    always_comb begin
       if (data_format[2] == 0) begin
           sign_fix = 32'b0;
           case (data_format[1:0])
               2'b00:   sign_fix = {{22{position_fix[7]}}, position_fix[7:0]};
               2'b01:   sign_fix = {{16{position_fix[15]}}, position_fix[15:0]};
               2'b10:   sign_fix = position_fix[31:0];
               default: sign_fix = 32'b0;
           endcase
       end
       else             sign_fix = position_fix;
    end
    
    always_comb begin
        if (read_enable) begin
            if (is_data_memory) data_fetched = sign_fix;
            else                data_fetched = 32'hxxxxxxxx;
        end
        else                    data_fetched = 32'hxxxxxxxx;
    end
    
endmodule
