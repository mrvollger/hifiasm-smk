def get_mem_mb(wildcards, attempt):
    if attempt < 3:
        return attempt * 1024 * 8
    return attempt * 1024 * 16

# get the memory for the assembly
def asm_mem_mb(wc, attempt):
    # 500GB for the first attempt, 1TB for the second, etc.
    return 500 * 1024 * attempt

