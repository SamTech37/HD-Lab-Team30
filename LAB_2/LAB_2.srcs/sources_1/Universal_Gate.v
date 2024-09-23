module Universal_Gate(out, a, b);
input a, b;
wire bbar;
output out;
not N1(bbar, b);
and A1(out, a, bbar);
endmodule