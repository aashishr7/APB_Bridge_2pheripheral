
//you can use uvm_analysis_imp instead of uvm_analysis_export + fifo if you want to directly receive transactions into the scoreboard without using a FIFO.

class ram_scb extends uvm_scoreboard;

  `uvm_component_utils(ram_scb)

  // Direct analysis implementation port (monitor connects to this)
  uvm_analysis_imp #(seq_item, ram_scb) scb_export;

  // Reference model: sparse RAM of 32-bit data
  bit [31:0] mem_model [*];

  int check_count;

  //----------------------
  // Constructor
  //----------------------
  function new(string name = "ram_scb", uvm_component parent = null);
    super.new(name, parent);
  endfunction

  //----------------------
  // Build phase
  //----------------------
  function void build_phase(uvm_phase phase);
    super.build_phase(phase);
    scb_export = new("scb_imp", this);
  endfunction

  //----------------------
  // write(): Called when monitor sends a txn
  //----------------------
  function void write(seq_item txn);
    if (txn.psel && txn.pen && txn.pready) begin
      if (txn.wr_en) begin
        // Write operation
        if(txn.paddr[14:13] == 2'b00) begin
          mem_model[txn.paddr] = (txn.pwdata[3:0]+(txn.pwdata[6:0]-txn.pwdata[3:0]));               
          `uvm_info(get_type_name(),
          $sformatf("T=%0t WRITE: Addr=0x%0h Data=0x%0h", $time, txn.paddr, txn.pwdata), UVM_LOW);
          
        end else if(txn.paddr[14:13] == 2'b01) begin
          
          mem_model[txn.paddr] = ((txn.pwdata[6:0]-txn.pwdata[3:0])+txn.pwdata[3:0]);              
           `uvm_info(get_type_name(),
          $sformatf("T=%0t WRITE: Addr=0x%0h Data=0x%0h", $time, txn.paddr, txn.pwdata), UVM_LOW);
        end else if(txn.paddr[14:13] == 2'b10)begin
          mem_model[txn.paddr] = ((txn.pwdata[6:0] / 2)+(txn.pwdata[6:0] - (txn.pwdata[6:0] / 2)));  
        end  else if(txn.paddr[14:13] == 2'b11) begin
          mem_model[txn.paddr] = txn.pwdata;
        end
      
      end
      else begin
        // Read operation
        if (!mem_model.exists(txn.paddr)) begin
         // `uvm_warning(get_type_name(),
         //   $sformatf("READ BEFORE WRITE @ Addr=0x%0h: Actual=0x%0h", txn.paddr, txn.prdata));
        end 
        else if (txn.prdata !== mem_model[txn.paddr]) begin
          `uvm_error(get_type_name(),
            $sformatf("READ MISMATCH @ Addr=0x%0h: Expected=0x%0h, Got=0x%0h",
              txn.paddr, mem_model[txn.paddr], txn.prdata));
        end 
        else begin
          `uvm_info(get_type_name(),
            $sformatf("T=%0t <<< READ MATCH >>> Addr=0x%0h: Expected=0x%0h, Got=0x%0h",
              $time, txn.paddr, mem_model[txn.paddr], txn.prdata), UVM_LOW);
        end
        check_count++;
      end
    end
  endfunction
  
   //----------------------
  // start_of_simulation_phase: Print configuration
  //----------------------
  function void start_of_simulation_phase(uvm_phase phase);
    super.start_of_simulation_phase(phase);
    `uvm_info(get_type_name(), $sformatf("Scoreboard Configuration:"), UVM_NONE);
  endfunction

  //----------------------
  // report_phase(): Print summary
  //----------------------
  function void report_phase(uvm_phase phase);
    super.report_phase(phase);
    `uvm_info(get_type_name(), "\n=== RAM Scoreboard Statistics ===", UVM_NONE);
    `uvm_info(get_type_name(),
      $sformatf("RAM SCB: Total Read Checks = %0d", check_count), UVM_NONE);
  endfunction

 
  
  
    
  
endclass

