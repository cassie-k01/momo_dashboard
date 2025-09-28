# Benchmark linear search vs dictionary lookup

import json
import time
import os
from search_algorithms import linear_search, dict_lookup

# Load transaction data
BASE_DIR = os.path.dirname(os.path.dirname(os.path.abspath(__file__)))
DATA_FILE = os.path.join(BASE_DIR, "data", "transactions.json")

def load_data():
    with open(DATA_FILE, "r") as f:
        return json.load(f)

# Load and prepare data
dict_data = load_data()                  # dictionary format for fast lookup
list_data = list(dict_data.values())     # convert to list for linear search

def benchmark(data_list, data_dict, target_id, repeat=1000):
    # Measure linear search time
    start = time.perf_counter()
    for _ in range(repeat):
        linear_search(data_list, target_id)
    linear_time = (time.perf_counter() - start) / repeat

    # Measure dictionary lookup time
    start = time.perf_counter()
    for _ in range(repeat):
        dict_lookup(data_dict, target_id)
    dict_time = (time.perf_counter() - start) / repeat

    return linear_time, dict_time

if __name__ == "__main__":
    total_linear = 0
    total_dict = 0

    # Run benchmark for 20 records
    for i in range(1, 21):
        tx_id = f"T{str(i).zfill(4)}"
        linear_time, dict_time = benchmark(list_data, dict_data, tx_id)
        total_linear += linear_time
        total_dict += dict_time
        print(f"{tx_id}: Linear={linear_time:.6f}s | Dict={dict_time:.6f}s")

    # Print average times
    print("\nAverage Linear Search Time:", total_linear / 20)
    print("Average Dictionary Lookup Time:", total_dict / 20)