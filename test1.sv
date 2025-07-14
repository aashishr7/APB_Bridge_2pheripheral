

`include "package.sv"
import uvm_pkg::*;
`include "uvm_macros.svh"

import ram_env_pkg::*;

class test_1 extends uvm_test;
  
  `uvm_component_utils(test_1)
  
  ram_sequence seq;
  ram_env env;
  
  function new(string name = "test_1", uvm_component parent);
    super.new(name, parent);
  endfunction
  
  function void build_phase(uvm_phase phase);
    super.build_phase(phase);
    
    env = ram_env::type_id::create("ram_env",this);
    $display("Created object of type:: TEST %s", env.get_type_name());
  endfunction
  
  function void connect_phase(uvm_phase phase);
super.connect_phase(phase);
`uvm_info("TEST_CLASS", "Connect Phase!", UVM_HIGH)
endfunction: connect_phase
  
  task run_phase(uvm_phase phase);
    super.run_phase(phase);
    
   
    //uvm_top.print_topology();
   
    
    phase.raise_objection(this);
    seq = ram_sequence::type_id::create("ram_sequence");
    $display("Created object of type: %s", seq.get_type_name());
    `uvm_info("TEST_CLASS", "Run  Phase!", UVM_HIGH)
    repeat(10) begin
      seq.start(env.ragt.seqr);
    end
    
    phase.drop_objection(this);
     `uvm_info(get_type_name, "End of testcase", UVM_LOW);  // Log end of test message
  endtask
    
endclass
    
