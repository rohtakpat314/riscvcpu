# Hey, this is Rohtak Patwardhan on 5/30/2026.

I just finished writing the code for the single-cycle CPU. Anyway, I wanted to write a blog on my entire process going into this and how I feel about it after leaving. Along with that, I want to talk about some future updates this repository will be seeing and some
changes I'll make. 

So firstly, in my first year of college, I took Intro to Computer Engineering and
Digital Systems Fundamentals, which taught me about LC-3 Assembly and SystemVerilog
as it applied to creating modules, writing datapath vs. structural verilog, and 
understanding hardware.

Upon completing the latter course, I decided to complete the RISC-V 32-bit CPU because
the ISA was open-source, and contributing to it and designing my own CPU from scratch
seemed like a logical step-up from coursework. 

# What this is 
This is currently a single-cycle CPU (RV32I) in SystemVerilog. It consists of an
arithmetic logic unit, control unit, data memory, immediate generator, instruction 
memory, a program counter, a register file, and a fully-wired, top datapath. 

# Future Extensions

1. I intend to wire this CPU in Logisim Evolution and put pictures on this repo. 
2. I intend to implement this on a Basys FPGA board.
3. I intend to pipeline this CPU with different stages.  
4. I intend to write a Code Tutorial for both designs, once complete.
5. I intend to have a folder demonstrating different testbenches, program hex files,
and applications of this CPU, because it's cool knowing all that it can do.

Anyway, I'm going to sign off for tonight since it's 4:06 AM and my body needs some sleep.
If anyone has any questions, please reach out at rohtak.pat314@gmail.com and I will be 
answering them ASAP. If anyone sees any bugs, has any code recommendations, or wants to join this project and help with designing the further stages, please contact me and we 
can work something out.


p.s. ill add the download info, tools I used / how I used them, and the simulation instructions soon so that you can easily follow this 