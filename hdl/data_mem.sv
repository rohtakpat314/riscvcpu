// 4 KB memory 

module data_mem(clk, mem_write, mem_read, addr, write_data, funct3, read_data); 

parameter MEM_SIZE = 1024; 
parameter DATA_WIDTH = 32;

input logic clk;
input logic mem_write; 
input logic mem_read;
input logic [DATA_WIDTH-1:0] addr;
input logic [DATA_WIDTH-1:0] write_data;
input logic [2:0] funct3;
output logic [DATA_WIDTH-1:0] read_data;

logic [DATA_WIDTH-1:0] memory [0:1023]; // 1024 locations 


/* 
 * Writing code allows for writing data to a unique memory location given by bits [11:2] of the address, 1024 locations
 * Can write halves (upper and lower) to memory 
 * Can also write to specific byte lanes in memory (1) (2) (3) or (4), where each byte is a group of 8 bits 
 */

always_ff @(posedge clk) begin 
    if (mem_write) begin
        case (funct3)
            3'b010: 
                memory[addr[11:2]] <= write_data;

            3'b001:
                if (addr[1])
                    memory[addr[11:2]][31:16] <= write_data[15:0];
                else 
                    memory[addr[11:2]][15:0] <= write_data[15:0];

            3'b000:
                case (addr[1:0])
                    2'b00: memory[addr[11:2]][7:0] <= write_data[7:0];
                    2'b01: memory[addr[11:2]][15:8] <= write_data[7:0];
                    2'b10: memory[addr[11:2]][23:16] <= write_data[7:0];
                    2'b11: memory[addr[11:2]][31:24] <= write_data[7:0];
                endcase
        endcase
    end
end

/* 
 * Reading is independent from the clock, no synchronization, always running 
 *
 * Code below allows for zero-extended OR sign-extended reading from upper and lower halves of the 32-bit data word
 * Code below allows for zero-extended OR sign-extended reading from 4 different bytes of the 32-bit data word 
 * Finally, can also just read the entire 32-bit data word 
 *
 * updated, 5/29/26 
 */ 

always_comb begin 
    read_data = 32'b0;
    if (mem_read) begin
        case (funct3)
            3'b010: 
                read_data = memory[addr[11:2]];

            3'b001:
                if (addr[1])
                    read_data = {{16{memory[addr[11:2]][31]}}, memory[addr[11:2]][31:16]};
                else 
                    read_data = {{16{memory[addr[11:2]][15]}}, memory[addr[11:2]][15:0]};

            3'b000:
                case (addr[1:0])
                    2'b00: read_data = {{24{memory[addr[11:2]][7]}}, memory[addr[11:2]][7:0]};
                    2'b01: read_data = {{24{memory[addr[11:2]][15]}}, memory[addr[11:2]][15:8]};
                    2'b10: read_data = {{24{memory[addr[11:2]][23]}}, memory[addr[11:2]][23:16]};
                    2'b11: read_data = {{24{memory[addr[11:2]][31]}}, memory[addr[11:2]][31:24]};
                endcase
            3'b101: 
                if (addr[1])
                    read_data = {16'b0, memory[addr[11:2]][31:16]};
                else 
                    read_data = {16'b0, memory[addr[11:2]][15:0]};
            3'b100: 
                case (addr[1:0])
                    2'b00: read_data = {24'b0, memory[addr[11:2]][7:0]};
                    2'b01: read_data = {24'b0, memory[addr[11:2]][15:8]};
                    2'b10: read_data = {24'b0, memory[addr[11:2]][23:16]};
                    2'b11: read_data = {24'b0, memory[addr[11:2]][31:24]};
                endcase
        endcase
    end
end



endmodule 