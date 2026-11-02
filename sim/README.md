# Simulaciones del laboratorio 03

Cada subcarpeta reúne el testbench Verilog, su ejecutable de Icarus Verilog, la traza VCD y una explicación de las entradas, el procesamiento, las salidas y las comprobaciones de la prueba. Los módulos del diseño se conservan en [src/](../src/).

| Simulación | Qué comprueba | Archivos |
|---|---|---|
| [ALU](alu/README.md) | Suma, resta, AND y OR para todos los operandos de cuatro bits | `alu/tb_alu.v`, `alu/tb_alu.vvp`, `alu/alu.vcd` |
| [Banco de registros](reg_bank/README.md) | Escritura síncrona, dos lecturas independientes, aislamiento y retención | `reg_bank/tb_reg_bank.v`, `reg_bank/tb_reg_bank.vvp`, `reg_bank/reg_bank.vcd` |
| [Controles e indicadores](controls/README.md) | Dirección, parejas A/B, LEDs, RGB y almacenamiento del resultado y su formato | `controls/tb_controls.v`, `controls/tb_controls.vvp`, `controls/controls.vcd` |
| [Antirrebote](debouncer/README.md) | Umbral real de 1.250.000 ciclos, pulsación mantenida y rearme | `debouncer/tb_debouncer.v`, `debouncer/tb_debouncer_real.vvp`, `debouncer/debouncer_real.vcd` |
| [Formato del display](display_formatter/README.md) | Conversión de valores decimales con signo y patrones binarios a segmentos | `display_formatter/tb_display_formatter.v`, `display_formatter/tb_display_formatter.vvp`, `display_formatter/display_formatter.vcd` |
| [Driver TM1637](tm1637/README.md) | Transmisión serial, coherencia de dígitos, ACK/NACK y recuperación | `tm1637/tb_tm1637.v`, `tm1637/tb_tm1637.vvp`, `tm1637/tm1637.vcd` |
| [Sistema completo](top/README.md) | Interacción de todos los módulos y conservación del último resultado ejecutado | `top/tb_top.v`, `top/tb_top.vvp`, `top/top.vcd` |

## Cómo leer las descripciones

El testbench genera los estímulos y compara la respuesta del circuito con los valores esperados. En el código, `dut` identifica el módulo bajo prueba; en la prueba de controles se usan las instancias `u1` a `u4`. Las señales auxiliares del testbench, como contadores de comprobaciones y valores de referencia, no son entradas o salidas físicas de la FPGA.

Los tiempos escritos como `#1`, `#4` o `#125` en estos testbenches están expresados en nanosegundos. Las trazas VCD utilizan una resolución de 1 ps; GTKWave puede representarlas en ns, µs o ms según la escala de la vista. Un mensaje `PASS` significa que el testbench llegó al final sin activar sus comprobaciones `$fatal`.

Las pruebas de ALU y formateador son combinacionales. Banco, controles y antirrebote utilizan un reloj de 125 MHz. Driver e integración utilizan 4 MHz para reducir el trabajo de simulación; la integración también reduce el antirrebote a cuatro muestras. La prueba independiente de antirrebote conserva el umbral real de 10 ms. Estos ajustes de los testbenches no modifican la configuración por defecto del diseño de FPGA.

## Capturas de GTKWave

Los siete README de simulación incorporan las **diez capturas suministradas por el equipo**, clasificadas por sus señales y por `stage` en la integración. Cada imagen se acompaña de la interpretación de lo que efectivamente muestra y del alcance de su intervalo temporal.

Las imágenes anteriores se reemplazaron por estas capturas. Los buses que aparecen en hexadecimal se interpretan explícitamente en cada análisis; una ventana parcial no sustituye las comprobaciones de todo el testbench. En ALU, banco, formateador y TM1637 se indican los tramos adicionales que permitirían mostrar el resto de la prueba. En antirrebote y retención interesa ampliar eventos que quedan comprimidos en una vista general.

[Volver al README principal](../README.md).
