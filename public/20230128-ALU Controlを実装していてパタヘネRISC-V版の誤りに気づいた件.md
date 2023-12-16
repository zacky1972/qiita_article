---
title: ALU Controlを実装していてパタヘネRISC-V版の誤りに気づいた件
tags:
  - SystemVerilog
  - RISC-V
private: false
updated_at: '2023-01-28T11:11:16+09:00'
id: 160d9043c5cec5d083cf
organization_url_name: fukuokaex
slide: false
ignorePublish: false
---
パタヘネRISC-V版(David A. Patterson and John L. Hennessy: Computer Organization and Design: The Hardware/Software Interface: RISC-V Edition, Morgan Kaufmann Publishers, 2017)にしたがって，ALU ControlをSystemVerilogで実装したのですが，書籍の誤りに気づきました．

出来上がったコード

```SystemVerilog:alu_control_rv32i.sv
module alu_control_rv32i(
    input logic [31:0] inst,
    input logic valid_inst,
    input logic [1:0] alu_op,
    output logic [3:0] alu_ctl
);

    logic [3:0] f;

    always_comb begin
        f = {inst[30], inst[14:12]};

        case (valid_inst)
            1: begin
                begin
                    alu_ctl[0] = (alu_op[1] & (f[1] & ~f[0]));
                    alu_ctl[1] = (~(alu_op[1]) | ~(f[2]));
                    alu_ctl[2] = (alu_op[0] | (alu_op[1] & f[3]));
                    alu_ctl[3] = 0;
                end
            end

            0: begin
                alu_ctl = 0;
            end
        endcase
    end

endmodule
```

# 書籍の誤りについて

Appendix C: Mapping Control to Hardware の C.2 Implementing Combinational Control Units の記載のFigure C.2.3が誤っていました．どのように訂正するかについては，前述のSystemVerilogのソースコードから察してください．



