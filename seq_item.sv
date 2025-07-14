

import uvm_pkg::*;
`include "uvm_macros.svh"
class seq_item extends uvm_sequence_item; 

  
  randc bit psel;                         
  rand bit [31:0] paddr;
  rand bit pen;
  randc bit wr_en;
  rand bit [31:0] pwdata;
  bit [31:0] prdata;
  bit pready;
  bit pselverr;

  
  function new(string name="seq_item");
    super.new(name);
  endfunction
  
  `uvm_object_utils_begin(seq_item)
  
    `uvm_field_int(psel, UVM_ALL_ON)
    `uvm_field_int(paddr, UVM_ALL_ON)
    `uvm_field_int(pen, UVM_ALL_ON)
    `uvm_field_int(wr_en, UVM_ALL_ON)
    `uvm_field_int(pwdata, UVM_ALL_ON)
    `uvm_field_int(prdata, UVM_ALL_ON)
    `uvm_field_int(pready, UVM_ALL_ON)
  `uvm_field_int(pselverr, UVM_ALL_ON)
 
  `uvm_object_utils_end
  constraint A1 { //paddr[12:0] inside {[13'h0000:13'h1FFF]};
    //paddr[12:0] inside {'h00ef,'h102f};
                 
                 pwdata inside {[1111:'hFFFF]};
    paddr[14:13] inside{3,3};
                               }
  
  constraint wr_en_c { soft wr_en == 1;
                       soft psel == 1;      
                     
                     }
  
endclass
    
    