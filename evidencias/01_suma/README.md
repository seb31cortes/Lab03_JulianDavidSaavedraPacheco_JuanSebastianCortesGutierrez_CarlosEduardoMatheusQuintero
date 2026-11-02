# Prueba 1 — Suma

[Video de la prueba](video.mp4) · Duración aproximada: **16,6 segundos**.

Se comprueba la carga de dos registros y la suma en la ALU de la FPGA.

## Procedimiento

1. Seleccionar **R0**, identificado por el RGB **rojo**, como destino. Establecer `sw[3:0]=1111` y pulsar BTN1 para guardar **15**.
2. Avanzar con BTN0 a **R1**, identificado por el RGB **verde**. Establecer `sw[3:0]=0001` y pulsar BTN1 para guardar **1**.
3. Seleccionar con BTN2 **A=R0, B=R1**; los LEDs codifican `0001`.
4. Cambiar los switches externos a `sw_sel[1:0]=00`, código de **suma**.
5. Pulsar BTN3 para ejecutar y guardar el resultado mostrado en el TM1637.

## Resultado

**15 + 1 = 16**. El display usa decimal y muestra **`0016`**. Los operandos tienen cuatro bits, pero el resultado tiene seis bits con signo; por eso la suma no se recorta a cuatro bits.

El RGB indica el destino de escritura; los LEDs codifican los índices A/B. El resultado y el formato quedan guardados hasta otra ejecución con BTN3.
