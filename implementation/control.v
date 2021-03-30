module control(in,jr,rt,regdest0,regdest1,alusrc,memtoreg0,memtoreg1,regwrite,memread,memwrite,jump0,jump1,aluop0,aluop1,aluop2,aluop3,beq,bne,bgez,bgtz,bltz,blez);
input [5:0] in,jr;
input [4:0] rt;
output regdest0,regdest1,alusrc,memtoreg0,memtoreg1,regwrite,memread,memwrite,aluop0,aluop1,aluop2,aluop3,jump0,jump1,beq,bne,bgez,bgtz,bltz,blez;
wire rformat,lw,sw,beq;
assign rformat=~|in;
assign lw=in[5]& (~in[4])&(~in[3])&(~in[2])&in[1]&in[0];
assign sw=in[5]& (~in[4])&in[3]&(~in[2])&in[1]&in[0];
assign beq= ~in[5]& (~in[4])&(~in[3])&in[2]&(~in[1])&(~in[0]);
assign andi = ~in[5]& (~in[4])&(in[3])&in[2]&(~in[1])&(~in[0]);
assign ori = ~in[5]& (~in[4])&(in[3])&in[2]&(~in[1])&(in[0]);  
assign addi = ~in[5]& (~in[4])&(in[3])&(~in[2])&(~in[1])&(~in[0]); 
assign rt_ctrl = ( | rt ) ;
assign jr_ctrl = ( (~jr[5])& (~jr[4])&(jr[3])&(~jr[2])& (~jr[1]) & (~jr[0])) ;
assign jal = ~in[5]& (~in[4])&(~in[3])&(~in[2])&(in[1])&(in[0]); 

assign bne = ~in[5]& (~in[4])&(~in[3])&in[2]&(~in[1])&(in[0]);
assign bgez = ~in[5]& (~in[4])&(~in[3])&(~in[2])&(~in[1])&(in[0]);
assign bgtz = ~in[5]& (~in[4])&(~in[3])&(in[2])&(in[1])&(in[0]);
assign blez = ~in[5]& (~in[4])&(~in[3])&(in[2])&(in[1])&(~in[0]);
assign bltz = bgez;

assign jump0 = ((~in[5])& (~in[4])&(~in[3])&(~in[2])& in[1] & (~in[0]));
assign jump1 = jal | jr_ctrl ;
assign regdest0=rformat;
assign regdest1=jal;
assign alusrc=lw|sw | addi | andi | ori ; 
assign memtoreg0=lw;
assign memtoreg1= jal ;
assign regwrite= (rformat|lw | andi | ori |addi | jal) & (~jr_ctrl)  ;
assign memread=lw;
assign memwrite=sw;
assign aluop0=beq | bne |blez | bltz | bgtz | ori ; 
assign aluop1= rformat | andi | ori  ;
assign aluop2= rformat   ;
assign aluop3= (bgez & rt_ctrl) ;
endmodule
