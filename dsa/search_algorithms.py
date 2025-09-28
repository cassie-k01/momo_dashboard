# Contains search functions for benchmarking

def linear_search(data, target_id):
    # Loop through list of transactions
    for tx in data:
        if tx["id"] == target_id:
            return tx
    return None

def dict_lookup(data, target_id):
    # Use dictionary's built-in lookup
    return data.get(target_id)