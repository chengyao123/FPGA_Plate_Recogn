`timescale 1ns/1ns
module VIP_vertical_projection #(
	parameter	[9:0]	IMG_HDISP = 10'd640,	//640*480
	parameter	[9:0]	IMG_VDISP = 10'd480
)(
	//global clock
	input				clk,  				//cmos video pixel clock
	input				rst_n,				//global reset

	//Image data prepred to be processd
	input				per_frame_vsync,//Prepared Image data vsync valid signal
	input				per_frame_href ,//Prepared Image data href vaild  signal
	input				per_frame_clken,//Prepared Image data output/capture enable clock
	input				per_img_Bit    ,//Prepared Image Bit flag outout(1: Value, 0:inValid)
	
	//Image data has been processd
	output				post_frame_vsync,	//Processed Image data vsync valid signal
	output				post_frame_href,	//Processed Image data href vaild  signal
	output				post_frame_clken,	//Processed Image data output/capture enable clock
	output				post_img_Bit, 		//Processed Image Bit flag outout(1: Value, 0:inValid)

    output reg [9:0] 	max_line_left ,		//��������
    output reg [9:0] 	max_line_right,
	
    input      [9:0] 	vertical_start,		//ͶӰ��ʼ��
    input      [9:0] 	vertical_end		//ͶӰ������	     
);

reg [9:0] 	max_pixel_left ;
reg [9:0] 	max_pixel_right;

reg			per_frame_vsync_r;
reg			per_frame_href_r;	
reg			per_frame_clken_r;
reg  		per_img_Bit_r;

reg			per_frame_vsync_r2;
reg			per_frame_href_r2;	
reg			per_frame_clken_r2;
reg         per_img_Bit_r2;

assign	post_frame_vsync 	= 	per_frame_vsync_r2;
assign	post_frame_href 	= 	per_frame_href_r2;	
assign	post_frame_clken 	= 	per_frame_clken_r2;
assign  post_img_Bit     	=   per_img_Bit_r2;

//------------------------------------------
//lag 1 clocks signal sync  
always@(posedge clk or negedge rst_n)begin
if(!rst_n)begin
    per_frame_vsync_r2 	<= 0;
    per_frame_href_r2 	<= 0;
    per_frame_clken_r2 	<= 0;
    per_img_Bit_r2		<= 0;
end
else begin
    per_frame_vsync_r2 	<= 	per_frame_vsync_r 	;
    per_frame_href_r2	<= 	per_frame_href_r 	;
    per_frame_clken_r2 	<= 	per_frame_clken_r 	;
    per_img_Bit_r2		<= 	per_img_Bit_r		;
end
end

//------------------------------------------
//lag 1 clocks signal sync  
always@(posedge clk or negedge rst_n)begin
if(!rst_n) begin
    per_frame_vsync_r 	<= 0;
    per_frame_href_r 	<= 0;
    per_frame_clken_r 	<= 0;
    per_img_Bit_r		<= 0;
end
else begin
    per_frame_vsync_r 	<= 	per_frame_vsync	;
    per_frame_href_r	<= 	per_frame_href	;
    per_frame_clken_r 	<= 	per_frame_clken	;
    per_img_Bit_r	    <= 	per_img_Bit		;
end
end

wire vsync_pos_flag;
wire vsync_neg_flag;
wire hrefr_neg_flag;
assign vsync_pos_flag =   per_frame_vsync_r  & (~per_frame_vsync_r2);
assign vsync_neg_flag = (~per_frame_vsync_r) &   per_frame_vsync_r2;
assign hrefr_neg_flag = (~per_frame_href_r) & per_frame_href_r2;

//------------------------------------------
//����������ؽ���"��/��"����������õ����ݺ�����
reg [9:0]  	x_cnt;
reg [9:0]   y_cnt;
always@(posedge clk or negedge rst_n)
begin
	if(!rst_n)begin
        x_cnt <= 10'd0;
        y_cnt <= 10'd0;
    end
	else if(vsync_neg_flag)begin
        x_cnt <= 10'd0;
        y_cnt <= 10'd0;
    end
    else if(hrefr_neg_flag)begin
        x_cnt <= 10'd0;
        y_cnt <= y_cnt + 1'b1;
    end
    else if(per_frame_clken_r) begin
        x_cnt <= x_cnt + 1'b1;
    end
end

//------------------------------------------
//�Ĵ�"��/��"�������
reg [9:0]  	x_cnt_d1;
reg [9:0]   y_cnt_d1;
reg [9:0]  	x_cnt_r;
reg [9:0]   y_cnt_r;

always@(posedge clk or negedge rst_n)
begin
	if(!rst_n)
		begin
			x_cnt_r <= 10'd0;
			y_cnt_r <= 10'd0;
		end
	else begin
			x_cnt_d1 <= x_cnt;
			x_cnt_r  <= x_cnt_d1;
            y_cnt_d1 <= y_cnt;
            y_cnt_r  <= y_cnt_d1;
		end
end

//------------------------------------------
//��ֱ����ͶӰ
reg  		clken_d1;
reg  		ram_wr;
wire  [9:0]	ram_wr_data;
wire  [9:0]	ram_rd_data;

always @ (posedge clk or negedge rst_n) begin
    if(!rst_n) begin
        clken_d1  <= 1'b0;
        ram_wr    <= 1'b0;
    end
    else if(per_frame_clken)begin
        clken_d1  <= 1'b1;
        ram_wr <= clken_d1;
    end
    else begin
        clken_d1  <= 1'b0;
        ram_wr <= clken_d1;
    end
end

//����֡����ͶӰ
// assign ram_wr_data = (y_cnt == 10'd0) ? 10'd0 : 					//��һ�У���ʼ��RAMΪ0
//                         per_img_Bit_r ? ram_rd_data + 1'b1 :
//                             ram_rd_data;
//��ָ��������֮�����ͶӰ

assign ram_wr_data = (y_cnt == 10'd0) ? 10'd0 : 					//��һ�У���ʼ��RAMΪ0
                        ((y_cnt > vertical_start) && (y_cnt < vertical_end)) ? (ram_rd_data + per_img_Bit_r) :  
                            ram_rd_data;

//ram	u_projection_ram (
//	.wrclock 	( clk ),
//	.wren 		( ram_wr ),
//	.wraddress 	( x_cnt_r ),
//	.data 		( ram_wr_data ),
	
//	.rdclock 	( clk ),
//	.rdaddress 	( x_cnt ),
//	.q 			( ram_rd_data )
//	);
projection_ram u_projection_ram (
  .clka  (clk           ),// input wire clka
  .wea   (ram_wr        ),// input wire [0 : 0] wea
  .addra (x_cnt_d1       ),// input wire [9 : 0] addra
  .dina  (ram_wr_data   ),// input wire [9 : 0] dina
  
  .clkb  (clk           ),// input wire clkb
  .addrb (x_cnt         ),// input wire [9 : 0] addrb
  .doutb (ram_rd_data   ) // output wire [9 : 0] doutb
);
//ila_0 u_ila_0 (
//	.clk       (clk        ), // input wire clk
//	.probe0    (x_cnt_r    ), // input wire [9:0]  probe0  
//	.probe1    (ram_wr_data), // input wire [9:0]  probe1 
//	.probe2    (x_cnt      ), // input wire [9:0]  probe2 
//	.probe3    (ram_rd_data), // input wire [9:0]  probe3 
//	.probe4    (ram_wr     )  // input wire [0:0]  probe4
//);
//ila_projection u_ila_projection (
//	.clk   (clk            ), // input wire clk
//	.probe0(per_frame_vsync), // input wire [0:0]  probe0  
//	.probe1(per_frame_href ), // input wire [0:0]  probe1 
//	.probe2(per_frame_clken), // input wire [0:0]  probe2 
//	.probe3(per_img_Bit    ), // input wire [0:0]  probe3 
//	.probe4(ram_wr     ), // input wire [0:0]  probe4 
//	.probe5(x_cnt_d1    ), // input wire [9:0]  probe5 
//	.probe6(ram_wr_data), // input wire [9:0]  probe6 
//	.probe7(x_cnt      ), // input wire [9:0]  probe7 
//	.probe8(ram_rd_data), // input wire [9:0]  probe8 
//	.probe9 (rd_data_d1  ), // input wire [9:0]  probe9 
//	.probe10(max_x1    ), // input wire [9:0]  probe10 
//	.probe11(max_x2    ), // input wire [9:0]  probe11 
//	.probe12(y_cnt     ),// input wire [9:0]  probe12
//	.probe13(clk) // input wire [0:0]  probe13
//);

reg [9:0] rd_data_d1;
reg [9:0] rd_data_d2;
reg [9:0] rd_data_d3;
reg [9:0] rd_data_d4;
reg [9:0] rd_data_d5;

always @ (posedge clk or negedge rst_n) begin
    if(!rst_n) begin
        rd_data_d1 <= 10'd0;
        rd_data_d2 <= 10'd0;
        rd_data_d3 <= 10'd0;
        rd_data_d4 <= 10'd0;
        rd_data_d5 <= 10'd0;
    end
    else if(per_frame_clken) begin
        rd_data_d1 <= ram_rd_data;
        rd_data_d2 <= rd_data_d1;
        rd_data_d3 <= rd_data_d2;
        rd_data_d4 <= rd_data_d3;
        rd_data_d5 <= rd_data_d4;
	end
end

reg [9:0] max_num1  ;
reg [9:0] max_x1    ;
reg [9:0] max_num2  ;
reg [9:0] max_x2    ;

always @ (posedge clk or negedge rst_n) begin
    if(!rst_n) begin
        max_num1 <= 10'd0;
        max_x1   <= 10'd0;
        max_num2 <= 10'd0;
        max_x2   <= 10'd0;
    end
    else if(per_frame_clken) begin

        if(y_cnt == IMG_VDISP - 1'b1) begin    
		
//			if((rd_data_d5 == 10'd0) && (ram_rd_data > 10'd30)) begin	//������
////			    max_x1		<= x_cnt_r-5;
//			    max_x1		<= x_cnt_r-2;
//				max_num1	<= rd_data_d1;
//			end	
//			else if((rd_data_d5 == 10'd0) && (ram_rd_data > 10'd30)) begin	//������
//			    max_x1		<= x_cnt_r-2;
//				max_num1	<= rd_data_d1;
//			end
            //�������о�
			if( (rd_data_d2 > rd_data_d1) && (rd_data_d2>10'd30) && (max_x1==10'd0))begin//��һ������ֵ����30
			    max_x1		<= x_cnt_r-2;
				max_num1	<= rd_data_d1;
			end	
			//�½����о�
			if( (rd_data_d2 < rd_data_d1) && (rd_data_d2>10'd30)) begin//���һ������ֵ����30
			    max_x2   	<= x_cnt_r-2;
				max_num2  	<= rd_data_d1;
			end
        end
	end
	else if(vsync_neg_flag) begin
		max_num1 <= 10'd0;
		max_x1   <= 10'd0;
		max_num2 <= 10'd0;
		max_x2   <= 10'd0;
	end
end

always @ (posedge clk or negedge rst_n) begin
    if(!rst_n) begin
        max_line_left  <= 10'd0;
        max_line_right <= 10'd0;
        max_pixel_left  <= 10'd0;
        max_pixel_right <= 10'd0;
    end
    else if(vsync_pos_flag) begin
		max_line_left   <= max_x1;
		max_pixel_left  <= max_num1;
		
		max_line_right  <= max_x2;
		max_pixel_right <= max_num2;
    end   
end

endmodule
