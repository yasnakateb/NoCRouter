module router( 
    clk, 
    reset, 
    i_Valid_Packet, 
    i_Sig_Read_Enable_1, 
    i_Sig_Read_Enable_2, 
    i_Sig_Read_Enable_3,
    i_Input_Data, 
    o_Output_Valid_Data_1, 
    o_Output_Valid_Data_2, 
    o_Output_Valid_Data_3, 
    o_Error, 
    o_Sig_Busy,
    o_Output_Data_1, 
    o_Output_Data_2, 
    o_Output_Data_3
    );


    input clk; 
    input reset; 
    input i_Valid_Packet; 
    input i_Sig_Read_Enable_1; 
    input i_Sig_Read_Enable_2; 
    input i_Sig_Read_Enable_3;
    input [7:0]i_Input_Data; 
    output o_Output_Valid_Data_1; 
    output o_Output_Valid_Data_2; 
    output o_Output_Valid_Data_3; 
    output o_Error; 
    output o_Sig_Busy;
    output [7:0]o_Output_Data_1; 
    output [7:0] o_Output_Data_2; 
    output [7:0] o_Output_Data_3;

    wire [2:0]w_Sig_Write_Enable;
    wire [2:0]w_Soft_Reset;
    wire [2:0]w_Sig_Read_Enable; 
    wire [2:0]w_Sig_Empty;
    wire [2:0]w_Sig_Full;
    wire w_Load_First_Data_State;
    wire [7:0]w_Temp_Output_Data[2:0];
    wire [7:0]w_Output_Data;
    wire w_Parity_Done;
    wire w_Sig_Fifo_Full;
    wire w_Sig_Address_Detected;
    wire w_State_Load_Data;
    wire w_State_Load_After;    
    wire w_Sig_Write_Enable_Reg;
    wire w_Sig_Low_Packet_Valid;
    wire w_Reset_Low_Packet_Valid;

    genvar a;

    assign w_Sig_Read_Enable[0]= i_Sig_Read_Enable_1;
    assign w_Sig_Read_Enable[1]= i_Sig_Read_Enable_2;
    assign w_Sig_Read_Enable[2]= i_Sig_Read_Enable_3;
    assign  o_Output_Data_1=w_Temp_Output_Data[0];
    assign o_Output_Data_2=w_Temp_Output_Data[1];
    assign o_Output_Data_3=w_Temp_Output_Data[2];


    register register1( 
        .clk( clk ), 
        .reset( reset ), 
        .i_Sig_Packet_Valid( i_Valid_Packet ), 
        .i_Input_Data( i_Input_Data ), 
        .i_Sig_Fifo_Full( w_Sig_Fifo_Full ), 
        .i_Sig_Address_Detected( w_Sig_Address_Detected ), 
        .i_Load_Data_State( w_State_Load_Data ),  
        .i_Load_After_State( w_State_Load_After ), 
        .i_Full_State( w_Sig_Full_state ), 
        .i_Load_First_Data_State( w_Load_First_Data_State ), 
        .i_Reset_Low_Packet_Valid( w_Reset_Low_Packet_Valid ), 
        .o_Output_Data( w_Output_Data ),  
        .o_Error( o_Error ), 
        .o_Sig_Parity_Done( w_Parity_Done ), 
        .o_Sig_Low_Packet_Valid( w_Sig_Low_Packet_Valid )
    );


    fsm fsm1( 
        .clk( clk ), 
        .reset( reset ), 
        .i_Sig_Packet_Valid( i_Valid_Packet ), 
        .i_Input_Data( i_Input_Data[1:0] ), 
        .i_Sig_Soft_Reset_1( w_Soft_Reset[0] ), 
        .i_Sig_Soft_Reset_2( w_Soft_Reset[1] ), 
        .i_Sig_Soft_Reset_3( w_Soft_Reset[2] ), 
        .i_Sig_Fifo_Full( w_Sig_Fifo_Full ), 
        .i_Sig_Fifo_1_Empty( w_Sig_Empty[0] ), 
        .i_Sig_Low_Packet_Valid( w_Sig_Low_Packet_Valid ), 
        .i_Sig_Fifo_2_Empty( w_Sig_Empty[1] ), 
        .i_Sig_Fifo_3_Empty( w_Sig_Empty[2] ),
        .o_Sig_Parity_Done( w_Parity_Done ), 
        .o_Sig_Busy( o_Sig_Busy ), 
        .o_Reset_Low_Packet_Valid_Reg( w_Reset_Low_Packet_Valid ), 
        .o_Full_State( w_Sig_Full_state ), 
        .o_Load_First_Data_State( w_Load_First_Data_State ), 
        .o_Load_After_State( w_State_Load_After ), 
        .o_Load_Data_State( w_State_Load_Data ), 
        .o_Sig_Address_Detected( w_Sig_Address_Detected ), 
        .o_Sig_Write_Enable_Reg( w_Sig_Write_Enable_Reg )
    );


    synchronizer synchronizer1( 
        .clk( clk ), 
        .reset( reset ), 
        .i_Input_Data( i_Input_Data[1:0] ), 
        .i_Sig_Address_Detected( w_Sig_Address_Detected ), 
        .i_Sig_Full_1( w_Sig_Full[0] ), 
        .i_Sig_Full_2( w_Sig_Full[1] ), 
        .i_Sig_Full_3( w_Sig_Full[2] ), 
        .i_Sig_Read_Enable_1( w_Sig_Read_Enable[0] ), 
        .i_Sig_Read_Enable_2( w_Sig_Read_Enable[1] ), 
        .i_Sig_Read_Enable_3( w_Sig_Read_Enable[2] ), 
        .i_Sig_Write_Enable_Reg( w_Sig_Write_Enable_Reg ), 
        .i_Sig_Empty_1( w_Sig_Empty[0] ),
        .i_Sig_Empty_2( w_Sig_Empty[1] ), 
        .i_Sig_Empty_3( w_Sig_Empty[2] ), 
        .o_Valid_Output_1( o_Output_Valid_Data_1 ), 
        .o_Valid_Output_2( o_Output_Valid_Data_2 ), 
        .o_Valid_Output_3( o_Output_Valid_Data_3 ), 
        .o_Sig_Soft_Reset_1( w_Soft_Reset[0] ), 
        .o_Sig_Soft_Reset_2( w_Soft_Reset[1] ), 
        .o_Sig_Soft_Reset_3( w_Soft_Reset[2] ), 
        .o_Sig_Write_Enable( w_Sig_Write_Enable ), 
        .o_Fifo_Full( w_Sig_Fifo_Full )
    );


    generate 
        for( a=0; a<3; a=a+1 ) begin:fifo
            fifo f( 
                .clk( clk ), 
                .reset( reset ), 
                .i_Sig_Soft_Reset( w_Soft_Reset[a] ),
                .i_Load_First_Data_State( w_Load_First_Data_State ), 
                .i_Sig_Write_Enable( w_Sig_Write_Enable[a] ), 
                .i_Input_Data( w_Output_Data ), 
                .i_Sig_Read_Enable( w_Sig_Read_Enable[a] ), 
                .o_Sig_Full( w_Sig_Full[a] ), 
                .o_Sig_Empty( w_Sig_Empty[a] ), 
                .o_Output_Data( w_Temp_Output_Data[a] )
             );
        end
    endgenerate     

endmodule