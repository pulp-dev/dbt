# dbt и ClickHouse

## Структура

- data/train.csv: исходный датасет, исключен из Git.
- dbt/: staging, 6 витрин, макросы, тесты и конфигурация dbt.
- results/: логи проверок, документация и снимок DAG.
- compose.yml: локальный ClickHouse.
- load_data.py: загрузка CSV в ClickHouse.
- Makefile: команды установки, запуска и проверки.
- .runtime/ и .venv/: локальные данные и окружение, исключены из Git.

## Запуск

Нужны Python 3.10 или новее и запущенный Docker с Compose v2.
Команды выполнять из hw4. Датасет должен находиться в data/train.csv.

```bash
make install  # установить зависимости
make up       # запустить ClickHouse
make load     # загрузить датасет
make deps     # установить пакеты dbt
make check    # построить модели, запустить тесты и линтер, создать документацию
make serve    # открыть сервер документации
```

Документация: http://localhost:8081. Автономная копия: results/dbt_docs.html.

Для остановки сервера документации нажмите Ctrl+C, затем остановите ClickHouse:

```bash
make down
```

## Результаты

Построены staging и 6 витрин.

- [load.log](results/load.log): результат загрузки данных.
- [build.log](results/build.log): построение моделей.
- [dbt_test.log](results/dbt_test.log): результаты тестов.
- [sqlfluff.log](results/sqlfluff.log): проверка SQL.
- [dbt_docs.html](results/dbt_docs.html): документация без сервера.
- [dbt_dag.png](results/dbt_dag.png): скриншот DAG.
