class ram_agent extends uvm_agent;
  
  `uvm_component_utils(ram_agent)
  
  ram_sequencer seqr;
  ram_driver drv;
  ram_monitor mon;
  
  function new(string name="ram_agent", uvm_component parent);
    super.new(name, parent);
  endfunction
  
  function void build_phase(uvm_phase phase);
    super.build_phase(phase);
    `uvm_info(get_type_name(), "RAM:: AGENT", UVM_HIGH);
    $display("Inside build phase= %s", get_type_name());
    
    mon = ram_monitor::type_id::create("mon", this);
    $display("Created object of type AGT :: %s", mon.get_type_name());
    
    if(get_is_active == UVM_ACTIVE) begin
      seqr = ram_sequencer::type_id::create("seqr", this);
      $display("Created object of type AGT :: %s", seqr.get_type_name());
      drv = ram_driver::type_id::create("drv", this);
      $display("Created object of type AGT:: %s", drv.get_type_name());
      
      
      
    end
  endfunction
  
  function void connect_phase(uvm_phase phase);
   
    
    if(get_is_active == UVM_ACTIVE) begin
      drv.seq_item_port.connect(seqr.seq_item_export) ;
      
    end
    
  endfunction
  
 // function run_phase(uvm_phase phase);
   // super.run_phase(phase);
 // endfunction
  
endclass