//1.���ݳ��Ƶı߽�ʶ�������ڵ�ǰ֡��������յĺ�ɫ���򣬿��Ϊ5���ء�
//2.�����ַ��ı߽�ʶ�������ڵ�ǰ֡��������յ���ɫ���򣬿��Ϊ3���ء�
module add_grid # (
	parameter	[9:0]	PLATE_WIDTH = 10'd5,
	parameter	[9:0]	CHAR_WIDTH  = 10'd3
)(
    input               clk             ,   // ʱ���ź�
    input               rst_n           ,   // ��λ�źţ�����Ч��
    //������Ƶ��
	input				per_frame_vsync     ,
	input				per_frame_href      ,	
	input				per_frame_clken     ,
	input    [15:0]     per_frame_rgb       ,		
    //���Ʊ߽�
    input    [9:0]      plate_boarder_up 	,//����ĳ��ƺ�ѡ����
    input    [9:0]      plate_boarder_down	,
    input    [9:0]      plate_boarder_left  ,   
    input    [9:0]      plate_boarder_right ,
    input               plate_exist_flag    ,
    //�ַ��߽�
    input    [9:0]     char_line_up 	    ,
    input    [9:0]     char_line_down	    ,
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
	output             post_frame_vsync     ,	
	output             post_frame_href      ,	
	output             post_frame_clken     ,	
	output reg [15:0]  post_frame_rgb       
);
reg			per_frame_vsync_r;
reg			per_frame_href_r;	
reg			per_frame_clken_r;
reg [15:0]  per_frame_rgb_r;

reg			per_frame_vsync_r2;
reg			per_frame_href_r2;	
reg			per_frame_clken_r2;
reg [15:0]  per_frame_rgb_r2;

assign	post_frame_vsync 	= 	per_frame_vsync_r2;
assign	post_frame_href 	= 	per_frame_href_r2;	
assign	post_frame_clken 	= 	per_frame_clken_r2;
//assign  post_frame_rgb     	=   per_frame_rgb_r2;
//------------------------------------------
//lag 1 �������źŽ��������ӳ٣�������ˮ�ߴ����ͬ��
always@(posedge clk or negedge rst_n)
begin
	if(!rst_n)
		begin
		per_frame_vsync_r2 	<= 0;
		per_frame_href_r2 	<= 0;
		per_frame_clken_r2 	<= 0;
		per_frame_rgb_r2		<= 0;
		end
	else
		begin
		per_frame_vsync_r2 	<= 	per_frame_vsync_r 	;
		per_frame_href_r2	<= 	per_frame_href_r 	;
		per_frame_clken_r2 	<= 	per_frame_clken_r 	;
		per_frame_rgb_r2		<= 	per_frame_rgb_r		;
		end
end

always@(posedge clk or negedge rst_n)
begin
	if(!rst_n)
		begin
		per_frame_vsync_r 	<= 0;
		per_frame_href_r 	<= 0;
		per_frame_clken_r 	<= 0;
		per_frame_rgb_r		<= 0;
		end
	else
		begin
		per_frame_vsync_r 	<= 	per_frame_vsync	;
		per_frame_href_r	<= 	per_frame_href	;
		per_frame_clken_r 	<= 	per_frame_clken	;
		per_frame_rgb_r	    <= 	per_frame_rgb   ;
	    end
end

//�õ���ͬ���źŵı���
wire vsync_pos_flag;
wire vsync_neg_flag;
wire href_pos_flag;
wire hrefr_neg_flag;
assign vsync_pos_flag = per_frame_vsync    & (~per_frame_vsync_r);
assign vsync_neg_flag = (~per_frame_vsync) & per_frame_vsync_r;
assign href_pos_flag = per_frame_href_r    & (~per_frame_href_r2);
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
	else if(vsync_pos_flag)begin
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
//��Ӻ�ɫ���Ʒ�����ɫ�ַ��߿�
always @(posedge clk or negedge rst_n)
if(!rst_n)
    post_frame_rgb <= 16'd0;
