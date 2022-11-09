`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// School: Cal Poly San Luis Obispo 
// Engineer: DLI
// 
// Create Date: 11/05/2022 03:57:47 AM
// Design Name: 
// Module Name: FP_COMP
// Project Name: 
// Target Devices: 
// Tool Versions: 
// Description: 
// 
// Dependencies: N/A
// 
// Revision:
// Revision 0.01 - Implemented Add and Sub
// Revision 1.00 - Implemented Multiplicaiton
// Revision 2.00 - Implemented Division
// Revision 2.50 - Optimized Leading Zero
// Revision 3.00 - Division Optimization 
// Revision 4.00 - Overflow and Done flags added
// Additional Comments:
// 
//////////////////////////////////////////////////////////////////////////////////
module LDZ(input [15:0]A,output logic [3:0]V);
always_comb begin 
if(A[15]) begin V <= 4'b0000; end
if(~( A[15] | ~A[14])) begin V <= 4'b0001; end
if(~( A[15] | A[14] | ~A[13])) begin V <= 4'b0010; end
if(~( A[15] | A[14] | A[13] | ~A[12])) begin V <= 4'b0011; end
if(~( A[15] | A[14] | A[13] | A[12] | ~A[11])) begin V <= 4'b0100; end
if(~( A[15] | A[14] | A[13] | A[12] | A[11] | ~A[10])) begin V <= 4'b0101; end
if(~( A[15] | A[14] | A[13] | A[12] | A[11] | A[10] | ~A[9])) begin V <= 4'b0110; end
if(~( A[15] | A[14] | A[13] | A[12] | A[11] | A[10] | A[9] | ~A[8])) begin V <= 4'b0111; end
if(~( A[15] | A[14] | A[13] | A[12] | A[11] | A[10] | A[9] | A[8] | ~A[7])) begin V <= 4'b1000; end
if(~( A[15] | A[14] | A[13] | A[12] | A[11] | A[10] | A[9] | A[8] | A[7] | ~A[6])) begin V <= 4'b1001; end
if(~( A[15] | A[14] | A[13] | A[12] | A[11] | A[10] | A[9] | A[8] | A[7] | A[6] | ~A[5])) begin V <= 4'b1010; end
if(~( A[15] | A[14] | A[13] | A[12] | A[11] | A[10] | A[9] | A[8] | A[7] | A[6] | A[5] | ~A[4])) begin V <= 4'b1011; end
if(~( A[15] | A[14] | A[13] | A[12] | A[11] | A[10] | A[9] | A[8] | A[7] | A[6] | A[5] | A[4] | ~A[3])) begin V <= 4'b1100; end
if(~( A[15] | A[14] | A[13] | A[12] | A[11] | A[10] | A[9] | A[8] | A[7] | A[6] | A[5] | A[4] | A[3] | ~A[2])) begin V <= 4'b1101; end
if(~( A[15] | A[14] | A[13] | A[12] | A[11] | A[10] | A[9] | A[8] | A[7] | A[6] | A[5] | A[4] | A[3] | A[2] | ~A[1])) begin V <= 4'b1110; end
if(~( A[15] | A[14] | A[13] | A[12] | A[11] | A[10] | A[9] | A[8] | A[7] | A[6] | A[5] | A[4] | A[3] | A[2] | A[1] | ~A[0])) begin V <= 4'b1111; end
end
endmodule


module FP_TOP(
    input wire clk,
    input wire signed [15:0]FPT_A,
    input wire signed [15:0]FPT_B,
    output reg signed [15:0]FPT_ADD,
    output reg signed [15:0]FPT_SUB,
    output reg signed [15:0]FPT_MUL
    );
    
    FP_ADD ADD (.clk(clk),.FP_A(FPT_A),.FP_B(FPT_B),.FP_OUT(FPT_ADD));
    FP_SUB SUB (.clk(clk),.FP_A(FPT_A),.FP_B(FPT_B),.FP_OUT(FPT_SUB));
    FP_MUL MUL (.clk(clk),.FP_A(FPT_A),.FP_B(FPT_B),.FP_OUT(FPT_MUL));

    endmodule
    
module FP_ADD(
    input wire clk,
    input wire signed [15:0]FP_A,
    input wire signed [15:0]FP_B,
    output reg signed [15:0]FP_OUT
    );
    always_ff@(posedge clk) begin
        FP_OUT <= FP_A + FP_B;
    end
endmodule

module FP_SUB(
    input wire clk,
    input wire signed [15:0]FP_A,
    input wire signed [15:0]FP_B,
    output reg signed [15:0]FP_OUT
    );
    always_ff@(posedge clk) begin
        FP_OUT <= FP_A - FP_B;
    end
endmodule

module FP_MUL(
    input wire clk,
    input wire signed [15:0]FP_A,
    input wire signed [15:0]FP_B,
    output reg signed [15:0]FP_OUT
    );
    
    wire signed [7:0] X1,Y1;
    wire signed [7:0] X2,Y2;
    
    assign X1 = FP_A;
    assign X2=  FP_A[7:0];
    assign Y1 = FP_B[7:0];
    assign Y2 =  FP_B[15:8];
        
    
    always_ff@(posedge clk) begin
        FP_OUT <= {{X1*Y1}[7:0],{X2*Y2}[15:8]};
    end
endmodule


// A/B = OUT + REMAINDER + others....
module FP_DIV(
    input wire logic clk,
    input reg restart = 1'b0,
    input reg signed [15:0]FP_A,
    input reg signed [15:0]FP_B,


    output logic [15:0]FP_OUT,
    output logic FP_BZ = 1'b0, // busy
    output logic FP_DBZ = 1'b0, // divide by zero
    output logic done = 1'b0,
    output logic overflow = 1'b0
    );
    //TODO -- Check the actual error decrease that occurs with non double sized A ( on MSB side).
    reg signed [23:0] A;
    reg [3:0]FP_LDZA;
    LDZ LDZA (.A(FP_A),.V(FP_LDZA[3:0]));
    reg [3:0]FP_LDZB;
    LDZ LDZB (.A(FP_B),.V(FP_LDZB[3:0]));
    
    logic [4:0] iter; // iteration counter;



    reg signed [4:0] temp=0;
    always begin @ *
        temp <= FP_LDZA-FP_LDZB;
    end
    
    always begin @(posedge clk)
        if(restart) begin
            iter <= 0;
            temp <= FP_LDZA-FP_LDZB;
            //restart <= 0;
            if (FP_B == 0) begin
                FP_DBZ <=1;
                FP_BZ <=0;
                done <=1;
            end else begin
                A <= {8'b00000000,FP_A};
                done <= 0;
                FP_BZ <=1;
            end
            
        end else if (FP_BZ) begin
            if ((iter != 5'b10000) && A !=0) begin // next
                if(A>=FP_B) begin
                    A <= (A - FP_B) << 1;
                    FP_OUT[15-iter] <= 1'b1;
                    iter <= iter + 1;
                end else begin 
                    A <= A <<1;
                    FP_OUT[15-iter] <= 1'b0;
                    iter <= iter +1;
                end
            end else begin // done!
                done <= 1;
                FP_BZ <= 0;
                temp <= FP_LDZA-FP_LDZB;
                if (FP_LDZB >= 8) begin temp <= -temp; end
                if (temp > 7) begin 
                    overflow <= 1;
                end
//                    overflow <= 1;
//                end
                FP_OUT <= FP_OUT >> 7+temp+1;
            end
        end
    
    end
    
//    while((iter < 90) && (A !=0) )
//    {
//        if(A>B) {A = (sub(A,B)<<1);arr[iter++] = 1;}
//        else {A <<= 1;counter++; arr[iter++]=0;}
//    }
    
   
    

  
   
endmodule
