`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Engineer: ��Ľ
// Create Date: 2023/04/25 10:36:47
// Description: ��ģ���������ĳ����ַ��߽磬������7�����������ֵ��
//ע�����մ����ҡ����ϵ��µ�˳�����ζ�������ֵ��������0~(HOR_SPLIT*VER_SPLIT-1'b1)
//////////////////////////////////////////////////////////////////////////////////

module Get_EigenValue#(
//    parameter [3:0] HOR_SPLIT = 4'd8, //ˮƽ�и�ɼ�������
//    parameter [3:0] VER_SPLIT = 4'd5  //��ֱ�и�ɼ�������
    parameter HOR_SPLIT = 8, //ˮƽ�и�ɼ�������
    parameter VER_SPLIT = 5  //��ֱ�и�ɼ�������
)(
    //ʱ�Ӽ���λ
    input               clk             ,   // ʱ���ź�
    input               rst_n           ,   // ��λ�źţ�����Ч��
    //������Ƶ��
    input               per_frame_vsync     ,
    input               per_frame_href      ,
    input               per_frame_clken     ,
    input               per_frame_bit       ,
    //�����ַ��߽�
    input    [9:0]     char_line_up 	    ,
    input    [9:0]     char_line_down       ,
    input    [9:0]     char1_line_left      ,
    input    [9:0]     char1_line_right     ,
    input    [9:0]     char2_line_left      ,
    input    [9:0]     char2_line_right     ,
    input    [9:0]     char3_line_left      ,
    input    [9:0]     char3_line_right     ,
    input    [9:0]     char4_line_left      ,
    input    [9:0]     char4_line_right     ,
    input    [9:0]     char5_line_left      ,
    input    [9:0]     char5_line_right     ,
    input    [9:0]     char6_line_left      ,
    input    [9:0]     char6_line_right     ,
    input    [9:0]     char7_line_left      ,
    input    [9:0]     char7_line_right     ,
    //�����Ƶ��
    output               post_frame_vsync,
    output               post_frame_href ,
    output               post_frame_clken,
    output               post_frame_bit  ,
    //���7������ֵ
    output reg [(HOR_SPLIT*VER_SPLIT-1'b1):0]     char1_eigenvalue  ,
    output reg [(HOR_SPLIT*VER_SPLIT-1'b1):0]     char2_eigenvalue  ,
    output reg [(HOR_SPLIT*VER_SPLIT-1'b1):0]     char3_eigenvalue  ,
    output reg [(HOR_SPLIT*VER_SPLIT-1'b1):0]     char4_eigenvalue  ,
    output reg [(HOR_SPLIT*VER_SPLIT-1'b1):0]     char5_eigenvalue  ,
    output reg [(HOR_SPLIT*VER_SPLIT-1'b1):0]     char6_eigenvalue  ,
    output reg [(HOR_SPLIT*VER_SPLIT-1'b1):0]     char7_eigenvalue   
);

//------------------------------------------
//����ÿ���ַ�����ĳ��Ϳ�
wire [9:0] char_height = char_line_down - char_line_up;
wire [9:0] char1_width = char1_line_right - char1_line_left;
wire [9:0] char2_width = char2_line_right - char2_line_left;
wire [9:0] char3_width = char3_line_right - char3_line_left;
wire [9:0] char4_width = char4_line_right - char4_line_left;
wire [9:0] char5_width = char5_line_right - char5_line_left;
wire [9:0] char6_width = char6_line_right - char6_line_left;
wire [9:0] char7_width = char7_line_right - char7_line_left;
//�����ַ�����ı߽�
reg [9:0] char_hor_border  [HOR_SPLIT:0];
reg [9:0] char1_ver_border [VER_SPLIT:0];
reg [9:0] char2_ver_border [VER_SPLIT:0];
reg [9:0] char3_ver_border [VER_SPLIT:0];
reg [9:0] char4_ver_border [VER_SPLIT:0];
reg [9:0] char5_ver_border [VER_SPLIT:0];
reg [9:0] char6_ver_border [VER_SPLIT:0];
reg [9:0] char7_ver_border [VER_SPLIT:0];
integer j;
generate
always@(*)
if(!rst_n)begin
    for(j=0;j<(HOR_SPLIT+1);j=j+1)begin: CHAR_HOR_BORDER_CAL1
        char_hor_border[j]  <= 10'd0;
        char1_ver_border[j] <= 10'd0;
        char2_ver_border[j] <= 10'd0;
        char3_ver_border[j] <= 10'd0;
        char4_ver_border[j] <= 10'd0;
        char5_ver_border[j] <= 10'd0;
        char6_ver_border[j] <= 10'd0;
        char7_ver_border[j] <= 10'd0;
    end
end
else begin
    for(j=0;j<(HOR_SPLIT+1);j=j+1)begin: CHAR_HOR_BORDER_CAL2
        if(j==0)
            char_hor_border[j] <= char_line_up;
        else if(j==HOR_SPLIT)
            char_hor_border[j] <= char_line_down;
        else
            char_hor_border[j] <= char_height*j/HOR_SPLIT + char_line_up;
    end
    for(j=0;j<(VER_SPLIT+1);j=j+1)begin: CHAR1_BORDER_CAL2
        if(j==0)
            char1_ver_border[j] <= char1_line_left;
        else if(j==VER_SPLIT)
            char1_ver_border[j] <= char1_line_right;
        else
            char1_ver_border[j] <= char1_width*j/VER_SPLIT + char1_line_left;
    end
    for(j=0;j<(VER_SPLIT+1);j=j+1)begin: CHAR2_BORDER_CAL2
        if(j==0)
            char2_ver_border[j] <= char2_line_left;
        else if(j==VER_SPLIT)
            char2_ver_border[j] <= char2_line_right;
        else
            char2_ver_border[j] <= char2_width*j/VER_SPLIT + char2_line_left;
    end
    for(j=0;j<(VER_SPLIT+1);j=j+1)begin: CHAR3_BORDER_CAL2
        if(j==0)
            char3_ver_border[j] <= char3_line_left;
        else if(j==VER_SPLIT)
            char3_ver_border[j] <= char3_line_right;
        else
            char3_ver_border[j] <= char3_width*j/VER_SPLIT + char3_line_left;
    end
    for(j=0;j<(VER_SPLIT+1);j=j+1)begin: CHAR4_BORDER_CAL2
        if(j==0)
            char4_ver_border[j] <= char4_line_left;
        else if(j==VER_SPLIT)
            char4_ver_border[j] <= char4_line_right;
        else
            char4_ver_border[j] <= char4_width*j/VER_SPLIT + char4_line_left;
    end
    for(j=0;j<(VER_SPLIT+1);j=j+1)begin: CHAR5_BORDER_CAL2
        if(j==0)
            char5_ver_border[j] <= char5_line_left;
        else if(j==VER_SPLIT)
            char5_ver_border[j] <= char5_line_right;
        else
            char5_ver_border[j] <= char5_width*j/VER_SPLIT + char5_line_left;
    end
    for(j=0;j<(VER_SPLIT+1);j=j+1)begin: CHAR6_BORDER_CAL2
        if(j==0)
            char6_ver_border[j] <= char6_line_left;
        else if(j==VER_SPLIT)
            char6_ver_border[j] <= char6_line_right;
        else
            char6_ver_border[j] <= char6_width*j/VER_SPLIT + char6_line_left;
    end
    for(j=0;j<(VER_SPLIT+1);j=j+1)begin: CHAR7_BORDER_CAL2
        if(j==0)
            char7_ver_border[j] <= char7_line_left;
        else if(j==VER_SPLIT)
            char7_ver_border[j] <= char7_line_right;
        else
            char7_ver_border[j] <= char7_width*j/VER_SPLIT + char7_line_left;
    end
end
endgenerate
//������ַ����������������
reg [15:0] char1_total_pixels [(HOR_SPLIT*VER_SPLIT-1'b1):0];
reg [15:0] char2_total_pixels [(HOR_SPLIT*VER_SPLIT-1'b1):0];
reg [15:0] char3_total_pixels [(HOR_SPLIT*VER_SPLIT-1'b1):0];
reg [15:0] char4_total_pixels [(HOR_SPLIT*VER_SPLIT-1'b1):0];
reg [15:0] char5_total_pixels [(HOR_SPLIT*VER_SPLIT-1'b1):0];
reg [15:0] char6_total_pixels [(HOR_SPLIT*VER_SPLIT-1'b1):0];
reg [15:0] char7_total_pixels [(HOR_SPLIT*VER_SPLIT-1'b1):0];

integer m;
generate
always@(*)
if(!rst_n)begin
    for(m=0;m<(HOR_SPLIT*VER_SPLIT);m=m+1)begin: CHAR_TOTAL_PIXEL_INIT1
        char1_total_pixels[m] <= 16'd0;
        char2_total_pixels[m] <= 16'd0;
        char3_total_pixels[m] <= 16'd0;
        char4_total_pixels[m] <= 16'd0;
        char5_total_pixels[m] <= 16'd0;
        char6_total_pixels[m] <= 16'd0;
        char7_total_pixels[m] <= 16'd0;
    end
end
else begin
    for(m=0;m<(HOR_SPLIT*VER_SPLIT);m=m+1)begin: CHAR_TOTAL_PIXEL_INIT2
        char1_total_pixels[m] <= (char1_ver_border[(m%VER_SPLIT)+1]-char1_ver_border[m%VER_SPLIT])*(char_hor_border[(m/VER_SPLIT)+1]-char_hor_border[m/VER_SPLIT]);
        char2_total_pixels[m] <= (char2_ver_border[(m%VER_SPLIT)+1]-char2_ver_border[m%VER_SPLIT])*(char_hor_border[(m/VER_SPLIT)+1]-char_hor_border[m/VER_SPLIT]);
        char3_total_pixels[m] <= (char3_ver_border[(m%VER_SPLIT)+1]-char3_ver_border[m%VER_SPLIT])*(char_hor_border[(m/VER_SPLIT)+1]-char_hor_border[m/VER_SPLIT]);
        char4_total_pixels[m] <= (char4_ver_border[(m%VER_SPLIT)+1]-char4_ver_border[m%VER_SPLIT])*(char_hor_border[(m/VER_SPLIT)+1]-char_hor_border[m/VER_SPLIT]);
        char5_total_pixels[m] <= (char5_ver_border[(m%VER_SPLIT)+1]-char5_ver_border[m%VER_SPLIT])*(char_hor_border[(m/VER_SPLIT)+1]-char_hor_border[m/VER_SPLIT]);
        char6_total_pixels[m] <= (char6_ver_border[(m%VER_SPLIT)+1]-char6_ver_border[m%VER_SPLIT])*(char_hor_border[(m/VER_SPLIT)+1]-char_hor_border[m/VER_SPLIT]);
        char7_total_pixels[m] <= (char7_ver_border[(m%VER_SPLIT)+1]-char7_ver_border[m%VER_SPLIT])*(char_hor_border[(m/VER_SPLIT)+1]-char_hor_border[m/VER_SPLIT]);
    end
end
endgenerate

//------------------------------------------
//�������źŽ��������ӳ٣�����ȡ����
reg per_frame_vsync_r;
reg per_frame_href_r ;    
reg per_frame_clken_r;
reg per_frame_bit_r  ;

reg per_frame_vsync_r2;
reg per_frame_href_r2 ;    
reg per_frame_clken_r2;
reg per_frame_bit_r2  ;

wire vsyncr_pos_flag;
wire vsyncr_neg_flag;
wire hrefr_pos_flag;
wire hrefr_neg_flag;

always@(posedge clk or negedge rst_n)
if(!rst_n)begin
    per_frame_vsync_r2 <= 1'b0;
    per_frame_href_r2  <= 1'b0;
    per_frame_clken_r2 <= 1'b0;
    per_frame_bit_r2   <= 1'b0;
    
    per_frame_vsync_r  <= 1'b0;
    per_frame_href_r   <= 1'b0;
    per_frame_clken_r  <= 1'b0;
    per_frame_bit_r    <= 1'b0;
end
else begin
    per_frame_vsync_r2 <= per_frame_vsync_r;
    per_frame_href_r2  <= per_frame_href_r ;
    per_frame_clken_r2 <= per_frame_clken_r;
    per_frame_bit_r2   <= per_frame_bit_r  ;
    
    per_frame_vsync_r <= per_frame_vsync;
    per_frame_href_r  <= per_frame_href ;
    per_frame_clken_r <= per_frame_clken;
    per_frame_bit_r   <= per_frame_bit  ;
end

assign vsyncr_pos_flag =   per_frame_vsync_r  & (~per_frame_vsync_r2);
assign vsyncr_neg_flag = (~per_frame_vsync_r) &   per_frame_vsync_r2;
assign hrefr_pos_flag =   per_frame_href_r  & (~per_frame_href_r2);
assign hrefr_neg_flag = (~per_frame_href_r) &   per_frame_href_r2;

assign post_frame_vsync = per_frame_vsync_r2;
assign post_frame_href  = per_frame_href_r2 ;
assign post_frame_clken = per_frame_clken_r2;
assign post_frame_bit   = per_frame_bit_r2  ;

//------------------------------------------
//����������ؽ���"��/��"����������õ����ݺ�����
reg [9:0] x_cnt;
reg [9:0] y_cnt;
always@(posedge clk or negedge rst_n)
if(!rst_n)begin
    x_cnt <= 10'd0;
    y_cnt <= 10'd0;
end
else if(vsyncr_neg_flag)begin
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

//------------------------------------------
//�Ĵ�"��/��"�������
reg [9:0]   x_cnt_r1;
reg [9:0]   y_cnt_r1;
reg [9:0]   x_cnt_r2;
reg [9:0]   y_cnt_r2;

always@(posedge clk or negedge rst_n)
if(!rst_n)
begin
    x_cnt_r1 <= 10'd0;
    y_cnt_r1 <= 10'd0;
    x_cnt_r2 <= 10'd0;
    y_cnt_r2 <= 10'd0;
end
else begin
    x_cnt_r1 <= x_cnt;
    y_cnt_r1 <= y_cnt;
    x_cnt_r2 <= x_cnt_r1;
    y_cnt_r2 <= y_cnt_r1;
end

//------------------------------------------
//������ַ��ĸ������ڵ���������
reg [15:0] char1_pixels [(HOR_SPLIT*VER_SPLIT-1'b1):0];
reg [15:0] char2_pixels [(HOR_SPLIT*VER_SPLIT-1'b1):0];
reg [15:0] char3_pixels [(HOR_SPLIT*VER_SPLIT-1'b1):0];
reg [15:0] char4_pixels [(HOR_SPLIT*VER_SPLIT-1'b1):0];
reg [15:0] char5_pixels [(HOR_SPLIT*VER_SPLIT-1'b1):0];
reg [15:0] char6_pixels [(HOR_SPLIT*VER_SPLIT-1'b1):0];
reg [15:0] char7_pixels [(HOR_SPLIT*VER_SPLIT-1'b1):0];

integer i;
generate
always@(posedge clk or negedge rst_n)
if(!rst_n)begin
    for(i=0;i<(HOR_SPLIT*VER_SPLIT);i=i+1)begin: CHAR_PIXEL_INIT1
        char1_pixels[i] = 16'd0;
        char2_pixels[i] = 16'd0;
        char3_pixels[i] = 16'd0;
        char4_pixels[i] = 16'd0;
        char5_pixels[i] = 16'd0;
        char6_pixels[i] = 16'd0;
        char7_pixels[i] = 16'd0;
    end
end
else if(vsyncr_neg_flag)begin
    for(i=0;i<(HOR_SPLIT*VER_SPLIT);i=i+1)begin: CHAR_PIXEL_INIT2
        char1_pixels[i] = 16'd0;
        char2_pixels[i] = 16'd0;
        char3_pixels[i] = 16'd0;
        char4_pixels[i] = 16'd0;
        char5_pixels[i] = 16'd0;
        char6_pixels[i] = 16'd0;
        char7_pixels[i] = 16'd0;
    end
end
else if(per_frame_clken_r && (y_cnt<=char_line_down))begin
    for(i=0;i<(HOR_SPLIT*VER_SPLIT);i=i+1)begin: CHAR_PIXEL_CAL
        if((x_cnt >= char1_ver_border[i%VER_SPLIT]) && (x_cnt<char1_ver_border[(i%VER_SPLIT)+1]) &&
           (y_cnt >= char_hor_border[i/VER_SPLIT])  && (y_cnt<char_hor_border[(i/VER_SPLIT)+1])
          )
        char1_pixels[i] = char1_pixels[i]+per_frame_bit_r;

        if((x_cnt >= char2_ver_border[i%VER_SPLIT]) && (x_cnt<char2_ver_border[(i%VER_SPLIT)+1]) &&
           (y_cnt >= char_hor_border[i/VER_SPLIT])  && (y_cnt<char_hor_border[(i/VER_SPLIT)+1])
          )
        char2_pixels[i] = char2_pixels[i]+per_frame_bit_r;

        if((x_cnt >= char3_ver_border[i%VER_SPLIT]) && (x_cnt<char3_ver_border[(i%VER_SPLIT)+1]) &&
           (y_cnt >= char_hor_border[i/VER_SPLIT])  && (y_cnt<char_hor_border[(i/VER_SPLIT)+1])
          )
        char3_pixels[i] = char3_pixels[i]+per_frame_bit_r;

        if((x_cnt >= char4_ver_border[i%VER_SPLIT]) && (x_cnt<char4_ver_border[(i%VER_SPLIT)+1]) &&
           (y_cnt >= char_hor_border[i/VER_SPLIT])  && (y_cnt<char_hor_border[(i/VER_SPLIT)+1])
          )
        char4_pixels[i] = char4_pixels[i]+per_frame_bit_r;

        if((x_cnt >= char5_ver_border[i%VER_SPLIT]) && (x_cnt<char5_ver_border[(i%VER_SPLIT)+1]) &&
           (y_cnt >= char_hor_border[i/VER_SPLIT])  && (y_cnt<char_hor_border[(i/VER_SPLIT)+1])
          )
        char5_pixels[i] = char5_pixels[i]+per_frame_bit_r;

        if((x_cnt >= char6_ver_border[i%VER_SPLIT]) && (x_cnt<char6_ver_border[(i%VER_SPLIT)+1]) &&
           (y_cnt >= char_hor_border[i/VER_SPLIT])  && (y_cnt<char_hor_border[(i/VER_SPLIT)+1])
          )
        char6_pixels[i] = char6_pixels[i]+per_frame_bit_r;

        if((x_cnt >= char7_ver_border[i%VER_SPLIT]) && (x_cnt<char7_ver_border[(i%VER_SPLIT)+1]) &&
           (y_cnt >= char_hor_border[i/VER_SPLIT])  && (y_cnt<char_hor_border[(i/VER_SPLIT)+1])
          )
        char7_pixels[i] = char7_pixels[i]+per_frame_bit_r;
    end
end
endgenerate

//------------------------------------------
//������������������ַ�������ֵ
reg [(HOR_SPLIT*VER_SPLIT-1'b1):0] char1_eigenvalue_temp;
reg [(HOR_SPLIT*VER_SPLIT-1'b1):0] char2_eigenvalue_temp;
reg [(HOR_SPLIT*VER_SPLIT-1'b1):0] char3_eigenvalue_temp;
reg [(HOR_SPLIT*VER_SPLIT-1'b1):0] char4_eigenvalue_temp;
reg [(HOR_SPLIT*VER_SPLIT-1'b1):0] char5_eigenvalue_temp;
reg [(HOR_SPLIT*VER_SPLIT-1'b1):0] char6_eigenvalue_temp;
reg [(HOR_SPLIT*VER_SPLIT-1'b1):0] char7_eigenvalue_temp;

integer n;
generate
always@(posedge clk or negedge rst_n)
if(!rst_n)begin
    for(n=0;n<(HOR_SPLIT*VER_SPLIT);n=n+1)begin: EIGENVALUE_INI
        char1_eigenvalue_temp[n] <= 1'b0;
        char2_eigenvalue_temp[n] <= 1'b0;
        char3_eigenvalue_temp[n] <= 1'b0;
        char4_eigenvalue_temp[n] <= 1'b0;
        char5_eigenvalue_temp[n] <= 1'b0;
        char6_eigenvalue_temp[n] <= 1'b0;
        char7_eigenvalue_temp[n] <= 1'b0;
    end
end
else if(y_cnt > char_line_down)begin
    for(n=0;n<(HOR_SPLIT*VER_SPLIT);n=n+1)begin: EIGENVALUE_CAL//��ɫ���ص���ڸ������40%��Ϊ1
        char1_eigenvalue_temp[n] <= (char1_pixels[n] > ((char1_total_pixels[n]/5)<<1)) ? 1'b1 : 1'b0;
        char2_eigenvalue_temp[n] <= (char2_pixels[n] > ((char2_total_pixels[n]/5)<<1)) ? 1'b1 : 1'b0;
        char3_eigenvalue_temp[n] <= (char3_pixels[n] > ((char3_total_pixels[n]/5)<<1)) ? 1'b1 : 1'b0;
        char4_eigenvalue_temp[n] <= (char4_pixels[n] > ((char4_total_pixels[n]/5)<<1)) ? 1'b1 : 1'b0;
        char5_eigenvalue_temp[n] <= (char5_pixels[n] > ((char5_total_pixels[n]/5)<<1)) ? 1'b1 : 1'b0;
        char6_eigenvalue_temp[n] <= (char6_pixels[n] > ((char6_total_pixels[n]/5)<<1)) ? 1'b1 : 1'b0;
        char7_eigenvalue_temp[n] <= (char7_pixels[n] > ((char7_total_pixels[n]/5)<<1)) ? 1'b1 : 1'b0;
    end
end
endgenerate

//������
generate
always@(posedge clk or negedge rst_n)
if(!rst_n)begin
    for(n=0;n<(HOR_SPLIT*VER_SPLIT);n=n+1)begin: EIGENVALUE_INI2
        char1_eigenvalue[n] <= 1'b0;
        char2_eigenvalue[n] <= 1'b0;
        char3_eigenvalue[n] <= 1'b0;
        char4_eigenvalue[n] <= 1'b0;
        char5_eigenvalue[n] <= 1'b0;
        char6_eigenvalue[n] <= 1'b0;
        char7_eigenvalue[n] <= 1'b0;
    end
end
else if(y_cnt == char_line_down+1)begin
    for(n=0;n<(HOR_SPLIT*VER_SPLIT);n=n+1)begin: EIGENVALUE_SYNC//��ɫ���ص���ڸ������40%��Ϊ1
        char1_eigenvalue[n] <= char1_eigenvalue_temp[n];
        char2_eigenvalue[n] <= char2_eigenvalue_temp[n];
        char3_eigenvalue[n] <= char3_eigenvalue_temp[n];
        char4_eigenvalue[n] <= char4_eigenvalue_temp[n];
        char5_eigenvalue[n] <= char5_eigenvalue_temp[n];
        char6_eigenvalue[n] <= char6_eigenvalue_temp[n];
        char7_eigenvalue[n] <= char7_eigenvalue_temp[n];
    end
end
endgenerate

endmodule
