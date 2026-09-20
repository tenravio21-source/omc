def remove_duplicates_fast(input_file, output_file):
    # Use 'with' to ensure files are closed automatically
    with open(input_file, "r") as f:
        # Read lines into a set to strip duplicates
        unique_lines = set(f.readlines())

    with open(output_file, "w") as f:
        f.writelines(unique_lines)


remove_duplicates_fast("history.txt", "clean_list.txt")
