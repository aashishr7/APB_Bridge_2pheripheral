/*
 * Modified APB Module - A peripheral that uses sum values in PRDATA and PWDATA
 *
 * This module interfaces with an APB bus master, where:
 * - PRDATA always represents the sum of operands a and b
 * - PWDATA is treated as the sum and is split between operands a and b
 * 
 * Register map:
 * - Offset 0: Operand A (Read/Write)
 * - Offset 4: Operand B (Read/Write)
 * - Offset 8: Sum control register (Read only)
 */

module apb_adder(
    // APB Interface signals
    input logic        PCLK,     // Clock input
    input logic        PRESETn,  // Active low reset
    input logic        PSEL,     // Peripheral select
    input logic        PENABLE,  // Enable signal
    input logic        PWRITE,   // Write control (1=Write, 0=Read)
    input logic [31:0] PADDR,    // Address bus
    input logic [31:0] PWDATA,   // Write data bus
    output logic       PREADY,   // Slave ready signal
    output logic [31:0] PRDATA,  // Read data bus
    output logic       PSLVERR   // Error response
);
    // Internal registers for operands and result
  logic [7:0] operand_a;  // 4-bit operand A
  logic [7:0] operand_b;  // 4-bit operand B
  logic [9:0] result;     // 7-bit result to accommodate maximum sum (15 + 15 = 30)
    
    // APB state machine definition
    typedef enum logic [1:0] {
        IDLE   = 2'b00,  // Idle state - waiting for transaction
        SETUP  = 2'b01,  // Setup state - address phase
        ACCESS = 2'b10,  // Access state - data phase
        WAIT   = 2'b11   // Wait state - for multi-cycle transactions
    } state_t;
    
    state_t present_state, next_state;  // State machine variables
    
    // State Transition Logic - Sequential part of state machine
    always_ff @(posedge PCLK or negedge PRESETn) begin
        if (!PRESETn) begin
            // Reset to IDLE state on active-low reset
            present_state <= IDLE;
        end else begin
            // Move to next state on clock edge
            present_state <= next_state;
        end
    end
    
    // Next State Logic - Combinational part of state machine
    always_comb begin
        // Default case to prevent latches
        next_state = IDLE;
        
        case (present_state)
            IDLE: begin
                // Move to SETUP when peripheral is selected
                if (PSEL) begin
                    next_state = SETUP;
                end else begin
                    next_state = IDLE;
                end
            end
            
            SETUP: begin
                // Move to ACCESS when PENABLE is asserted
                if (PENABLE) begin
                    next_state = ACCESS;
                end else begin
                    next_state = SETUP;
                end
            end
            
            ACCESS: begin
                if (PREADY) begin
                    // Transaction completed
                    if (!PSEL) begin
                        // If PSEL deasserted, go to IDLE
                        next_state = IDLE;
                    end else begin
                        // If PSEL still asserted, start new transaction
                        next_state = SETUP;
                    end
                end else begin
                    // If not ready, wait
                    next_state = WAIT;
                end
            end
            
            WAIT: begin
                // Stay in WAIT state until PREADY is asserted
                if (PREADY) begin
                    next_state = ACCESS;
                end else begin
                    next_state = WAIT;
                end
            end
            
            default: next_state = IDLE;
        endcase
    end
    // Register write operation - handles PWDATA as sum a+b
    always_ff @(posedge PCLK or negedge PRESETn) begin
        if (!PRESETn) begin
            // Reset all registers
            operand_a <= 4'h0;
            operand_b <= 4'h0;
        end else if ((present_state == ACCESS) && PSEL && PENABLE && PWRITE) begin
            // Write operation in ACCESS state
          //$display("PADDR[14:13]=%0h PWDATA[3:0] =%0h operand_a=%0h  operand_b= %0h",PADDR[14:13],PWDATA[3:0] , operand_a , operand_b);
          case (PADDR[14:13])  // Use bits [3:2] for register selection (word-aligned)
                2'b00: begin
                    // When writing to operand A, update it and adjust B to maintain sum
                    operand_a = PWDATA[3:0];
                     //$display("00_1::PWDATA[3:0] =%0h operand_a=%0h  operand_b= %0h",PWDATA[3:0] , operand_a , operand_b);// Update A with lower 4 bits
                    // B becomes the remainder to maintain the sum in PWDATA
                    if (PWDATA[6:0] > PWDATA[3:0]) begin
                        operand_b = PWDATA[6:0] - PWDATA[3:0];
                      //$display("00_2::PWDATA[3:0] =%0h PWDATA[6:0]=%0h operand_a=%0h  operand_b= %0h",PWDATA[3:0],PWDATA[6:0] , operand_a , operand_b);
                    end else begin
                        operand_b = 4'h0; // Prevent underflow
                      //$display("00_3::operand_a=%0h  operand_b= %0h",PWDATA[3:0] , operand_a , operand_b);
                    end
                end
                
                2'b01: begin
                    // When writing to operand B, update it and adjust A to maintain sum
                    operand_b = PWDATA[3:0];  // Update B with lower 4 bits
                      $display("01_1::PWDATA[3:0] =%0h  operand_b= %0h",PWDATA[3:0] ,  operand_b);
                    // A becomes the remainder to maintain the sum in PWDATA
                    if (PWDATA[6:0] > PWDATA[3:0]) begin
                        operand_a = PWDATA[6:0] - PWDATA[3:0];
                         //$display("01_2::PWDATA[3:0] =%0h PWDATA[6:0]=%0h operand_a=%0h ",PWDATA[3:0],PWDATA[6:0] , operand_a );
                    end else begin
                        operand_a = 4'h0; // Prevent underflow
                         //$display("01_3:: operand_a=%0h  ", operand_a);
                    end
                end
                
                2'b10: begin
                    // When writing to sum control register, split the sum equally
                    // or as close as possible between A and B
                    operand_a = PWDATA[6:0] / 2;
                    operand_b = (PWDATA[6:0] - (PWDATA[6:0] / 2));
                end
                
                default: begin
                    // No action for invalid addresses
                end
            endcase
        end
    end

    //// Adder logic - Continuously compute the result
    always_comb begin
        result = operand_a + operand_b;
      
      //$display("Result =%0h operand_a=%0h  operand_b= %0h",result , operand_a , operand_b);
    end

    // Read data - always returns the sum regardless of address
    always_ff @(posedge PCLK or negedge PRESETn) begin
        if (!PRESETn) begin
            PRDATA = 32'h0;
         // $display("Result =%0h   PRDATA= %0h",result  , PRDATA);
        end else if ((present_state == ACCESS) && PSEL && PENABLE && !PWRITE) begin
            // Read operation always returns the sum
            PRDATA = {25'h0, result};
          //$display("Result =%0h  PRDATA= %0h",result , PRDATA);
        end
    end

    // APB control signals
    assign PREADY = 1'b1;   // Always ready (single-cycle response)
    assign PSLVERR = 1'b0;  // No errors
endmodule