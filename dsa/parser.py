#!/usr/bin/env python3

import xml.etree.ElementTree as ET
import json
import sys
import os

# Fields we want to convert to numbers if possible
NUMERIC_FIELDS = ["amount", "date", "date_sent"]

def parse_xml(xml_file):
    tree = ET.parse(xml_file)
    root = tree.getroot()
    records = {}

    # assume each record is inside <record> tag
    for idx, rec in enumerate(root.findall(".//record"), start=1):
        data = {}

        # collect attributes
        for k, v in rec.attrib.items():
            key = k.lower()
            val = v.strip()
            if key in NUMERIC_FIELDS:
                try:
                    val = float(val) if '.' in val else int(val)
                except ValueError:
                    pass
            data[key] = val

        # collect children tags
        for child in rec:
            tag = child.tag.lower()
            text = (child.text or "").strip()
            if tag in NUMERIC_FIELDS:
                try:
                    text = float(text) if '.' in text else int(text)
                except ValueError:
                    pass
            data[tag] = text

        # give each record a unique id
        record_id = f"T{idx:04d}"
        data["id"] = record_id
        records[record_id] = data  # use id as key

    return records

def save_json(data, json_file):
    with open(json_file, "w", encoding="utf-8") as f:
        json.dump(data, f, indent=2)

def main():
    if len(sys.argv) != 3:
        print("Usage: python3 parser.py input.xml output.json")
        return

    xml_file = sys.argv[1]
    json_file = sys.argv[2]

    if not os.path.exists(xml_file):
        print("XML file not found:", xml_file)
        return

    data = parse_xml(xml_file)
    save_json(data, json_file)
    print(f"Saved {len(data)} transactions to {json_file}")

if __name__ == "__main__":
    main()
