module Sobel_Edge_Detector #(
    parameter  SOBEL_THRESHOLD = 250 //Sobel ��ֵ
)(
    input       clk,             //cmos ����ʱ��
    input       rst_n,  
    //����ǰ����
    input       per_frame_vsync, 
    input       per_frame_href,  
    input       per_frame_clken, 
    input [7:0] per_img_y,       
    //����������
    output      post_frame_vsync, 
    output      post_frame_href,  
    output      post_frame_clken, 
    output      post_img_bit    
);
//reg define 
reg [9:0]  gx_temp2; //������ֵ
reg [9:0]  gx_temp1; //��һ��ֵ
reg [9:0]  gx_data;  //x�����ƫ����
reg [9:0]  gy_temp1; //��һ��ֵ
reg [9:0]  gy_temp2; //������ֵ
reg [9:0]  gy_data;  //y�����ƫ����
reg [20:0] gxy_square;
reg [15:0] per_frame_vsync_r;
reg [15:0] per_frame_href_r; 
reg [15:0] per_frame_clken_r;

//wire define 
wire        matrix_frame_vsync; 
wire        matrix_frame_href;  
wire        matrix_frame_clken; 
wire [10:0] dim;
//���3X3 ����
wire [7:0]  matrix_p11; 
wire [7:0]  matrix_p12; 
wire [7:0]  matrix_p13; 
wire [7:0]  matrix_p21; 
wire [7:0]  matrix_p22; 
wire [7:0]  matrix_p23;
wire [7:0]  matrix_p31; 
wire [7:0]  matrix_p32; 
wire [7:0]  matrix_p33;

//*****************************************************
//**                    main code
//*****************************************************

assign post_frame_vsync = per_frame_vsync_r[10];
assign post_frame_href  = per_frame_href_r[10] ;
assign post_frame_clken = per_frame_clken_r[10];
assign post_img_bit     = post_frame_href ? post_img_bit_r : 1'b0;

//3x3����
matrix_generate_3x3_8bit u_matrix_generate_3x3_8bit(
    .clk                 (clk),    
    .rst_n               (rst_n),
    //Ԥ��������
    .per_frame_vsync     (per_frame_vsync), 
    .per_frame_href      (per_frame_href),  
    .per_frame_clken     (per_frame_clken), 
    .per_img_y           (per_img_y),       
    
    //����������
    .matrix_frame_vsync  (matrix_frame_vsync), 
    .matrix_frame_href   (matrix_frame_href),  
    .matrix_frame_clken  (matrix_frame_clken), 
    .matrix_p11          (matrix_p11), 
    .matrix_p12          (matrix_p12), 
    .matrix_p13          (matrix_p13), //��� 3X3 ����
    .matrix_p21          (matrix_p21), 
    .matrix_p22          (matrix_p22),  
    .matrix_p23          (matrix_p23),
    .matrix_p31          (matrix_p31), 
    .matrix_p32          (matrix_p32),  
    .matrix_p33          (matrix_p33)
);

//Sobel ����
//         gx                  gy                  ���ص�
// [   -1  0   +1  ]   [   +1  +2   +1 ]     [   P11  P12   P13 ]
// [   -2  0   +2  ]   [   0   0    0  ]     [   P21  P22   P23 ]
// [   -1  0   +1  ]   [   -1  -2   -1 ]     [   P31  P32   P33 ]

//Step 1 ����x�����ƫ����
always@(posedge clk or negedge rst_n)begin
    if(!rst_n)begin
        gy_temp1 <= 10'd0;
        gy_temp2 <= 10'd0;
        gy_data <=  10'd0;
    end
    else begin
        gy_temp1 <= matrix_p13 + (matrix_p23 << 1) + matrix_p33; 
        gy_temp2 <= matrix_p11 + (matrix_p21 << 1) + matrix_p31; 
        gy_data <= (gy_temp1 >= gy_temp2) ? gy_temp1 - gy_temp2 : 
                   (gy_temp2 - gy_temp1);
    end
end

//Step 2 ����y�����ƫ����
always@(posedge clk or negedge rst_n)begin
    if(!rst_n)begin
        gx_temp1 <= 10'd0;
        gx_temp2 <= 10'd0;
        gx_data <=  10'd0;
    end
    else begin
        gx_temp1 <= matrix_p11 + (matrix_p12 << 1) + matrix_p13; 
        gx_temp2 <= matrix_p31 + (matrix_p32 << 1) + matrix_p33; 
        gx_data <= (gx_temp1 >= gx_temp2) ? gx_temp1 - gx_temp2 : 
                   (gx_temp2 - gx_temp1);
    end
end

//Step 3 ����ƽ����
always@(posedge clk or negedge rst_n)begin
    if(!rst_n)
        gxy_square <= 21'd0;
    else
        gxy_square <= gx_data * gx_data + gy_data * gy_data;
end

//Step 4 ��ƽ�����ݶ������Ĵ�С��
cordic u_cordic(
    .aclk                     (clk),
    .s_axis_cartesian_tvalid  (1'b1),
    .s_axis_cartesian_tdata   (gxy_square),
    .m_axis_dout_tvalid       (),
   . m_axis_dout_tdata        (dim)
  );

//Step 5 ����ƽ�����������Ԥ����ֵ�Ƚ�
reg post_img_bit_r;
always@(posedge clk or negedge rst_n)begin
    if(!rst_n)
        post_img_bit_r <= 1'b0; //��ʼֵ
    else if(dim >= SOBEL_THRESHOLD)
        post_img_bit_r <= 1'b1; //��⵽��Ե1
    else
    post_img_bit_r <= 1'b0; //���Ǳ�Ե 0
end

//�ӳ�5������ͬ��
always@(posedge clk or negedge rst_n)begin
    if(!rst_n)begin
        per_frame_vsync_r <= 0;
        per_frame_href_r  <= 0;
        per_frame_clken_r <= 0;
    end
    else begin
        per_frame_vsync_r  <=  {per_frame_vsync_r[14:0],matrix_frame_vsync};
        per_frame_href_r   <=  {per_frame_href_r[14:0],matrix_frame_href};
        per_frame_clken_r  <=  {per_frame_clken_r[14:0],matrix_frame_clken};
    end
end

endmodule 