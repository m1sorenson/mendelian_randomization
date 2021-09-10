import sys
import os

colmap = {
    "SNP": [
        "SNPID",
        "MARKERNAME",
        "RSID"
    ],
    "CHR": [
        "CHROM",
        "CHROMOSOME"
    ],
    "POS": [
        "BP",
        "POSITION(HG19)",
        "POSITION"
    ],
    "BETA": [],
    "MAF": [
        "EAF"
    ],
    "SE": [],
    "A1_A2_pairs": [
        ["A1", "A2"],
        ["A1_EFFECT", "A2_OTHER"],
        ["A2_EFFECT", "A1_OTHER"],
        ["A2_OTHER", "A1_REFERENCE"],
        ["A2_EFFECT", "A1_REFERENCE"],
        ["EFFECT", "OTHER"],
        ["ALT", "REF"],
        ["EA", "NEA"],
        ["EFFECT_ALLELE", "OTHER_ALLELE"],
        ["OTHER_ALLELE", "REFERENCE_ALLELE"]
    ],
    "OR": [
        "OR(A1)"
    ],
    "P": [
        "P-VAL",
        "P.VALUE"
    ],
    "phenotype_col": [],
    "samplesize": [
        "N"
    ]
}

def main(file):
    with open(file, 'r') as f:
        header = f.readline()
    spaces = False
    if header.find('\t') == -1:
        header = header.strip('\n').split(' ')
        spaces = True
    else:
        header = header.strip('\n').split('\t')
    print(header)
    # deal with cases where A1 is reference allele and A2 is alt/effect allele
    headers_found = {key: False for key in colmap}
    # fix all column names
    for i in range(len(header)):
        header[i] = header[i].upper()
        for key, vals in colmap.items():
            if header[i] == key or header[i] in vals:
                header[i] = key
                headers_found[key] = True
    # fix A1/A2 columns
    for a1_col, a2_col in colmap["A1_A2_pairs"]:
        if a1_col in header and a2_col in header:
            if a1_col == "A1" and a2_col == "A2":
                print("File already has A1 and A2 as column names, make sure to check that A1 is the effect allele and A2 is the reference")
            a1_ind = header.index(a1_col)
            a2_ind = header.index(a2_col)
            header[a1_ind] = "A1"
            header[a2_ind] = "A2"
            headers_found["A1_A2_pairs"] = True
    if not headers_found["A1_A2_pairs"]:
        raise Exception(f"ERROR: unrecognized A1/A2 pair in {file}, add the pair as a two value list in colmap[\"A1_A2_pairs\"] in 11_fix_header.py")
    print(header)
    # if a column name hasn't been found, search for column names with "_EUR"
    # suffix and use that for the MR
    for i in range(len(header)):
        eur_index = header[i].find('_EUR')
        if eur_index != -1:
            cleaned = header[i][:eur_index]
            for key, vals in colmap.items():
                if not headers_found[key] and (cleaned == key or cleaned in vals):
                    header[i] = cleaned
                    headers_found[key] = True
    print(header)
    with open(file + '.fixed', 'w') as f:
        if spaces:
            f.write(' '.join(header) + '\n')
        else:
            f.write('\t'.join(header) + '\n')

if __name__ == "__main__":
    if len(sys.argv) == 1:
        throw(f"USAGE: python3 {sys.argv[0]} <header_file>")
    file = sys.argv[1]
    if not os.path.exists(file):
        throw("ERROR: file does not exist: " + file)
    main(file)
