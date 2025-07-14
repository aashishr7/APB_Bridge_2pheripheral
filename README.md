# APB_Bridge_2pheripheral
EDA playground link: https://www.edaplayground.com/x/A6a3
Here's a **detailed analysis and description** of your **APB Bridge System RTL project**, broken down into logical components and behavior:

---

## 🧾 **Project Overview**

This SystemVerilog RTL project implements a **simple APB bridge system** that connects **one APB master** to **two slave peripherals**:

* A **RAM peripheral**
* An **Adder peripheral**

The **APB Bridge** is responsible for **address decoding**, **peripheral selection**, and **data routing** between the master and the slaves.

---

## 🔧 **Included Modules**

```systemverilog
`include "ram_peripheral.v"
`include "adder_peripheral.v"
```

These files are assumed to contain the RTL definitions of:

* `apb_single_port_ram`: APB-compatible RAM slave
* `apb_adder`: APB-compatible adder logic

---

## 🏗️ **Top-Level Module: `apb_bridge_system`**

### 🔌 **Ports**

* **Clock & Reset**

  * `PCLK`: Clock
  * `PRESETn`: Active-low reset

* **APB Master Interface**

  * `PADDR [31:0]`: Address bus
  * `PWRITE`: Write signal (`1` = write, `0` = read)
  * `PSEL`: Peripheral select
  * `PENABLE`: Enable signal for APB transaction
  * `PWDATA [31:0]`: Write data
  * `PRDATA [31:0]`: Read data output from selected slave
  * `PREADY`: Ready signal from slave to master
  * `PSLVERR`: Error signal

---

## 🧠 **Key Features and Design Flow**

### 1. **Address Decoding & Peripheral Selection**

* Based on `PADDR[14:13]`, the system selects between RAM and Adder:

  * **RAM**: `PADDR[14:13] == 2'b11`
  * **Adder**: All other values (`2'b00`, `2'b01`, `2'b10`)
* Logic:

  ```systemverilog
  ram_sel   = (PSEL & (PADDR[14:13] == 2'b11));
  adder_sel = (PSEL & (PADDR[14:13] != 2'b11));
  ```

### 2. **Read Data Multiplexing**

* `PRDATA` is selected based on which slave is active:

  ```systemverilog
  PRDATA = ram_sel ? ram_prdata : adder_sel ? adder_prdata : 32'hAF;
  ```

  * If no slave is selected, returns default: `32'hAF`

### 3. **Ready Signal Multiplexing**

* `PREADY` is passed through from the active slave:

  ```systemverilog
  PREADY = ram_sel ? ram_ready : adder_sel ? adder_ready : 1'b1;
  ```

### 4. **Debug Output**

* `$display()` is used to log:

  * Current address and its upper bits
  * Selection status of RAM/Adder
  * PRDATA and PREADY values
  * Peripheral name based on selection

### 5. **Peripheral Instantiations**

#### 🔹 **RAM Instance**

```systemverilog
apb_single_port_ram ram_inst (...);
```

* Standard APB slave interface
* Handles RAM read/write operations
* Accepts full `PADDR[31:0]`, but likely uses only lower bits (e.g., `[9:0]`)

#### 🔹 **Adder Instance**

```systemverilog
apb_adder adder_inst (...);
```

* Accepts two inputs and returns their sum (assumed behavior)
* Also supports APB read/write protocol

---

## 🧪 **Design Assumptions and Notes**

* The bridge assumes that:

  * Address decoding is **cleanly divided**
  * Only one peripheral is selected at any time

* If **no peripheral is selected**, the system outputs:

  * `PRDATA = 32'hAF`
  * `PREADY = 1'b1` (default ready)

* `PSLVERR` signals from both peripherals are wired, but **top-level `PSLVERR` output is not driven**. It’s declared as `reg`, but unused — this needs correction if error handling is required.

---

## ✅ **Possible Improvements**

* Handle `PSLVERR` output like this:

  ```systemverilog
  always_comb begin
    if (ram_sel)
      PSLVERR = pslverr_ram;
    else if (adder_sel)
      PSLVERR = pslverr_adder;
    else
      PSLVERR = 0;
  end
  ```

* Improve address decoder to use a full address map (e.g., `PADDR[15:12]` or `PADDR[31:16]` if needed).

---

## 🧩 **Use Case Scenarios**

* **RAM Peripheral**:

  * Used for normal memory read/write over APB
  * Can be tested by writing and reading back data

* **Adder Peripheral**:

  * Write two operands to designated registers
  * Read the sum from result register

---

## 📚 **Summary**

* **Project Name**: APB Bridge System
* **Functionality**: Connects 1 APB master to 2 APB slaves (RAM + Adder)
* **Selection**: Based on `PADDR[14:13]`
* **Flexibility**: Simple design, easily extendable
* **Debugging**: Built-in `$display()` for monitoring address mapping and peripheral activity

---

Here is a **block diagram** representation of your `apb_bridge_system`, which connects **1 APB master** to **2 APB slaves**: `ram_peripheral` and `adder_peripheral`.

### 📦 APB Bridge System Block Diagram

                    +----------------------+
                    |   APB Master (CPU)   |
                    |                      |
                    |   PADDR, PWRITE,     |
                    |   PWDATA, PENABLE,   |
                    |   PSEL, PREADY,      |
                    |   PRDATA             |
                    +----------+-----------+
                               |
                               | APB Signals
                               v
                    +----------+-----------+
                    |      APB Bridge      |  <== apb_bridge_system
                    |                      |
                    |   Address Decode     |
                    |   PSELx Generation   |
                    +----+------------+----+
                         |            |
                         |            |
         +---------------+            +----------------+
         |                                         |
         v                                         v
+-----------------------+               +------------------------+
|   RAM Peripheral      |               |   Adder Peripheral     |
| (`ram_peripheral`)    |               | (`adder_peripheral`)   |
|                       |               |                        |
|  PRDATA, PREADY       |               |  PRDATA, PREADY        |
|  Interface Signals     |               |  Interface Signals     |
+-----------------------+               +------------------------+
```

### Key Signal Flow:

* The **APB Master** sends requests (via `PADDR`, `PWRITE`, `PWDATA`, `PENABLE`, `PSEL`) to the **APB Bridge**.
* The **APB Bridge** decodes the address (`PADDR`) and generates a `PSEL` signal for either `ram_peripheral` or `adder_peripheral`.
* The **Bridge** forwards transactions to the appropriate slave.
* Only one slave is selected at a time using `PSELx`.
* The **Bridge** returns `PRDATA` and `PREADY` back to the master based on the selected slave.



