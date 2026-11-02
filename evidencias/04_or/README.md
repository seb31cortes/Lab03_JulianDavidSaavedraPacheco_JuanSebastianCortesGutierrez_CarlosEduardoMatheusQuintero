# Prueba 4 — OR bit a bit

[Video de la prueba](video.mp4) · Duración aproximada: **23,3 segundos**.

Se comprueba OR con **R0=15** (`1111`) y **R1=1** (`0001`), manteniendo los valores de las pruebas anteriores.

## Procedimiento

1. Cargar 15 en R0 y 1 en R1 con los switches de datos y BTN1. BTN0 elige el destino, identificado con RGB **rojo para R0** y **verde para R1**.
2. Seleccionar con BTN2 **A=R0, B=R1**; los LEDs muestran `0001`.
3. Cambiar los switches externos a `sw_sel[1:0]=11`, código de **OR**.
4. Pulsar BTN3 para ejecutar y almacenar el resultado con formato binario.

## Resultado

```text
  R0: 1111
  R1: 0001
  OR: 1111
```

El display muestra **`1111`**, equivalente a **15 decimal**. OR produce uno si al menos uno de los bits de entrada es uno. Como R0 contiene cuatro unos, todos los bits del resultado quedan en uno.

Se muestran cuatro bits, con el más significativo a la izquierda. Valor y modo se conservan hasta una nueva ejecución con BTN3.
