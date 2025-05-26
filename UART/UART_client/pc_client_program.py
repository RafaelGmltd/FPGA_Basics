import serial
import math
from fixedpoint import FixedPoint

# Эта функция переводит 16-ричное число hexstr в знаковое целое число, считая, что оно закодировано в дополнительном коде (two's complement) на bits бит

def twos_complement(hexstr,bits):    # строка hex формате и количество бит
     value = int(hexstr,16)          # переводим из hex в int
     if value & (1 << (bits-1)):     # проверяем бит знака (старший бит)
         value -= 1 << bits          # если он установлен — вычитаем 2^bits стандартная процедура 2s compl вспомни
     return value
# например у нас есть число в hex 2182a4705ae7 48 бит его переводим в инт = 36737178325415 теперь побитово проверим с  (1 << (bits-1)) это
# 1 << 47 = 140 737 488 355 328 это битовая маска на 48 бит где все нули кроме MSB -> 1000 0000 0000 0000 0000 0000 0000 0000 0000 0000 0000 0000
# теперь если с это маской число входное побитово & то если 0 вернется значит знак 0 положительное если не 0 то зна отрицательный
#  1000 0000 0000 0000 0000 0000 0000 0000 0000 0000 0000 0000 & 0010 0001 0110 1001 1000 1010 0111 0110 1101 0001 1010 0111 (это 36737178325415) = 0
# знак положительный значит return 36737178325415 теперь если его обратно прогонишь через ( / (2**44)) * 180.0 / math.pi) то получишь 120.0 как раз то что вводил
# вот так можно из бинарного представление угол в градуссы вернуть или в радианы оставить просто на 2^44 поделить 


# Это функция которая реализует CRC-8 высчитывает его логика такая же как с lsfr
# тут каждый байт (8 бит) берем и прогоняем его через lsfr и полученое crc сохраняем 
def crc_8(bytearr):
    generator = 0x9b
    crc = 0
# вот сама логика lsfr
    for byte in bytearr: # каждый байт ксорим с тем что получиться после обработки crc 
        crc = crc ^ byte
        for i in range(0, 8): # каждый байт прогоняем через 8 итираций 
# В Python переменные типа int могут расти сколько угодно, у них нет фиксированной длины.
# поэтому надо постоянно обрезать длину после сдвигов каждый сдвиг он все дальше и дальше
# сдвигаться будет поэтому делаем побитовое & 0xFF и остаеться 8 бит только
            if ((crc >> 7) & 0xFF): # тут логика такая же как и с lsfr если старший бит 1 то ксорим с полиномом сдвиг
                crc = ((crc << 1) & 0xFF) ^ generator # вот тут будешь кадый раз сдвигать у тебя будет crc все дальше и дальше расширяться поэтому надо 0xFF
            else:                   # если нет то только сдвиг оставляем  смотри строчку  o_lfsr  <= {o_lfsr[N-2:0], 1'b0} ^ (poly & {N{o_lfsr[N-1]}});
                crc = ((crc << 1) & 0xFF)
    return crc

def main():
    serial_port = 'COM7' # вводишь тот который у тебя 
    baud_rate = 3000000  # тоже на той частоте которой дизайн расчитан 
    # Создаётся объект Serial, который открывает соединение с COM-портом:
    ser = serial.Serial(serial_port, baud_rate, timeout=3, parity=serial.PARITY_ODD) 
    print("\nSuccessfully opened serial port " + str(serial_port) + " with baud rate " + str(baud_rate) + ".")

    print("\nWelcome to the Arty-A7 UART comm program. Have fun interacting with the CORDIC module!")


    # Command try используется, чтобы поймать ошибки (исключения) и не дать программе «рухнуть» при их возникновени если что то не так пойдет 
    # то есть  нажмешь Ctrl + c это означает KeyboardInterruptтебя перекинет на except ser.close() и порт закроеться все 
    try:
        while True:

            command = input("\nEnter command (1-4):\n \
            (1- Single angle)\n \
            (2- Disable)\n \
            (3- Enable)\n \
            (4- Echo Test Mode) ")
    # тут другой except смотри ниже если введешь не int то перебросит на except ValueError и выйдет сообщение  
            try:

                # Convert command to integer
                command = int(command)

                # Single command
                if command == 1:

                    # Prompt user for angle
                    angle = input("\nEnter angle (degrees): ") # ввели угол максимум 458 ьольше уже не поместиться в angle_rad_fixed
                    angle_rad = float(angle) * math.pi / 180.0 # перевели его в радианы
                    angle_rad_fixed = FixedPoint(angle_rad, signed=True, m=4, n=44) # перевели FixedPoint (48 бит: 1 знак 3 целых, 44 дробных) тут важно что 48 бит 
                                                                                    # это 6 байт по 2 символа на 1 байт 12 символов  
                                                                                    # дальше мы как раз рзберем его на кусочки в пакет 
