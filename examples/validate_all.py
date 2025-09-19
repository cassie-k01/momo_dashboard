#!/usr/bin/env python3
import json
import os
from jsonschema import validate, ValidationError

BASE_DIR = os.path.dirname(__file__)
schemas_dir = os.path.join(BASE_DIR, "schemas")
instances_dir = os.path.join(BASE_DIR, "instances")

def load_json(filepath):
    with open(filepath, "r", encoding="utf-8") as f:
        return json.load(f)

def validate_instance(schema_file, instance_file):
    schema = load_json(schema_file)
    instance = load_json(instance_file)
    try:
        validate(instance=instance, schema=schema)
        print(f"[OK] {os.path.basename(instance_file)} is valid against {os.path.basename(schema_file)}")
    except ValidationError as e:
        print(f"[ERROR] {os.path.basename(instance_file)} failed validation: {e.message}")

def main():
    schema_map = {
        "user.schema.json": "user_example.json",
        "category.schema.json": "category_example.json",
        "transaction.schema.json": "transaction_example.json",
        "system_log.schema.json": "log_example.json",
        "sms_transaction.schema.json": "sms_transaction_example.json",
        "audit_event.schema.json": "audit_event_example.json",
        "categorized_transaction.schema.json": "categorized_example.json"
    }

    for schema_file, instance_file in schema_map.items():
        schema_path = os.path.join(schemas_dir, schema_file)
        instance_path = os.path.join(instances_dir, instance_file)
        validate_instance(schema_path, instance_path)

if __name__ == "__main__":
    main()
