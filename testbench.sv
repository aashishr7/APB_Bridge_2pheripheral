`include "interface.sv"
`include "uvm_macros.svh"
`include "test_1.sv"

module ahb_ram_tb;
  
  bit clk;
  bit rst;
  
  always #5 clk = ~clk;
  
 initial begin 
    rst = 0;
    #5 rst =1;
    #15 rst =0;
    #10 rst = 1;
  end
  
  intf vif(clk, rst);
  
  apb_bridge_system DUT(.PCLK(vif.clk),
                          .PRESETn(vif.rst),
                          .PSEL(vif.psel), 
                          .PADDR(vif.paddr),
                          .PENABLE(vif.pen),
                          .PWRITE(vif.wr_en),
                          .PWDATA(vif.pwdata),
                          .PRDATA(vif.prdata),
                          .PREADY(vif.pready),
                          .PSLVERR(vif.pselverr)
                          
                         );
  
  
 initial begin
    // set interface in config_db
    uvm_config_db#(virtual intf)::set(uvm_root::get(), "*", "vif", vif);
    // Dump waves
    $dumpfile("dump.vcd");
    $dumpvars(0);
  end
  
  initial begin
    run_test("test_1");
    #500;
    $finish();
  end
  
endmodule
