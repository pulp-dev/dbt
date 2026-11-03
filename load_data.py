import os
import subprocess
import sys
from pathlib import Path
from urllib.request import Request, urlopen
from base64 import b64encode

host = os.getenv('CLICKHOUSE_HOST', 'localhost')
user = os.getenv('CLICKHOUSE_USER', 'user')
password = os.getenv('CLICKHOUSE_PASSWORD', 'password')
url = f'http://{host}:8123/'
auth = b64encode(f'{user}:{password}'.encode()).decode()


def query(sql):
    request = Request(url, data=sql.encode(), headers={'Authorization': f'Basic {auth}'})
    with urlopen(request) as response:
        return response.read().decode().strip()


path = Path(sys.argv[1]) if len(sys.argv) > 1 else Path(__file__).parent / 'data/train.csv'
if not path.is_file():
    raise SystemExit(f'Dataset not found: {path}')
query('CREATE DATABASE IF NOT EXISTS transactions_db')
query('''CREATE TABLE IF NOT EXISTS transactions_db.transactions (
    transaction_time DateTime, merch String, cat_id String, amount Decimal(9, 2),
    name_1 String, name_2 String, gender String, street String, one_city String,
    us_state String, post_code UInt32, lat Decimal(9, 4), lon Decimal(9, 4),
    population_city UInt32, jobs String, merchant_lat Decimal(9, 6),
    merchant_lon Decimal(9, 6), target UInt8
) ENGINE = MergeTree ORDER BY (us_state, cat_id, transaction_time)''')
count = int(query('SELECT count() FROM transactions_db.transactions'))
if count == 0:
    with path.open('rb') as data:
        subprocess.run([
            'curl', '--fail-with-body', '--silent', '--show-error',
            '--user', f'{user}:{password}', '--data-binary', '@-',
            url + '?date_time_input_format=best_effort&query=INSERT%20INTO%20'
            'transactions_db.transactions%20FORMAT%20CSVWithNames',
        ], stdin=data, check=True)
else:
    print('Source already contains data; loading skipped.')
print(query('SELECT count() AS rows, sum(amount) AS total_amount, '
            'sum(target) AS fraud_count FROM transactions_db.transactions FORMAT TabSeparatedWithNames'))
