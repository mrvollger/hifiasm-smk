
rule input_reads:
    input:
        reads=lambda wc: tbl.loc[wc.sm, "hifi"],
    output:
        reads=temp("temp/{sm}/{sm}.hifi.reads.fa.gz"),
    threads: 8
    resources:
        mem_mb=8 * 1024,
        runtime=60 * 4,
    conda:
        "../envs/env.yml"
    shell:
        """
        # make a fasta if bam cram or sam
        if [[ {input.reads} =~ .*\\.(fa|fa.gz|fq|fq.gz|fasta|fasta.gz|fastq|fastq.gz) ]]; then
            echo "linking {input.reads} to {output.reads}"
            ln -s $(realpath {input.reads}) {output.reads}
        elif [[ {input.reads} =~ .*\\.(bam|sam|cram) ]]; then
            echo "converting {input.reads} to {output.reads}"
            samtools fasta -@ {threads} {input.reads} | bgzip -@ {threads} > {output.reads}
        fi
        """


rule hifiasm:
    input:
        reads=rules.input_reads.output.reads,
    output:
        hap1="results/{sm}/{sm}.{asm_type}.hap1.p_ctg.gfa",
        lowQ1="results/{sm}/{sm}.{asm_type}.hap1.p_ctg.lowQ.bed",
        noseq1=temp("results/{sm}/{sm}.{asm_type}.hap1.p_ctg.noseq.gfa"),
        hap2="results/{sm}/{sm}.{asm_type}.hap2.p_ctg.gfa",
        lowQ2="results/{sm}/{sm}.{asm_type}.hap2.p_ctg.lowQ.bed",
        noseq2=temp("results/{sm}/{sm}.{asm_type}.hap2.p_ctg.noseq.gfa"),
        utg="results/{sm}/{sm}.{asm_type}.p_utg.gfa",
        lowQutg="results/{sm}/{sm}.{asm_type}.p_utg.lowQ.bed",
        nosequtg=temp("results/{sm}/{sm}.{asm_type}.p_utg.noseq.gfa"),
        r_utg="results/{sm}/{sm}.{asm_type}.r_utg.gfa",
        lowQr_utg="results/{sm}/{sm}.{asm_type}.r_utg.lowQ.bed",
        noseqr_utg=temp("results/{sm}/{sm}.{asm_type}.r_utg.noseq.gfa"),
        #ec_bin="results/{sm}/{sm}.ec.bin",
    threads: config.get("asm-threads", 48)
    resources:
        mem_mb=asm_mem_mb,
        runtime=60 * 24,
    conda:
        "../envs/env.yml"
    shell:
        """
        out_dir=results/{wildcards.sm}/{wildcards.sm}
        mkdir -p $out_dir
        hifiasm -o $out_dir -t {threads} {input.reads}
        """


rule gfa_to_fa:
    input:
        gfa="results/{sm}/{sm}.{asm_type}.{hap}.p_ctg.gfa",
    output:
        # results/asm/test.bp.hap1.fa.gz
        fa="results/assemblies/{sm}.{asm_type}.{hap}.fa.gz",
        fai="results/assemblies/{sm}.{asm_type}.{hap}.fa.gz.fai",
    threads: 4
    resources:
        mem_mb=8 * 1024,
        runtime=60 * 4,
    conda:
        "../envs/env.yml"
    shell:
        """
        gfatools gfa2fa {input.gfa} | bgzip -@ {threads} > {output.fa}
        samtools faidx {output.fa}
        """
