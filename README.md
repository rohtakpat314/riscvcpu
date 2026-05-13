# CPU 
A custom CPU, built ground-up, using the RISC-V 32-bit instruction set architecture, of which I chose a 16 instruction subset. As I continue working on this daily over the summer, I will make weekly updates (or less than weekly :) ).

Day 1: defined the instruction subset 

Day 2: researched RV32I, datapath, control logic, and microarchitecture 

Day 3: designed a fully functinal register file (reg_file.sv) --> still need to make a testbench (reg_file_tb.sv), which will be created tomorrow.

Day 4: finishde pc and instruction memory components for single-cycle 



All code is written by myself. 

During the coding process, I used a diagram to help me understand the inputs and outputs for each module. 
For learning more Verilog syntax, I referenced [HDLBits](https://hdlbits.01xz.net/wiki/Main_Page). 

For the Logisim and diagram basis, I referenced"Chuck's Tech Talk" on YouTube, which you can find [here](https://youtu.be/Z7LHCMTc0gI?si=A58NFnOHnKUldpkI). 

Finally, I used _Computer Organization and Design RISC-V Edition_ by David A. Patterson and John L. Hennessy, frequently referencing Chapter 2 and 4, 
along with Diagrams 4.9-4.11 for a clearer model of how to design the CPU and code it, along with understanding the functionality.

Last but not least, I referenced the RV32I "Green Card" online for a cheat sheet into the instructions and their entire 32-bit format, so I knew how to
wire things together, contract my digital logic into simpler, more elegant circuits, and finally to help with the immediate generator because of the 
many different formats that the imm_gen has depending on whether the instruction is S-type, I-type, R-type, etc.
