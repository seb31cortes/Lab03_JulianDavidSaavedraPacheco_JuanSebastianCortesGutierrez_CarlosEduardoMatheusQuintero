# Laboratorio 03 — ALU y banco de registros en Zybo Z7-10

Electrónica Digital II · Universidad Nacional de Colombia, sede Bogotá · 2026-2

| Integrante | Correo |
|---|---|
| Julián David Saavedra Pacheco | jusaavedrap@unal.edu.co |
| Juan Sebastián Cortés Gutiérrez | jcortesgu@unal.edu.co |
| Carlos Eduardo Matheus Quintero | cmatheus@unal.edu.co |

## Descripción y estado de la práctica

El proyecto integra una ALU de cuatro bits, un banco de cuatro registros, un selector de operandos y un display TM1637. Sigue la arquitectura modular de la guía **Lab03 – ALU + Banco de Registros + Diseño Modular** suministrada para la práctica.

**El diseño ya fue implementado en la FPGA y presentado presencialmente al profesor.** Los cinco videos de [evidencias/](evidencias/) documentan la explicación general y las pruebas de suma, resta, AND y OR. Esta entrega organiza esas evidencias, actualiza la documentación y reproduce las simulaciones.

Se conservan los módulos de [src/](src/) y las asignaciones de [constraints/zybo_z7.xdc](constraints/zybo_z7.xdc). En los testbenches solo se instrumentó la escritura de VCD: se añadieron los volcados que faltaban y se ajustaron las rutas para ejecutar desde `sim/`. El testbench de antirrebote utiliza el umbral real de 1.250.000 ciclos; se mantienen sus comprobaciones y las conexiones del diseño.

## Funcionamiento e interfaz

1. `sw[3:0]` establece un dato de cuatro bits, entre 0 y 15.
2. BTN0 elige el registro de destino; BTN1 guarda el dato en él.
3. BTN2 cambia el par ordenado de registros que alimenta A y B.
4. Los dos switches externos `sw_sel[1:0]` seleccionan la operación.
5. BTN3 captura el resultado y el formato. El display conserva ambos hasta una nueva ejecución.

La ALU calcula continuamente, pero el display utiliza el **resultado almacenado**. Cambiar datos, operación o pareja de registros no modifica lo mostrado hasta pulsar BTN3. El refresco periódico del TM1637 transmite ese mismo contenido guardado.

| Señal o control | Función implementada |
|---|---|
| `clk` | Reloj de 125 MHz de la Zybo Z7 |
| `sw[3:0]` | Dato de entrada del banco de registros |
| `sw_sel[1:0]` | Operación, mediante switches externos independientes del dato |
| `btn[0]` / BTN0 | Avanza destino: R0 → R1 → R2 → R3 → R0 |
| `btn[1]` / BTN1 | Escribe en el destino seleccionado |
| `btn[2]` / BTN2 | Avanza la combinación ordenada A,B |
| `btn[3]` / BTN3 | Guarda resultado y formato |
| `led[3:0]` | `{sel_a,sel_b}`: dos bits para el índice de A y dos para B |
| `{rgb_r,rgb_g,rgb_b}` | Destino: R0 rojo `100`, R1 verde `010`, R2 azul `001`, R3 blanco `111` |
| `tm_clk`, `tm_dio` | Interfaz del TM1637; DIO bidireccional |

| `sw_sel[1:0]` | Operación | Ejemplo A=15, B=1 | Display |
|---|---|---|---|
| `00` | Suma `A+B` | 15+1=16 | `0016`, decimal |
| `01` | Resta `A−B` | 15−1=14 | `0014`, decimal |
| `10` | AND `A & B` | `1111 & 0001 = 0001` | `0001`, binario |
| `11` | OR `A \| B` | `1111 \| 0001 = 1111` | `1111`, binario |

Los operandos son **sin signo**, de cuatro bits. El resultado tiene **seis bits con signo**: suma de 0 a 30 y resta de −15 a 15. Así, 15+1 produce 16 sin recorte a cuatro bits. Invertir los operandos de la resta produce 1−15=−14, mostrado como `-014`.

