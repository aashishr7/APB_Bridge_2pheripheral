class ram_env extends uvm_env;
  
  ram_agent ragt;
  ram_scb rscb;
  
  `uvm_component_utils(ram_env)
  
  //constructor
  function new(string name ="ram_env", uvm_component parent);
    super.new(name, parent);
    `uvm_info("ENV_const", "Inside Constructor!", UVM_HIGH)
  endfunction
  
  //build phase
  function void build_phase(uvm_phase phase);
    super.build_phase(phase);
    `uvm_info(get_type_name(), "Inside Build_phase!", UVM_HIGH)
    
    // Create the agents and other components here
    ragt = ram_agent::type_id::create("ragt", this);
    $display("Created object of type:: ENV %s", ragt.get_type_name());
    rscb = ram_scb::type_id::create("rscb", this);
    $display("Created object of type:: ENV %s", rscb.get_type_name());
    
    // Ensure the objects are allocated before accessing them
    assert(ragt != null) else `uvm_fatal("ENV", "Failed to create ragt");
    assert(rscb != null) else `uvm_fatal("ENV", "Failed to create rscb");
  endfunction
  
  //connect phase
  function void connect_phase(uvm_phase phase);
    // Connect the components after they have been properly created
    assert(ragt != null) else `uvm_fatal("ENV", "ragt not created during build_phase");
    assert(rscb != null) else `uvm_fatal("ENV", "rscb not created during build_phase");
    
    ragt.mon.mon_port.connect(rscb.scb_export);
  endfunction
  
  function void end_of_elaboration_phase(uvm_phase phase);
  uvm_factory factory = uvm_factory::get();
  `uvm_info(get_type_name(), "Information printed from top_env::end_of_elaboration_phase method", UVM_MEDIUM)
  `uvm_info(get_type_name(), $sformatf("Verbosity threshold is %d", get_report_verbosity_level()), UVM_MEDIUM)
  uvm_top.print_topology();
  factory.print();
endfunction : end_of_elaboration_phase
  
endclass


