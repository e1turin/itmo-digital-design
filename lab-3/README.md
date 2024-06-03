# Лабораторная работа №3 по теме


- - -

## Комментарии

ссылки на чужие работы:

- https://github.com/AaLexUser/Functional-circuitry
- https://github.com/nibitoff/Functional-circuitry

Чтобы начать можно проверить работаспособность FPGA с помощью простого прямого
подключения светодиодов к сдвиговым переключателям.

### Начало работы

В Vivado нужно создать проект для подходящей платы:
1. В поиске набираем кодовые названия "100t" и "CSG324", выбираем самую
   простую, с меньшими частотами или чем они там отличаются
   > xc7a100tcsg324-1

Потребуется файл с ограничениями (constarints), который можно найти в репозитории под свою модель платы:

- https://github.com/Digilent/digilent-xdc
- для [Nexys-A7-100T](https://github.com/Digilent/digilent-xdc/blob/master/Nexys-A7-100T-Master.xdc)

В нем нужно раскомментить нужные строчки для добавления названий линий в исходники. Называться линии будут так как указано в строке:
- `[get_ports { SW[0] }]`... -> `SW[0:15]`

Еще потребуется refence-manual, который можно взять на официальном сайте:

- https://digilent.com/shop/nexys-a7-fpga-trainer-board-recommended-for-ece-curriculum/
- -> https://digilent.com/reference/programmable-logic/nexys-a7/reference-manual
- -> https://digilent.com/reference/_media/reference/programmable-logic/nexys-a7/nexys-a7_rm.pdf

### Работа с FPGA

#### 7-сегментный дисплей

Устройство 7-сегментных дисплеев:

- [reference-manual#seven-segment_display](https://digilent.com/reference/programmable-logic/nexys-a7/reference-manual#seven-segment_display)
- [Занятие 2 (2023-24): Схемы с тактовым сигналом и состоянием. Отечественный симулятор Delta Design.](https://youtu.be/NyOlu_2OTXA?t=4283)

#### Кнопки

Подавление дребезга можно сделать по разному, суть обычно состоит в том, чтобы *дождаться* сигнала в 
следующий момент

- [http://www.labfor.ru/articles/debouncer_verilog](http://www.labfor.ru/articles/debouncer_verilog)
- [https://dzen.ru/a/Xur1F6FTWTX5gLj6](https://dzen.ru/a/Xur1F6FTWTX5gLj6)
- [https://nabbla1.livejournal.com/204808.html](https://nabbla1.livejournal.com/204808.html)
- Некоторый смысл, другая реализация: https://www.fpga4student.com/2017/04/simple-debouncing-verilog-code-for.html
- Некоторая реализация, со странным результатом: https://www.fpga4fun.com/Debouncer2.html

При этом, на кнопку `CPU_RESETN` не нужно весить гаситель дребезга.

- [https://www.eevblog.com/forum/projects/necessary-to-debound-a-reset-button/](https://www.eevblog.com/forum/projects/necessary-to-debound-a-reset-button/)

Суть подавления дребезга состоит в том, чтобы "перенести тактовый сигнал в другую доменную зону", 
т.е. считывать его не так часто как хотелось бы. Без этого понимания, я почему-то не мог написать 
нормально работающий дебаунсер.
