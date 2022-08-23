module CPU #(parameter IL=16)(
input[IL-1:0] instruction, inM,
input clk, reset,
output wire [15:0] outM, 
output wire [14:0] addressM,
output wire [IL-2:0] addressI,
output wire loadPC,
output wire writeM,
output wire stall,
output reg signed[15:0] D,
output reg signed[15:0] A);

initial begin
	D <= 0;
	A <= 0;
end

// Control signals
wire loadRegA, loadRegD, selM, selA, AMplus1, setOperandDTo1, izx, inx, izy, iny, inf, inno;
wire jgt, jge, jlt, jne, jle, jmp, jeq;

// ALU operands
wire signed [15:0] operandA, operandD;
// ALU output
wire signed [15:0] ALUout;
// ALU output flags
wire ozr, ong;

wire tmpWriteM;

Decoder #(.IL(IL)) Decoder (
  // input
  .I(instruction),
  // output control signals
  .loadRegA(loadRegA),
  .loadRegD(loadRegD),
  .selM(selM),
  .selA(selA),
  .AMplus1(AMplus1), 
  .setOperandDTo1(setOperandDTo1),
  .izx(izx),
  .inx(inx),
  .izy(izy),
  .iny(iny),
  .inf(inf),
  .inno(inno),
  .jgt(jgt), 
  .jge(jge),
  .jlt(jlt),
  .jne(jne),
  .jle(jle),
  .jmp(jmp),
  .jeq(jeq),
  .writeM(tmpWriteM),
  .memread(stall)
);

ALU ALU(
     // ALU inputs
     .x(operandD),
	  .y(operandA),
	  .zx(izx), 
	  .nx(inx),
	  .zy(izy),
	  .ny(iny),
	  .f(inf), 
	  .no(inno),
	  // ALU outputs
	  .out(ALUout),
	  .zr(ozr),
	  .ng(ong));

reg state;
reg state2;
reg state3;

initial begin
state <= 0; // for writem
state2 <= 0; // for loadD
state3 <= 0; // for loadA
end

assign writeM = (stall & tmpWriteM) ? state : tmpWriteM;

always @(posedge clk) begin
	if (loadRegA && (state3 || !stall))
	    A <= (selA==0) ? instruction : ALUout;
		 
	if (loadRegD && (state2 || !stall))
	    D <= ALUout;
	
	state <= (stall & tmpWriteM) ? ~state : 1'b0;
	state2 <= (stall & loadRegD) ? ~state2 : 1'b0;
	state3 <= (stall & loadRegA) ? ~state3 : 1'b0;
end

assign operandD = AMplus1 ? 1'b1 : D;
assign outM = ALUout;
assign operandA = (setOperandDTo1 ? 15'h1 : (selM ? inM : A));

// outputs 
assign addressM = A[14:0];
assign addressI = A[IL-2:0];
assign loadPC = jeq & ozr | jgt & !ozr & !ong | jge & !ong | jlt & ong | jle & (ong | ozr) | jne & !ozr | jmp;

endmodule