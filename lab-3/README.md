# Лабораторная работа №3 по теме


- - -

Чтобы начать можно проверить работаспособность FPGA с помощью простого прямого
подключения светодиодов к сдвиговым переключателям.

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


