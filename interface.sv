

interface intf(input logic clk, input logic rst);
  
  logic [31:0] paddr;
  logic wr_en;
  logic psel;
  logic pen;
  logic [31:0] pwdata;
  logic [31:0] prdata;
  logic pready;
  logic pselverr;

  clocking cb_drv @(posedge clk);
    default input #1 output #1;
    
     output paddr;
     output wr_en;
     output psel;
     output pen;
     output pwdata;
  
     input prdata;
     input pready;
     input pselverr;
    
  endclocking
  
    clocking cb_mon @(posedge clk);
    default input #1 output #1;
    
     input paddr;
     input wr_en;
     input psel;
     input pen;
     input pwdata;
  
     input prdata;
     input pready;
     input pselverr;
    
  endclocking
  
  modport DUT(clocking cb_drv, input clk, input rst);
    
  modport MON(clocking cb_mon, input clk, input rst);
    
endinterface