# 1 знак 0 или 1 если 0 то положительное значение если 1 отрицательно дальше целая часть 3 бита максимум 7 будет и на дробную часть 44 знака
# если 120 введешь то получишь 2.0943951023931953 это float и в 16 ой это  2182a4705ae7
# 0(знак) 010(это 2)  0001 1000 0010 1010 0100 0111 0000 0101 1010 1110 0111(это 44 знака на дробную часть )
# дробную часть помнишь как переводить если нет смотри  на планшете есть или вот0 бит: 0 × 2^-1 = 0
    # 0 бит: 0 × 2^-2 = 0
    # 0 бит: 0 × 2^-3 = 0
    # 1 бит: 1 × 2^-4 = 1/16 = 0.0625
    # 1 бит: 1 × 2^-5 = 1/32 = 0.03125
    # 0 бит: 0 × 2^-6 = 0
    # 0 бит: 0 × 2^-7 = 0
    # 0 бит: 0 × 2^-8 = 0 и так далее а если наобарот бинарную часть в флоат поинт то 
    # эту дробную часть будем последовательно умножать на 2 и записывать целые части результата (0 или 1), 44 раза
    # Возьмём frac = 0.0943951023931953
    # frac * 2 = 0.1887902047863906 → целая часть = 0(бит: 0, новая frac = 0.1887902047863906)
    # 0.1887902047863906 * 2 = 0.3775804095727812 → 0 и так далее 