La implementación presentada usa switches externos para la operación y LEDs que codifican los índices A/B. Se documentan estas convenciones del montaje, aunque la interfaz propuesta en la guía describe switches compartidos y LEDs por registro activo.

### Selección de operandos

El destino de escritura y la pareja de operandos son independientes. El RGB puede estar verde porque se escribe R1 mientras la ALU utiliza A=R0 y B=R1.

`comb_selector` incrementa un índice de cuatro bits, de 0 a 15, con cada pulsación de BTN2. `sel_a=índice[3:2]` y `sel_b=índice[1:0]`. El recorrido es:

```text
(R0,R0), (R0,R1), (R0,R2), (R0,R3),
(R1,R0), (R1,R1), (R1,R2), (R1,R3),
(R2,R0), (R2,R1), (R2,R2), (R2,R3),
(R3,R0), (R3,R1), (R3,R2), (R3,R3), y vuelve al inicio.
```

`LED3:LED2` representa el índice de A y `LED1:LED0` el de B. `0001` indica A=R0/B=R1; `0100`, A=R1/B=R0. `0000` significa A=B=R0.

## Arquitectura modular

```mermaid
flowchart LR
    SW["sw: dato"] --> SYNC["sync_inputs"]
    EXT["sw_sel: operación"] --> OPS["sync_inputs de 2 bits"]
    BTN["BTN0 a BTN3"] --> DB["debouncer + edge_detector"]
    DB -->|BTN0| ADDR["address"]
    DB -->|BTN1| BANK["reg_bank: R0 a R3"]
    SYNC --> BANK
    ADDR --> BANK
    DB -->|BTN2| COMB["comb_selector"]
    COMB -->|direcciones A y B| BANK
    BANK -->|operandos| ALU["alu"]
    OPS --> ALU
    ALU --> REG["result_register: valor + formato"]
    OPS -->|modo| REG
    DB -->|BTN3| REG
    REG --> FMT["display_formatter"]
    FMT --> DRIVER["tm1637_driver"]
    DRIVER --> DISP["TM1637"]
    ADDR --> IND["indicators"]
    COMB --> IND
    IND --> LED["RGB + LEDs"]
```

`top.v` conecta los bloques anteriores. `display_tm1637.v` agrupa el formateador y el driver.

| Módulo | Funcionamiento |
|---|---|
| [top.v](src/top.v) | Integra entradas, controles, banco, ALU, resultado, indicadores y display. Mantiene separados los buses de datos y operación. |
| [sync_inputs.v](src/sync_inputs.v) | Sincroniza los switches mediante dos etapas por bit. Se instancia con anchos de cuatro y dos bits. |
| [debouncer.v](src/debouncer.v) | Sincroniza cada botón y exige `STABLE_CYCLES` muestras estables antes de aceptar un cambio al pulsar o soltar. |
| [edge_detector.v](src/edge_detector.v) | Genera un pulso de un ciclo en la subida del botón filtrado; mantenerlo presionado no repite acciones. |
| [address.v](src/address.v) | Contador de dos bits que avanza el destino de escritura con BTN0. |
| [reg_bank.v](src/reg_bank.v) | Cuatro palabras de cuatro bits. Escritura en flanco ascendente con `write_enable` y dos lecturas combinacionales independientes. |
| [comb_selector.v](src/comb_selector.v) | Contador de cuatro bits activado por BTN2; bits altos para A y bajos para B. |
| [alu.v](src/alu.v) | Calcula las cuatro operaciones de forma combinacional. Extiende los operandos antes de sumar/restar y entrega seis bits con signo. |
| [result_register.v](src/result_register.v) | Con `execute`, captura `alu_result` y `binary_mode`. Conserva `result_q` y `binary_q` entre ejecuciones. |
| [indicators.v](src/indicators.v) | Asigna el RGB según el destino y muestra `{sel_a,sel_b}` en los LEDs. |
| [display_tm1637.v](src/display_tm1637.v) | Une conversión a segmentos y transmisión serial; recibe valor y modo guardados. |
| [display_formatter.v](src/display_formatter.v) | Convierte el resultado en cuatro bytes de segmentos, en decimal con signo o cuatro bits binarios. |
| [tm1637_driver.v](src/tm1637_driver.v) | Captura los cuatro dígitos al iniciar la trama. Su máquina de estados envía comandos, datos LSB primero, ACK y brillo. |

