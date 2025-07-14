`include "uvm_macros.svh"
import uvm_pkg::*;

class ram_sequencer extends uvm_sequencer#(seq_item);
  
  `uvm_component_utils(ram_sequencer)
  
  function new(string name="ram_sequencer", uvm_component parent);
    super.new(name, parent);
    
  endfunction
  
  function void build_phase(uvm_phase phase);
    super.build_phase(phase);
    `uvm_info(get_type_name(), "RAM:: SEQUENCER", UVM_HIGH);
    $display("Inside build phase SEQR= %s", get_type_name());
  endfunction
  
endclass
    