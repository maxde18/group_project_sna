#!/usr/bin/env python3
"""
Fetch Voting Data and Co-Authoring Data from Tweede Kamer Open Data Portal
Fetches exact date ranges needed for 1-year pre-election vs post-formation analysis.

Data Source: https://opendata.tweedekamer.nl
API: https://gegevensmagazijn.tweedekamer.nl/OData/v4/2.0/
"""

import requests
import pandas as pd
import time
import json
import urllib.parse

BASE_URL = "https://gegevensmagazijn.tweedekamer.nl/OData/v4/2.0"
BATCH_SIZE = 250  # API maximum limit

def fetch_paginated_data(endpoint, filter_query=None):
    """Fetch all data from API with pagination."""
    import urllib.parse
    
    all_data = []
    skip = 0
    batch_num = 1
    total_records = 0
    
    while True:
        if filter_query:
            url = f"{BASE_URL}/{endpoint}?$filter={urllib.parse.quote(filter_query)}&$top={BATCH_SIZE}&$skip={skip}"
        else:
            url = f"{BASE_URL}/{endpoint}?$top={BATCH_SIZE}&$skip={skip}"
        
        # Show progress every 10 batches or on first/last batch
        if batch_num == 1 or batch_num % 10 == 0:
            print(f"Batch {batch_num} (skip={skip:,})...", end=" ", flush=True)
        
        try:
            response = requests.get(url, headers={"Accept": "application/json"})
            response.raise_for_status()
            data = response.json()
            
            if "value" not in data or len(data["value"]) == 0:
                if batch_num % 10 != 0:
                    print(f"\nBatch {batch_num}: Done.")
                else:
                    print("Done.")
                break
            
            batch_df = pd.DataFrame(data["value"])
            all_data.append(batch_df)
            total_records += len(batch_df)
            
            if batch_num == 1 or batch_num % 10 == 0:
                print(f"{len(batch_df)} records (total: {total_records:,})")
            
            if len(batch_df) < BATCH_SIZE:
                if batch_num % 10 != 0:
                    print(f"\nBatch {batch_num}: {len(batch_df)} records (total: {total_records:,})")
                break
            
            skip += BATCH_SIZE
            batch_num += 1
            time.sleep(0.1)  # Reduced from 0.5 to 0.1 seconds
            
        except Exception as e:
            print(f"\nError at batch {batch_num}: {e}")
            if hasattr(e, 'response') and e.response is not None:
                print(f"Response: {e.response.text[:200]}")
            break
    
    if all_data:
        result = pd.concat(all_data, ignore_index=True)
        print(f"\nTotal fetched: {len(result):,} records")
        return result
    return pd.DataFrame()


def process_voting_data(df):
    """Clean voting data: keep only Voor/Tegen, select essential columns."""
    if df.empty:
        return df
    
    # Filter Voor/Tegen votes
    if "Soort" in df.columns:
        df = df[df["Soort"].isin(["Voor", "Tegen"])]
    
    # Select essential columns
    cols = ["Besluit_Id", "ActorFractie", "Soort", "GewijzigdOp"]
    available_cols = [c for c in cols if c in df.columns]
    
    if available_cols:
        df = df[available_cols].drop_duplicates()
    
    return df


