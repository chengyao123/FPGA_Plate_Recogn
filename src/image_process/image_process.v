//****************************************Copyright (c)***********************************//
//����֧�֣�www.openedv.com
//�Ա����̣�http://openedv.taobao.com
//��ע΢�Ź���ƽ̨΢�źţ�"����ԭ��"����ѻ�ȡFPGA & STM32���ϡ�
//��Ȩ���У�����ؾ���
//Copyright(C) ����ԭ�� 2018-2028
//All rights reserved
//----------------------------------------------------------------------------------------
// File name:           vip
// Last modified Date:  2019/03/22 16:33:40
// Last Version:        V1.0
// Descriptions:        ����ͼ����ģ���װ��
//----------------------------------------------------------------------------------------
// Created by:          ����ԭ��
// Created date:        2019/03/22 16:33:56
// Version:             V1.0
// Descriptions:        The original version
//
//----------------------------------------------------------------------------------------
//****************************************************************************************//

module image_process(
    //module clock
    input           clk            ,   // ʱ���ź�
    input           rst_n          ,   // ��λ�źţ�����Ч��

    //ͼ����ǰ�����ݽӿ�
    input           pre_frame_vsync,
    input           pre_frame_hsync,
    input           pre_frame_de   ,
    input    [15:0] pre_rgb        ,
    input    [10:0] xpos           ,
    input    [10:0] ypos           ,

    //ͼ���������ݽӿ�
    output          post_frame_vsync,  // ��ͬ���ź�
    output          post_frame_hsync,  // ��ͬ���ź�
    output          post_frame_de   ,  // ��������ʹ��
    output   [15:0] post_rgb           // RGB565��ɫ����
);

//wire define
//-----------------��һ����-----------------
//RGBתYCbCr
wire                  ycbcr_vsync;
wire                  ycbcr_hsync;
wire                  ycbcr_de   ;
wire   [ 7:0]         img_y      ;
wire   [ 7:0]         img_cb     ;
wire   [ 7:0]         img_cr     ;
//��ֵ��
wire                  binarization_vsync;
wire                  binarization_hsync;
wire                  binarization_de   ;
wire                  binarization_bit  ;
//��ʴ
wire                  erosion_vsync;
wire                  erosion_hsync;
wire                  erosion_de   ;
wire                  erosion_bit  ;
//��ֵ�˲�1
wire                  median1_vsync;
wire                  median1_hsync;
wire                  median1_de   ;
wire                  median1_bit  ;
//Sobel��Ե���
wire                  sobel_vsync;
wire                  sobel_hsync;
wire                  sobel_de   ;
wire                  sobel_bit  ;
//��ֵ�˲�2
wire                  median2_vsync;
wire                  median2_hsync;
wire                  median2_de   ;
wire                  median2_bit  ;
//����
wire                  dilation_vsync;
wire                  dilation_hsync;
wire                  dilation_de   ;
wire                  dilation_bit  ;
//ͶӰ
wire                  projection_vsync;
wire                  projection_hsync;
wire                  projection_de   ;
wire                  projection_bit  ;
wire [9:0] max_line_up  ;//ˮƽͶӰ���
wire [9:0] max_line_down;
wire [9:0] max_line_left ;//��ֱͶӰ���
wire [9:0] max_line_right;
//�������ƵĿ��
wire [9:0] plate_boarder_up   ;
wire [9:0] plate_boarder_down ;
wire [9:0] plate_boarder_left ;
wire [9:0] plate_boarder_right;
wire       plate_exist_flag   ;
//-----------------�ڶ�����-----------------
//�ַ���ֵ��
wire                  char_bin_vsync;
wire                  char_bin_hsync;
wire                  char_bin_de   ;
wire                  char_bin_bit  ;
//��ʴ
wire                  char_ero_vsync;
wire                  char_ero_hsync;
wire                  char_ero_de   ;
wire                  char_ero_bit  ;
//����
wire                  char_dila_vsync;
wire                  char_dila_hsync;
wire                  char_dila_de   ;
wire                  char_dila_bit  ;
//ͶӰ
wire char_proj_vsync;
wire char_proj_hsync;
wire char_proj_de   ;
wire char_proj_bit  ;
wire [9:0] char_line_up  ;//ˮƽͶӰ���
wire [9:0] char_line_down;
wire [9:0] char1_line_left ;//��ֱͶӰ���
wire [9:0] char1_line_right;
wire [9:0] char2_line_left ;
wire [9:0] char2_line_right;
wire [9:0] char3_line_left ;
wire [9:0] char3_line_right;
wire [9:0] char4_line_left ;
wire [9:0] char4_line_right;
wire [9:0] char5_line_left ;
wire [9:0] char5_line_right;
wire [9:0] char6_line_left ;
wire [9:0] char6_line_right;
wire [9:0] char7_line_left ;
wire [9:0] char7_line_right;

