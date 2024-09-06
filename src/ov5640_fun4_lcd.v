//****************************************Copyright (c)***********************************//
//ԭ�Ӹ����߽�ѧƽ̨��www.yuanzige.com
//����֧�֣�www.openedv.com
//�Ա����̣�http://openedv.taobao.com
//��ע΢�Ź���ƽ̨΢�źţ�"����ԭ��"����ѻ�ȡZYNQ & FPGA & STM32 & LINUX���ϡ�
//��Ȩ���У�����ؾ���
//Copyright(C) ����ԭ�� 2018-2028
//All rights reserved
//----------------------------------------------------------------------------------------
// File name:           ov5640_lcd_yuv
// Last modified Date:  2021/01/04 9:19:08
// Last Version:        V1.0
// Descriptions:        OV5640����ͷLCD�Ҷ���ʾ
//                      
//----------------------------------------------------------------------------------------
// Created by:          ����ԭ��
// Created date:        2019/05/04 9:19:08
// Version:             V1.0
// Descriptions:        The original version
//
//----------------------------------------------------------------------------------------
//****************************************************************************************//

module ov5640_fun4_lcd(    	
    input                 sys_clk      ,  //ϵͳʱ��
    input                 sys_rst_n    ,  //ϵͳ��λ���͵�ƽ��Ч
    //����ͷ�ӿ�                       
    input                 cam_pclk     ,  //cmos ��������ʱ��
    input                 cam_vsync    ,  //cmos ��ͬ���ź�
    input                 cam_href     ,  //cmos ��ͬ���ź�
    input   [7:0]         cam_data     ,  //cmos ����
    output                cam_rst_n    ,  //cmos ��λ�źţ��͵�ƽ��Ч
    output                cam_pwdn ,      //��Դ����ģʽѡ�� 0������ģʽ 1����Դ����ģʽ
    output                cam_scl      ,  //cmos SCCB_SCL��
    inout                 cam_sda      ,  //cmos SCCB_SDA��       
    // DDR3                            
    inout   [31:0]        ddr3_dq      ,  //DDR3 ����
    inout   [3:0]         ddr3_dqs_n   ,  //DDR3 dqs��
    inout   [3:0]         ddr3_dqs_p   ,  //DDR3 dqs��  
    output  [13:0]        ddr3_addr    ,  //DDR3 ��ַ   
    output  [2:0]         ddr3_ba      ,  //DDR3 banck ѡ��
    output                ddr3_ras_n   ,  //DDR3 ��ѡ��
    output                ddr3_cas_n   ,  //DDR3 ��ѡ��
    output                ddr3_we_n    ,  //DDR3 ��дѡ��
    output                ddr3_reset_n ,  //DDR3 ��λ
    output  [0:0]         ddr3_ck_p    ,  //DDR3 ʱ����
    output  [0:0]         ddr3_ck_n    ,  //DDR3 ʱ�Ӹ�
    output  [0:0]         ddr3_cke     ,  //DDR3 ʱ��ʹ��
    output  [0:0]         ddr3_cs_n    ,  //DDR3 Ƭѡ
    output  [3:0]         ddr3_dm      ,  //DDR3_dm
    output  [0:0]         ddr3_odt     ,  //DDR3_odt									   
    //lcd�ӿ�                           
    output                lcd_hs       ,  //LCD ��ͬ���ź�
    output                lcd_vs       ,  //LCD ��ͬ���ź�
    output                lcd_de       ,  //LCD ��������ʹ��
    inout       [23:0]    lcd_rgb      ,  //LCD ��ɫ����
    output                lcd_bl       ,  //LCD ��������ź�
    output                lcd_rst      ,  //LCD ��λ�ź�
    output                lcd_pclk        //LCD ����ʱ��	
	
    );                                 
									   							   
