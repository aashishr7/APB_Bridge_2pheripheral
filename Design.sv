`include "ram_peripheral.v"
`include "adder_peripheral.v"
// APB Bridge System RTL Design
// This design implements a bridge connecting 1 master to 2 slaves (RAM and Adder)

// Top-level APB Bridge module
module apb_bridge_system (
    input    logic      PCLK,      // Clock
    input    logic      PRESETn,   // Reset (active low)
    // Master interface signals
    input  logic [31:0]  PADDR,     // Address
    input  logic        PWRITE,    // Write signal (1=write, 0=read)
    input  logic        PSEL,      // Device select
    input  logic        PENABLE,   // Enable signal
    input  logic [31:0]  PWDATA,    // Write data
    output logic [31:0]  PRDATA,    // Read data
    output logic        PREADY,     // Ready signal
    output reg PSLVERR
);
    // Internal signals for peripheral selection
    wire        ram_sel;
    wire        adder_sel;
    
    // Internal signals for data from peripherals
    wire [31:0] ram_prdata;
    wire [31:0] adder_prdata;
    wire        ram_ready;
    wire        adder_ready;
    wire pslverr_ram, pslverr_adder;
    
    // Address decoder - select peripheral based on address
    // Addresses 0x0000-0x0FFF: RAM
    // Addresses 0x1000-0x1FFF: Adder
  assign ram_sel   = (PSEL & (PADDR[14:13] == 2'b11));
  assign adder_sel = (PSEL & (
    (PADDR[14:13] == 2'b00) |
    (PADDR[14:13] == 2'b01) |
    (PADDR[14:13] == 2'b10) ));

    
    // Mux for read data from peripherals
 
  assign PRDATA = ram_sel   ? ram_prdata   :
                   adder_sel ? adder_prdata : 32'hAF;
  //assign PRDATA = (ram_sel && PENABLE) ? ram_prdata :
           //       (adder_sel && PENABLE) ? adder_prdata : 32'hAF;
    
    // Mux for ready signal from peripherals
    // assign ram_ready = 1;
    assign PREADY = ram_sel   ? ram_ready   :
                   adder_sel ? adder_ready : 1'b1;
    
    // Debug information for address decoding
    always @(PADDR or PSEL) begin
      if (PSEL) begin
        $display("[%0t] Bridge: ADDR=%0h,PADDR[14:13]=%0b, ram_sel=%0b,ram_prdata=%0h \/\/\ adder_sel=%0b adder_prdata=%0h PREADY=%0h", 
                 $time, PADDR, PADDR[14:13], ram_sel,ram_prdata, adder_sel,adder_prdata, PREADY);
      end
       if(ram_sel)begin
         $display("\n******\\/\\/\\/\\/\\/\\/\\ RAM Peripheral is selected \\/\\/\\/\\/\\/\\/\\/******");
        end
      if(adder_sel) begin
        $display("\n******\\/\\/\\/\\/\\/\\/\\ ADDER Peripheral is selected \\/\\/\\/\\/\\/\\/\\/******");
        end
     
    end

    // Instantiate RAM peripheral
    apb_single_port_ram ram_inst (
        .PCLK     (PCLK),
        .PRESETn  (PRESETn),
        .PADDR    (PADDR[31:0]),  // Only lower 10 bits for RAM addressing
        .PWRITE   (PWRITE),
        .PSEL     (ram_sel),
        .PENABLE  (PENABLE),
        .PWDATA   (PWDATA),
        .PRDATA   (ram_prdata),
        .PREADY   (ram_ready),
        .PSLVERR  (pslverr_ram)
    );
    
    // Instantiate Adder peripheral
    apb_adder adder_inst (
        .PCLK     (PCLK),
        .PRESETn  (PRESETn),
        .PADDR    (PADDR[31:0]),  // Only lower 12 bits for adder addressing
        .PWRITE   (PWRITE),
        .PSEL     (adder_sel),
        .PENABLE  (PENABLE),
        .PWDATA   (PWDATA),
        .PRDATA   (adder_prdata),
        .PREADY   (adder_ready),
        .PSLVERR  (pslverr_adder)
    );
  
endmodule