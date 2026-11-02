# Prueba 3 — AND bit a bit

[Video de la prueba](video.mp4) · Duración aproximada: **25,8 segundos**.

Se comprueba AND con **R0=15** (`1111`) y **R1=1** (`0001`).

## Procedimiento

1. Cargar 15 en R0 y 1 en R1 usando los switches de datos y BTN1. BTN0 selecciona el destino: **rojo para R0** y **verde para R1**.
2. Seleccionar con BTN2 **A=R0, B=R1**; los LEDs codifican `0001`.
3. Cambiar los switches externos a `sw_sel[1:0]=10`, código de **AND**.
4. Pulsar BTN3 para guardar resultado y formato binario en el TM1637.

## Resultado

```text
  R0: 1111
  R1: 0001
 AND: 0001
```

El display muestra **`0001`**, con el bit más significativo a la izquierda. AND produce uno solo si ambos bits de entrada son uno; únicamente el bit 0 cumple esta condición. Equivale a 1 decimal, representado aquí en binario.

BTN3 guarda el valor y el modo binario; ambos se conservan hasta otra ejecución.