else begin
    if(((x_cnt >= plate_boarder_left ) && (x_cnt < plate_boarder_left +PLATE_WIDTH) &&
        (y_cnt >= plate_boarder_up   ) && (y_cnt <= plate_boarder_down )               ) ||//��߿�
       ((x_cnt <= plate_boarder_right) && (x_cnt > plate_boarder_right-PLATE_WIDTH) &&
        (y_cnt >= plate_boarder_up   ) && (y_cnt <= plate_boarder_down )               ) ||//�ұ߿�
       ((y_cnt >= plate_boarder_up   ) && (y_cnt < plate_boarder_up   +PLATE_WIDTH) &&
        (x_cnt >= plate_boarder_left ) && (x_cnt <= plate_boarder_right)               ) ||//�ϱ߿�
       ((y_cnt <= plate_boarder_down ) && (y_cnt > plate_boarder_down -PLATE_WIDTH) &&
        (x_cnt >= plate_boarder_left ) && (x_cnt <= plate_boarder_right)               )   //�±߿�
       ) //��ɫ���Ʒ���
        post_frame_rgb <= plate_exist_flag ? 16'hf800 : per_frame_rgb_r;//11111_000000_00000
    else if(((y_cnt >= char_line_up   ) && (y_cnt < char_line_up  +CHAR_WIDTH) &&
             (x_cnt >= char1_line_left) && (x_cnt <= char7_line_right)               ) ||//�ϱ߿�
            ((y_cnt <= char_line_down ) && (y_cnt > char_line_down-CHAR_WIDTH) &&
             (x_cnt >= char1_line_left) && (x_cnt <= char7_line_right)               ) ||//�±߿�
            ((x_cnt >= char1_line_left ) && (x_cnt < char1_line_left +CHAR_WIDTH) &&
             (y_cnt >= char_line_up    ) && (y_cnt <= char_line_down )               ) ||//�ַ�1��߿�
            ((x_cnt >= char2_line_left ) && (x_cnt < char2_line_left +CHAR_WIDTH) &&
             (y_cnt >= char_line_up    ) && (y_cnt <= char_line_down )               ) ||//�ַ�2��߿�
            ((x_cnt >= char3_line_left ) && (x_cnt < char3_line_left +CHAR_WIDTH) &&
             (y_cnt >= char_line_up    ) && (y_cnt <= char_line_down )               ) ||//�ַ�3��߿�
            ((x_cnt >= char4_line_left ) && (x_cnt < char4_line_left +CHAR_WIDTH) &&
             (y_cnt >= char_line_up    ) && (y_cnt <= char_line_down )               ) ||//�ַ�4��߿�
            ((x_cnt >= char5_line_left ) && (x_cnt < char5_line_left +CHAR_WIDTH) &&
             (y_cnt >= char_line_up    ) && (y_cnt <= char_line_down )               ) ||//�ַ�5��߿�
            ((x_cnt >= char6_line_left ) && (x_cnt < char6_line_left +CHAR_WIDTH) &&
             (y_cnt >= char_line_up    ) && (y_cnt <= char_line_down )               ) ||//�ַ�6��߿�
            ((x_cnt >= char7_line_left ) && (x_cnt < char7_line_left +CHAR_WIDTH) &&
             (y_cnt >= char_line_up    ) && (y_cnt <= char_line_down )               )   //�ַ�7��߿�
       )//��ɫ�ַ����½硢��߿�
        post_frame_rgb <= 16'h07e0;//00000_111111_00000
    else if(((x_cnt <= char1_line_right) && (x_cnt > char1_line_right-CHAR_WIDTH) &&
             (y_cnt >= char_line_up    ) && (y_cnt <= char_line_down )               ) ||//�ַ�1�ұ߿�
            ((x_cnt <= char2_line_right) && (x_cnt > char2_line_right-CHAR_WIDTH) &&
             (y_cnt >= char_line_up    ) && (y_cnt <= char_line_down )               ) ||//�ַ�2�ұ߿�
            ((x_cnt <= char3_line_right) && (x_cnt > char3_line_right-CHAR_WIDTH) &&
             (y_cnt >= char_line_up    ) && (y_cnt <= char_line_down )               ) ||//�ַ�3�ұ߿�
            ((x_cnt <= char4_line_right) && (x_cnt > char4_line_right-CHAR_WIDTH) &&
             (y_cnt >= char_line_up    ) && (y_cnt <= char_line_down )               ) ||//�ַ�4�ұ߿�
            ((x_cnt <= char5_line_right) && (x_cnt > char5_line_right-CHAR_WIDTH) &&
             (y_cnt >= char_line_up    ) && (y_cnt <= char_line_down )               ) ||//�ַ�5�ұ߿�
            ((x_cnt <= char6_line_right) && (x_cnt > char6_line_right-CHAR_WIDTH) &&
             (y_cnt >= char_line_up    ) && (y_cnt <= char_line_down )               ) ||//�ַ�6�ұ߿�
            ((x_cnt <= char7_line_right) && (x_cnt > char7_line_right-CHAR_WIDTH) &&
             (y_cnt >= char_line_up    ) && (y_cnt <= char_line_down )               )   //�ַ�7�ұ߿�
       )//��ɫ�ַ��ұ߿�
        post_frame_rgb <= 16'h001f;//00000_000000_11111
    else
        post_frame_rgb <= per_frame_rgb_r;
end

endmodule