//wire define                          
wire         clk_50m                   ;  //50mhzʱ��,�ṩ��lcd����ʱ��
wire         locked                    ;  //ʱ�������ź�
wire         rst_n                     ;  //ȫ�ָ�λ 								    						    
wire         wr_en                     ;  //DDR3������ģ��дʹ��
wire  [15:0] wr_data                   ;  //DDR3������ģ��д����
wire         rdata_req                 ;  //DDR3������ģ���ʹ��
wire  [15:0] rd_data                   ;  //DDR3������ģ�������
wire         cmos_frame_valid          ;  //������Чʹ���ź�
wire         init_calib_complete       ;  //DDR3��ʼ�����init_calib_complete
wire         sys_init_done             ;  //ϵͳ��ʼ�����(DDR��ʼ��+����ͷ��ʼ��)
wire         clk_200m                  ;  //ddr3�ο�ʱ��
wire         cmos_frame_vsync          ;  //���֡��Ч��ͬ���ź�
wire         cmos_frame_href           ;  //���֡��Ч��ͬ���ź� 
wire  [12:0] h_disp                    ;  //LCD��ˮƽ�ֱ���
wire  [12:0] v_disp                    ;  //LCD����ֱ�ֱ���     
wire  [10:0] h_pixel                   ;  //����ddr3��ˮƽ�ֱ���        
wire  [10:0] v_pixel                   ;  //����ddr3������ֱ�ֱ��� 
wire  [27:0] ddr3_addr_max             ;  //����DDR3������д��ַ 
wire  [12:0] total_h_pixel             ;  //ˮƽ�����ش�С 
wire  [12:0] total_v_pixel             ;  //��ֱ�����ش�С
wire  [10:0] pixel_xpos_w              ;
wire  [10:0] pixel_ypos_w              ;
wire         post_frame_vsync          ;
wire         post_frame_hsync          ;
wire         post_frame_de             ;    
wire  [15:0] post_rgb                  ;
wire  [15:0] lcd_id                    ;

//*****************************************************
//**                    main code
//*****************************************************
//��ʱ�������������λ�����ź�
assign  rst_n = sys_rst_n & locked;

//ϵͳ��ʼ����ɣ�DDR3��ʼ�����
assign  sys_init_done = init_calib_complete;

//����ͷͼ��ֱ�������ģ��
picture_size u_picture_size (
    .rst_n              (rst_n),
    .clk                (clk_50m  ),    
    .ID_lcd             (lcd_id),           //LCD������ID
                        
    .cmos_h_pixel       (h_disp  ),         //����ͷˮƽ�ֱ���
    .cmos_v_pixel       (v_disp  ),         //����ͷ��ֱ�ֱ���  
    .total_h_pixel      (total_h_pixel ),   //ˮƽ�����ش�С
    .total_v_pixel      (total_v_pixel ),   //��ֱ�����ش�С
    .sdram_max_addr     (ddr3_addr_max)     //ddr3����д��ַ
    );
   
 //ov5640 ����
ov5640_dri u_ov5640_dri(
    .clk               (clk_50m),
    .rst_n             (rst_n),

    .cam_pclk          (cam_pclk ),
    .cam_vsync         (cam_vsync),
    .cam_href          (cam_href ),
    .cam_data          (cam_data ),
    .cam_rst_n         (cam_rst_n),
    .cam_pwdn          (cam_pwdn ),
    .cam_scl           (cam_scl  ),
    .cam_sda           (cam_sda  ),
    
    .capture_start     (init_calib_complete),
    .cmos_h_pixel      (h_disp),
    .cmos_v_pixel      (v_disp),
    .total_h_pixel     (total_h_pixel),
    .total_v_pixel     (total_v_pixel),
    .cmos_frame_vsync  (cmos_frame_vsync),
    .cmos_frame_href   (cmos_frame_href),
    .cmos_frame_valid  (cmos_frame_valid),
    .cmos_frame_data   (wr_data)
    );   
    
 //ͼ����ģ��
image_process u_image_process(
    //module clock
    .clk              (cam_pclk),           // ʱ���ź�
    .rst_n            (rst_n    ),          // ��λ�źţ�����Ч��
    //ͼ����ǰ�����ݽӿ�
    .pre_frame_vsync  (cmos_frame_vsync   ),
    .pre_frame_hsync  (cmos_frame_href   ),
    .pre_frame_de     (cmos_frame_valid   ),
    .pre_rgb          (wr_data),
    .xpos             (pixel_xpos_w   ),
    .ypos             (pixel_ypos_w   ),
    //ͼ���������ݽӿ�
    .post_frame_vsync (post_frame_vsync ),  // ��ͬ���ź�
    .post_frame_hsync (post_frame_href ),   // ��ͬ���ź�
    .post_frame_de    (post_frame_de ),     // ��������ʹ��
    .post_rgb         (post_rgb)            // RGB565��ɫ����

);       