//-----------------��������-----------------
//��������ֵ
wire [39:0] char1_eigenvalue;
wire [39:0] char2_eigenvalue;
wire [39:0] char3_eigenvalue;
wire [39:0] char4_eigenvalue;
wire [39:0] char5_eigenvalue;
wire [39:0] char6_eigenvalue;
wire [39:0] char7_eigenvalue;
wire        cal_eigen_vsync;
wire        cal_eigen_hsync;
wire        cal_eigen_de   ;
wire        cal_eigen_bit  ;
//ģ��ƥ��
wire        template_vsync;
wire        template_hsync;
wire        template_de   ;
wire        template_bit  ;
wire [5:0]  match_index_char1;
wire [5:0]  match_index_char2;
wire [5:0]  match_index_char3;
wire [5:0]  match_index_char4;
wire [5:0]  match_index_char5;
wire [5:0]  match_index_char6;
wire [5:0]  match_index_char7;
//��ӱ߿�
wire           add_grid_vsync;
wire           add_grid_href ;
wire           add_grid_de   ;
wire   [15:0]  add_grid_rgb  ;
//���ս��
wire           post_frame_vsync;
wire           post_frame_href ;
wire           post_frame_de   ;
wire   [15:0]  post_rgb;
//*****************************************************
//**                    main code
//*****************************************************

//---------------------------��һ����-----------------------------
//��һ���ָ�����ɫ��ʶ�����еĳ������򣬲�����߽硣
//���ν��У�
//  1.1 RGBתYCbCr
//  1.2 ��ֵ��
//  1.3 ��ʴ
//  1.4 Sobel��Ե���
//  1.5 ����
//  1.6 ˮƽͶӰ&��ֱͶӰ-->������Ʊ߽�

//RGBתYCbCrģ��
rgb2ycbcr u1_rgb2ycbcr(
    //module clock
    .clk             (clk    ),            // ʱ���ź�
    .rst_n           (rst_n  ),            // ��λ�źţ�����Ч��
    //ͼ����ǰ�����ݽӿ�
    .pre_frame_vsync (pre_frame_vsync),    // vsync�ź�
    .pre_frame_hsync (pre_frame_hsync),    // href�ź�
    .pre_frame_de    (pre_frame_de   ),    // data enable�ź�
    .img_red         (pre_rgb[15:11] ),
    .img_green       (pre_rgb[10:5 ] ),
    .img_blue        (pre_rgb[ 4:0 ] ),
    //ͼ���������ݽӿ�
    .post_frame_vsync(ycbcr_vsync),   // vsync�ź�
    .post_frame_hsync(ycbcr_hsync),   // href�ź�
    .post_frame_de   (ycbcr_de   ),   // data enable�ź�
    .img_y           (img_y ),
    .img_cb          (img_cb),
    .img_cr          (img_cr)
);

