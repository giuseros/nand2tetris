module CPU(
input[15:0] instruction, inM,
input clk, reset,
output wire [15:0] outM, 
output wire [14:0] addressM,
output wire [14:0] addressI,
output wire loadPC,
output wire writeM,
output wire stall);

reg[15:0] D;
reg[15:0] A;

initial begin
	D <= 0;
	A <= 0;
end

// Control signals
wire loadRegA, loadRegD, selM, selA, AMplus1, const1OrDplus1, izx, inx, izy, iny, inf, inno, jgt, jge, jlt, jne, jle, jmp;

// ALU operands
wire [15:0] operandA, operandD;
// ALU output
wire [15:0] ALUout;
// ALU output flags
wire ozr, ong;

wire tmpWriteM;

Decoder Decoder (
  // input
  .I(instruction),
  // output control signals
  .loadRegA(loadRegA),
  .loadRegD(loadRegD),
  .selM(selM),
  .selA(selA),
  .AMplus1(AMplus1), 
  .const1OrDplus1(const1OrDplus1),
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

initial begin
state <= 0;
end

assign writeM = (stall & tmpWriteM) ? state : tmpWriteM;

always @(posedge clk) begin
	if (loadRegA)
	    A <= (selA==0) ? instruction : ALUout;
	if (loadRegD)
	    D <= ALUout;
	
	state <= (stall & tmpWriteM) ? ~state : 0;
end

assign operandD = AMplus1 ? 1'b1 : D;
assign outM = ALUout;
assign operandA = const1OrDplus1 ? 1 : selM ? inM : A;

// outputs 
assign addressM = A[14:0];
assign addressI = A[14:0];
assign loadPC = jeq & ozr | jgt & !ozr & !ong | jge & !ong | jlt & ong | jle & (ong | ozr) | jne & !ozr | jmp;

endmodule