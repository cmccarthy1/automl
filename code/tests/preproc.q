\l ../../automl.q
.aml.loadfile`:init.q

\d .aml
// basic table
norm_tab:([]5?1f;5?0b;"t"$til 5;5?10)
// table containing null values
null_tab:([]0n,"f"$4#1;00011b;("t"$til 4),0n;0N,4#3)

// various forms of tables including symbols for testing
sym_tab_f_o:([]`a`a`b;`a`b`c;5 4 3;3 2 1)
sym_tab_f:([]`a`b`c;5 4 3;3 2 1)
sym_tab_o:([]`a`a`b;5 4 3;3 2 1)

// table containing positive and negative infinities
inf_tab:([]neg[0w],"f"$til 4;00011b;("t"$til 4),0w;0W,til 4)

// Table for bulk transform 
bulk_tab:([]til 5;desc til 5;3 2 1 2 3f;"t"$til 5)

// Null encoding functionality
prep.i.nullencode[norm_tab;min] ~ norm_tab
prep.i.nullencode[null_tab;min] ~ ([]"f"$5#1;0 0 0 1 1;"t"$(til 4),0;5#3;x_null:1 0 0 0 0;x2_null:0 0 0 0 1;x3_null:1 0 0 0 0)

// Symbol encoding functionality
// Apply encoding onto new data with no idea of encoding schema
prep.i.symencode[sym_tab_o;2;0b;enlist[`typ]!enlist`normal;::] ~ ([]x1:5 4 3;x2:3 2 1;x_a:1 1 0f;x_b:0 0 1f)
prep.i.symencode[sym_tab_f;2;0b;enlist[`typ]!enlist`normal;::] ~ ([]x1:5 4 3;x2:3 2 1;x_freq:3#1%3)
// Return how the data is to be encoded
prep.i.symencode[sym_tab_o;2;1b;enlist[`typ]!enlist`normal;::] ~ `freq`ohe!(`symbol$();`x,())
prep.i.symencode[sym_tab_f;2;1b;enlist[`typ]!enlist`normal;::] ~ `freq`ohe!(`x,();`symbol$())
// Apply encoding based on an encoding schema
prep.i.symencode[sym_tab_o;2;0b;enlist[`typ]!enlist`normal;`freq`ohe!(`x,();`symbol$())]~([]x1:5 4 3;x2:3 2 1;x_freq:(2#2%3),1%3)
prep.i.symencode[sym_tab_f;2;0b;enlist[`typ]!enlist`normal;`freq`ohe!(`symbol$();`x,())]~([]x1:5 4 3;x2:3 2 1;x_a:1 0 0f;x_b:0 1 0f;x_c:0 0 1f)

// Infinity encoding functionality
.ml.infreplace[inf_tab] ~ ([]"f"$0,til 4;00011b;("t"$til 4),0w;3,til 4)

// Description functionality
desc_columns:`count`unique`mean`std`min`max`type
desc_values_1:(4#3;3 3 2 3;4 2f,2#(::);1 1f,2#(::);3 1,2#(::);5 3,2#(::);`numeric`numeric`categorical`categorical)
prep.i.describe[sym_tab_f_o] ~ (`x2`x3`x`x1)!flip desc_columns!desc_values_1

// Bulk transformation functionality
bulk_columns:`x`x1`x2`x3`xx1_multi`xx1_sum`xx1_div`xx1_sub
bulk_values:(til 5;desc til 5;3 2 1 2 3f;"t"$til 5;0 3 4 3 0;5#4;"f"$(0w;1;0.5;1%3;0.25);(4;2;0;neg[2];neg[4]))
prep.i.bulktransform[bulk_tab;::] ~ flip bulk_columns!bulk_values 
