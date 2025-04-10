def get_mem_mb(wildcards, attempt):
    if attempt < 3:
        return attempt * 1024 * 8
    return attempt * 1024 * 16

# get the memory for the assembly
def asm_mem_mb(wc, attempt):
    # 500GB for the first attempt, 1TB for the second, etc.
    return 500 * 1024 * attempt




def asm_inputs(wc):
    rtn = {}
    rtn["reads"] = rules.input_reads.output.reads
    if HAS_PARENTAL[wc.sm]:
        rtn["pat"] = expand(rules.yak.output.yak, parental="pat", allow_missing=True)
        rtn["mat"] = expand(rules.yak.output.yak, parental="mat", allow_missing=True)
    return rtn


def get_parental_reads(wc):
    if wc.parental == "pat":
        return tbl.loc[wc.sm, "paternal"]
    elif wc.parental == "mat":
        return tbl.loc[wc.sm, "maternal"]
    else:
        raise ValueError(f"Unknown parental type: {wc.parental}")


def extra_asm_options(wc):
    if wc.asm_type == "bp":
        return ""
    elif wc.asm_type == "dip":
        pat_yak = rules.yak.output.yak.format(parental="pat", asm_type="dip", sm=wc.sm)
        mat_yak = rules.yak.output.yak.format(parental="mat", asm_type="dip", sm=wc.sm)
        return f" -1 {pat_yak} -2 {mat_yak}"
    else:
        raise ValueError(f"Unknown assembly type: {wc.asm_type}")