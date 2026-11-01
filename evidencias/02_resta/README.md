# Prueba 2 — Resta e inversión de operandos

[Video de la prueba](video.mp4) · Duración aproximada: **28,1 segundos**.

Se comprueba la resta en ambos órdenes con **R0=15** y **R1=1**, incluyendo un resultado negativo.

## Procedimiento

1. Guardar **15** (`1111`) en **R0**, identificado con RGB **rojo**, y **1** (`0001`) en **R1**, identificado con RGB **verde**. BTN0 selecciona el destino y BTN1 escribe el dato.
2. Cambiar los switches externos a `sw_sel[1:0]=01`, código de **resta**.
3. Seleccionar con BTN2 **A=R0, B=R1**; los LEDs codifican `0001`. Pulsar BTN3.
4. Avanzar hasta **A=R1, B=R0**; los LEDs codifican `0100`. Pulsar BTN3 para ejecutar con los operandos invertidos.

## Resultados

| Operandos | Cálculo | Display decimal |
|---|---|---|
| A=R0=15, B=R1=1 | 15 − 1 = **14** | **`0014`** |
| A=R1=1, B=R0=15 | 1 − 15 = **−14** | **`-014`** |

La resta depende del orden A/B. Los operandos son valores sin signo; el resultado de seis bits con signo representa −14 correctamente. Cambiar la pareja no actualiza por sí solo el display: BTN3 realiza la nueva captura.

Descripción basada en la demostración física informada por el equipo. Original: `WhatsApp Video 2026-11-01 at 4.54.32 PM (1).mp4`, copiado íntegramente como `video.mp4`.