//��ֵ��
binarization u1_binarization(
    .clk     (clk    ),   // ʱ���ź�
    .rst_n   (rst_n  ),   // ��λ�źţ�����Ч��

	.per_frame_vsync   (ycbcr_vsync),
	.per_frame_href    (ycbcr_hsync),	
	.per_frame_clken   (ycbcr_de   ),
	.per_img_Y         (img_cb     ),		

	.post_frame_vsync  (binarization_vsync),	
	.post_frame_href   (binarization_hsync),	
	.post_frame_clken  (binarization_de   ),	
	.post_img_Bit      (binarization_bit  ),		

	.Binary_Threshold  (8'd150)//�����ֵ�����÷ǳ���Ҫ
);

//��ʴ
VIP_Bit_Erosion_Detector # (
    .IMG_HDISP (10'd640),    //640*480
    .IMG_VDISP (10'd480)
)u1_VIP_Bit_Erosion_Detector(
    //Global Clock
    .clk     (clk    ),   //cmos video pixel clock
    .rst_n   (rst_n  ),   //global reset

    //Image data prepred to be processd
    .per_frame_vsync   (binarization_vsync), //Prepared Image data vsync valid signal
    .per_frame_href    (binarization_hsync), //Prepared Image data href vaild  signal
    .per_frame_clken   (binarization_de   ), //Prepared Image data output/capture enable clock
    .per_img_Bit       (binarization_bit  ), //Prepared Image Bit flag outout(1: Value, 0:inValid)
    
    //Image data has been processd
    .post_frame_vsync  (erosion_vsync),    //Processed Image data vsync valid signal
    .post_frame_href   (erosion_hsync),    //Processed Image data href vaild  signal
    .post_frame_clken  (erosion_de   ),    //Processed Image data output/capture enable clock
    .post_img_Bit      (erosion_bit  )     //Processed Image Bit flag outout(1: Value, 0:inValid)
);

////��ֵ�˲�ȥ�����
//VIP_Gray_Median_Filter # (
//	.IMG_HDISP(10'd640),	//640*480
//	.IMG_VDISP(10'd480)
//)u1_Gray_Median_Filter(
//	//global clock
//	.clk   (clk    ),  				//100MHz
//	.rst_n (rst_n  ),				//global reset

//	//Image data prepred to be processd
//	.per_frame_vsync   (erosion_vsync   ),	//Prepared Image data vsync valid signal
//	.per_frame_href    (erosion_hsync   ),	//Prepared Image data href vaild  signal
//	.per_frame_clken   (erosion_de      ),	//Prepared Image data output/capture enable clock
//	.per_img_Y         ({8{erosion_bit}}),	//Prepared Image brightness input
	
//	//Image data has been processd
//	.post_frame_vsync  (median1_vsync),	//Processed Image data vsync valid signal
//	.post_frame_href   (median1_hsync),	//Processed Image data href vaild  signal
//	.post_frame_clken  (median1_de   ),	//Processed Image data output/capture enable clock
//	.post_img_Y	   	   (median1_bit  )	//Processed Image brightness input
//);

//Sobel��Ե���
Sobel_Edge_Detector #(
    .SOBEL_THRESHOLD   (8'd128) //Sobel ��ֵ
) u1_Sobel_Edge_Detector (
    //global clock
    .clk               (clk    ),              //cmos video pixel clock
    .rst_n             (rst_n  ),                //global reset
    //Image data prepred to be processd
    .per_frame_vsync  (erosion_vsync   ),    //Prepared Image data vsync valid signal
    .per_frame_href   (erosion_hsync   ),    //Prepared Image data href vaild  signal
    .per_frame_clken  (erosion_de      ),    //Prepared Image data output/capture enable clock
    .per_img_y        ({8{erosion_bit}}),    //Prepared Image brightness input  
    //Image data has been processd
    .post_frame_vsync (sobel_vsync),    //Processed Image data vsync valid signal
    .post_frame_href  (sobel_hsync),    //Processed Image data href vaild  signal
    .post_frame_clken (sobel_de   ),    //Processed Image data output/capture enable clock
    .post_img_bit     (sobel_bit  )     //Processed Image Bit flag outout(1: Value, 0 inValid)
);

//////��ֵ�˲�ȥ�����
////VIP_Gray_Median_Filter # (
////	.IMG_HDISP(10'd640),	//640*480
////	.IMG_VDISP(10'd480)
////)u2_Gray_Median_Filter(
////	//global clock
////	.clk   (clk    ),  				//100MHz
////	.rst_n (rst_n  ),				//global reset

////	//Image data prepred to be processd
////	.per_frame_vsync   (sobel_vsync   ),	//Prepared Image data vsync valid signal
////	.per_frame_href    (sobel_hsync   ),	//Prepared Image data href vaild  signal
////	.per_frame_clken   (sobel_de      ),	//Prepared Image data output/capture enable clock
////	.per_img_Y         ({8{sobel_bit}}),	//Prepared Image brightness input
	
////	//Image data has been processd
////	.post_frame_vsync  (post_frame_vsync),	//Processed Image data vsync valid signal
////	.post_frame_href   (post_frame_hsync),	//Processed Image data href vaild  signal
////	.post_frame_clken  (post_frame_de   ),	//Processed Image data output/capture enable clock
////	.post_img_Y	   	   (post_img_bit    )	//Processed Image brightness input
////);

//����
VIP_Bit_Dilation_Detector#(
	.IMG_HDISP(10'd640),	//640*480
	.IMG_VDISP(10'd480)
)u1_VIP_Bit_Dilation_Detector(
	//global clock
	.clk   (clk    ),  				//cmos video pixel clock
	.rst_n (rst_n  ),				//global reset

	//Image data prepred to be processd
	.per_frame_vsync   (sobel_vsync   ),	//Prepared Image data vsync valid signal
	.per_frame_href    (sobel_hsync   ),	//Prepared Image data href vaild  signal
	.per_frame_clken   (sobel_de      ),	//Prepared Image data output/capture enable clock
	.per_img_Bit       (sobel_bit     ),	//Prepared Image Bit flag outout(1: Value, 0:inValid)
	
	//Image data has been processd
	.post_frame_vsync  (dilation_vsync),	//Processed Image data vsync valid signal
	.post_frame_href   (dilation_hsync),	//Processed Image data href vaild  signal
	.post_frame_clken  (dilation_de   ),	//Processed Image data output/capture enable clock
	.post_img_Bit  	   (dilation_bit  )   //Processed Image Bit flag outout(1: Value, 0:inValid)
);

//ˮƽͶӰ
VIP_horizon_projection # (
	.IMG_HDISP(10'd640),	//640*480
	.IMG_VDISP(10'd480)
)u1_VIP_horizon_projection(
	//global clock
	.clk   (clk    ),  				//cmos video pixel clock
	.rst_n (rst_n  ),				//global reset

	//Image data prepred to be processd
	.per_frame_vsync   (dilation_vsync),//Prepared Image data vsync valid signal
	.per_frame_href    (dilation_hsync),//Prepared Image data href vaild  signal
	.per_frame_clken   (dilation_de   ),//Prepared Image data output/capture enable clock
	.per_img_Bit       (dilation_bit  ),//Prepared Image Bit flag outout(1: Value, 0:inValid)
	
	//Image data has been processd
	.post_frame_vsync  (projection_vsync),//Processed Image data vsync valid signal
	.post_frame_href   (projection_hsync),//Processed Image data href vaild  signal
	.post_frame_clken  (projection_de   ),//Processed Image data output/capture enable clock
	.post_img_Bit      (projection_bit  ),//Processed Image Bit flag outout(1: Value, 0:inValid)

    .max_line_up  (max_line_up  ),//��������
    .max_line_down(max_line_down),
	
    .horizon_start  (10'd10 ),//ͶӰ��ʼ��
    .horizon_end    (10'd630) //ͶӰ������  
);

//��ֱͶӰ
VIP_vertical_projection # (
	.IMG_HDISP(10'd640),	//640*480
	.IMG_VDISP(10'd480)
)u1_VIP_vertical_projection(
	//global clock
	.clk   (clk    ),//cmos video pixel clock
	.rst_n (rst_n  ),//global reset

	//Image data prepred to be processd
	.per_frame_vsync   (dilation_vsync),//Prepared Image data vsync valid signal
	.per_frame_href    (dilation_hsync),//Prepared Image data href vaild  signal
	.per_frame_clken   (dilation_de   ),//Prepared Image data output/capture enable clock
	.per_img_Bit       (dilation_bit  ),//Prepared Image Bit flag outout(1: Value, 0:inValid)
	
	//Image data has been processd
	.post_frame_vsync  (),//Processed Image data vsync valid signal
	.post_frame_href   (),//Processed Image data href vaild  signal
	.post_frame_clken  (),//Processed Image data output/capture enable clock
	.post_img_Bit      (),//Processed Image Bit flag outout(1: Value, 0:inValid)

    .max_line_left (max_line_left ),		//��������
    .max_line_right(max_line_right),
	
    .vertical_start(10'd10 ),//ͶӰ��ʼ��
    .vertical_end  (10'd470) //ͶӰ������	     
);

////�������Ƶı߿򣬵�����������ַ�
//plate_boarder_adjust u_plate_boarder_adjust(
//    //global clock
//    .clk   (clk    ),                  
//    .rst_n (rst_n  ),                

//    .per_frame_vsync (post_frame_vsync),    

//    .max_line_up     (max_line_up   ), //����ĳ��ƺ�ѡ����
//    .max_line_down   (max_line_down ),
//    .max_line_left   (max_line_left ),     
//    .max_line_right  (max_line_right),
    
//    .plate_boarder_up     (plate_boarder_up   ), //������ı߿�
//    .plate_boarder_down   (plate_boarder_down ), 
//    .plate_boarder_left   (plate_boarder_left ),
//    .plate_boarder_right  (plate_boarder_right),
//    .plate_exist_flag     (plate_exist_flag   )  //��������ı߿��߱ȣ��ж��Ƿ���ڳ���    
//);
//----------------------------------------------------------------


//---------------------------�ڶ�����-----------------------------
//�ڶ��������õ�һ������ȡ�ĳ��Ʊ߽磬��ȡ�߽���ÿ���ַ�������
//���ν��У�
//  2.1 ��ֵ��
//  2.2 ��ʴ
//  2.3 ����
//  2.4 ˮƽͶӰ&��ֱͶӰ-->��������ַ��ı߽�

//2.1 �ڳ��Ʊ߽��ڣ���RGB�е�R���ж�ֵ�������Ʊ߽��ⲻ����
char_binarization # (
    .BIN_THRESHOLD   (8'd160    ) //��ֵ����ֵ
)u2_char_binarization(
    .clk             (clk       ),   // ʱ���ź�
    .rst_n           (rst_n     ),   // ��λ�źţ�����Ч��
    //������Ƶ��
	.per_frame_vsync(pre_frame_vsync),
	.per_frame_href (pre_frame_hsync),	
	.per_frame_clken(pre_frame_de   ),
	.per_frame_Red  ({pre_rgb[15:11],3'b111} ),
    //���Ʊ߽�
    .plate_boarder_up 	 (max_line_up   +10'd10),//����ĳ��ƺ�ѡ����
    .plate_boarder_down  (max_line_down -10'd10),
    .plate_boarder_left  (max_line_left +10'd10),   
    .plate_boarder_right (max_line_right-10'd10),
    .plate_exist_flag    (1'b1   ),
    //�����Ƶ��
	.post_frame_vsync(char_bin_vsync),	
	.post_frame_href (char_bin_hsync),	
	.post_frame_clken(char_bin_de   ),	
	.post_frame_Bit  (char_bin_bit  )
);

//2.2 ��ʴ
VIP_Bit_Erosion_Detector # (
    .IMG_HDISP (10'd640),    //640*480
    .IMG_VDISP (10'd480)
)u2_VIP_Bit_Erosion_Detector(
    //Global Clock
    .clk     (clk    ),   //cmos video pixel clock
    .rst_n   (rst_n  ),   //global reset

    //Image data prepred to be processd
    .per_frame_vsync   (char_bin_vsync), //Prepared Image data vsync valid signal
    .per_frame_href    (char_bin_hsync), //Prepared Image data href vaild  signal
    .per_frame_clken   (char_bin_de   ), //Prepared Image data output/capture enable clock
    .per_img_Bit       (char_bin_bit  ), //Prepared Image Bit flag outout(1: Value, 0:inValid)
    
    //Image data has been processd
    .post_frame_vsync  (char_ero_vsync),    //Processed Image data vsync valid signal
    .post_frame_href   (char_ero_hsync),    //Processed Image data href vaild  signal
    .post_frame_clken  (char_ero_de   ),    //Processed Image data output/capture enable clock
    .post_img_Bit      (char_ero_bit  )     //Processed Image Bit flag outout(1: Value, 0:inValid)
);

//2.3 ����
VIP_Bit_Dilation_Detector#(
	.IMG_HDISP(10'd640),	//640*480
	.IMG_VDISP(10'd480)
)u2_VIP_Bit_Dilation_Detector(
	//global clock
	.clk   (clk    ),  				//cmos video pixel clock
	.rst_n (rst_n  ),				//global reset

	//Image data prepred to be processd
	.per_frame_vsync   (char_ero_vsync ),	//Prepared Image data vsync valid signal
	.per_frame_href    (char_ero_hsync ),	//Prepared Image data href vaild  signal
	.per_frame_clken   (char_ero_de    ),	//Prepared Image data output/capture enable clock
	.per_img_Bit       (char_ero_bit   ),	//Prepared Image Bit flag outout(1: Value, 0:inValid)
	
	//Image data has been processd
	.post_frame_vsync  (char_dila_vsync),	//Processed Image data vsync valid signal
	.post_frame_href   (char_dila_hsync),	//Processed Image data href vaild  signal
	.post_frame_clken  (char_dila_de   ),	//Processed Image data output/capture enable clock
	.post_img_Bit  	   (char_dila_bit  )   //Processed Image Bit flag outout(1: Value, 0:inValid)
);


//2.4.1 �ַ������ˮƽͶӰ
char_horizon_projection # (
	.IMG_HDISP(10'd640),	//640*480
	.IMG_VDISP(10'd480)
)u2_char_horizon_projection(
	//global clock
	.clk   (clk         ),  			//cmos video pixel clock
	.rst_n (rst_n       ),				//global reset

	//Image data prepred to be processd
	.per_frame_vsync   (char_dila_vsync),//Prepared Image data vsync valid signal
	.per_frame_href    (char_dila_hsync),//Prepared Image data href vaild  signal
	.per_frame_clken   (char_dila_de   ),//Prepared Image data output/capture enable clock
	.per_img_Bit       (char_dila_bit  ),//Prepared Image Bit flag outout(1: Value, 0:inValid)
	
	//Image data has been processd
	.post_frame_vsync  (char_proj_vsync),//Processed Image data vsync valid signal
	.post_frame_href   (char_proj_hsync),//Processed Image data href vaild  signal
	.post_frame_clken  (char_proj_de   ),//Processed Image data output/capture enable clock
	.post_img_Bit      (char_proj_bit   ),//Processed Image Bit flag outout(1: Value, 0:inValid)

    .max_line_up    (char_line_up  ),//��������
    .max_line_down  (char_line_down),
	
    .horizon_start  (10'd10 ),//ͶӰ��ʼ��
    .horizon_end    (10'd630) //ͶӰ������  
);


//2.4.2 �ַ�����Ĵ�ֱͶӰ
char_vertical_projection # (
	.IMG_HDISP(10'd640),	//640*480
	.IMG_VDISP(10'd480)
)u2_char_vertical_projection(
	//global clock
	.clk   (clk    ),//cmos video pixel clock
	.rst_n (rst_n  ),//global reset
	//Image data prepred to be processd
	.per_frame_vsync   (char_dila_vsync),//Prepared Image data vsync valid signal
	.per_frame_href    (char_dila_hsync),//Prepared Image data href vaild  signal
	.per_frame_clken   (char_dila_de   ),//Prepared Image data output/capture enable clock
	.per_img_Bit       (char_dila_bit  ),//Prepared Image Bit flag outout(1: Value, 0:inValid)
	//���ؼ�ⷶΧ
	.vertical_start  (10'd10 ),//ͶӰ��ʼ��
    .vertical_end    (10'd630),//ͶӰ������    
    //�����������
	.char1_line_left   (char1_line_left ),
    .char1_line_right  (char1_line_right),
    .char2_line_left   (char2_line_left ),
    .char2_line_right  (char2_line_right),
    .char3_line_left   (char3_line_left ),
    .char3_line_right  (char3_line_right),
    .char4_line_left   (char4_line_left ),
    .char4_line_right  (char4_line_right),
    .char5_line_left   (char5_line_left ),
    .char5_line_right  (char5_line_right),
    .char6_line_left   (char6_line_left ),
    .char6_line_right  (char6_line_right),
    .char7_line_left   (char7_line_left ),
    .char7_line_right  (char7_line_right),
	//Image data has been processd
	.post_frame_vsync  (),//Processed Image data vsync valid signal
	.post_frame_href   (),//Processed Image data href vaild  signal
	.post_frame_clken  (),//Processed Image data output/capture enable clock
	.post_img_Bit      () //Processed Image Bit flag outout(1: Value, 0:inValid)   
);

//----------------------------------------------------------------


//---------------------------��������-----------------------------
//�������ָ��ݵڶ����ָ�����ÿ���ַ��ı߽磬����ģ��ƥ�䡣
//���ν��У�
//  3.1 ��ȡ����ֵ
//  3.2 ģ��ƥ��
//  3.3 ��ӱ߿�
//  3.4 ����ַ�

// 3.1 ��ȡ����ֵ
Get_EigenValue#(
    .HOR_SPLIT(8), //ˮƽ�и�ɼ�������
    .VER_SPLIT(5)  //��ֱ�и�ɼ�������
)u3_Get_EigenValue(
    //ʱ�Ӽ���λ
    .clk             (clk     ),   // ʱ���ź�
    .rst_n           (rst_n   ),   // ��λ�źţ�����Ч��
    //������Ƶ��
    .per_frame_vsync     (char_dila_vsync    ),//char_dila_vsync
    .per_frame_href      (char_dila_hsync    ),//char_dila_hsync
    .per_frame_clken     (char_dila_de       ),//char_dila_de   
    .per_frame_bit       (char_dila_bit      ),//char_dila_bit  
    //�����ַ��߽�
    .char_line_up 	     (char_line_up       ),
    .char_line_down      (char_line_down     ),
    .char1_line_left     (char1_line_left    ),
    .char1_line_right    (char1_line_right   ),
    .char2_line_left     (char2_line_left    ),
    .char2_line_right    (char2_line_right   ),
    .char3_line_left     (char3_line_left    ),
    .char3_line_right    (char3_line_right   ),
    .char4_line_left     (char4_line_left    ),
    .char4_line_right    (char4_line_right   ),
    .char5_line_left     (char5_line_left    ),
    .char5_line_right    (char5_line_right   ),
    .char6_line_left     (char6_line_left    ),
    .char6_line_right    (char6_line_right   ),
    .char7_line_left     (char7_line_left    ),
    .char7_line_right    (char7_line_right   ),
    //�����Ƶ��
	.post_frame_vsync    (cal_eigen_vsync    ),	
	.post_frame_href     (cal_eigen_hsync    ),	
	.post_frame_clken    (cal_eigen_de       ),	
	.post_frame_bit      (cal_eigen_bit      ),
    //���7������ֵ
    .char1_eigenvalue    (char1_eigenvalue   ),
    .char2_eigenvalue    (char2_eigenvalue   ),
    .char3_eigenvalue    (char3_eigenvalue   ),
    .char4_eigenvalue    (char4_eigenvalue   ),
    .char5_eigenvalue    (char5_eigenvalue   ),
    .char6_eigenvalue    (char6_eigenvalue   ),
    .char7_eigenvalue    (char7_eigenvalue   ) 
);

//3.2 ͬ��ģ��ƥ��
template_matching#(
    .HOR_SPLIT(8), //ˮƽ�и�ɼ�������
    .VER_SPLIT(5)  //��ֱ�и�ɼ�������
)u3_template_matching(
    //ʱ�Ӽ���λ
    .clk             (clk     ),   // ʱ���ź�
    .rst_n           (rst_n   ),   // ��λ�źţ�����Ч��
    //������Ƶ��
    .per_frame_vsync     (cal_eigen_vsync),
    .per_frame_href      (cal_eigen_hsync),
    .per_frame_clken     (cal_eigen_de   ),
    .per_frame_bit       (cal_eigen_bit  ),
    //���Ʊ߽�
    .plate_boarder_up    (max_line_up   ),
    .plate_boarder_down  (max_line_down ),
    .plate_boarder_left  (max_line_left ),   
    .plate_boarder_right (max_line_right),
    .plate_exist_flag    (1'b1  ),        
    //����7���ַ�������ֵ
    .char1_eigenvalue  (char1_eigenvalue),
    .char2_eigenvalue  (char2_eigenvalue),
    .char3_eigenvalue  (char3_eigenvalue),
    .char4_eigenvalue  (char4_eigenvalue),
    .char5_eigenvalue  (char5_eigenvalue),
    .char6_eigenvalue  (char6_eigenvalue),
    .char7_eigenvalue  (char7_eigenvalue),
    //�����Ƶ��
    .post_frame_vsync  (template_vsync  ), 
    .post_frame_href   (template_hsync  ), 
    .post_frame_clken  (template_de     ), 
    .post_frame_bit    (template_bit    ), 
    //���ģ��ƥ����
    .match_index_char1 (match_index_char1),//ƥ�����ַ�1���
    .match_index_char2 (match_index_char2),//ƥ�����ַ�2���
    .match_index_char3 (match_index_char3),//ƥ�����ַ�3���
    .match_index_char4 (match_index_char4),//ƥ�����ַ�4���
    .match_index_char5 (match_index_char5),//ƥ�����ַ�5���
    .match_index_char6 (match_index_char6),//ƥ�����ַ�6���
    .match_index_char7 (match_index_char7) //ƥ�����ַ�7���
);

//ila_eigenvalue u_ila_eigenvalue (
//	.clk(clk), // input wire clk
//	.probe0 (match_index_char1), // input wire [5:0]  probe0  
//	.probe1 (match_index_char2), // input wire [5:0]  probe1 
//	.probe2 (match_index_char3), // input wire [5:0]  probe2 
//	.probe3 (match_index_char4), // input wire [5:0]  probe3 
//	.probe4 (match_index_char5), // input wire [5:0]  probe4 
//	.probe5 (match_index_char6), // input wire [5:0]  probe5 
//	.probe6 (match_index_char7), // input wire [5:0]  probe6
//	.probe7 (char1_eigenvalue ), // input wire [39:0]  probe7 
//	.probe8 (char2_eigenvalue ), // input wire [39:0]  probe8 
//	.probe9 (char3_eigenvalue ), // input wire [39:0]  probe9 
//	.probe10(char4_eigenvalue ), // input wire [39:0]  probe10 
//	.probe11(char5_eigenvalue ), // input wire [39:0]  probe11 
//	.probe12(char6_eigenvalue ), // input wire [39:0]  probe12 
//	.probe13(char7_eigenvalue )  // input wire [39:0]  probe13
//);

//�����Ʊ߿��ַ��߿���ӵ�ͼ����
add_grid # (
	.PLATE_WIDTH(10'd5),
	.CHAR_WIDTH (10'd2)
)u4_add_grid(
    .clk             (clk   ),   // ʱ���ź�
    .rst_n           (rst_n ),   // ��λ�źţ�����Ч��
    //������Ƶ��
	.per_frame_vsync     (pre_frame_vsync),//char_dila_vsync     //pre_frame_vsync
	.per_frame_href      (pre_frame_hsync),//char_dila_hsync     //pre_frame_hsync	
	.per_frame_clken     (pre_frame_de   ),//char_dila_de        //pre_frame_de   
	.per_frame_rgb       (pre_rgb        ),//{16{char_dila_bit}} //pre_rgb        		
    //���Ʊ߽�
    .plate_boarder_up 	 (max_line_up   ),//(10'd200),
    .plate_boarder_down	 (max_line_down ),//(10'd300),
    .plate_boarder_left  (max_line_left ),//(10'd200),   
    .plate_boarder_right (max_line_right),//(10'd500),
    .plate_exist_flag    (1'b1  ),        //(1'b1   ),
    //�ַ��߽�
    .char_line_up 	      (char_line_up    ),//(10'd210),
    .char_line_down	      (char_line_down  ),//(10'd290),
    .char1_line_left      (char1_line_left ),//(10'd210),
    .char1_line_right     (char1_line_right),//(10'd230),
    .char2_line_left      (char2_line_left ),//(10'd250),
    .char2_line_right     (char2_line_right),//(10'd270),
    .char3_line_left      (char3_line_left ),//(10'd290),
    .char3_line_right     (char3_line_right),//(10'd310),
    .char4_line_left      (char4_line_left ),//(10'd330),
    .char4_line_right     (char4_line_right),//(10'd350),
    .char5_line_left      (char5_line_left ),//(10'd370),
    .char5_line_right     (char5_line_right),//(10'd390),
    .char6_line_left      (char6_line_left ),//(10'd410),
    .char6_line_right     (char6_line_right),//(10'd430),
    .char7_line_left      (char7_line_left ),//(10'd450),
    .char7_line_right     (char7_line_right),//(10'd470),
    //�����Ƶ��
	.post_frame_vsync     (add_grid_vsync),	
	.post_frame_href      (add_grid_href ),	
	.post_frame_clken     (add_grid_de   ),	
	.post_frame_rgb       (add_grid_rgb  )
);

add_char u4_add_char(
    //ʱ�Ӽ���λ
    .clk             (clk     ),   // ʱ���ź�
    .rst_n           (rst_n   ),   // ��λ�źţ�����Ч��
    //������Ƶ��
    .per_frame_vsync     (add_grid_vsync),
    .per_frame_href      (add_grid_href ),
    .per_frame_clken     (add_grid_de   ),
    .per_frame_rgb       (add_grid_rgb  ),
    //���Ʊ߽�
    .plate_boarder_up    (max_line_up   ),
    .plate_boarder_down  (max_line_down ),
    .plate_boarder_left  (max_line_left ),   
    .plate_boarder_right (max_line_right),
    .plate_exist_flag    (1'b1          ),        
    //����ģ��ƥ����
    .match_index_char1   (match_index_char1),//(6'd2),//(match_index_char1)//(char1_eigenvalue[5:0])
    .match_index_char2   (match_index_char2),//(6'd2),//(match_index_char2)//(char2_eigenvalue[5:0])
    .match_index_char3   (match_index_char3),//(6'd2),//(match_index_char3)//(char3_eigenvalue[5:0])
    .match_index_char4   (match_index_char4),//(6'd2),//(match_index_char4)//(char4_eigenvalue[5:0])
    .match_index_char5   (match_index_char5),//(6'd2),//(match_index_char5)//(char5_eigenvalue[5:0])
    .match_index_char6   (match_index_char6),//(6'd2),//(match_index_char6)//(char6_eigenvalue[5:0])
    .match_index_char7   (match_index_char7),//(6'd2),//(match_index_char7)//(char7_eigenvalue[5:0])
    //�����Ƶ��
    .post_frame_vsync    (post_frame_vsync ),  // ��ͬ���ź�
    .post_frame_href     (post_frame_hsync ),  // ��ͬ���ź�
    .post_frame_clken    (post_frame_de    ),  // ��������ʹ��
    .post_frame_rgb      (post_rgb         )   // RGB565��ɫ����
);


//----------------------------------------------------------------

endmodule