def fetch_coauthoring_data(date_from, date_to, pause_s=0.2):
    """
    Fetch co-authoring data (motions with co-signers) from Document endpoint.
    Uses @odata.nextLink for pagination (more reliable than $skip).
    
    Args:
        date_from: Start date (YYYY-MM-DD)
        date_to: End date (YYYY-MM-DD)
        pause_s: Pause between requests in seconds
    
    Returns:
        List of document items with expanded DocumentActor information
    """
    # Build filter query
    filter_query = (
        "Verwijderd eq false "
        "and Soort eq 'Motie' "
        f"and Datum ge {date_from} "
        f"and Datum le {date_to}"
    )
    
    # Expand to get DocumentActor (first signer and co-signers)
    expand_query = "DocumentActor($filter=Relatie eq 'Eerste ondertekenaar' or Relatie eq 'Mede ondertekenaar')"
    
    # Select relevant fields (Nummer doesn't exist, removed)
    select_query = "Id,Datum,Soort,Titel,Onderwerp,DocumentActor"
    
    # Build initial URL
    params = {
        "$filter": filter_query,
        "$expand": expand_query,
        "$select": select_query,
        "$top": "250"
    }
    
    # Build query string
    query_parts = []
    for key, value in params.items():
        query_parts.append(f"{key}={urllib.parse.quote(value)}")
    query_string = "&".join(query_parts)
    
    url = f"{BASE_URL}/Document?{query_string}"
    
    headers = {
        "Accept": "application/json",
        "User-Agent": "tweede-kamer-analysis/1.0"
    }
    
    all_items = []
    seen = 0
    batch_num = 1
    skip = 0
    
    while True:
        # Show progress every 10 batches or on first/last batch
        if batch_num == 1 or batch_num % 10 == 0:
            print(f"Batch {batch_num} (skip={skip:,})...", end=" ", flush=True)
        
        try:
            response = requests.get(url, headers=headers, timeout=60)
            response.raise_for_status()
            payload = response.json()
            
            value = payload.get("value", [])
            all_items.extend(value)
            seen += len(value)
            
            next_link = payload.get("@odata.nextLink")
            
            if batch_num == 1 or batch_num % 10 == 0:
                print(f"{len(value):4d} records (total: {seen:6d})")
            
            # Check if we got fewer records than requested (last batch)
            if len(value) < 250:
                if batch_num % 10 != 0:
                    print(f"\nBatch {batch_num}: {len(value):4d} records (total: {seen:6d})")
                else:
                    print("Done.")
                break
            
            # If there's a next link, use it (preferred method)
            if next_link:
                url = next_link
            else:
                # Fallback: use $skip if no next link but we got a full batch
                skip += 250
                # Rebuild URL with new skip value
                query_parts = []
                for key, val in params.items():
                    if key != "$skip":  # Don't include skip in params, we'll add it separately
                        query_parts.append(f"{key}={urllib.parse.quote(val)}")
                query_parts.append(f"$skip={skip}")
                query_string = "&".join(query_parts)
                url = f"{BASE_URL}/Document?{query_string}"
            
            batch_num += 1
            time.sleep(pause_s)
            
        except Exception as e:
            print(f"\nError at batch {batch_num}: {e}")
            if hasattr(e, 'response') and e.response is not None:
                print(f"Response: {e.response.text[:200]}")
            break
    
    print(f"\nTotal fetched: {len(all_items):,} documents")
    return all_items


