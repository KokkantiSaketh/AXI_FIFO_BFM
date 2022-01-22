`ifndef AXI4_MASTER_DRIVER_BFM_INCLUDED_
`define AXI4_MASTER_DRIVER_BFM_INCLUDED_

//-------------------------------------------------------
// Importing global package
//-------------------------------------------------------
import axi4_globals_pkg::*;

//--------------------------------------------------------------------------------------------
// Interface : axi4_master_driver_bfm
//  Used as the HDL driver for axi4
//  It connects with the HVL driver_proxy for driving the stimulus
//--------------------------------------------------------------------------------------------
interface axi4_master_driver_bfm(input bit aclk, 
                                 input bit aresetn,
                                 
                                 //Write Address Channel Signals
                                 output reg               [3:0]awid,
                                 output reg [ADDRESS_WIDTH-1:0]awaddr,
                                 output reg               [3:0]awlen,
                                 output reg               [2:0]awsize,
                                 output reg               [1:0]awburst,
                                 output reg               [1:0]awlock,
                                 output reg               [3:0]awcache,
                                 output reg               [2:0]awprot,
                                 output reg                    awvalid,
                                 input    	                   awready,

                                 //Write Data Channel Signals
                                 output reg    [DATA_WIDTH-1: 0]wdata,
                                 output reg [(DATA_WIDTH/8)-1:0]wstrb,
                                 output reg                     wlast,
                                 output reg                [3:0]wuser,
                                 output reg                     wvalid,
                                 input                          wready,

                                 //Write Response Channel Signals
                                 input      [3:0]bid,
                                 input      [1:0]bresp,
                                 input      [3:0]buser,
                                 input           bvalid,
                                 output	reg      bready,

                                 //Read Address Channel Signals
                                 output reg               [3:0]arid,
                                 output reg [ADDRESS_WIDTH-1:0]araddr,
                                 output reg               [7:0]arlen,
                                 output reg               [2:0]arsize,
                                 output reg               [1:0]arburst,
                                 output reg               [1:0]arlock,
                                 output reg               [3:0]arcache,
                                 output reg               [2:0]arprot,
                                 output reg               [3:0]arqos,
                                 output reg               [3:0]arregion,
                                 output reg               [3:0]aruser,
                                 output reg                    arvalid,
                                 input                         arready,

                                 //Read Data Channel Signals
                                 input                  [3:0]rid,
                                 input      [DATA_WIDTH-1: 0]rdata,
                                 input                  [1:0]rresp,
                                 input                       rlast,
                                 input                  [3:0]ruser,
                                 input                       rvalid,
                                 output	reg                  rready  
                                );  
  
  //-------------------------------------------------------
  // Importing UVM Package 
  //-------------------------------------------------------
  import uvm_pkg::*;
  `include "uvm_macros.svh" 

  //-------------------------------------------------------
  // Importing Global Package
  //-------------------------------------------------------
  import axi4_master_pkg::axi4_master_driver_proxy;

  //Variable: name
  //Used to store the name of the interface
  string name = "AXI4_MASTER_DRIVER_BFM"; 

  //Variable: axi4_master_driver_proxy_h
  //Creating the handle for master driver proxy
  axi4_master_driver_proxy axi4_master_drv_proxy_h;

  initial begin
    `uvm_info(name,$sformatf(name),UVM_LOW)
  end

  //-------------------------------------------------------
  // Task: wait_for_aresetn
  // Waiting for the system reset to be active low
  //-------------------------------------------------------
  task wait_for_aresetn();
    @(negedge aresetn);
    `uvm_info(name,$sformatf("SYSTEM RESET DETECTED"),UVM_HIGH)
    awvalid <= 1'b0;
    wvalid  <= 1'b0;
    bready  <= 1'b0;
    arvalid <= 1'b0;
    rready  <= 1'b0;
     
    @(posedge aresetn);
    `uvm_info(name,$sformatf("SYSTEM RESET DEACTIVATED"),UVM_HIGH)
  endtask : wait_for_aresetn

  //--------------------------------------------------------------------------------------------
  // Tasks written for all 5 channels in BFM are given below
  //--------------------------------------------------------------------------------------------

  //-------------------------------------------------------
  // Task: axi4_write_address_channel_task
  // This task will drive the write address signals
  //-------------------------------------------------------
  task axi4_write_address_channel_task (inout axi4_write_transfer_char_s data_write_packet, axi4_transfer_cfg_s cfg_packet);
    @(posedge aclk);

    `uvm_info(name,$sformatf("data_write_packet=\n%p",data_write_packet),UVM_HIGH)
    `uvm_info(name,$sformatf("cfg_packet=\n%p",cfg_packet),UVM_HIGH)
    `uvm_info(name,$sformatf("DRIVING_WRITE_ADDRESS_CHANNEL"),UVM_HIGH)
    
    awid    <= data_write_packet.awid;
    awaddr  <= data_write_packet.awaddr;
    awlen   <= data_write_packet.awlen;
    awsize  <= data_write_packet.awsize;
    awburst <= data_write_packet.awburst;
    awlock  <= data_write_packet.awlock;
    awcache <= data_write_packet.awcache;
    awprot  <= data_write_packet.awprot;
    awvalid <= 1'b1;
    
    `uvm_info(name,$sformatf("detect_awready = %0d",awready),UVM_HIGH)
    while(awready === 0) begin
      @(posedge aclk);
      data_write_packet.wait_count_write_address_channel++;
      `uvm_info(name,$sformatf("inside_detect_awready = %0d",awready),UVM_HIGH)
    end
    `uvm_info(name,$sformatf("After_loop_of_Detecting_awready = %0d, awvalid = %0d",awready,awvalid),UVM_HIGH)
    
    while(awvalid !== 1'b1) begin
      @(posedge aclk);
      `uvm_info(name,$sformatf("DEBUG_SAHA:: awready= %0d, awvalid=%0d",awready,awready),UVM_HIGH)
    end
     
    if(awvalid === 1) begin
      while(awready !== 1)begin
        `uvm_info(name,$sformatf("DEBUG_SAHA:: awready= %0d",awready),UVM_HIGH)
        awvalid <= 1'b1;
        @(posedge aclk);
      end
    end
    awvalid <= 1'b0;
    //end
    //@(posedge aclk);
    //awvalid <= 1'b0;

  endtask : axi4_write_address_channel_task

  //-------------------------------------------------------
  // Task: axi4_write_data_channel_task
  // This task will drive the write data signals
  //-------------------------------------------------------
  task axi4_write_data_channel_task (inout axi4_write_transfer_char_s data_write_packet, input axi4_transfer_cfg_s cfg_packet);
    
    `uvm_info(name,$sformatf("data_write_packet=\n%p",data_write_packet),UVM_HIGH)
    `uvm_info(name,$sformatf("cfg_packet=\n%p",cfg_packet),UVM_HIGH)
    `uvm_info(name,$sformatf("DRIVE TO WRITE DATA CHANNEL"),UVM_HIGH)

    // if(tx_type==WRITE) begin
    @(posedge aclk);

    for(int i=0; i<data_write_packet.awlen + 1; i++) begin
      // MSHA: repeat(data_write_packet.wait_cycles_between_beats) begin
      // MSHA:   @(posedge aclk);
      // MSHA: end
      wdata  <= data_write_packet.wdata[i];
      wstrb  <= data_write_packet.wstrb[i];
      wuser  <= data_write_packet.wuser;
      wlast  <= 1'b0;
      wvalid <= 1'b1;
      `uvm_info(name,$sformatf("DETECT_WRITE_DATA_WAIT_STATE"),UVM_HIGH)
        
      // MSHA:while(wready===0) begin
      // MSHA:  @(posedge aclk);
      // MSHA:  data_write_packet.wait_count_write_data_channel++;
      // MSHA:end

      if(data_write_packet.awlen == i)begin  
        `uvm_info(name,$sformatf("DEBUG_NA:WLAST=%0d",wlast),UVM_HIGH)
        wlast  <= 1'b1;
        `uvm_info(name,$sformatf("DEBUG_NA:After driving WLAST=%0d",wlast),UVM_HIGH)
      end

      do begin
        @(posedge aclk);
        // MSHA: data_write_packet.wait_count_write_data_channel++;
      end while(wready===0);
      
      `uvm_info(name,$sformatf("DEBUG_NA:WDATA[%0d]=%0h",i,data_write_packet.wdata[i]),UVM_HIGH)
       
    end

    //while(wvalid !== 1'b1) begin
    //  @(posedge aclk);
    //  `uvm_info(name,$sformatf("DEBUG_SAHA:: wready= %0d, wvalid=%0d",wready,wready),UVM_HIGH)
    //end
    // 
    //if(wvalid === 1) begin
    //  while(wready !== 1)begin
    //    `uvm_info(name,$sformatf("DEBUG_SAHA:: wready= %0d",wready),UVM_HIGH)
    //    wvalid <= 1'b1;
    //    @(posedge aclk);
    //  end
    //end
    //wvalid <= 1'b0;
    //wlast  <= 1'b0;

    //@(posedge aclk);
    wlast <= 1'b0;
    wvalid<= 1'b0;

    `uvm_info(name,$sformatf("WRITE_DATA_COMP data_write_packet=\n%p",data_write_packet),UVM_HIGH)
  endtask : axi4_write_data_channel_task

  //-------------------------------------------------------
  // Task: axi4_write_response_channel_task
  // This task will drive the write response signals
  //-------------------------------------------------------
  task axi4_write_response_channel_task (inout axi4_write_transfer_char_s data_write_packet, input axi4_transfer_cfg_s cfg_packet);
    @(posedge aclk);
    `uvm_info(name,$sformatf("WRITE_RESP data_write_packet=\n%p",data_write_packet),UVM_HIGH)
    `uvm_info(name,$sformatf("cfg_packet=\n%p",cfg_packet),UVM_HIGH)
    `uvm_info(name,$sformatf("DRIVE TO WRITE RESPONSE CHANNEL"),UVM_HIGH)

    while(wlast !== 1'b1) begin
      @(posedge aclk);
      `uvm_info(name,$sformatf("WAITING FOR WLAST :: %0d",wlast),UVM_HIGH);
    end

    repeat(data_write_packet.no_of_wait_states)begin
      `uvm_info(name,$sformatf("DRIVING WAIT STATES :: %0d",data_write_packet.no_of_wait_states),UVM_HIGH);
      @(posedge aclk);
      bready <= 0;
    end

    data_write_packet.bvalid = bvalid;
    data_write_packet.bid    = bid;
    data_write_packet.bresp  = bresp;
    data_write_packet.buser  = buser;
    bready <= 1'b1;

    `uvm_info(name,$sformatf("CHECKING WRITE RESPONSE :: %p",data_write_packet),UVM_HIGH);
    @(posedge aclk);
    bready <= 1'b0;

  endtask : axi4_write_response_channel_task

  //-------------------------------------------------------
  // Task: axi4_read_address_channel_task
  // This task will drive the read address signals
  //-------------------------------------------------------
  task axi4_read_address_channel_task (inout axi4_read_transfer_char_s data_read_packet, input axi4_transfer_cfg_s cfg_packet);
    @(posedge aclk);
    
    `uvm_info(name,$sformatf("data_read_packet=\n%p",data_read_packet),UVM_HIGH)
    `uvm_info(name,$sformatf("cfg_packet=\n%p",cfg_packet),UVM_HIGH)
    `uvm_info(name,$sformatf("DRIVE TO READ ADDRESS CHANNEL"),UVM_HIGH)

    arid    <= data_read_packet.arid;
    araddr  <= data_read_packet.araddr;
    arlen   <= data_read_packet.arlen;
    arsize  <= data_read_packet.arsize;
    arburst <= data_read_packet.arburst;
    arlock  <= data_read_packet.arlock;
    arcache <= data_read_packet.arcache;
    arprot  <= data_read_packet.arprot;
    arqos   <= data_read_packet.arqos;
    aruser  <= data_read_packet.aruser;
    arregion<= data_read_packet.arregion;
    arvalid <= 1'b1;

    `uvm_info(name,$sformatf("detect_awready = %0d",arready),UVM_HIGH)
    while(arready === 0) begin
      @(posedge aclk);
      data_read_packet.wait_count_read_address_channel++;
      `uvm_info(name,$sformatf("inside_detect_awready = %0d",arready),UVM_HIGH)
    end
    `uvm_info(name,$sformatf("After_loop_of_Detecting_arready = %0d",arready),UVM_HIGH)

    while(arvalid !== 1'b1) begin
      @(posedge aclk);
      `uvm_info(name,$sformatf("DEBUG_SAHA:: arready= %0d, arvalid=%0d",arready,arready),UVM_HIGH)
    end
     
    if(arvalid === 1) begin
      while(arready !== 1)begin
        `uvm_info(name,$sformatf("DEBUG_SAHA:: arready= %0d",arready),UVM_HIGH)
        arvalid <= 1'b1;
        @(posedge aclk);
      end
    end
    arvalid <= 1'b0;
    
    //@(posedge aclk);
    //arvalid <= 1'b0;

  endtask : axi4_read_address_channel_task

  //-------------------------------------------------------
  // Task: axi4_read_data_channel_task
  // This task will drive the read data signals
  //-------------------------------------------------------
  task axi4_read_data_channel_task (inout axi4_read_transfer_char_s data_read_packet, input axi4_transfer_cfg_s cfg_packet);
    @(posedge aclk);

    `uvm_info(name,$sformatf("data_read_packet=\n%p",data_read_packet),UVM_HIGH)
    `uvm_info(name,$sformatf("cfg_packet=\n%p",cfg_packet),UVM_HIGH)
    `uvm_info(name,$sformatf("DRIVE TO READ DATA CHANNEL"),UVM_HIGH)
    
    //Driving rready as low initially
    rready  <= 0;

    data_read_packet.rvalid   = rvalid;
    if(rvalid === 1'b1) begin
      repeat(data_read_packet.no_of_wait_states)begin
        `uvm_info(name,$sformatf("DRIVING WAIT STATES :: %0d",data_read_packet.no_of_wait_states),UVM_HIGH);
        @(posedge aclk);
        rready<=0;
      end
    end

    //Driving ready as high
    rready <= 1'b1;
    
    for(int i=0; i<data_read_packet.arlen + 1; i++) begin
      @(posedge aclk);
      data_read_packet.rid      = rid;
      data_read_packet.rdata[i] = rdata[i];
      data_read_packet.ruser    = ruser;
      data_read_packet.rresp    = rresp;
      `uvm_info(name,$sformatf("DEBUG_NA:RDATA[%0d]=%0h",i,data_read_packet.rdata[i]),UVM_HIGH)
      
      if(data_read_packet.arlen == i)begin  
        data_read_packet.rlast  <= rlast;
      end
      
      //while(rlast === 1'b0)begin
      //  @(posedge aclk);
      //end
    end
   
    @(posedge aclk);
    rready <= 1'b0;

  endtask : axi4_read_data_channel_task

  task axi4_wait_task();
    
    `uvm_info(name,$sformatf("DEBUG_NA:WAIT_TASK_CALLED"),UVM_HIGH)

    while(wlast !== 1'b1)begin
      @(posedge aclk);
    end

    //while(bvalid !== 1'b1)begin
    //  @(posedge aclk);
    //end

    `uvm_info(name,$sformatf("DEBUG_NA:WAIT_TASK_ENDED"),UVM_HIGH)

  endtask : axi4_wait_task

endinterface : axi4_master_driver_bfm

`endif

