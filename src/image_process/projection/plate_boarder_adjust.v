//�������Ƶı߿򣬵�����������ַ�

module plate_boarder_adjust (
	//global clock
	input				clk,  				
	input				rst_n,				

	input				per_frame_vsync,	

    input      [9:0] 	max_line_up 	,		//����ĳ��ƺ�ѡ����
    input      [9:0] 	max_line_down	,
    input      [9:0] 	max_line_left 	,     
    input      [9:0] 	max_line_right	,
	
    output reg [9:0] 	plate_boarder_up 	,  	//������ı߿�
    output reg [9:0] 	plate_boarder_down	, 
    output reg [9:0] 	plate_boarder_left 	,
    output reg [9:0] 	plate_boarder_right	,
	
	output reg 			plate_exist_flag		//��������ı߿��߱ȣ��ж��Ƿ���ڳ���	
);

reg per_frame_vsync_r;
always@(posedge clk or negedge rst_n)
begin
	if(!rst_n)
		per_frame_vsync_r 	<= 0;
	else
		per_frame_vsync_r 	<= 	per_frame_vsync	;
end
//��ͬ���ź������أ�����ı߽���Ч
wire vsync_pos_flag;
assign vsync_pos_flag = per_frame_vsync & (~per_frame_vsync_r);


//����߽�Ŀ��
wire [9:0] max_line_height;       
wire [9:0] max_line_width ;
assign max_line_height	= max_line_down  - max_line_up;
assign max_line_width   = max_line_right - max_line_left;


//��������߱ȵ�������߼����ù���ʱ����Ϊ��������VSYNC�����زŻ��õ�����ʱ�����ȶ�����
//���ƵĿ�߱ȴ���Ϊ"3��1"�����ܳ���һ���ķ�Χ���÷�Χ����Ϊ��ȵ�1/8
reg [11:0] height_mult_3;	//�߶�*3
reg [ 9:0] width_div_8;		//���/8
reg [11:0] difference;		//���
//�߶�*3
always@(posedge clk or negedge rst_n)
begin
	if(!rst_n)
		height_mult_3 	<= 12'd0;
	else
		height_mult_3  <= max_line_height + max_line_height + max_line_height;
end
//�����߱ȵ����
always@(posedge clk or negedge rst_n)
begin
	if(!rst_n)
		difference	<= 12'd0;
	else begin
		if(height_mult_3 > max_line_width)
			difference	<= height_mult_3 - max_line_width;
		else
		if(height_mult_3 <= max_line_width)
			difference	<= max_line_width - height_mult_3;
	end
end
//����������ޣ����/8
always@(posedge clk or negedge rst_n)
begin
	if(!rst_n)
		width_div_8	<= 12'd0;
	else
		width_div_8	<= max_line_width[9:3];
end


//�жϳ����Ƿ����
always@(posedge clk or negedge rst_n)
begin
	if(!rst_n)
		plate_exist_flag 	<= 0;
	else if(vsync_pos_flag) begin
	
		if(max_line_down <= max_line_up)				//���Ƶ��±߿���С���ϱ߿�
			plate_exist_flag <= 0;
		else
		if(max_line_right <= max_line_left)				//���Ƶ��ұ߿���С����߿�
			plate_exist_flag <= 0;
		else
		if(max_line_height < 10'd16)					//�߶Ȳ���С��16
			plate_exist_flag <= 0;
		else
		if(max_line_width < 10'd48)						//��Ȳ���С��48
			plate_exist_flag <= 0;
		else
		if(difference > width_div_8)					//���ƿ�߱ȵ���������
			plate_exist_flag <= 0;
		else
			plate_exist_flag <= 1;
	end
end


//����һ���������������ַ��ı߽�
reg [9:0] h_shift;	//ˮƽ����߽�ƫ���� =  width/32
reg [9:0] v_shift;	//��ֱ����߽�ƫ���� =  (heitht*3)/16
always@(posedge clk or negedge rst_n)
begin
	if(!rst_n) 
		h_shift	<= 10'd0;
	else
		h_shift	<= max_line_width[9:5];
end

always@(posedge clk or negedge rst_n)
begin
	if(!rst_n) 
		v_shift	<= 10'd0;
	else
		v_shift	<= height_mult_3[11:4];
end


//���������ı߽�
always@(posedge clk or negedge rst_n)
begin
	if(!rst_n) begin
		plate_boarder_up 	<= 10'd0;
		plate_boarder_down	<= 10'd0;
		plate_boarder_left 	<= 10'd0;
		plate_boarder_right	<= 10'd0;
	end
	else if(vsync_pos_flag) begin
		plate_boarder_up 	<= max_line_up 	  + v_shift;
		plate_boarder_down	<= max_line_down  - v_shift;
		plate_boarder_left 	<= max_line_left  + h_shift;
		plate_boarder_right	<= max_line_right - h_shift;
	end
end

endmodule