### Reloj y captura

La FPGA usa `CLK_HZ=125_000_000`, `DEBOUNCE_CYCLES=1_250_000` y `TM_BIT_HZ=100_000`. El umbral de antirrebote equivale a 10 ms, más la sincronización. Todos los bloques secuenciales utilizan el mismo reloj; los botones generan habilitaciones.

Al configurar la tarjeta, los registros, la dirección, la combinación y el resultado parten de cero. El modo inicial es decimal. No hay entrada de reset adicional. Si dos acciones se aceptan en un mismo flanco, los registros consumen el estado anterior: escribir y ejecutar simultáneamente usa el operando previo. La interfaz normal se maneja pulsando un botón cada vez.

### Visualización

- **Suma/resta:** decimal con ceros a la izquierda: `0016`, `0014`, `0030`. El signo negativo ocupa la izquierda: `-014`, `-015`.
- **AND/OR:** cuatro bits, con el bit 3 a la izquierda: `0001`, `1111`. En OR, `1111` equivale a 15 decimal.
- BTN3 almacena el modo junto al valor; mover el selector sin ejecutar conserva ambos.

El driver transmite `0x40` (incremento automático), `0xC0` seguido de los cuatro bytes de segmentos y `0x8F` (display habilitado, brillo 7), con START/STOP y un noveno pulso para ACK por byte. DIO se conduce a cero o se libera en alta impedancia. Capturar juntos los cuatro bytes evita mezclar resultados durante una trama. `ack_err` es un diagnóstico interno sin pin de salida en `top`.

## Simulación reproducible

La siguiente tabla resume los testbenches, los archivos de simulación generados y los resultados obtenidos. Las entradas, el procesamiento, las salidas y el desarrollo de cada prueba se detallan en el [índice de simulaciones](sim/README.md).

| Testbench | Ejecutable / traza | Resultado |
|---|---|---|
| [tb_alu.v](sim/alu/tb_alu.v) | `tb_alu.vvp` / `alu.vcd` | **PASS:** 1.024 casos: 4 operaciones × 16 valores de A × 16 de B. |
| [tb_reg_bank.v](sim/reg_bank/tb_reg_bank.v) | `tb_reg_bank.vvp` / `reg_bank.vcd` | **PASS:** 64 escrituras y 1.040 pares de lectura; retención, aislamiento y escritura síncrona. |
| [tb_controls.v](sim/controls/tb_controls.v) | `tb_controls.vvp` / `controls.vcd` | **PASS:** dirección, 16 pares recorridos dos veces, indicadores y captura/retención de valor y formato. |
| [tb_debouncer.v](sim/debouncer/tb_debouncer.v) | `tb_debouncer_real.vvp` / `debouncer_real.vcd` | **PASS:** N=1.250.000, el valor usado en la FPGA; rebotes, umbral de 10 ms, pulsación mantenida y nueva pulsación. |
| [tb_display_formatter.v](sim/display_formatter/tb_display_formatter.v) | `tb_display_formatter.vvp` / `display_formatter.vcd` | **PASS:** 64 valores decimales con signo (−32…31) y 16 patrones binarios. |
| [tb_tm1637.v](sim/tm1637/tb_tm1637.v) | `tb_tm1637.vvp` / `tm1637.vcd` | **PASS:** siete tramas, comandos, bits, ACK/NACK, coherencia y recuperación. |
| [tb_top.v](sim/top/tb_top.v) | `tb_top.vvp` / `top.vcd` | **PASS:** cuatro registros, 16 pares × 4 operaciones, **197 comprobaciones**, display serial y retención. |

La integración carga **R0=5, R1=3, R2=10 y R3=15** y usa un reloj simulado de 4 MHz y cuatro muestras de antirrebote. Son parámetros del testbench; los valores por defecto de FPGA se conservan. Las pruebas físicas emplean **R0=15 y R1=1**.

### Capturas de GTKWave