ddr3_top u_ddr3_top (
    .clk_200m              (clk_200m),              //ϵͳʱ��
    .sys_rst_n             (rst_n),                 //��λ,����Ч
    .sys_init_done         (sys_init_done),         //ϵͳ��ʼ�����
    .init_calib_complete   (init_calib_complete),   //ddr3��ʼ������ź�    
    //ddr3�ӿ��ź�         
    .app_addr_rd_min       (28'd0),                 //��DDR3����ʼ��ַ
    .app_addr_rd_max       (ddr3_addr_max[27:1]),   //��DDR3�Ľ�����ַ
    .rd_bust_len           (h_disp[10:4]),          //��DDR3�ж�����ʱ��ͻ������
    .app_addr_wr_min       (28'd0),                 //дDDR3����ʼ��ַ
    .app_addr_wr_max       (ddr3_addr_max[27:1]),   //дDDR3�Ľ�����ַ
    .wr_bust_len           (h_disp[10:4]),          //��DDR3��д����ʱ��ͻ������
    // DDR3 IO�ӿ�                
    .ddr3_dq               (ddr3_dq),               //DDR3 ����
    .ddr3_dqs_n            (ddr3_dqs_n),            //DDR3 dqs��
    .ddr3_dqs_p            (ddr3_dqs_p),            //DDR3 dqs��  
    .ddr3_addr             (ddr3_addr),             //DDR3 ��ַ   
    .ddr3_ba               (ddr3_ba),               //DDR3 banck ѡ��
    .ddr3_ras_n            (ddr3_ras_n),            //DDR3 ��ѡ��
    .ddr3_cas_n            (ddr3_cas_n),            //DDR3 ��ѡ��
    .ddr3_we_n             (ddr3_we_n),             //DDR3 ��дѡ��
    .ddr3_reset_n          (ddr3_reset_n),          //DDR3 ��λ
    .ddr3_ck_p             (ddr3_ck_p),             //DDR3 ʱ����
    .ddr3_ck_n             (ddr3_ck_n),             //DDR3 ʱ�Ӹ�  
    .ddr3_cke              (ddr3_cke),              //DDR3 ʱ��ʹ��
    .ddr3_cs_n             (ddr3_cs_n),             //DDR3 Ƭѡ
    .ddr3_dm               (ddr3_dm),               //DDR3_dm
    .ddr3_odt              (ddr3_odt),              //DDR3_odt
    //�û�
    .ddr3_read_valid       (1'b1),                  //DDR3 ��ʹ��
    .ddr3_pingpang_en      (1'b1),                  //DDR3 ƹ�Ҳ���ʹ��
    .wr_clk                (cam_pclk),              //дʱ��
    .wr_load               (post_frame_vsync),      //����Դ�����ź�   
	.datain_valid          (post_frame_de),         //������Чʹ���ź�
    .datain                (post_rgb),              //��Ч���� 
    .rd_clk                (lcd_clk),               //��ʱ�� 
    .rd_load               (rd_vsync),              //���Դ�����ź�    
    .dataout               (rd_data),               //rfifo�������
    .rdata_req             (rdata_req)              //������������     
     );  
	 
 clk_wiz_0 u_clk_wiz_0
   (
    // Clock out ports
    .clk_out1              (clk_200m),     
    .clk_out2              (clk_50m),
    // Status and control signals
    .reset                 (1'b0), 
    .locked                (locked),       
   // Clock in ports
    .clk_in1               (sys_clk)
    );     

//LCD������ʾģ��
lcd_rgb_top  u_lcd_rgb_top(
	.sys_clk               (clk_50m  ),
    .sys_rst_n             (rst_n ),
	.sys_init_done         (sys_init_done),		
				           
    //lcd�ӿ� 				           
    .lcd_id                (lcd_id),                //LCD����ID�� 
    .lcd_hs                (lcd_hs),                //LCD ��ͬ���ź�
    .lcd_vs                (lcd_vs),                //LCD ��ͬ���ź�
    .lcd_de                (lcd_de),                //LCD ��������ʹ��
    .lcd_rgb               (lcd_rgb),               //LCD ��ɫ����
    .lcd_bl                (lcd_bl),                //LCD ��������ź�
    .lcd_rst               (lcd_rst),               //LCD ��λ�ź�
    .lcd_pclk              (lcd_pclk),              //LCD ����ʱ��
    .lcd_clk               (lcd_clk), 	            //LCD ����ʱ��
	//�û��ӿ�			           
    .out_vsync             (rd_vsync),              //lcd���ź�
    .h_disp                (),                      //�зֱ���  
    .v_disp                (),                      //���ֱ���  
    .pixel_xpos            (pixel_xpos_w),
    .pixel_ypos            (pixel_ypos_w),       
    .data_in               (rd_data),	            //rfifo�������
    .data_req              (rdata_req)              //������������
    );   

endmodule