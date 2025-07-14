`include "uvm_macros.svh"
import uvm_pkg::*;

class ram_sequence extends uvm_sequence#(seq_item);
  
  `uvm_object_utils(ram_sequence)
  
  seq_item txn;
  
  function new(string name ="ram_sequence");
    super.new(name);
  endfunction
  

  
  task body();
  
    repeat(1) begin
      txn = seq_item::type_id::create("txn");
      //$display("Created object of type :: SEQ %s", txn.get_type_name());
      
      start_item(txn);
      
      if(!txn.randomize()) begin
        `uvm_error(get_type_name(), "!! Randomization failed !!");
      end
      else begin
        // $display( "WRITE_SEQ::  paddr=%0d, pwdata=%0d, wr_en=%0d, psel=%0d, pen=%0d, prdata=%0d\n",txn.paddr, txn.pwdata, txn.wr_en, txn.psel, txn.pen, txn.prdata);
        `uvm_info(get_type_name(), "!! Randomization success !!", UVM_HIGH);
      end
      
      finish_item(txn);
      //#10;
      
    end
    
    
     repeat(1) begin
      txn = seq_item::type_id::create("txn");
      //$display("Created object of type :: SEQ %s", txn.get_type_name());
      
      start_item(txn);
      
       if(!txn.randomize() with {txn.wr_en == 0;}) begin
        `uvm_error(get_type_name(), "!! Randomization failed !!");
      end
      else begin
       // $display( "READ_SEQ::  paddr=%0d, pwdata=%0d, wr_en=%0d, psel=%0d, pen=%0d, prdata=%0d\n",txn.paddr, txn.pwdata, txn.wr_en, txn.psel, txn.pen, txn.prdata);
        `uvm_info(get_type_name(), "!! Randomization success !!", UVM_HIGH);
      end
      
      finish_item(txn);
      //#10;
      
    end
    
    
  endtask
  
endclass
      
      
      