La interpretación de las señales se amplía en las descripciones de [integración](sim/top/README.md) y del [driver TM1637](sim/tm1637/README.md).

![GTKWave: operaciones y resultado almacenado](sim/top/capturas/top_operaciones.jpg)

En `stage=2`, A=5 y B=3 producen 8, 2, 1 y 7. `alu_out` es el cálculo instantáneo; `result_q` y `binary_q` se capturan con BTN3. `received` contiene los segmentos reconstruidos desde el bus del display.

![GTKWave: integración y retención](sim/top/capturas/top_general.jpg)

La vista general incluye carga y recorrido de parejas. Las etapas 4 a 8 comprueban retención tras escritura, BTN3 mantenido, rebotes, independencia de switches y eventos simultáneos. Sus condiciones se verifican automáticamente en `tb_top.v`.

![GTKWave: TM1637 y ACK/NACK](sim/tm1637/capturas/tm1637.jpg)

La prueba incluye recepción correcta, NACK temprano, recuperación y ausencia simulada del display. `ack_err` conserva el fallo de la trama afectada y vuelve a cero tras una trama correcta.

## Evidencias de funcionamiento en FPGA

En cada operación se cambiaron los **switches externos de selección**. El RGB identifica el destino de escritura: R0 rojo y R1 verde.

**Explicación general:** [video de aproximadamente 55 segundos](evidencias/explicacion_general.mp4), directamente en `evidencias/`.

| Prueba | Video | Descripción | Resultado |
|---|---|---|---|
| Suma, ≈16,6 s | [Video](evidencias/01_suma/video.mp4) | [Procedimiento](evidencias/01_suma/README.md) | 15+1=16 → `0016` |
| Resta, ≈28,1 s | [Video](evidencias/02_resta/video.mp4) | [Procedimiento](evidencias/02_resta/README.md) | 15−1=14 → `0014`; 1−15=−14 → `-014` |
| AND, ≈25,8 s | [Video](evidencias/03_and/video.mp4) | [Procedimiento](evidencias/03_and/README.md) | `1111 & 0001 = 0001` |
| OR, ≈23,3 s | [Video](evidencias/04_or/video.mp4) | [Procedimiento](evidencias/04_or/README.md) | `1111 \| 0001 = 1111` |

Los videos se copiaron íntegros, sin recortes ni recodificación. Se clasificaron por duración y por la descripción suministrada por el equipo.

## Organización

```text
Avances Práctica 3/
├── README.md
├── src/                         13 módulos Verilog del diseño presentado
├── constraints/zybo_z7.xdc      Pines conservados
├── sim/
│   ├── README.md                Índice y alcance de las simulaciones
│   ├── alu/                     Testbench, VVP, VCD y explicación de la ALU
│   ├── reg_bank/                Testbench, VVP, VCD y explicación del banco
│   ├── controls/                Testbench, VVP, VCD y explicación de controles
│   ├── debouncer/               Prueba con el umbral real de antirrebote
│   ├── display_formatter/       Conversión decimal y binaria a segmentos
│   ├── tm1637/                  Protocolo serial, ACK/NACK y capturas previas
│   └── top/                     Integración completa y capturas previas
└── evidencias/
    ├── explicacion_general.mp4
    ├── 01_suma/                 video.mp4 + README.md
    ├── 02_resta/                video.mp4 + README.md
    ├── 03_and/                  video.mp4 + README.md
    └── 04_or/                   video.mp4 + README.md
```

Solo `src/*.v` y el XDC corresponden a síntesis; `sim/` contiene la verificación.

## Análisis de resultados

La suma física 15+1=16 utiliza el ancho adicional del resultado. Las dos restas comprueban el orden A/B y la representación negativa. AND conserva el único bit común en uno; OR conserva todos los bits activos de cualquiera de los operandos. El formato decimal o binario permite interpretar cada resultado en el display.

La prueba exhaustiva de la ALU complementa las cuatro demostraciones físicas. Banco y controles se verifican por separado; la integración comprueba escritura, selección, ejecución y transmisión al display. Guardar valor y modo garantiza la conservación del último resultado hasta una nueva ejecución.
