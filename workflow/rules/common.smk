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
    rtn["reads"] = rules.merge_input_reads.output.reads.format(
        sm=wc.sm,
        read_type="hifi",
    )
    if HAS_PARENTAL[wc.sm]:
        rtn["pat"] = expand(rules.yak.output.yak, parental="pat", allow_missing=True)
        rtn["mat"] = expand(rules.yak.output.yak, parental="mat", allow_missing=True)
    return rtn


def get_input_reads(wc):
    idx = int(wc.idx)
    if wc.read_type == "hifi":
        return tbl.loc[wc.sm, "hifi"][idx]
    elif wc.read_type == "mat":
        return tbl.loc[wc.sm, "maternal"][idx]
    elif wc.read_type == "pat":
        return tbl.loc[wc.sm, "paternal"][idx]
    else:
        raise ValueError(f"Unknown read type: {wc.read_type}")


def get_inputs_to_merge(wc):
    read_type = wc.read_type
    if read_type == "pat":
        read_type = "paternal"
    elif read_type == "mat":
        read_type = "maternal"
    files = tbl.loc[wc.sm, read_type]
    n_files = len(files)
    return expand(
        rules.input_reads.output.reads,
        sm=wc.sm,
        read_type=wc.read_type,
        idx=[i for i in range(n_files)],
    )


def get_parental_reads(wc):
    if wc.parental == "pat":
        return rules.merge_input_reads.output.reads.format(
            sm=wc.sm,
            read_type="pat",
        )
    elif wc.parental == "mat":
        return rules.merge_input_reads.output.reads.format(
            sm=wc.sm,
            read_type="mat",
        )
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


def get_ref(wc):
    return REFS[wc.ref]


def set_references():
    references = config.get("references", {})
    if not references:
        t2t = "/mmfs1/gscratch/stergachislab/assemblies/T2Tv2.0_maskedY.fa"
        if os.path.exists(t2t):
            references["T2T-CHM13v2.0"] = t2t
        hg38 = "/mmfs1/gscratch/stergachislab/assemblies/simple-names/GCA_000001405.15_GRCh38_no_alt_analysis_set.fna"
        if os.path.exists(hg38):
            references["GRCh38"] = hg38
    return references
