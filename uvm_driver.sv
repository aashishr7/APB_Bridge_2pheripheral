
class ram_driver extends uvm_driver#(seq_item);
  
  `uvm_component_utils(ram_driver)
  
  virtual intf vif;
  seq_item txn;
  bit ok;
  
  function new(string name="ram_driver", uvm_component parent);
    super.new(name, parent);
  endfunction
  
  function void build_phase(uvm_phase phase);
    super.build_phase(phase);
    `uvm_info(get_type_name(), "RAM:: DRIVER", UVM_HIGH);
    //$display("Inside build phase= %s", get_type_name());   
    
    ok = uvm_config_db#(virtual intf)::get(uvm_root::get(),"get_name()","vif", vif);
    
    if(!ok | vif == null) begin
      `uvm_fatal(get_type_name(), "DRV Not set at top level !! failed to get interface");
      
    end else begin
      `uvm_info(get_type_name(), "Interface is found", UVM_HIGH);
    end
    
  endfunction
  
  task run_phase(uvm_phase phase);
     super.run_phase(phase);
    forever begin
      seq_item_port.get_next_item(txn);
        // `uvm_info(get_type_name, $sformatf("A = %0d, B = %0d", req.a, req.b), UVM_LOW);
        reset();
        drive_write();
        drive_read();
       
      seq_item_port.item_done();
      
      
    end
  endtask
  
  task reset();
     @(posedge vif.DUT.clk) begin
      vif.DUT.rst <= 0;
         vif.DUT.cb_drv.psel <=0 ;                         
         vif.DUT.cb_drv.paddr <=0 ;
         vif.DUT.cb_drv.pen <=0 ;
         vif.DUT.cb_drv.wr_en <=0 ;
         vif.DUT.cb_drv.pwdata <=0 ;
         vif.DUT.cb_drv.prdata <=0 ;
         vif.DUT.cb_drv.pready <=0 ;
         vif.DUT.cb_drv.pselverr <=0 ;
       
       vif.DUT.rst <= 1;
     end
    
  endtask
  
  task drive_write();
    
    @(posedge vif.DUT.clk) begin

      //SETUP phase
      vif.DUT.cb_drv.psel <= 1;
      vif.DUT.cb_drv.pen <= 1;
    end
    
     @(posedge vif.DUT.clk) begin
      
      vif.DUT.cb_drv.wr_en <= 1;
    
      vif.DUT.cb_drv.paddr <= txn.paddr;
      vif.DUT.cb_drv.pwdata <= txn.pwdata;
       
    end
           
  endtask
  
    task drive_read();   
    
    @(posedge vif.DUT.clk) begin

      //SETUP phase
      vif.DUT.cb_drv.psel <= 1;
      vif.DUT.cb_drv.pen <= 1;
    end
    
    @(posedge vif.DUT.clk) begin
       
       vif.DUT.cb_drv.wr_en <= 0;
    
       vif.DUT.cb_drv.paddr <= txn.paddr;
       txn.prdata = vif.DUT.cb_drv.prdata ;
      $display("txn.prdata <=%0h vif.DUT.cb_drv.prdata =%0h ;", txn.prdata , vif.DUT.cb_drv.prdata );


    end
               
  endtask
    
  
  
endclass
    
    
  