# немного тут задержимся тут логика какая например ввели угол 120 первый этап это его в ФП это 120.0 дальше в радианы angle_rad = 120 * math.pi / 180.0
# дальше надо его в бинарное представление 4 на целую часть 44 на дробную тут такая логика 120 в радианах это 2.0943951023931953 теперь масштаб дробной части оценим
# для этого 2^ 44 = 17,592,186,044,416 дальше умножаем на  2.0943951023931953 и получим 36,844,988,291,815 а это в HEX = 2182a4705ae7 как раз то что в бинарном выше 


                    # Construct message
                    packet = bytearray() # тип данных хранящий байты каждый элемент занимает один байт(8бит) в 16 форму все переводит
                    packet.append(0x5a)  # этот записываеться в позицию [0] это HEADER означает начало пакета BYTE_HEADER в pkg_msg
                    packet.append(0xd1)  # этот записывается в [1]  это CMD_SINGLE_TRANS в pkg_msg
                    for i in reversed(range(0,6)):
                        packet.append ( int(str(angle_rad_fixed)[(i*2):(i*2)+2], 16) ) # тут он FixedPoint который получили разрезает по 2 
                                                                                       # В hex (шестнадцатеричной) записи 1 байт — это 2 символа
                                                                                       # и тоже в пакет записывает только задом наперед
                    packet.append(crc_8(packet))                                       # тут формирует CRC для сверки затем что данные дошли целыми
                                                                                       # это функция смотри в начале 
                    
                    # Print message
                    print("\nSending message: ")
                    print("\tHeader: 0x" + str(format(packet[0], '02x'))) # format(packet[0], '02x') — форматирует байт как двузначное шестнадцатеричное число (например, 5 → 05, 255 → ff)
                    print("\tCmd:    0x" + str(format(packet[1], '02x'))) 
                    print("\tTheta:  0x", end="")                         # end="" означает: не переходить на следующую строку
                    for i in range(0,6):
                        print(format(packet[i+2], '02x'), end="")
                    angle_in = (twos_complement(str(angle_rad_fixed), 48) / (2**44)) * 180.0 / math.pi # тут уже обяснил выше
                    print(" (" + str(angle_in) + ")" )
                    print("\tCRC-8:  0x" + str(format(packet[-1], '02x')))

                    # Send message
                    ser.write(packet) # отправку пакета байтов по последовательному порту (через объект serial.Serial, сокращённо ser

                    # Read response message bytes_back — это переменная, в которую записываются данные, прочитанные из последовательного порта, например, через ser.read()
                    bytes_back = ser.read(15)
                    # Если за это время 3 сек данные не пришли, ser.read() вернёт пустой байтовый объект b'' 
                    if bytes_back == b'': 
                        print("\nTimed out.")
                        continue # пропускает текущую итерацию цикла и сразу переходит к следующему запросу или операции

                    # Format received theta 
                    # две переменные 
                    mycos = ''
                    mysin = ''
                    for i in reversed(range(0,6)):
                        mycos += format(bytes_back[i+2], '02x')
                        mysin += format(bytes_back[i+8], '02x')
                    cos_val = twos_complement(mycos, 48) / (2**46)
                    sin_val = twos_complement(mysin, 48) / (2**46)

                    # Print received message
                    print("\nReceived message: ")
                    print("\tHeader:        0x" + str(format(bytes_back[0], '02x')))
                    print("\tCmd:           0x" + str(format(bytes_back[1], '02x')))

                    print("\tCos(theta):    0x", end="")
                    for i in reversed(range(0,6)):
                        print(format(bytes_back[i+2], '02x'), end="")
                    print(" (" + str(cos_val) + ")")

                    print("\tSin(theta):    0x", end="")
                    for i in reversed(range(0,6)):
                        print(format(bytes_back[i+8], '02x'), end="")
                    print(" (" + str(sin_val) + ")")

                    print("\tCRC-8:         0x" + str(format(bytes_back[-1], '02x')))

                    # CRC-8 check
                    if crc_8(bytes_back) == 0:
                        print("\nCRC-8 of received message passes.")
                    else:
                        print("\nCRC-8 of received message does not pass.")

                # Disable command
                elif command == 2:

                    # Construct message
                    packet = bytearray()
                    packet.append(0x5a)
                    packet.append(0xe1)
                    packet.append(crc_8(packet))
                    
                    # Print message
                    print("\nSending message: ")
                    print("\tHeader: 0x" + str(format(packet[0], '02x')))
                    print("\tCmd:    0x" + str(format(packet[1], '02x')))
                    print("\tCRC-8:  0x" + str(format(packet[-1], '02x')))

                    # Send message
                    ser.write(packet)

                    # Read received message
                    bytes_back = ser.read(3)

                    # Print received message
                    print("\nReceived message: ")
                    print("\tHeader: 0x" + str(format(bytes_back[0], '02x')))
                    print("\tCmd:    0x" + str(format(bytes_back[1], '02x')))
                    print("\tCRC-8:  0x" + str(format(bytes_back[-1], '02x')))

                    # CRC-8 check
                    if crc_8(bytes_back) == 0:
                        print("\nCRC-8 of received message passes.")
                    else:
                        print("\nCRC-8 of received message does not pass.")

                # Enable command
                elif command == 3:
                    
                    # Construct message
                    packet = bytearray()
                    packet.append(0x5a)
                    packet.append(0xe2)
                    packet.append(crc_8(packet))
                    
                    # Print message
                    print("\nSending message: ")
                    print("\tHeader: 0x" + str(format(packet[0], '02x')))
                    print("\tCmd:    0x" + str(format(packet[1], '02x')))
                    print("\tCRC-8:  0x" + str(format(packet[-1], '02x')))

                    # Send message
                    ser.write(packet)

                    # Read received message
                    bytes_back = ser.read(3)
                    
                    # Print received message
                    print("\nReceived message: ")
                    print("\tHeader: 0x" + str(format(bytes_back[0], '02x')))
                    print("\tCmd:    0x" + str(format(bytes_back[1], '02x')))
                    print("\tCRC-8:  0x" + str(format(bytes_back[-1], '02x')))

                    # CRC-8 check
                    if crc_8(bytes_back) == 0:
                        print("\nCRC-8 of received message passes.")
                    else:
                        print("\nCRC-8 of received message does not pass.")

                # Echo test command
                elif command == 4:

                    testbyte = input("\nEnter test character: ")
                    ser.write(testbyte.encode("utf-8"))
                    byte_out = ser.read(1)
                    print("\nReceived byte: " + byte_out.decode("utf-8") + "\n")

                else:

                    print("\nInvalid command. Please enter 1, 2, 3, 4, or 5.")

            except ValueError:

                print("\nInput was not an integer.")

    except KeyboardInterrupt:
        ser.close()
        pass

if __name__ == "__main__":
    main()