def main():
    print("=" * 80)
    print("FETCHING DATA FROM TWEEDE KAMER API")
    print("=" * 80)
    
    # ============================================================================
    # PRE-ELECTION PERIOD: Nov 22, 2022 - Nov 21, 2023
    # ============================================================================
    
    print("\n" + "=" * 80)
    print("PRE-ELECTION PERIOD: Nov 22, 2022 - Nov 21, 2023")
    print("=" * 80)
    
    # Fetch voting data
    print("\nFetching VOTING DATA...")
    print("-" * 80)
    pre_filter = "GewijzigdOp ge 2022-11-22T00:00:00Z and GewijzigdOp le 2023-11-21T23:59:59Z"
    pre_data = fetch_paginated_data("Stemming", pre_filter)
    
    # If filter failed, fetch all and filter in Python
    if pre_data.empty:
        print("Date filter failed, fetching all data and filtering in Python...")
        all_data = fetch_paginated_data("Stemming")
        if not all_data.empty:
            processed = process_voting_data(all_data)
            if "GewijzigdOp" in processed.columns:
                processed["GewijzigdOp"] = pd.to_datetime(processed["GewijzigdOp"], format='ISO8601', errors='coerce', utc=True)
                pre_start_dt = pd.Timestamp("2022-11-22", tz='UTC')
                pre_end_dt = pd.Timestamp("2023-11-21 23:59:59", tz='UTC')
                pre_data = processed[
                    (processed["GewijzigdOp"] >= pre_start_dt) & 
                    (processed["GewijzigdOp"] <= pre_end_dt)
                ]
    
    if not pre_data.empty:
        pre_processed = process_voting_data(pre_data)
        if "GewijzigdOp" in pre_processed.columns:
            pre_processed["GewijzigdOp"] = pd.to_datetime(pre_processed["GewijzigdOp"], format='ISO8601', errors='coerce', utc=True)
            pre_start_dt = pd.Timestamp("2022-11-22", tz='UTC')
            pre_end_dt = pd.Timestamp("2023-11-21 23:59:59", tz='UTC')
            pre_processed = pre_processed[
                (pre_processed["GewijzigdOp"] >= pre_start_dt) & 
                (pre_processed["GewijzigdOp"] <= pre_end_dt)
            ]
        
        pre_processed.to_csv("data/voting_data_2023_preelection.csv", index=False)
        print(f"✓ Saved: {len(pre_processed):,} votes, "
              f"{pre_processed['Besluit_Id'].nunique():,} motions, "
              f"{pre_processed['ActorFractie'].nunique()} parties")
    else:
        print("✗ No voting data found for pre-election period")
    
    # Fetch co-authoring data
    print("\nFetching CO-AUTHORING DATA...")
    print("-" * 80)
    coauth_pre_items = fetch_coauthoring_data("2022-11-22", "2023-11-21")
    
    if coauth_pre_items:
        output_file = "data/coauthoring_data_2023_preelection.json"
        with open(output_file, 'w', encoding='utf-8') as f:
            json.dump(coauth_pre_items, f, ensure_ascii=False, indent=2, default=str)
        
        unique_docs = len(set(item.get("Id") for item in coauth_pre_items if item.get("Id")))
        total_actors = sum(len(item.get("DocumentActor", [])) for item in coauth_pre_items)
        
        print(f"✓ Saved: {len(coauth_pre_items):,} documents, "
              f"{unique_docs:,} unique motions, "
              f"{total_actors:,} total actor-document relationships")
    else:
        print("✗ No co-authoring data found for pre-election period")
    
    # ============================================================================
    # POST-FORMATION PERIOD: Jul 5, 2024 - Jul 4, 2025
    # ============================================================================
    
    print("\n" + "=" * 80)
    print("POST-FORMATION PERIOD: Jul 5, 2024 - Jul 4, 2025")
    print("=" * 80)
    
    # Fetch voting data
    print("\nFetching VOTING DATA...")
    print("-" * 80)
    post_filter = "GewijzigdOp ge 2024-07-05T00:00:00Z and GewijzigdOp le 2025-07-04T23:59:59Z"
    post_data = fetch_paginated_data("Stemming", post_filter)
    
    # If filter failed, fetch all and filter in Python
    if post_data.empty:
        print("Date filter failed, fetching all data and filtering in Python...")
        all_data = fetch_paginated_data("Stemming")
        if not all_data.empty:
            processed = process_voting_data(all_data)
            if "GewijzigdOp" in processed.columns:
                processed["GewijzigdOp"] = pd.to_datetime(processed["GewijzigdOp"], format='ISO8601', errors='coerce', utc=True)
                post_start_dt = pd.Timestamp("2024-07-05", tz='UTC')
                post_end_dt = pd.Timestamp("2025-07-04 23:59:59", tz='UTC')
                post_data = processed[
                    (processed["GewijzigdOp"] >= post_start_dt) & 
                    (processed["GewijzigdOp"] <= post_end_dt)
                ]
    
    if not post_data.empty:
        post_processed = process_voting_data(post_data)
        if "GewijzigdOp" in post_processed.columns:
            post_processed["GewijzigdOp"] = pd.to_datetime(post_processed["GewijzigdOp"], format='ISO8601', errors='coerce', utc=True)
            post_start_dt = pd.Timestamp("2024-07-05", tz='UTC')
            post_end_dt = pd.Timestamp("2025-07-04 23:59:59", tz='UTC')
            post_processed = post_processed[
                (post_processed["GewijzigdOp"] >= post_start_dt) & 
                (post_processed["GewijzigdOp"] <= post_end_dt)
            ]
        
        post_processed.to_csv("data/voting_data_clean.csv", index=False)
        print(f"✓ Saved: {len(post_processed):,} votes, "
              f"{post_processed['Besluit_Id'].nunique():,} motions, "
              f"{post_processed['ActorFractie'].nunique()} parties")
    else:
        print("✗ No voting data found for post-formation period")
    
    # Fetch co-authoring data
    print("\nFetching CO-AUTHORING DATA...")
    print("-" * 80)
    coauth_post_items = fetch_coauthoring_data("2024-07-05", "2025-07-04")
    
    if coauth_post_items:
        output_file = "data/coauthoring_data_2024_postformation.json"
        with open(output_file, 'w', encoding='utf-8') as f:
            json.dump(coauth_post_items, f, ensure_ascii=False, indent=2, default=str)
        
        unique_docs = len(set(item.get("Id") for item in coauth_post_items if item.get("Id")))
        total_actors = sum(len(item.get("DocumentActor", [])) for item in coauth_post_items)
        
        print(f"✓ Saved: {len(coauth_post_items):,} documents, "
              f"{unique_docs:,} unique motions, "
              f"{total_actors:,} total actor-document relationships")
    else:
        print("✗ No co-authoring data found for post-formation period")
    
    print("\n" + "=" * 80)
    print("✓ Complete!")
    print("=" * 80)


if __name__ == "__main__":
    main()

