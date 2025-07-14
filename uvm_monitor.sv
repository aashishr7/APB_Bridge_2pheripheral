class ram_monitor extends uvm_monitor;
  
  `uvm_component_utils(ram_monitor)
    
  uvm_analysis_port #(seq_item) mon_port;
  
  virtual intf vif;
  
  seq_item mon_txn;
  
  bit ok;

  function new(string name="ram_monitor", uvm_component parent);
    super.new(name, parent);
    mon_port = new("mon_port", this);
    mon_txn = new();
  endfunction
  
  function void build_phase(uvm_phase phase);
    super.build_phase(phase);
    `uvm_info(get_type_name(), "RAM:: MONITOR Inside build phase", UVM_HIGH);
    //$display("Inside build phase= %s", get_type_name());
    
    ok = uvm_config_db#(virtual intf)::get(uvm_root::get(),"get_name()","vif", vif);
    
    if(!ok || vif == null) begin
      `uvm_fatal(get_type_name(), "MON:: Not set at top level !! failed to get interface");
    end else begin
      `uvm_info(get_type_name(), "Interface is found", UVM_HIGH);
    end
  endfunction

  task run_phase(uvm_phase phase);
    forever begin
      @(posedge vif.MON.clk);

      // Valid APB access: only when transfer is completed
      if (vif.MON.cb_mon.psel && vif.MON.cb_mon.pen) begin
        mon_txn = seq_item::type_id::create("mon_txn", this);
        //$display("Created object of type MON:: %s", mon_txn.get_type_name());

        mon_txn.paddr     = vif.MON.cb_mon.paddr;
        mon_txn.pwdata    = vif.MON.cb_mon.pwdata;
        mon_txn.wr_en     = vif.MON.cb_mon.wr_en;
        mon_txn.psel      = vif.MON.cb_mon.psel;
        mon_txn.pen       = vif.MON.cb_mon.pen;
        mon_txn.pready    = vif.MON.cb_mon.pready;
        mon_txn.pselverr  = vif.MON.cb_mon.pselverr;

        // Wait 1 clk for valid PRDATA (especially for reads)
        if((!vif.MON.cb_mon.wr_en) & (vif.MON.cb_mon.paddr[14:13] ==2'b11) ) begin
          repeat(3)@(posedge vif.MON.clk);
          //#1;
          //@(posedge vif.MON.clk);
          // @(posedge vif.MON.clk);
          mon_txn.prdata  = vif.MON.cb_mon.prdata;
          //$display(">>>MON bits:: paddr=%0d, pwdata=%0d, prdata=%0b---vif.MON.cb_mon.prdata--%0d vif.MON.cb_mon.prdata=%0h",$bits( mon_txn.paddr),$bits( mon_txn.pwdata),$bits( mon_txn.prdata), $bits(vif.MON.cb_mon.prdata), vif.MON.cb_mon.prdata);
          //$display(">>>MON:: paddr=%0h, pwdata=%0h, prdata=%0h---%0d, wr_en=%0h, psel=%0h pen=%0h, pready=%0h",
               //    mon_txn.paddr, mon_txn.pwdata, mon_txn.prdata, $bits( mon_txn.prdata), mon_txn.wr_en, mon_txn.psel, mon_txn.pen, mon_txn.pready);
        end else  if((!vif.MON.cb_mon.wr_en) & (vif.MON.cb_mon.paddr[14:13] !=2'b11) ) begin
       // if (!vif.MON.cb_mon.wr_en) begin
          repeat(2) @(posedge vif.MON.clk);

        mon_txn.prdata    = vif.MON.cb_mon.prdata;

        //$display("MON:: paddr=%0h, pwdata=%0h, prdata=%0h, wr_en=%0h, psel=%0h pen=%0h, pready=%0h",
               //  mon_txn.paddr, mon_txn.pwdata, mon_txn.prdata, mon_txn.wr_en, mon_txn.psel, mon_txn.pen, mon_txn.pready);
        end 

        mon_port.write(mon_txn);
      end
    end
  endtask

endclass
