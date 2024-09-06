//�ڳ��Ʊ߽��ڣ���RGB�е�R���ж�ֵ�������Ʊ߽��ⲻ����
module char_binarization # (
    parameter BIN_THRESHOLD = 128 //��ֵ����ֵ
)(
    input               clk             ,   // ʱ���ź�
    input               rst_n           ,   // ��λ�źţ�����Ч��
    //������Ƶ��
	input				per_frame_vsync,
	input				per_frame_href ,	
	input				per_frame_clken,
	input		[7:0]	per_frame_Red  ,		
    //���Ʊ߽�
    input    [9:0]      plate_boarder_up 	,//����ĳ��ƺ�ѡ����
    input    [9:0]      plate_boarder_down	,
    input    [9:0]      plate_boarder_left  ,   
    input    [9:0]      plate_boarder_right ,
    input               plate_exist_flag    ,
    //�����Ƶ��
	output	wire		post_frame_vsync,	
	output	wire		post_frame_href ,	
	output	wire		post_frame_clken,	
	output	reg         post_frame_Bit  
);

//------------------------------------------
//��������Ƶ�������ӳ٣���ȡ�����

reg			per_frame_vsync_r;
reg			per_frame_href_r ;	
reg			per_frame_clken_r;
reg [7:0]   per_frame_Red_r  ;

reg			per_frame_vsync_r2;
reg			per_frame_href_r2 ;	
reg			per_frame_clken_r2;
reg [7:0]   per_frame_Red_r2  ;

wire vsync_pos_flag;
wire vsync_neg_flag;
wire hrefr_neg_flag;

assign	post_frame_vsync =  per_frame_vsync_r2;
assign	post_frame_href  =  per_frame_href_r2 ;	
assign	post_frame_clken =  per_frame_clken_r2;
//assign  post_frame_Bit   =  per_frame_Red_r2  ;

always@(posedge clk or negedge rst_n)
if(!rst_n)begin
    per_frame_vsync_r 	<= 0;
    per_frame_href_r 	<= 0;
    per_frame_clken_r 	<= 0;
    per_frame_Red_r		<= 0;
    
    per_frame_vsync_r2 	<= 0;
    per_frame_href_r2 	<= 0;
    per_frame_clken_r2 	<= 0;
    per_frame_Red_r2    <= 0;
end
else begin
    per_frame_vsync_r   <=  per_frame_vsync	;
    per_frame_href_r    <=  per_frame_href	;
    per_frame_clken_r   <=  per_frame_clken	;
    per_frame_Red_r     <=  per_frame_Red	;
        
    per_frame_vsync_r2 	<=  per_frame_vsync_r;
    per_frame_href_r2	<=  per_frame_href_r ;
    per_frame_clken_r2 	<=  per_frame_clken_r;
    per_frame_Red_r2    <=  per_frame_Red_r  ;
end



assign vsync_pos_flag =   per_frame_vsync_r  & (~per_frame_vsync_r2);
assign vsync_neg_flag = (~per_frame_vsync_r) &   per_frame_vsync_r2;
assign hrefr_neg_flag = (~per_frame_href_r)  &   per_frame_href_r2;

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
//��ֵ��
always @(posedge clk or negedge rst_n)
if(!rst_n)
    post_frame_Bit <= 1'b0;
else if(plate_exist_flag)
    if((y_cnt > plate_boarder_up  ) && (y_cnt < plate_boarder_down ) &&
       (x_cnt > plate_boarder_left) && (x_cnt < plate_boarder_right)  ) begin
        if(per_frame_Red_r > BIN_THRESHOLD)  //��ֵ
            post_frame_Bit <= 1'b1;
        else
            post_frame_Bit <= 1'b0;
    end
    else
        post_frame_Bit <= 1'b0;
else begin
    if(per_frame_Red_r > BIN_THRESHOLD)  //��ֵ
        post_frame_Bit <= 1'b1;
    else
        post_frame_Bit <= 1'b0;
end

//always@(posedge clk or negedge rst_n)
//if(!rst_n) begin
//    post_frame_vsync <= 1'd0;
//    post_frame_href  <= 1'd0;
//    post_frame_clken <= 1'd0;
//end
//else begin
//    post_frame_vsync <= per_frame_vsync;
//    post_frame_href  <= per_frame_href ;
//    post_frame_clken <= per_frame_clken;
//end


endmodule
