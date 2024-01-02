"""

"""
from __init__ import __version__, __author__
from __init__ import *

import os

DEFAULT_TEXT = "Введите вашу команду:\n    "
ERROR_TEXT = "Команда не найдена! Попытайтесь ещё раз, или наберите help для вызова списка команд:\n    "

connection = sqlite3.connect('identifier.sqlite')
cursor = connection.cursor()


def clear_console():
    """

    Очищение консоли

    """
    os.system('cls')


def insert_teacher() -> None:
    """

    :param full_name: Полное имя учителя. 200 символов
    :type full_name: str
    :param gender: Пол учителя. m, f, o
    :type gender: str
    :param has_degree: Наличие учёной степени
    :type has_degree: bool
    :param date_birth: Дата рождения. "2000-01-01"

    :return: Создаёт запись типа teacher
    :rtype: None

    """
    state_input = ""
    full_name = ""
    gender = ""
    has_degree = False
    date_birth = ""
    while state_input != "y":
        clear_console()
        full_name = input("Введите полное ФИО:\n    ")
        gender = input("Введите пол ([m]ale, [f]emale, [o]ther:\n    ")
        has_degree = True if input("Имеется ли научная степень? ([y]es, [n]o:\n    ") == "y" else False
        date_birth = input("Введите дату рождения в формате: '2000-01-01':\n    ")

        print(f"Проверьте правильность введённых данных:\n"
              f"    {full_name}\n    {gender}\n    {has_degree}\n    {date_birth}")
        state_input = input("\nВсё верно? [y]es, [n]o:\n    ")
        "Специально не проверяю в самом коде правильность ввода, чтобы было видно, что всё правильно обрабатывается в SQL"
    "Try-Except не работает..."
    cursor.execute("INSERT INTO Teachers ('Full Name', gender, has_degree, 'Date of birth') VALUES (?, ?, ?, ?)",
               (full_name, gender, has_degree, date_birth))


if __name__ == "__main__":
    clear_console()
    print(f"Автор: {__author__}\n"
          f"Версия программы: {__version__}\n")

    input_text = input(DEFAULT_TEXT)
    while input_text != "break":
        is_success = True
        match input_text:
            case "help":
                pass
            case "create teacher":
                insert_teacher()
            case "create student":
                pass
            case _:
                is_success = False
        connection.commit()
        clear_console()
        if is_success:
            input_text = input(DEFAULT_TEXT)
        else:
            input_text = input(ERROR_TEXT)

    connection.close()
