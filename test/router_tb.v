module router_tb();

    reg clk;
    reg resetn; 
    reg r_Sig_Read_Enable_1; 
    reg r_Sig_Read_Enable_2; 
    reg r_Sig_Read_Enable_3; 
    reg r_Valid_Packet;
    reg [7:0] r_Input_Data;
    wire [7:0] w_Output_Data_1;
    wire [7:0] w_Output_Data_2;
    wire [7:0] w_Output_Data_3;
    wire w_Output_Valid_Data_1;
    wire w_Output_Valid_Data_2;
    wire w_Output_Valid_Data_3;
    wire w_Error;
    wire w_Sig_Busy;
    integer i;


    router DUT( 
        .clk(clk), 
        .reset(resetn), 
        .i_Valid_Packet(r_Valid_Packet), 
        .i_Sig_Read_Enable_1(r_Sig_Read_Enable_1), 
        .i_Sig_Read_Enable_2(r_Sig_Read_Enable_2), 
        .i_Sig_Read_Enable_3(r_Sig_Read_Enable_3),
        .i_Input_Data(r_Input_Data), 
        .o_Output_Valid_Data_1(w_Output_Valid_Data_1), 
        .o_Output_Valid_Data_2(w_Output_Valid_Data_2), 
        .o_Output_Valid_Data_3(w_Output_Valid_Data_3), 
        .o_Error(w_Error), 
        .o_Sig_Busy(w_Sig_Busy),
        .o_Output_Data_1(w_Output_Data_1), 
        .o_Output_Data_2(w_Output_Data_2), 
        .o_Output_Data_3(w_Output_Data_3)
        );


    initial begin
        clk = 1;
        forever 
        #5 clk = ~clk;
    end
        
    task reset; begin
            resetn=1'b0;
            {
                r_Sig_Read_Enable_1, 
                r_Sig_Read_Enable_2, 
                r_Sig_Read_Enable_3, 
                r_Valid_Packet, 
                r_Input_Data
            } = 0;

            #10;
            resetn=1'b1;
        end
    endtask
        
    task pktm_gen_8;	
        reg [7:0] r_Header;
        reg [7:0] r_Payload_Data;
        reg [7:0] r_Parity;
        reg [8:0] r_Payload_Length;
        
        begin
            r_Parity=0;
            wait(!w_Sig_Busy)
            begin
            @(negedge clk);
            r_Payload_Length=8;
            r_Valid_Packet=1'b1;
            r_Header={r_Payload_Length,2'b10};
            r_Input_Data=r_Header;
            r_Parity=r_Parity^r_Input_Data;
            end
            @(negedge clk);
                        
            for(i=0;i<r_Payload_Length;i=i+1)
                begin
                wait(!w_Sig_Busy)				
                @(negedge clk);
                r_Payload_Data={$random}%256;
                r_Input_Data=r_Payload_Data;
                r_Parity=r_Parity^r_Input_Data;				
                end					
                            
            wait(!w_Sig_Busy)				
                @(negedge clk);
                r_Valid_Packet=0;				
                r_Input_Data=r_Parity;
                repeat(30)
        @(negedge clk);
        r_Sig_Read_Enable_2=1'b1;
        end
    endtask
        
    task pktm_gen_5;	
        reg [7:0] r_Header;
        reg [7:0] r_Payload_Data;
        reg [7:0] r_Parity;
        reg [4:0] r_Payload_Length;
        
        begin
            r_Parity=0;
            wait(!w_Sig_Busy)
            begin
            @(negedge clk);
            r_Payload_Length=5;
            r_Valid_Packet=1'b1;
            r_Header={r_Payload_Length,2'b10};
            r_Input_Data=r_Header;
            r_Parity=r_Parity^r_Input_Data;
            end
            @(negedge clk);
                        
            for(i=0;i<r_Payload_Length;i=i+1)
                begin
                wait(!w_Sig_Busy)				
                @(negedge clk);
                r_Payload_Data={$random}%256;
                r_Input_Data=r_Payload_Data;
                r_Parity=r_Parity^r_Input_Data;				
                end					
                            
            wait(!w_Sig_Busy)				
                @(negedge clk);
                r_Valid_Packet=0;				
                r_Input_Data=r_Parity;
                repeat(30)
        @(negedge clk);
        r_Sig_Read_Enable_3=1'b1;
        end
    endtask
        
    initial begin
        $dumpfile("router_tb.vcd");
        $dumpvars(0,router_tb);

        reset;
        #10;
        pktm_gen_8;
        pktm_gen_5;
        #1000;
        $finish;
    end
			
endmodule
